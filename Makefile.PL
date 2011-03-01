use strict;
use warnings;

use inc::Module::Install;

name     'Tapper-Reports-DPath';
all_from 'lib/Tapper/Reports/DPath.pm';
author   'AMD OSRC Tapper Team <tapper@amd64.org>';
license  'freebsd';

requires 'perl'                  => 5.010;
requires 'JSON'                  => 0;
requires 'parent'                => 0;
requires 'DateTime'              => 0;
requires 'Template'              => 0;
requires 'HTML::Mason'           => "1.40";
requires 'Data::DPath'           => '0.33';
requires 'Sub::Exporter'         => '0.982';
requires 'File::ShareDir'        => 0;
requires 'Tapper::Config'        => "3.000001";
requires 'Tapper::Schema'        => "3.000001";
requires 'Tapper::Model'         => "3.000001";
requires 'Cache::FileCache'      => 0;
requires 'Data::Structure::Util' => 0;

build_requires 'Test::More';
build_requires 'Test::Perl::Critic';
build_requires 'Tapper::Schema::TestTools';
build_requires 'Test::Fixture::DBIC::Schema';

author_requires 'Module::Install::WriteAll';

makemaker_args(dist => { PREOP => 'pod2text lib/Tapper/Reports/DPath.pm > README' });

WriteAll;

