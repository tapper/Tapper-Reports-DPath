#! perl

use Test::More;

BEGIN {
        use Class::C3;
        use MRO::Compat;
}

use Artemis::Reports::DPath::TT 'render';
use Artemis::Schema::TestTools;
use Test::Fixture::DBIC::Schema;
use Data::Dumper;

print "TAP Version 13\n";
plan tests => 3;

# -------------------- path division --------------------

my $tt = new Artemis::Reports::DPath::TT;

# -----------------------------------------------------------------------------------------------------------------
construct_fixture( schema  => reportsdb_schema, fixture => 't/fixtures/reportsdb/report.yml' );
# -----------------------------------------------------------------------------------------------------------------


my $template = q|
[% data  = [ { tests_planned => 1}, { tests_planned => 2}, { tests_planned => 3}, { tests_planned => 4}] -%]
[% data.Dumper -%]
|;
my $expected = q|
$VAR1 = [
          {
            'tests_planned' => 1
          },
          {
            'tests_planned' => 2
          },
          {
            'tests_planned' => 3
          },
          {
            'tests_planned' => 4
          }
        ];
|;
is($tt->render(template => $template), $expected, "tt template with Dumper");


$template = q|
[% data  = [ { tests_planned => 1}, { tests_planned => 2}, { tests_planned => 3}, { tests_planned => 4}] -%]
[% data.to_yaml -%]
|;
$expected = q|
---
- tests_planned: 1
- tests_planned: 2
- tests_planned: 3
- tests_planned: 4
|;
is($tt->render(template => $template), $expected, "tt template with YAML");

$template = q|
[% data  = [ { tests_planned => 1}, { tests_planned => 2}, { tests_planned => 3}, { tests_planned => 4}] -%]
[% data.to_json -%]
|;
$expected = q|
[
   {
      "tests_planned" : 1
   },
   {
      "tests_planned" : 2
   },
   {
      "tests_planned" : 3
   },
   {
      "tests_planned" : 4
   }
]|;
is($tt->render(template => $template), $expected, "tt template with JSON");
