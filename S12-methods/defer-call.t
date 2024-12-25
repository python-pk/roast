use Test;

plan 21;

# L<S12/"Calling sets of methods"/"Any method can defer to the next candidate method in the list">

# Simple test, making sure callwith passes on parameters properly.
class A {
    method a(*@A) {
        flat (self.raku, @A)
    }
}
class B is A {
    method a() {
        callwith("FIRST ARG", "SECOND ARG")
    }
}
{
    my $instance = B.new;
    my @result = $instance.a();
    is @result.elems, 3, 'nextwith passed on right number of parameters';
    is @result[0], $instance.raku, 'invocant passed on correctly';
    is @result[1], "FIRST ARG", 'first argument correct';
    is @result[2], "SECOND ARG", 'second argument correct';
}

class Foo {
    # $.tracker is used to determine the order of calls.
    has $.tracker is rw;
    multi method doit()  {$.tracker ~= 'foo,'}
    multi method doit(Int $num) {$.tracker ~= 'fooint,'}   #OK not used
    method show  {$.tracker}
    method clear {$.tracker = ''}
}

class BarCallSame is Foo {
    multi method doit() {$.tracker ~= 'bar,'; callsame; $.tracker ~= 'ret1,'}
    multi method doit(Int $num) {$.tracker ~= 'barint,'; callsame; $.tracker ~= 'ret2,'}   #OK not used
}

{
    my $o = BarCallSame.new;
    $o.clear;
    $o.doit;
    is($o.show, 'bar,foo,ret1,', 'callsame inheritance test');
    $o.clear;
    is($o.show, '', 'sanity test for clearing');
    $o.doit(5);
    is($o.show, 'barint,fooint,ret2,', 'callsame multimethod/inheritance test');
}


class BarCallWithEmpty is Foo {
    multi method doit() {$.tracker ~= 'bar,'; callwith(); $.tracker ~= 'ret1,'}
    multi method doit(Int $num) {$.tracker ~= 'barint,'; callwith($num); $.tracker ~= 'ret2,'}   #OK not used
}
{
    my $o = BarCallWithEmpty.new;
    $o.clear;
    $o.doit;
    is($o.show, 'bar,foo,ret1,', 'callwith() inheritance test');
    $o.clear;
    is($o.show, '', 'sanity test for clearing');
    {
        $o.doit(5);
        is($o.show, 'barint,fooint,ret2,', 'callwith() multimethod/inheritance test');
    }
}

class BarCallWithInt is Foo {
    multi method doit() {$.tracker ~= 'bar,'; callwith(); $.tracker ~= 'ret1,'}
    multi method doit(Int $num) {$.tracker ~= 'barint,'; callwith(42); $.tracker ~= 'ret2,'}   #OK not used
}
{
    my $o = BarCallWithInt.new;
    $o.clear;
    $o.doit;
    is($o.show, 'bar,foo,ret1,', 'callwith(42) inheritance test');
    $o.clear;
    is($o.show, '', 'sanity test for clearing');
    $o.doit(5);
    is($o.show, 'barint,fooint,ret2,', 'callwith(42) multimethod/inheritance test');
}


{
    multi sub f(0) { };
    multi sub f($n) {
        callwith($n - 1);
    }
    lives-ok { f(3) }, 'can recurse several levels with callwith()';
}


{
    use soft;
    my @xs;
    sub foo { push @xs, 'X' };
    &foo.wrap: { callsame; callsame; callsame };
    foo;
    is @xs, ['X'], 'callsame exhausts the iterator';
}
{
    use soft;
    my @xs;
    sub foo { push @xs, 'X' };
    &foo.wrap: { my &wrappee = nextcallee; wrappee; wrappee; wrappee; };
    foo;
    is @xs, ['X', 'X', 'X'], 'use nextcallee in order to call multiple times';
}

# callwith and callsame without anywhere to defer to return Nil
{
    my $after-cw = False;
    my $after-cs = False;
    my class DeadEnd {
        method cw($a) { my \result = callwith(42); $after-cw = True; result }
        method cs($a) { my \result = callsame(); $after-cs = True; result }
    }
    is DeadEnd.cw(1), Nil, 'callwith with nowhere to defer produces Nil';
    ok $after-cw, 'control reaches after callwith that has nowhere to go';
    is DeadEnd.cs(1), Nil, 'callsame with nowhere to defer produces Nil';
    ok $after-cs, 'control reaches after callsame that has nowhere to go';
}

subtest "Two methods of different names in a class both using callsame" => {
    my class C1 {
        method m1() { "c1-m1" }
        method m2() { "c1-m2" }
    }
    my class C2 is C1 {
        method m1() { "c2-m1," ~ callsame }
        method m2() { "c2-m2," ~ callsame }
    }
    is C2.m1, "c2-m1,c1-m1", "First method callsame works";
    is C2.m2, "c2-m2,c1-m2", "Second method callsame works";
}

# vim: expandtab shiftwidth=4
