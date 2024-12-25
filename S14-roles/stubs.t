use Test;

plan 30;

role WithStub { method a() { ... } };
role ProvidesStub1 { method a() { 1 } };
role ProvidesStub2 { method a() { 2 } };
role WithMultiStub { multi method a(Int) { ... }; };

dies-ok  { EVAL 'class A does WithStub { }' },
        'need to implement stubbed methods at role-into-class composition time';
lives-ok { EVAL 'role B does WithStub { }' },
        'but roles are fine';
lives-ok { EVAL 'class C does WithStub { method a() { 3 } }' },
        'directly implementing the stubbed method is fine';
lives-ok { EVAL 'class D does WithStub does ProvidesStub1 { }' },
        'composing the stubbed method is fine';
dies-ok  { EVAL 'class E does WithStub does ProvidesStub1 does ProvidesStub2 { }' },
        'composing stub and 2 implementations dies again';
lives-ok { EVAL 'class F does WithStub does ProvidesStub1 does ProvidesStub2 {
    method a() { 4 } }' },
        'composing stub and 2 implementations allows custom implementation';

{
    class G does WithMultiStub { multi method a(Int) { } };
    lives-ok { EVAL 'G.a(1)' }, "No ambiguous dispatch on stubbed multi in interface";
    dies-ok { EVAL 'class H does WithMultiStub { multi method a(Str) { } }' },
        "Interface contract enforced on stubbed multi";
}


eval-lives-ok q[class C2901 does WithStub { multi method a() { "OHAI" } }],
    'Class can define multi method to implement non-multi method stubbed in role';

lives-ok { EVAL 'class I does WithStub {
    has WithStub $.with-stub handles <a>}' },
        'composing stub implemented with attribute handles';

class ProvidesA { method a() { 5 } };
lives-ok { EVAL 'class ChildA is ProvidesA does WithStub { }' },
        'stubbed method can come from parent class too';


lives-ok { EVAL 'class RT115212 does WithStub { has $.a }' }, 'stubbed method can come from accessor';

class HasA { has $.a }

lives-ok { EVAL 'class RT115212Child is HasA does WithStub { }' }, 'stubbed method can come from accessor in parent class';


throws-like { EVAL 'my role F119643 { ... }; class C119643 does F119643 {}' },
    X::Role::Parametric::NoSuchCandidate;


{
    my role WithPrivate { method !foo { "p" } };
    my role WithPrivateStub { method !foo { ... } };
    my class ClassPrivate does WithPrivate does WithPrivateStub { method bar {self!foo } };

    is ClassPrivate.new.bar(), 'p', 'RT #125606: Stub resolution works for private methods too';
}


{
    my role A { method !foo(A:D:) { "success!" } };
    my role B { method !foo { ... }; method bar {self!foo } };
    my class C does B does A { }
    is C.new.bar(), "success!", 'private method call in role dispatches on type of target class';
}


{
    my role R { method m() { ... } }
    for <gist raku DUMP item Str Bool defined so not WHICH WHERE Stringy Numeric Real> {
        lives-ok { R."$_"() }, ".$_ on role with requirement does not pun it and die";
    }
}

# vim: expandtab shiftwidth=4
