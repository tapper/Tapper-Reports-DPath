#! perl

use Test::More;

BEGIN {
        use Class::C3;
        use MRO::Compat;
}
use Artemis::Reports::DPath 'reports_dpath_search', 'rds';
use Artemis::Schema::TestTools;
use Test::Fixture::DBIC::Schema;
use Data::Dumper;


print "TAP Version 13\n";
plan tests => 29;

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
print "  ---\n";
print "  foo: bar\n";
print "  affe: zomtec\n";
print "  ...\n";

# -------------------- syntax fake sugar --------------------

# single
is(Artemis::Reports::DPath::_fix_condition('{ id => 23 }'),          '{ "me.id" => 23 }', "allow easier report.id column 1");
is(Artemis::Reports::DPath::_fix_condition('{ "id" => 23 }'),        '{ "me.id" => 23 }', "allow easier report.id column 2");
is(Artemis::Reports::DPath::_fix_condition('{ "me.id" => 23 }'),     '{ "me.id" => 23 }', "allow easier report.id column 3");
is(Artemis::Reports::DPath::_fix_condition('{ "report.id" => 23 }'), '{ "me.id" => 23 }', "allow easier report.id column 4");

# multi
is(Artemis::Reports::DPath::_fix_condition('{ id => 23, suite_name => "perfmon" }'),          '{ "me.id" => 23, "suite.name" => "perfmon" }', "allow easier report.id column 1");
is(Artemis::Reports::DPath::_fix_condition('{ "id" => 23, suite_name => "perfmon" }'),        '{ "me.id" => 23, "suite.name" => "perfmon" }', "allow easier report.id column 2");
is(Artemis::Reports::DPath::_fix_condition('{ "me.id" => 23, suite_name => "perfmon" }'),     '{ "me.id" => 23, "suite.name" => "perfmon" }', "allow easier report.id column 3");
is(Artemis::Reports::DPath::_fix_condition('{ "report.id" => 23, suite_name => "perfmon" }'), '{ "me.id" => 23, "suite.name" => "perfmon" }', "allow easier report.id column 4");

# multi + newlines
is(Artemis::Reports::DPath::_fix_condition('{ id => 23,
suite_name => "perfmon" }'),          '{ "me.id" => 23,
"suite.name" => "perfmon" }', "allow easier report.id column 1");
is(Artemis::Reports::DPath::_fix_condition('{ "id" => 23,
suite_name => "perfmon" }'),        '{ "me.id" => 23,
"suite.name" => "perfmon" }', "allow easier report.id column 2");
is(Artemis::Reports::DPath::_fix_condition('{ "me.id" => 23,
suite_name => "perfmon" }'),     '{ "me.id" => 23,
"suite.name" => "perfmon" }', "allow easier report.id column 3");
is(Artemis::Reports::DPath::_fix_condition('{ "report.id" => 23,
suite_name => "perfmon" }'), '{ "me.id" => 23,
"suite.name" => "perfmon" }', "allow easier report.id column 4");

# -------------------- get by paths --------------------

@res = rds '//tap/tests_planned';
is(scalar @res, 4,  "count ALL plans including sections - no braces" );

@res = rds '{ "report.id" => 23 }:://tap/tests_planned';
is(scalar @res, 2,  "id + dpath - all sections" );

@res = rds '{ id => 23 }:://section-000/tap/tests_planned';
is(scalar @res, 1,  "id + dpath - section 0" );
is($res[0], 4,  "id + dpath - section 0 tests_planned" );

@res = rds '{ id => 23 }:://section-001/tap/tests_planned';
is(scalar @res, 1,  "id + dpath - section 1" );
is($res[0], 3,  "id + dpath - section 1 tests_planned" );

@res = rds '{ "suite.name" => "perfmon" }//tap/tests_planned';
is(scalar @res, 4,  "count ALL plans of suite perfmon" );

@res = rds '{ "suite.name" => "perfmon", "suite_version" => "1.03" }//tap/tests_planned';
is(scalar @res, 2,  "count plans of suite perfmon 1.03" );

@res = rds '{ "suite.name" => "perfmon", "suite_version" => "1.02" }//tap/tests_planned';
is(scalar @res, 1,  "count plans of suite perfmon 1.02" );

@res = rds '{ suite_name => "perfmon", "suite_version" => "1.03" }//tap/tests_planned';
is(scalar @res, 2,  "count plans of suite perfmon 1.03" );

@res = rds '{ "suite_name" => "perfmon", "suite_version" => "1.03" }//tap/tests_planned';
is(scalar @res, 2,  "count plans of suite perfmon 1.03" );

