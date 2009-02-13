#! perl

use Test::More tests => 11;

BEGIN {
        use Class::C3;
        use MRO::Compat;
}
use Artemis::Reports::DPath 'reports_dpath_search', 'rds';
use Artemis::Schema::TestTools;
use Test::Fixture::DBIC::Schema;
use Data::Dumper;

# -------------------- path division --------------------

my $dpath = new Artemis::Reports::DPath;
my $condition;
my $path;
my @res;

# -----------------------------------------------------------------------------------------------------------------
construct_fixture( schema  => reportsdb_schema, fixture => 't/fixtures/reportsdb/report.yml' );
# -----------------------------------------------------------------------------------------------------------------

is( reportsdb_schema->resultset('Report')->count, 3,  "report count" );

my $report      = reportsdb_schema->resultset('Report')->find(23);
#print STDERR Dumper($report->tap);
my $tapdom = Artemis::Reports::DPath::get_tapdom($report);
#print STDERR Dumper($tapdom);
is ($tapdom->[0]{section}{'section-000'}{tap}{tests_planned}, 4, "parsed tap - section 0 - tests_planned");
is ($tapdom->[1]{section}{'section-001'}{tap}{tests_planned}, 3, "parsed tap - section 1 - tests_planned");

my $report_data = Artemis::Reports::DPath::as_data($report);
#say STDERR "REPORT_DATA ".Dumper($report_data);
is ($report_data->{results}[0]{section}{'section-000'}{tap}{tests_planned}, 4, "full report - section 0 - tests_planned");
is ($report_data->{results}[1]{section}{'section-001'}{tap}{tests_planned}, 3, "full report - section 1 - tests_planned");

@res = rds '{}:://tap/tests_planned';
is(scalar @res, 4,  "count ALL plans including sections - empty braces" );

@res = rds '//tap/tests_planned';
is(scalar @res, 4,  "count ALL plans including sections - no braces" );

@res = rds '{ id => 23 }:://section-000/tap/tests_planned';
is(scalar @res, 1,  "id + dpath - section 0" );
is($res[0], 4,  "id + dpath - section 0 tests_planned" );

@res = rds '{ id => 23 }:://section-001/tap/tests_planned';
is(scalar @res, 1,  "id + dpath - section 1" );
is($res[0], 3,  "id + dpath - section 1 tests_planned" );

