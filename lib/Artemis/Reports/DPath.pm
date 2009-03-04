use MooseX::Declare;

use 5.010;

class Artemis::Reports::DPath {

        our $VERSION = '0.01';

        use Artemis::Model 'model';
        use Text::Balanced 'extract_codeblock';
        use Artemis::TAP::Harness;
        use Data::DPath::Path;
        use Data::Dumper;
        use TAP::DOM;
        use Sub::Exporter -setup => { exports =>           [ 'reports_dpath_search', 'rds', 'reportdata' ],
                                      groups  => { all  => [ 'reports_dpath_search', 'rds', 'reportdata' ] },
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
        sub _fix_condition
        {
                no warnings 'uninitialized';
                my ($condition) = @_;
                $condition      =~ s/(['"])?\bsuite_name\b(['"])?\s*=>/"suite.name" =>/;        # ';
                $condition      =~ s/(\W)(['"])?((report|me)\.)?(?<!suite\.)(\w+)\b(['"])?(\s*)=>/$1"me.$5" =>/;        # ';
                return $condition;

        }

        sub reports_dpath_search($) {
                my ($reports_path) = @_;

                my ($condition, $path) = _extract_condition_and_part($reports_path);
                my $dpath              = new Data::DPath::Path( path => $path );
                $condition             = _fix_condition($condition);
                my %condition          = $condition ? %{ eval $condition } : ();
                my $rs = model('ReportsDB')->resultset('Report')->search
                    (
                     {
                      %condition
                     },
                     {
                      order_by  => 'me.id desc',
                      join      => [ 'suite', ],
                      '+select' => [ 'suite.name', ],
                      '+as'     => [ 'suite.name', ]
                     }
                    );
                my @rows = $rs->all;
                my @data = map { as_data($_) } @rows;
                return map { $dpath->match ($_) } @data;
        }

        sub _dummy_needed_for_tests {
                # once there were problems with eval
                return eval "12345";
        }

        sub as_data
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
                                   results => get_tapdom($report),
                                  };
                return $simple_hash;
        }

        sub get_tapdom
        {
                my ($report) = @_;

                my $TAPVERSION = "TAP Version 13";
                my @tapdata = ();
                if (not $report->tapdata) {
                        my $harness = new Artemis::TAP::Harness( tap => $report->tap );
                        $harness->evaluate_report();
                        foreach (@{$harness->parsed_report->{tap_sections}}) {
                                my $rawtap = $_->{raw};
                                $rawtap = $TAPVERSION."\n".$rawtap unless $rawtap =~ /^TAP Version/ms;
                                my $tapdata = new TAP::DOM ( tap => $rawtap );
                                push @tapdata, { section => { $_->{section_name} => { tap => $tapdata }}};
                        }
                }
                return \@tapdata;
        }
}

1;

__END__

=head1 NAME

Artemis::Reports::DPath - Extended DPath access to Artemis reports.

=head1 SYNOPSIS

    use Artemis::Reports::DPath 'reports_dpath_search';
    # the first bogomips entry of math sections:
    @resultlist = reports_dpath_search(
                     '{ suite_name => "TestSuite-LmBench" } :: /tap/section/math/*/bogomips[0]'
                  );
    # all report IDs of suite_id 17 that FAILed:
    @resultlist = reports_dpath_search(
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

Takes an extended DPath expression, applies it to an Artemis TAP::DOM
structure and returns the matching results in an array.

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

