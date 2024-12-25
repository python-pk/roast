use Test;

plan 52;

=begin pod

Basic parameterized role tests, see L<S14/Roles>

=end pod

# L<S14/Run-time Mixins/may be parameterized>

# Some basic arity-based selection tests.
role AritySelection {
    method x { 1 }
}
role AritySelection[$x] {
    method x { 2 }
}
role AritySelection[$x, $y] {
    method x { 3 }
}
class AS_1 does AritySelection { }
class AS_2 does AritySelection[1] { }
class AS_3 does AritySelection[1, 2] { }
is(AS_1.new.x, 1, 'arity-based selection of role with no parameters');
is(AS_2.new.x, 2, 'arity-based selection of role with 1 parameter');
is(AS_3.new.x, 3, 'arity-based selection of role with 2 parameters');

# Test .candidates method
is(+AritySelection.HOW.candidates(AritySelection), 3);

# Make sure Foo[] works as well as Foo.
role AritySelection2[] {
    method x { 1 }
}
role AritySelection2[$x] {
    method x { 2 }
}
class AS2_1 does AritySelection2 { }
class AS2_2 does AritySelection2[] { }
class AS2_3 does AritySelection2[1] { }
is(AS2_1.new.x, 1, 'Foo[] invoked as Foo');
is(AS2_2.new.x, 1, 'Foo[] invoked as Foo[]');
is(AS2_3.new.x, 2, 'Foo[1] (for sanity)');

# Some type based choices.
class NarrownessTestA { }
class NarrownessTestB is NarrownessTestA { }
role TypeSelection[Str $x] {
    method x { 1 }
}
role TypeSelection[NarrownessTestA $x] {
    method x { 2 }
}
role TypeSelection[NarrownessTestB $x] {
    method x { 3 }
}
role TypeSelection[::T] {
    method x { 4 }
}
class TS_1 does TypeSelection["OH HAI"] { }
class TS_2 does TypeSelection[NarrownessTestB] { }
class TS_3 does TypeSelection[NarrownessTestA] { }
class TS_4 does TypeSelection[Pair] { }
is(TS_1.new.x, 1, 'type-based selection of role');
is(TS_2.new.x, 3, 'type-based selection of role (narrowness test)');
is(TS_3.new.x, 2, 'type-based selection of role (narrowness test)');
is(TS_4.new.x, 4, 'type-based selection of role (type variable)');

# Use of parameters within methods.
role MethParams[$x] {
    method x { $x }
    method y { { "42" ~ $x } }
}
class MP_1 does MethParams[1] { }
class MP_2 does MethParams['BBQ'] { }
is(MP_2.new.x,   'BBQ',   'use of type params in methods works...');
is(MP_1.new.x,   1,       '...even over many invocations.');
is(MP_2.new.y,   '42BBQ', 'params in nested scopes in methods');
is(MP_1.new.y,   '421',   'params in nested scopes in methods');

# Use of parameters with attribute initialization.
role AttrParams[$a, $b] {
    has $.x = $a;
    has $.y = $b;
}
class AP_1 does AttrParams['a','b'] { }
class AP_2 does AttrParams[1,2] { }
is(AP_2.new.x,   1,    'use of type params in attr initialization works');
is(AP_2.new.y,   2,    'use of type params in attr initialization works');
is(AP_1.new.x,   'a',  'use of type params in attr initialization works after 2nd invocation');
is(AP_1.new.y,   'b',  'use of type params in attr initialization works after 2nd invocation');

# Use of parameters as type constraints.
{
    role TypeParams[::T] {
        method x(T $x) { return "got a " ~ T.gist() ~ " it was $x" }
    }
    class TTP_1 does TypeParams[Int] { }
    class TTP_2 does TypeParams[Str] { }
    is(TTP_1.new.x(42),       'got a (Int) it was 42',     'type variable in scope and accepts right value');
    is(TTP_2.new.x("OH HAI"), 'got a (Str) it was OH HAI', 'type variable in scope and accepts right value');
    dies-ok({ TTP_1.new.x("OH HAI") },                   'type constraint with parameterized type enforced');
    dies-ok({ TTP_2.new.x(42) },                         'type constraint with parameterized type enforced');
}

# test multi dispatch on parameterized roles
# not really basic anymore, but I don't know where else to put these tests
{
    role MD_block[Int $x where { $x % 2 == 0 }] {
        method what { 'even' };
    }
    role MD_block[Int $x where { $x % 2 == 1 }] {
        method what { 'odd' };
    }

    class CEven does MD_block[4] { };
    class COdd  does MD_block[3] { };

    is CEven.new.what, 'even',
       'multi dispatch on parameterized role works with where-blocks (1)';
    is COdd.new.what,  'odd',
       'multi dispatch on parameterized role works with where-blocks (2)';
    is CEven.what, 'even',
       'same with class methods (1)';
    is COdd.what,  'odd',
       'same with class methods (2)';
    throws-like 'class MD_not_Int does MD_block["foo"] { }',
        X::Role::Parametric::NoSuchCandidate,
        "Can't compose without matching role multi";
}

{
    role MD_generics[::T $a, T $b] {
        method what { 'same type' }
    }
    role MD_generics[$a, $b] {
        method what { 'different type' }
    }
    class CSame does MD_generics[Array, Array] { }
    class CDiff does MD_generics[Int, Hash] { }

    is CSame.new.what, 'same type',
       'MD with generics at class composition time (1)';
    is CDiff.new.what, 'different type',
       'MD with generics at class composition time (2)';

    is CSame.what, 'same type',
       'MD with generics at class composition time (class method) (1)';
    is CDiff.what, 'different type',
       'MD with generics at class composition time (class method) (2)';
    throws-like 'class WrongFu does MD_generics[3] { }',
        X::Role::Parametric::NoSuchCandidate,
       'MD with generics at class composition times fails (wrong arity)';
}


{
    lives-ok { role A[::T $?] {}; class B does A[] {} },
        'question mark for optional parameter is parsed correctly';
    throws-like 'role A[::T?] {}; class B does A[] {}',
        X::Syntax::Malformed,
        'cannot put question mark on a type constraint';
}


{
    role Foo[::T] { has T @.a = T }; class Bar {};
    is( Foo[Bar].new.a[0], Bar, 'generic role with defaulted and typed attr' );
}

# GH #2698
{
    my role PR00[::T] { }
    my role PR01[::T] { }
    my role PR02 { }

    my role PR1 does PR00[Int] { }
    my role PR1[::T] does PR00[T] { }
    my role PR1[::T1, ::T2] does PR00[T1] does PR01[T2] does PR02 { }

    my \r = PR1[Int, Str];

    my @expect_roles = PR00[Int], PR01[Str], PR02;
    for @expect_roles -> \expected {
        ok r ~~ expected, "PR1 type match against consumed " ~ expected.^name ~ " role";
    }

    ok r ~~ PR01[Str], "Curryied role matches a consumed role explicitly";
    nok r ~~ PR00[Str], "Curryied role only matches its own consumed roles";
}

# Indirect role consumption
{
    my role Foo {
        method foo { ::?ROLE.^name }
    }
    my role RR[::T] does T { }
    my class C does RR[Foo] { }

    does-ok C, Foo, "class does indirectly consumed role";
    is C.foo, "Foo", "method of indirectly consumed role is available";
    does-ok RR[Foo], Foo, "role does indirectly consumed role";
    nok RR[Foo] ~~ Numeric, "consuming role doesn't accidentally match to a not consumed role";
    nok Foo ~~ RR[Foo], "indirectly consumed role doesn't match against consumer";
}

# Indirect inheritance
{
    my class Bar {
        method bar { ::?CLASS.^name }
    }
    my role RC[::T] is T {}
    my class C does RC[Bar] {}

    isa-ok C, Bar, "class typechecks against indirectly inherited parent";
    is C.bar, "Bar", "method from indirect parent is available";
    isa-ok RC[Bar], Bar, "role typechecks against indirect parent";
    nok RC[Bar] ~~ Int, "role doesn't accidentally match against non-parent";
    nok Bar ~~ RC[Bar], "indirect parent doesn't accidentally typecheck against the role";
}


{
    throws-like q:to/CODE/, X::Role::Unimplemented::Multi, "use of ::?CLASS results in the right exception";
my role R {
    multi method multi(::?CLASS:D: --> ::?CLASS) {...}
}
my class Foo does R { }
CODE
}

# vim: expandtab shiftwidth=4
