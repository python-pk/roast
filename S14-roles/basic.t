use Test;

plan 53;

=begin description

Basic role tests from L<S14/Roles>

=end description

# L<S14/Roles>
# Basic definition
role Foo {}
class Bar does Foo {};

# Smartmatch and .HOW.does and .^does
my $bar = Bar.new();
ok ($bar ~~ Bar),               '... smartmatch our $bar to the Bar class';
ok ($bar.HOW.does($bar, Foo)),  '.HOW.does said our $bar does Foo';
ok ($bar.^does(Foo)),           '.^does said our $bar does Foo';
ok ($bar ~~ Foo),               'smartmatch said our $bar does Foo';
nok Foo.defined,                'role type objects are undefined';

# Can also write does inside the class.
{
    role Foo2 { method x { 42 } }
    class Bar2 { also does Foo2; }
    my $bar2 = Bar2.new();
    ok ($bar2 ~~ Foo2),          'smartmatch works when role is done inside class';
    is $bar2.x, 42,              'method composed when role is done inside class';
}

# Mixing a Role into a Mu using imperative C<does>
my $baz = { };
ok defined($baz does Foo),      'mixing in our Foo role into $baz worked';
ok $baz.HOW.does($baz, Foo),    '.HOW.does said our $baz now does Foo';
ok $baz.^does(Foo),             '.^does said our $baz now does Foo';
throws-like q{ $baz ~~ Baz }, X::Undeclared::Symbols, 'smartmatch against non-existent type dies';

# L<S14/Roles/but with a role keyword:>
# Roles may have methods
{
    role A { method say_hello(Str $to) { "Hello, $to" } }
    my Bar $a .= new();
    ok(defined($a does A), 'mixing A into $a worked');
    is $a.say_hello("Ingo"), "Hello, Ingo",
        '$a "inherited" the .say_hello method of A';
}

# L<S14/Roles/Roles may have attributes:>
{
    role B { has $.attr is rw = 42 }
    my Bar $b .= new();
    $b does B;
    ok defined($b),        'mixing B into $b worked';
    is $b.attr, 42,        '$b "inherited" the $.attr attribute of B (1)';
    is ($b.attr = 23), 23, '$b "inherited" the $.attr attribute of B (2)';

    # L<S14/Run-time Mixins/"but creates a copy">
    # As usual, ok instead of todo_ok to avoid unexpected succeedings.
    my Bar $c .= new(),
    ok defined($c),             'creating a Foo worked';
    ok !($c ~~ B),              '$c does not B';
    ok (my $d = $c but B),      'mixing in a Role via but worked';
    ok !($c ~~ B),              '$c still does not B...';
    ok $d ~~ B,                 '...but $d does B';
}

# Using roles as type constraints.
role C { }
class DoesC does C { }
lives-ok { my C $x; },          'can use role as a type constraint on a variable';
dies-ok { my C $x = 42 },       'type-check enforced';
dies-ok { my C $x; $x = 42 },   'type-check enforced in future assignments too';
lives-ok {my C $x = DoesC.new },'type-check passes for class doing role';
lives-ok { my C $x = 42 but C },'type-check passes when role mixed in';

class HasC {
    has C $.x is rw;
}
lives-ok { HasC.new },          'attributes typed as roles initialized OK';
lives-ok { HasC.new.x = DoesC.new },
                                'typed attribute accepts things it should';
dies-ok { HasC.new.x = Mu },    'typed attribute rejects things it should';
dies-ok { HasC.new.x = 42 },    'typed attribute rejects things it should';


throws-like '0 but RT66178', X::Undeclared::Symbols, '"but" with non-existent role dies';

{
    dies-ok { EVAL 'class Animal does NonExistentRole { }; 1' },
        'a class dies when it does a non-existent role';

    try { EVAL 'class AnotherAnimal does NonExistentRole { }; 1' };
    my $err = "$!";
    ok $err ~~ /NonExistentRole/,
       '... and the error message mentions the role';
}


{
    class AClass { };
    dies-ok { EVAL 'class BClass does AClass { }; 1' },
	    'class SomeClass does AnotherClass  dies';
    my $x = try EVAL 'class CClass does AClass { }; 1';
    ok "$!" ~~ /AClass/, 'Error message mentions the offending non-role';
}


{
    try EVAL 'class Boo does Boo { };';
    ok "$!" ~~ /Boo/, 'class does itself produces sensible error message';
}


throws-like 'role RR { }; class RR { };', X::Redeclaration, symbol => 'RR';
throws-like 'role RRR { }; class RRR does RRR { };', X::Redeclaration,
             symbol => 'RRR';


{
    role StrTest {
        method s { self.gist }
    };
    ok StrTest.s ~~ /StrTest/,
        'default role gistification contains role name';
}


lives-ok {0 but True}, '0 but True has applicable candidate';


#?rakudo skip 'RT #67768'
{
    eval-lives-ok 'role List { method foo { 67768 } }',
        'can declare a role with a name already assigned to a class';
    eval-lives-ok 'class C67768 does OUR::List { }',
        'can use a role with a name already assigned to a class';
    is ::OUR::C67768.new.foo, 67768,
        'can call method from a role with a name already assigned to a class';
}


{
    lives-ok { my role R { my $.r }; my class C does R {} },
        'Can have "my $.r" in a role (RT #114380)';
}


{
    my role AccessesAttr {
        method meth() {
            self.x;
        }
    }
    my class WithAttr does AccessesAttr {
        has $.x = 42;
        method meth() {
            self.AccessesAttr::meth();
        }
    }
    is WithAttr.new.meth, 42, '$obj.Role::method() passes correct invocant';
}


{
    my role A {
        method pub { self!priv };
        method !priv () { 42 };
    };
    my class C does A { };
    is C.new.pub, 42, 'private methods in roles bind "self" correctly';
}


{
    lives-ok { role RT120931 { method foo {}; RT120931.foo } },
        'can call a role method from within the role block';
}


{
    throws-like { EVAL q[role A::B { method foo(A::C $a) { } }] },
        X::Parameter::InvalidType,
        'undeclared type in signature in role results in X::Parameter::InvalidType';
}


{
    lives-ok { sub rt123002 { EVAL 'role RT123002 { }' }; rt123002 },
        'can call a sub which runs EVAL on minimal role declaration';
}

{
    my role R:ver<0.1>:auth<ority> {}
    is R.^ver, v0.1, '.^ver on role works';
    is R.^auth, 'ority', '.^auth on role works';
}


{
    role Rule {
        has Int $.number;
        has $.foo = $!number;
    }
    class Wolfram does Rule {
        has Rule $.r .= new(:$!number);
    }
    my $obj = Wolfram.new: number => 30;
    is $obj.number,   30, ‘attribute value was set correctly’;
    is $obj.r.number, 30, ‘deeper attribute value was set correctly’;
}

# vim: expandtab shiftwidth=4
