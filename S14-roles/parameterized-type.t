use Test;

plan 11;

=begin pod

Tests for using parameterized roles as types, plus the of keyword.

=end pod

# L<S14/Parametric Roles>
# L<S14/Relationship Between of And Types>

subtest "Parameterization as constraint" => {
    my role R1[::T] { method x { T } }
    my class C1 does R1[Int] { }
    my class C2 does R1[Str] { }
    lives-ok { my R1 of Int $x = C1.new },      'using of as type constraint on variable works (class does role)';
    dies-ok  { my R1 of Int $x = C2.new },      'using of as type constraint on variable works (class does role)';
    lives-ok { my R1 of Int $x = R1[Int].new }, 'using of as type constraint on variable works (role instantiation)';
    dies-ok  { my R1 of Int $x = R1[Str].new }, 'using of as type constraint on variable works (role instantiation)';

    sub param_test(R1 of Int $x) { $x.x }
    isa-ok param_test(C1.new),      Int,          'using of as type constraint on parameter works (class does role)';
    dies-ok { param_test(C2.new) },             'using of as type constraint on parameter works (class does role)';
    isa-ok param_test(R1[Int].new), Int,          'using of as type constraint on parameter works (role instantiation)';
    dies-ok { param_test(R1[Str].new) },        'using of as type constraint on parameter works (role instantiation)';
}

subtest "Recursive-ish parameterization" => {
    my role R2[::T] {
        method x { "ok" }
        method call_test { self.call_test_helper(T.new) }
        method call_test_helper(T $x) { "ok" }   #OK not used
        method call_fail { self.call_test_helper(4.5) }
    }
    my class C3 does R2[R2[Int]] { }
    my class C4 does R2[R2[Str]] { }

    lives-ok { my R2 of R2 of Int $x = C3.new },          'roles parameterized with themselves as type constraints';
    dies-ok { my R2 of R2 of Int $x = C4.new },           'roles parameterized with themselves as type constraints';
    lives-ok { my R2 of R2 of Int $x = R2[R2[Int]].new }, 'roles parameterized with themselves as type constraints';
    dies-ok { my R2 of R2 of Int $x = R2[R2[Str]].new },  'roles parameterized with themselves as type constraints';

    sub param_test_r(R2 of R2 of Int $x) { $x.x }
    is param_test_r(C3.new),          'ok',    'roles parameterized with themselves as type constraints';
    dies-ok { param_test_r(C4.new) },          'roles parameterized with themselves as type constraints';
    is param_test_r(R2[R2[Int]].new), 'ok',    'roles parameterized with themselves as type constraints';
    dies-ok { param_test_r(R2[R2[Str]].new) }, 'roles parameterized with themselves as type constraints';

    is R2[Int].new.call_test,    'ok', 'types being used as type constraints inside roles work';
    dies-ok { R2[Int].new.call_fail }, 'types being used as type constraints inside roles work';
    is C3.new.call_test,         'ok', 'roles being used as type constraints inside roles work';
    dies-ok { C3.new.call_fail },      'roles being used as type constraints inside roles work';
    is C4.new.call_test,         'ok', 'roles being used as type constraints inside roles work';
    dies-ok { C4.new.call_fail },      'roles being used as type constraints inside roles work';
    is R2[C3].new.call_test,     'ok', 'classes being used as type constraints inside roles work';
    dies-ok { R2[C3].new.call_fail },  'classes being used as type constraints inside roles work';
}


throws-like 'role ABCD[EFGH] { }', X::Parameter::InvalidType, 'role with undefined type as parameter dies';


{
    my role TreeNode[::T] does Positional {
        has TreeNode[T] @!children handles <AT-POS ASSIGN-POS BIND-POS>;
        has T $.data is rw;
    };
    my $tree = TreeNode[Int].new;
    $tree.data = 3;
    $tree[0] = TreeNode[Int].new;
    $tree[1] = TreeNode[Int].new;
    $tree[0].data = 1;
    $tree[1].data = 4;
    is ($tree.data, $tree[0,1]>>.data).flat.join(','), '3,1,4',
        'parameterized role doing non-parameterized role';
}


{
    my role P[$x] { }
    # ::T only makes sense in a signature here, not in
    # an argument list.
    dies-ok { EVAL 'class MyClass does P[::T] { }' },
        'can not use ::T in role application';
}


{
    my role R[::T = my role Q[::S = role { method baz { "OH HAI" } }] { method bar { S.baz } }] { method foo { T.bar } };
    is R.new.foo, 'OH HAI', 'can use a parameterized role as a default value of a parameterized role';

}


{
    my module A {
        role B[$x] is export {
            method payload { $x }
        }
    }
    import A;
    is B['blubb'].payload, 'blubb', 'can export and import parameterized roles';
}


{
    my role R[::T] { multi method foo(T $t) { T.gist } };
    my class A does R[Str] does R[Int] { };
    is A.new.foo(5), 5.WHAT.gist, 'correct multi selected from multiple parametric roles';
}


{
    throws-like 'sub f(Int @x) {}; f( [] )',
        X::TypeCheck::Binding,
        message => /Positional\[Int\]/,
        'error message mentions expected type when a typed array in a signature fails to bind';
}


lives-ok { EVAL 'my role A [ :$bs where { True } = 512] { }; class B does A { }' },
    'role with where clause and default in parametric signature works out OK';

{
    my role A[::T] { 
        method a { A[T] } 
    } 
    isa-ok A[Int].a, A[Int], "role is correctly paramterized in a role's method body";
}

# vim: expandtab shiftwidth=4
