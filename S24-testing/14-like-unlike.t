use Test;
use lib $?FILE.IO.parent(2).add: 'packages/Test-Helpers';
use Test::Util;

plan 4;


like 42, /42/, '`like` can accept non-Str objects (Int)';
like class { method Str { 'foo' } }, /foo/,
    '`like` can accept non-Str objects (custom)';


unlike 42, /43/, '`unlike` can accept non-Str objects (Int)';
unlike class { method Str { 'foo' } }, /bar/,
    '`unlike` can accept non-Str objects (custom)';

# vim: expandtab shiftwidth=4
