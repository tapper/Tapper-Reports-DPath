use MooseX::Declare;

use 5.010;

class Artemis::Reports::DPath is dirty {

        use Artemis::Model 'model';
        use Text::Balanced 'extract_codeblock';
        use Data::DPath::Path;
        use Data::Dumper;
        use Sub::Exporter -setup => { exports =>           [ 'reportdata' ],
                                      groups  => { all  => [ 'reportdata' ] },
                                    };

        sub _extract_condition_and_part {
                my ($reports_path) = @_;
                my ($condition, $path) = extract_codeblock($reports_path, '{}');
                $path =~ s/^\s*::\s*//;
                return ($condition, $path);
        }

        # better use alias
        sub rds($) { reports_dpath_search(@_) }

        # better use alias
        sub reportdata($) { reports_dpath_search(@_) }

        # allow trivial better readable column names
        # - foo => 23           ... mapped to "me.foo" => 23
        # - "report.foo" => 23  ... mapped to "me.foo" => 23
        # - suite_name => "bar" ... mapped to "suite.name" => "bar"
        # - -and => ...         ... mapped to "-and" => ...
        sub _fix_condition
        {
                no warnings 'uninitialized';
                my ($condition) = @_;
                $condition      =~ s/(['"])?\bsuite_name\b(['"])?\s*=>/"suite.name" =>/;        # ';
                $condition      =~ s/([^-\w])(['"])?((report|me)\.)?(?<!suite\.)(\w+)\b(['"])?(\s*)=>/$1"me.$5" =>/;        # ';
                return $condition;

        }

        sub reports_dpath_search($) {
                my ($reports_path) = @_;

                my ($condition, $path) = _extract_condition_and_part($reports_path);
                my $dpath              = new Data::DPath::Path( path => $path );
                $condition             = _fix_condition($condition);
                say STDERR "condition: ".($condition || '');
                my %condition          = $condition ? %{ eval $condition } : ();
                my $rs = model('ReportsDB')->resultset('Report')->search
                    (
                     {
                      %condition
                     },
                     {
                      order_by  => 'me.id asc',
                      columns   => [ qw(
                                               id
                                               suite_id
                                               suite_version
                                               reportername
                                               peeraddr
                                               peerport
                                               peerhost
                                               successgrade
                                               reviewed_successgrade
                                               total
                                               failed
                                               parse_errors
                                               passed
                                               skipped
                                               todo
                                               todo_passed
                                               wait
                                               exit
                                               success_ratio
                                               starttime_test_program
                                               endtime_test_program
                                               machine_name
                                               machine_description
                                               created_at
                                               updated_at
                                      )],
                      join      => [ 'suite',      ],
                      '+select' => [ 'suite.name', ],
                      '+as'     => [ 'suite.name', ],
                     }
                    );
                my @res = ();
                while (my $row = $rs->next)
                {
                        my $data = _as_data($row);
                        my @row_res  = $dpath->match ($data);
                        push @res, @row_res;
                }
                return @res;
        }

        sub _dummy_needed_for_tests {
                # once there were problems with eval
                return eval "12345";
        }

        sub _as_data
        {
                my ($report) = @_;

                my $simple_hash = {
                                   report => {
                                              $report->get_columns,
                                              suite_name         => $report->suite ? $report->suite->name : 'unknown',
                                              machine_name       => $report->machine_name || 'unknown',
                                              created_at_ymd_hms => $report->created_at->ymd('-')." ".$report->created_at->hms(':'),
                                              created_at_ymd     => $report->created_at->ymd('-'),
                                             },
                                   results => $report->get_cached_tapdom,
                                  };
                return $simple_hash;
        }

}

package Artemis::Reports::DPath;
our $VERSION = '2.010012';

1;

__END__

=head1 NAME

Artemis::Reports::DPath - Extended DPath access to Artemis reports.

=head1 SYNOPSIS

    use Artemis::Reports::DPath 'reports_dpath_search';
    # the first bogomips entry of math sections:
    @resultlist = reportdata (
                     '{ suite_name => "TestSuite-LmBench" } :: /tap/section/math/*/bogomips[0]'
                  );
    # all report IDs of suite_id 17 that FAILed:
    @resultlist = reportdata (
                     '{ suite_name => "TestSuite-LmBench" } :: /suite_id[value == 17]/../successgrade[value eq 'FAIL']/../id'
                  );

This searches all reports of the test suite "TestSuite-LmBench" and
furthermore in them for a TAP section "math" with the particular
subtest "bogomips" and takes the first array entry of them.

The part before the '::' selects reports to search in a DBIx::Class
search query, the second part is a normal L<Data::DPath|Data::DPath>
expression that matches against the datastructure that is build from
the DB.

=head1 METHODS and FUNCTIONS

=head2 reports_dpath_search

Takes an extended DPath expression, applies it to an Artemis Reports
with TAP::DOM structure and returns the matching results in an array.

=head2 rds

Alias for reports_dpath_search.

=head2 reportdata

Alias for reports_dpath_search.

=head1 AUTHOR

OSRC SysInt Team, C<< <osrc-sysint at elbe.amd.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 OSRC SysInt Team, all rights reserved.

This program is released under the following license: proprietary


=cut

