#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Artemis::Reports::DPath' );
}

diag( "Testing Artemis::Reports::DPath $Artemis::Reports::DPath::VERSION, Perl $], $^X" );
