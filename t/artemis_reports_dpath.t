#! perl

use Test::More tests => 9;
BEGIN {
        use Class::C3;
        use MRO::Compat;
}
use Artemis::Reports::DPath 'reports_dpath_search';
use Artemis::Schema::TestTools;
use Test::Fixture::DBIC::Schema;

# -------------------- path division --------------------

my $dpath = new Artemis::Reports::DPath;
my $condition;
my $path;

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "TestSuite-LmBench" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "TestSuite-LmBench" }', "condition easy");
is($path,      '/tap/section/math/*/bogomips[0]',       "path easy");

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "TestSuite::LmBench" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "TestSuite::LmBench" }', "condition colons");
is($path,      '/tap/section/math/*/bogomips[0]',        "path colons");

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "{TestSuite::LmBench}" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "{TestSuite::LmBench}" }', "condition balanced braces");
is($path,      '/tap/section/math/*/bogomips[0]',          "path balanced braces");

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "TestSuite::LmBench}" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "TestSuite::LmBench}" }', "condition unbalanced braces");
is($path,      '/tap/section/math/*/bogomips[0]',         "path unbalanced braces");

# -----------------------------------------------------------------------------------------------------------------
construct_fixture( schema  => reportsdb_schema, fixture => 't/fixtures/reportsdb/report.yml' );
# -----------------------------------------------------------------------------------------------------------------

is( reportsdb_schema->resultset('Report')->count, 3,  "report count" );

