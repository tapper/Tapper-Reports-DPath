#! perl

use Test::More;

BEGIN {
        use Class::C3;
        use MRO::Compat;
}
use Artemis::Reports::DPath 'reportdata';
use Artemis::Schema::TestTools;
use Test::Fixture::DBIC::Schema;
use Data::Dumper;
use Test::NoWarnings;

print "TAP Version 13\n";
plan tests => 40;

# -------------------- path division --------------------

my $dpath = new Artemis::Reports::DPath;
my $condition;
my $path;
my @res;

# -----------------------------------------------------------------------------------------------------------------
construct_fixture( schema  => reportsdb_schema, fixture => 't/fixtures/reportsdb/report.yml' );
# -----------------------------------------------------------------------------------------------------------------

is( reportsdb_schema->resultset('Report')->count, 4,  "report count" );

my $report      = reportsdb_schema->resultset('Report')->find(23);
#print STDERR Dumper($report->tap);
my $tapdom = $report->get_cached_tapdom;
#print STDERR Dumper($tapdom);
is ($tapdom->[0]{section}{'section-000'}{tap}{tests_planned}, 4, "parsed tap - section 0 - tests_planned");
is ($tapdom->[1]{section}{'section-001'}{tap}{tests_planned}, 3, "parsed tap - section 1 - tests_planned");

my $report_data = Artemis::Reports::DPath::_as_data($report);
#say STDERR "REPORT_DATA ".Dumper($report_data);
is ($report_data->{results}[0]{section}{'section-000'}{tap}{tests_planned}, 4, "full report - section 0 - tests_planned");
is ($report_data->{results}[1]{section}{'section-001'}{tap}{tests_planned}, 3, "full report - section 1 - tests_planned");

# -------------------- syntax fake sugar --------------------

# single
is(Artemis::Reports::DPath::_fix_condition('{ id => 23 }'),          '{ "me.id" => 23 }', "allow easier report.id column 1");
is(Artemis::Reports::DPath::_fix_condition('{ "id" => 23 }'),        '{ "me.id" => 23 }', "allow easier report.id column 2");
is(Artemis::Reports::DPath::_fix_condition('{ "me.id" => 23 }'),     '{ "me.id" => 23 }', "allow easier report.id column 3");
is(Artemis::Reports::DPath::_fix_condition('{ "report.id" => 23 }'), '{ "me.id" => 23 }', "allow easier report.id column 4");
is(Artemis::Reports::DPath::_fix_condition('{ -and => 23 }'),        '{ -and => 23 }',    "allow easier report.id column 5");

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

@res = reportdata '{}:://tap/tests_planned';
is(scalar @res, 8,  "count ALL plans including sections - empty braces" );

@res = reportdata '{} :: //tap/tests_planned';
is(scalar @res, 8,  "count ALL plans including sections - empty braces and whitespace" );

@res = reportdata '//tap/tests_planned';
is(scalar @res, 8,  "count ALL plans including sections - no braces" );

@res = reportdata '{ "report.id" => 23 }:://tap/tests_planned';
is(scalar @res, 2,  "id + dpath - all sections" );

@res = reportdata '{ id => 23 }:://section-000/tap/tests_planned';
is(scalar @res, 1,  "id + dpath - section 0" );
is($res[0], 4,  "id + dpath - section 0 tests_planned" );

@res = reportdata '{ id => 23 }:://section-001/tap/tests_planned';
is(scalar @res, 1,  "id + dpath - section 1" );
is($res[0], 3,  "id + dpath - section 1 tests_planned" );

@res = reportdata '{ "suite.name" => "perfmon" }//tap/tests_planned';
is(scalar @res, 4,  "count ALL plans of suite perfmon" );

@res = reportdata '{ "suite.name" => "perfmon", "suite_version" => "1.03" }//tap/tests_planned';
is(scalar @res, 2,  "count plans of suite perfmon 1.03" );

@res = reportdata '{ "suite.name" => "perfmon", "suite_version" => "1.02" }//tap/tests_planned';
is(scalar @res, 1,  "count plans of suite perfmon 1.02" );

@res = reportdata '{ suite_name => "perfmon", "suite_version" => "1.03" }//tap/tests_planned';
is(scalar @res, 2,  "count plans of suite perfmon 1.03" );

@res = reportdata '{ "suite_name" => "perfmon", "suite_version" => "1.03" }//tap/tests_planned';
is(scalar @res, 2,  "count plans of suite perfmon 1.03" );

# ------ context meta info ----
$report      = reportsdb_schema->resultset('Report')->find(20);
print STDERR Dumper($report->tap);
$tapdom = $report->get_cached_tapdom;
print STDERR Dumper($tapdom);
is ($tapdom->[0]{section}{'Metainfo'}{tap}{tests_planned}, 2,                                 "parsed tap - section 0 - tests_planned");
is ($tapdom->[1]{section}{'XEN-Metainfo'}{tap}{tests_planned}, 1,                             "parsed tap - section 1 - tests_planned");
is ($tapdom->[2]{section}{'guest_1_suse_sles10_sp3_rc2_32b_smp_qcow'}{tap}{tests_planned}, 1, "parsed tap - section 2 - tests_planned");
is ($tapdom->[3]{section}{'guest_2_opensuse_11_1_32b_qcow'}{tap}{tests_planned}, 1,           "parsed tap - section 3 - tests_planned");

$report_data = Artemis::Reports::DPath::_as_data($report);
#say STDERR "REPORT_DATA ".Dumper($report_data);
is ($report_data->{results}[0]{section}{'Metainfo'}{tap}{tests_planned}, 2,                                 "full report - section 0 - tests_planned");
is ($report_data->{results}[1]{section}{'XEN-Metainfo'}{tap}{tests_planned}, 1,                             "full report - section 1 - tests_planned");
is ($report_data->{results}[2]{section}{'guest_1_suse_sles10_sp3_rc2_32b_smp_qcow'}{tap}{tests_planned}, 1, "full report - section 2 - tests_planned");
is ($report_data->{results}[3]{section}{'guest_2_opensuse_11_1_32b_qcow'}{tap}{tests_planned}, 1,           "full report - section 3 - tests_planned");
