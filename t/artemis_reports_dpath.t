#!perl -T

use Test::More tests => 8;
use Artemis::Reports::DPath 'reports_dpath_search';

use Text::Balanced qw(
                             extract_delimited
                             extract_bracketed
                    );
my $dpath = new Artemis::Reports::DPath;

my $condition, $path;

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "TestSuite-LmBench" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "TestSuite-LmBench" }', "condition 1 easy");
is($path,      '/tap/section/math/*/bogomips[0]', "     path 1 easy");

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "TestSuite::LmBench" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "TestSuite::LmBench" }', "condition 2 colons");
is($path,      '/tap/section/math/*/bogomips[0]',        "path 2 colons");

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "{TestSuite::LmBench}" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "{TestSuite::LmBench}" }', "condition 2 balanced braces");
is($path,      '/tap/section/math/*/bogomips[0]',        "path 2 balanced braces");

($condition, $path) = $dpath->extract_condition_and_part('{ suite_name => "TestSuite::LmBench}" } :: /tap/section/math/*/bogomips[0]');
is($condition, '{ suite_name => "TestSuite::LmBench}" }', "condition 2 unbalanced braces");
is($path,      '/tap/section/math/*/bogomips[0]',        "path 2 unbalanced braces");

