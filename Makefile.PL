use strict;
use warnings;

use inc::Module::Install;

name     'Artemis-Reports-DPath';
all_from 'lib/Artemis/Reports/DPath.pm';
author   'OSRC SysInt Team <osrc-sysint@elbe.amd.com>';

requires 'perl'                  => 5.010;
requires 'parent'                => 0;
requires 'HTML::Mason'           => "1.40";
requires 'Data::DPath'           => '0.10';
requires 'File::ShareDir'        => 0;
requires 'Artemis::Config'       => 0;
requires 'Artemis::Schema'       => '2.010033';
requires 'B::Hooks::EndOfScope'  => '0.05';

build_requires 'Test::More';
build_requires 'Artemis::Schema::TestTools';
build_requires 'Test::Fixture::DBIC::Schema';

makemaker_args(dist => { PREOP => 'pod2text lib/Artemis/Reports/DPath.pm > README' });

WriteAll;

