use Test;

=begin pod

    access or assign on undeclared attribute will raise an error.

=end pod

plan 11;


dies-ok { class A { method set_a { $.a = 1 }}; A.new.set_a; },
    "Test Undeclared public attribute assignment from a class";
dies-ok { role B { method set_b { $.b = 1 }};class C does B { }; C.new.set_b; },
    "Test Undeclared public attribute assignment from a role";

throws-like ' class D { method d { $!d = 1 }}; D.new.d; ', X::Attribute::Undeclared,
    "Test Undeclared private attribute assignment from a class";
throws-like ' role E { method e { $!e = 1 }};class F does E { }; F.new.e; ',
    X::Attribute::Undeclared,
    "Test Undeclared private attribute assignment from a role";

##### access the undeclared attribute
dies-ok { class H { method set_h { $.h }}; H.new.set_h; },
    "Test Undeclared public attribute access from a class";
dies-ok { role I { method set_i { $.i }};class J does I { }; J.new.set_i; },
    "Test Undeclared public attribute access from a role";

throws-like ' class K { method k { $!k }}; K.new.k; ', X::Attribute::Undeclared,
    "Test Undeclared private attribute access from a class";
throws-like ' role L { method l { $!l }};class M does L { }; M.new.l; ',
    X::Attribute::Undeclared,
    "Test Undeclared private attribute access from a role";

## skip class 'Q' here to avoid quote operator conflict.

throws-like ' role R { method r { $!r := 1 }};class S does R { }; S.new.r; ',
    X::Attribute::Undeclared,
    "Test Undeclared private attribute binding from a role";
throws-like ' class T { method t { $!t := 1 }}; ::T.new.t; ',
    X::Attribute::Undeclared,
    "Test Undeclared private attribute binding from a class";


{
    throws-like { EVAL q[has $.x] },
        X::Attribute::NoPackage,
        message => q[You cannot declare attribute '$.x' here; maybe you'd like a class or a role?];
}

# vim: expandtab shiftwidth=4
