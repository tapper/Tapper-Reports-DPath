use strict;
use warnings;

use inc::Module::Install;

name     'Artemis-Reports-DPath';
all_from 'lib/Artemis/Reports/DPath.pm';
author   'OSRC SysInt Team <osrc-sysint@elbe.amd.com>';

build_requires 'Test::More';
requires 'perl' => 5.010;
requires 'parent' => 0;

makemaker_args(dist => { PREOP => 'pod2text lib/Artemis/Reports/DPath.pm > README' });

WriteAll;

