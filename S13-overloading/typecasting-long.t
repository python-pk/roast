use Test;

plan 39;

# L<S13/"Type Casting"/"method CALL-ME(**@slice) {...}">
# basic tests to see if the methods overload correctly.

{
    my multi testsub ($a,$b) {   #OK not used
        return 1;
    }
    my multi testsub ($a) {   #OK not used
        return 2;
    }
    my multi testsub () {
        return 3;
    }
    class TypeCastSub {
        method CALL-ME (|c) {return 'pretending to be a sub ' ~ testsub(|c) }
    }

    my $thing = TypeCastSub.new;
    is($thing(), 'pretending to be a sub 3', 'overloaded () call works');
    is($thing.(), 'pretending to be a sub 3', 'overloaded .() call works');
    is($thing.(1), 'pretending to be a sub 2', 'overloaded .($) call works');
    is($thing.(1,2), 'pretending to be a sub 1', 'overloaded .($,$) call works');

    class TypeCastSub2 {
        method CALL-ME (|c) {return 'pretending to be a sub ' ~ testsub(|c) }
    }

    my $thing2 = TypeCastSub2.new;
    is($thing2(), 'pretending to be a sub 3', 'overloaded () call works (CALL-ME)');
    is($thing2.(), 'pretending to be a sub 3', 'overloaded .() call works (CALL-ME)');
    is($thing2.(1), 'pretending to be a sub 2', 'overloaded .($) call works (CALL-ME)');
    is($thing2.(1,2), 'pretending to be a sub 1', 'overloaded .($,$) call works (CALL-ME)');

    class TypeCastSub3 {
        multi method CALL-ME () {return 'pretending to be a sub 3' }
        multi method CALL-ME ($a) {return "pretending to be a sub $a" }
        multi method CALL-ME ($a, $b) {return "pretending to be a sub $a $b" }
    }

    my $thing3 = TypeCastSub3.new;
    is($thing3(), 'pretending to be a sub 3', 'overloaded () call works (multi CALL-ME)');
    is($thing3.(), 'pretending to be a sub 3', 'overloaded .() call works (multi CALL-ME)');
    is($thing3.(2), 'pretending to be a sub 2', 'overloaded .($) call works (multi CALL-ME)');
    is($thing3.(3,4), 'pretending to be a sub 3 4', 'overloaded .($,$) call works (multi CALL-ME)');

    class TypeCastSub4 {
        method CALL-ME () {return "pretending to be a sub" }
    }

    my $thing4 = TypeCastSub4.new;
    is($thing4(), 'pretending to be a sub', 'overloaded () call works (only CALL-ME)');
    is($thing4.(), 'pretending to be a sub', 'overloaded .() call works (only CALL-ME)');

    class TypeCastSub5 {
        method CALL-ME ($a) {return "pretending to be a sub $a" }
    }

    my $thing5 = TypeCastSub5.new;
    is($thing5(42), 'pretending to be a sub 42', 'overloaded ($) call works (only CALL-ME)');
    is($thing5.(42), 'pretending to be a sub 42', 'overloaded .($) call works (only CALL-ME)');

    class TypeCastSub6 {
        method CALL-ME ($a,$b) {return "pretending to be a sub $a $b" }
    }

    my $thing6 = TypeCastSub6.new;
    is($thing6(42,43), 'pretending to be a sub 42 43', 'overloaded ($,$) call works (only CALL-ME)');
    is($thing6.(42,43), 'pretending to be a sub 42 43', 'overloaded .($,$) call works (only CALL-ME)');

}


{
    my $*res = 0;
    sub somesub () { $*res = 42; };
    class Foo {
        has @.a is rw;
        method add(&c){ @.a.push(&c) }
        method CALL-ME($self: |c) {
            @.a>>.(|c)
        }
    }
    my $foo = Foo.new;
    $foo.add(&somesub);
    $foo();
    is $*res, 42, 'example code works';
}


{
    class A { method CALL-ME (A:U:) { 3 } };
    is A.(), 3, '.() -> (:U) works, dotted form';
    is A(:a), 3, '(:a) -> (:U) works';
    is A.(:a), 3, '.(:a) -> (:U) works, dotted form';

    class B { method CALL-ME(B:U: $x) { 3 } };
    is B(0), 3, '($: $) -> (:U, $) case';
    is B.(0), 3, '.($: $) -> (:U, $) case, dotted form';
    throws-like 'class XYX { method CALL-ME(XYX:U: $x) { } }; XYX(:a);', Exception,
      '($:, :$) -> (:U, $) arity check';
    throws-like 'class XYY { method CALL-ME(XYY:U: $x) { } }; XYY.();', Exception,
      '.($:) -> (:U, $) arity check';
    throws-like 'class YYY { method CALL-ME(YYY:U: $x) { } }; YYY.(:a);', Exception,
      '.($:, :$) -> (:U, $) arity check';
    throws-like 'class XYZ { method CALL-ME(XYZ:U: $x) { } }; XYZ(3,4,5);', Exception,
      '($: $, $, $) -> (:U, $) arity check';
    throws-like 'class XZZ { method CALL-ME(XZZ:U: $x) { } }; XZZ.(3,4,5);', Exception,
      '.($: $, $, $) -> (:U, $) arity check';

    isa-ok A().HOW, Metamodel::CoercionHOW, 'A() is a type coercion literal';
    isa-ok A(Any).HOW, Metamodel::CoercionHOW, 'A(Any) is a type coercion literal';
}


{
    class Bar {
        has $.str;
        method CALL-ME($i, $k) { $.str.substr: $i, $k }
    }
    my Bar $x .= new: :str("abcde");
    is $x(2, 1), 'c', 'example works';
}

{ 
    my role R01 {
        multi method CALL-ME(::?ROLE:U:) { ::?ROLE }
        multi method CALL-ME(::?ROLE:U: \v) {
            v.raku
        }
    }

    isa-ok R01.(), R01, "role pretends to be a sub";
    is R01(pi), pi.raku, "argument passing to role's CALL-ME";

    my role R02 { }
    throws-like { R02("boom!") },
        X::Coerce::Impossible,
        "coercion attempt for a non-invocable role throws";

    my role R03 {
        has $.val;
        method COERCE($val) { self.new(:$val) }
    }

    my $coerced = R03("foo");
    isa-ok $coerced, R03, "coerced into a pun";
    is $coerced.val, "foo", "coercion initialized with value";

    my role R04 does R01 { }
    isa-ok R04.(), R01, "role consuming other role pretends to be a sub";
    is R04.(e), e.raku, "argument passing to a role consuming another role"
}

# vim: expandtab shiftwidth=4
