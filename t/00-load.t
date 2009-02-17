#!perl -T

use Test::More tests => 3;

use Class::C3;
use MRO::Compat;

BEGIN {
	use_ok( 'Artemis::Reports::DPath' );
	use_ok( 'Artemis::Reports::DPath::Mason' );
}

# there were some eval problems
is(Artemis::Reports::DPath::_dummy_needed_for_tests(), 12345, 'eval works');

diag( "Testing Artemis::Reports::DPath $Artemis::Reports::DPath::VERSION, Perl $], $^X" );
