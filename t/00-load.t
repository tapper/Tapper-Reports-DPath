#!perl

use Test::More tests => 3;

use Class::C3;
use MRO::Compat;

BEGIN {
	use_ok( 'Tapper::Reports::DPath' );
	use_ok( 'Tapper::Reports::DPath::Mason' );
}

# there were some eval problems
is(Tapper::Reports::DPath::_dummy_needed_for_tests(), 12345, 'eval works');

diag( "Testing Tapper::Reports::DPath $Tapper::Reports::DPath::VERSION, Perl $], $^X" );
