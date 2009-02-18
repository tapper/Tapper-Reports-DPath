#! perl

use Test::More;

BEGIN {
        use Class::C3;
        use MRO::Compat;
}

use Artemis::Reports::DPath::Mason 'render';
use Artemis::Schema::TestTools;
use Test::Fixture::DBIC::Schema;
use Data::Dumper;

print "TAP Version 13\n";
plan tests => 2;

# -------------------- path division --------------------

my $mason = new Artemis::Reports::DPath::Mason;
my $result;
my $template;
my $path;

# -----------------------------------------------------------------------------------------------------------------
construct_fixture( schema  => reportsdb_schema, fixture => 't/fixtures/reportsdb/report.yml' );
# -----------------------------------------------------------------------------------------------------------------

use Cwd 'abs_path', 'cwd';


# component paths look (and must be) absolute, but are always taken relative to comp_root
like($mason->render(file     => "/t/helloworld.mas"), qr/Hello, world!\s*/, "mason hello world file");
SKIP: {
        skip "bummer!", 1;
        #like($mason->render(template => "foo <% 'bar' %> baz"), qr/foo bar baz\s*/, "mason hello world template");
}
#$mason->render(template => "SOME_TEMPLATE");
