use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 3;

# tests related to postcircumfix:<{ }> and other stuff

class A {
    has %!attrs;
    method postcircumfix:<{ }>($key) { %!attrs{$key} }
};


#?rakudo todo 'nom regression'
is A.new(:attrs({ foo => "bar" }))<foo>,
    'bar', 'custom postcircumfix{ } is tied to the right class';


is_run 'class A { method postcircumfix:<{ }>() {} }; my &r = {
my $a }; if 0 { if 0 { my $a } }',
   {status => 0, err => '' },
   'custom postcircumfix{ } does not lead to warnings';


eval-lives-ok q[
class B {
method postcircumfix:<{ }>($table) {
}
}

{
1;
}
], 'custom postcircumfix{ } with weird whitespacing does not require ;';

# vim: expandtab shiftwidth=4
