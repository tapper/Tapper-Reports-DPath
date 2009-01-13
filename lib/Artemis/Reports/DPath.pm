use MooseX::Declare;

use 5.010;

class Artemis::Reports::DPath {

        our $VERSION = '0.01';

        use Artemis::Model 'model';
        use Text::Balanced 'extract_codeblock';
        use Data::Dumper;
        use Sub::Exporter -setup => { exports =>           [ 'reports_dpath_search' ],
                                      groups  => { all  => [ 'reports_dpath_search' ] },
                                    };

        method extract_condition_and_part($reports_path) {
                my ($condition, $path) = extract_codeblock($reports_path, '{}');
                $path =~ s/^\s*::\s*//;
                return ($condition, $path);
        }

        sub reports_dpath_search($) {
                my ($reports_path) = @_;

                my ($condition, $path) = extract_condition_and_part($reports_path);

                say "condition: $condition";
                say "path: $path";

                my $dpath = new Data::DPath::Path(path => $path);
                say "dpath->_steps: ".Dumper($dpath->_steps);
                my $rs = model('ReportsDB')->resultset('Report')->search
                    (
                     {
                      eval '\%$condition'   },
                     {
                      order_by => 'id desc' }
                    );
                say "count reports: ".Dumper($rs->count);
                return $rs->count;
        }

        sub _dummy_needed_for_tests {
                # there were problems with eval
                return eval "12345";
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

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented
module.

=head1 METHODS and FUNCTIONS

=head2 reports_dpath_search

Takes an extended DPath expression, applies it to an
Artemis::TAP::Data structure and returns the matching results in an
array.

=head1 AUTHOR

OSRC SysInt Team, C<< <osrc-sysint at elbe.amd.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 OSRC SysInt Team, all rights reserved.

This program is released under the following license: proprietary


=cut

