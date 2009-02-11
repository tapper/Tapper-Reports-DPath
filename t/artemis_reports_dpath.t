#! perl

use Test::More tests => 4;

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

@res = reports_dpath_search('{}::/tap/');
is(scalar @res, 3,  "empty braces" );

@res = reports_dpath_search('/tap/');
is(scalar @res, 3,  "no braces" );

@res = rds('{ id => 23 }::/tap/foo/bar');
#print STDERR Dumper(\@res);
is(scalar @res, 1,  "search by id" );

