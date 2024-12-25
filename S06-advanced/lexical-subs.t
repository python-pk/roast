use Test;

plan 13;

{
    sub f() {
        my sub g(){"g"}; my sub h(){g()}; h();
    };
    is(f(), 'g', 'can indirectly call lexical sub');
    throws-like 'g', X::Undeclared::Symbols,
        'lexical sub not visible outside current scope';
}

{
    sub foo($x) { $x + 1 }

    sub callit(&foo) {
        foo(1);
    }

    is(foo(1), 2, 'calls subs passed as &foo parameter');
    is(callit({ $^x + 2 }), 3, "lexical subs get precedence over package subs");
}

{
    sub infix:<@@> ($x, $y) { $x + $y }

    sub foo2(&infix:<@@>) {
        2 @@ 3;
    }

    is(2 @@ 3, 5);
    is(foo2({ $^a * $^b }), 6);
}

{
    my sub test_this {     #OK not used
        ok 1, "Could call ok from within a lexical sub";
        return 1;
    }
    EVAL 'test_this()';
    if ($!) {
        ok 0, "Could call ok from within a lexical sub";
    }
}


{
    sub a { 'outer' };
    {
        my sub a { 'inner' };
        is a(), 'inner', 'inner lexical hides outer sub of same name';
    }
    is a(), 'outer', '... but only where it is visisble';
}

{
    package TestScope {
        sub f { };
    }
    dies-ok { TestScope::f }, 'subs without scoping modifiers are not entered in the namespace';
}


{
    throws-like 'sub a { }; sub a { }', X::Redeclaration;
}


{
    my $rt109322;
    sub foo ($a, $f) {
        if $f {
            foo('z', 0);
        }
        given $a {
            $rt109322 ~= $a;
            $rt109322 ~= $_;
        }
    }
    foo('x', 1);
    is $rt109322, 'zzxx', 'no lexical weirdness from blocks inside re-entrant subs (1)';

    $rt109322 = '';
    sub bar ($a, $f) {
        if $f {
            bar('z', 0);
        }
        {
            $_ = $a;
            $rt109322 ~= $a;
            $rt109322 ~= $_;
        }
    };
    bar('x', 1);
    is $rt109322, 'zzxx', 'no lexical weirdness from blocks inside re-entrant subs (2)';
}

# vim: expandtab shiftwidth=4
