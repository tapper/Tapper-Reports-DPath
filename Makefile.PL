use strict;
use warnings;

use inc::Module::Install;

name     'Artemis-Reports-DPath';
all_from 'lib/Artemis/Reports/DPath.pm';
author   'OSRC SysInt Team <osrc-sysint@elbe.amd.com>';

requires 'perl'                  => 5.010;
requires 'JSON'                  => 0;
requires 'parent'                => 0;
requires 'DateTime'              => 0;
requires 'Data::DPath'           => '0.31';
requires 'HTML::Mason'           => "1.40";
requires 'Sub::Exporter'         => '0.982';
requires 'File::ShareDir'        => 0;
requires 'Artemis::Config'       => 0;
requires 'Artemis::Schema'       => '2.010057';
requires 'Artemis::Model'        => '2.010014';
requires 'Cache::FileCache'      => 0;
requires 'Data::Structure::Util' => 0;

build_requires 'Test::More';
build_requires 'Artemis::Schema::TestTools';
build_requires 'Test::Fixture::DBIC::Schema';

makemaker_args(dist => { PREOP => 'pod2text lib/Artemis/Reports/DPath.pm > README' });

WriteAll;

