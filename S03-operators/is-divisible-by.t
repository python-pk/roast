use Test;

plan 16;

# L<S03/"is divisible by">
{
    ok 6 %% 3, '6 %% 3';
    isa-ok 6 %% 3, Bool, '6 %% 3 isa Bool';
    nok 6 %% 4, '6 %% 4';
    isa-ok 6 %% 4, Bool, '6 %% 4 isa Bool';

    is (1..10).grep({ $_ %% 3 }), <3 6 9>, '%% works with explicit closure';
    is (1..10).grep( * %% 3 ), <3 6 9>, '%% works with whatever *';
} #6

{
    nok 6 !%% 3, '6 !%% 3';
    isa-ok 6 !%% 3, Bool, '6 !%% 3 isa Bool';
    ok 6 !%% 4, '6 !%% 4';
    isa-ok 6 %% 4, Bool, '6 !%% 4 isa Bool';

    is (1..10).grep({ $_ !%% 3 }), <1 2 4 5 7 8 10>, '%% works with explicit closure';
    is (1..10).grep( * !%% 3 ), <1 2 4 5 7 8 10>, '%% works with whatever *';
} #6


{
    # TODO: implement typed exception and adapt test
    throws-like { EVAL q[ 9 !% 0 ] }, X::Syntax::CannotMeta,
        'infix<!%> is not iffy enough';
} #1

{
    throws-like { 9 %% 0 }, X::Numeric::DivideByZero,
        using => 'infix:<%%>',
        numerator => 9,
        'cannot divide by zero using infix:<%%>';
    #?rakudo todo "not sure why this doesn't fire"
    throws-like { EVAL "9 !%% 0" }, X::Numeric::DivideByZero,
        using => 'infix:<%%>',
        numerator => 9,
        'cannot divide by zero using infix:<%%>';
} #2


subtest 'no crashes with bigint args' => {
    plan 2;
    is-deeply 23067200747291880127814827277075079921671259751791
      %% 100000000000000000000000000000000000000000000000577, False, '%% op';
    is-deeply 23067200747291880127814827277075079921671259751791
      % 100000000000000000000000000000000000000000000000577,
      23067200747291880127814827277075079921671259751791, '% op';
}

# vim: expandtab shiftwidth=4
