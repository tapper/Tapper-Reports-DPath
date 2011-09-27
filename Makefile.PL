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
requires 'MooseX::Declare'       => "0.34";
requires 'Tapper::Config' => "3.000010";
requires 'Tapper::Schema' => "3.000010";
requires 'Tapper::Model' => "3.000010";
requires 'Data::Structure::Util' => 0;
requires 'Data::Serializer'; # needed by CHI using non-default serializer
requires 'CHI'                   => 0;

build_requires 'Test::More' => '0.88';
build_requires 'Test::Perl::Critic';
build_requires 'Tapper::Schema::TestTools' => "3.000010";
build_requires 'Test::Fixture::DBIC::Schema';

author_requires 'Module::Install::WriteAll';

repository 'git://github.com/amd/Tapper-Reports-DPath.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tapper-Reports-DPath';

WriteAll;

