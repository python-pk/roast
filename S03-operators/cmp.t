use Test;

plan 64;

# cmp on scalar values
{
    is 5 cmp 6, Order::Less, "cmp on int (1)";
    is 5 cmp 5, Order::Same, "cmp on int (2)";
    is 6 cmp 5, Order::More, "cmp on int (3)";

    is "a" cmp "b", Order::Less, "cmp on characters (1)";
    is "b" cmp "a", Order::More, "cmp on characters (2)";
    is "a" cmp "a", Order::Same, "cmp on characters (3)";
}

# cmp on variables
{
    my Int $a = 11;
    my Int $b = 10;

    is $a cmp $b, Order::More, "cmp on Int variables (1)";
    --$a;
    is $a cmp $b, Order::Same, "cmp on Int variables (2)";
    --$a;
    is $a cmp $b, Order::Less, "cmp on Int variables (3)";

    my Str $c = "aaa";
    my Str $d = "bbb";

    is $c cmp $d, Order::Less, "cmp on Str variables (1)";
    $c = "bbb";
    is $c cmp $d, Order::Same, "cmp on Str variables (2)";
    $c = "ccc";
    is $c cmp $d, Order::More, "cmp on Str variables (3)";
}

# cmp on Pair
{
    is (:a<5> cmp :a<5>), Order::Same, "cmp on Pair (1)";
    is (:a<5> cmp :b<5>), Order::Less, "cmp on Pair (2)";
    is (:b<5> cmp :a<5>), Order::More, "cmp on Pair (3)";
    is (:a<6> cmp :a<5>), Order::More, "cmp on Pair (4)";
    is (:a<5> cmp :a<6>), Order::Less, "cmp on Pair (5)";

    my $cmp5 = { :$^q cmp :q<5> };
    is $cmp5(5), Order::Same, "cmp on Pair from local variable";

    is (:a<5> cmp  Inf), Order::Less, "cmp on Pair/Inf";
    is (:a<5> cmp -Inf), Order::More, "cmp on Pair/-Inf";
    is ( Inf cmp :a<5>), Order::More, "cmp on Inf/Pair";
    is (-Inf cmp :a<5>), Order::Less, "cmp on -Inf/Pair";
}

# cmp on numeric lists
{
    is [1,10] cmp [1,10], Same, "cmp Same on identical lists";
    is [1,10] cmp [1,10,0], Less, "cmp Less on shorter list";
    is [1,10,0] cmp [1,10], More, "cmp More on longer list";
    is [-1,10] cmp [1,10], Less, "cmp Less on lists differing at pos 0";
    is [102,10] cmp [21,10], More, "cmp More on lists differing at pos 0";
    is [1,9] cmp [1,10], Less, "cmp Less on lists differing at pos 1";
    is [1,10] cmp [1,9], More, "cmp More on lists differing at pos 1";
    is [1,9] cmp [1,10,19], Less, "cmp Less on lists differing at pos 1 ignoring lengths";
    is [1,10] cmp [1,9,19], More, "cmp More on lists differing at pos 1 ignoring lengths";
}

# NaN always sorts as if "NaN" instead.
{
    is NaN cmp NaN, Same, "NaN cmp NaN";
    is NaN cmp 0, More, "NaN cmp 0";
    is 0 cmp NaN, Less, "0 cmp NaN";
    is NaN cmp Inf, More, "NaN cmp Inf";
    is Inf cmp NaN, Less, "Inf cmp NaN";
}

# ranges vs ranges and reals
{
    is (5..10)  cmp (5..10),   Same, "(5..10) cmp (5..10)";
    is (5..10)  cmp (5^..10),  Less, "(5..10) cmp (5^..10)";
    is (5..10)  cmp (5..^10),  More, "(5..10) cmp (5..^10)";
    is (5^..10) cmp (5..10),   More, "(5^..10) cmp (5..10)";
    is (5..^10) cmp (5..10),   Less, "(5..^10) cmp (5..10)";
    is (5..^11) cmp (5..10),   More, "(5..^11) cmp (5..10)";
    is  5       cmp (5..10),   Less, "5 cmp (5..10)";
    is  6       cmp (5..10),   More, "6 cmp (5..10)";
    is  5.1     cmp (5^..10),  More, "5.1 cmp (5..10)";
    is (5..10)  cmp (5..10.1), Less, "(5..10) cmp (5..10.1)";
    is (5..10)  cmp (5..9.9),  More, "(5..10) cmp (5..9.9)";
}

# ranges vs lists
{
    is (5..10) cmp (5,6,7,8,9,10), Same, "(5..10) cmp (5,6,7,8,9,10),";
    is (5^..10) cmp (6,7,8,9,10), Same, "(5^..10) cmp (6,7,8,9,10),";
    is (5..^10) cmp (5,6,7,8,9), Same, "(5..^10) cmp (5,6,7,8,9),";
    is (5^..^10) cmp (6,7,8,9), Same, "(5^..^10) cmp (6,7,8,9),";
    is (5^..10) cmp (5,6,7,8,9,10), More, "(5^..10) cmp (5,6,7,8,9,10),";
    is (5..^10) cmp (5,6,7,8,9,10), Less, "(5..^10) cmp (5,6,7,8,9,10),";
}


{
    is () cmp (0,), Less, 'empty list on the left';
    is (0,) cmp (), More, 'empty list on the right';
    is () cmp (), Same, 'empty lists on both sides';
}

for Rat, FatRat -> \RatT {
    my $nan  = RatT.new:  0, 0;
    my $inf  = RatT.new:  1, 0;
    my $ninf = RatT.new: -1, 0;

    subtest "$nan.raku() (behaves like NaN)" => {
        plan 10;
        is-deeply $nan cmp  NaN, Same, "$nan.raku() cmp NaN";
        is-deeply $nan cmp   42, More, "$nan.raku() cmp 42";
        is-deeply $nan cmp  -42, More, "$nan.raku() cmp -42";
        is-deeply $nan cmp  Inf, More, "$nan.raku() cmp Inf";
        is-deeply $nan cmp -Inf, More, "$nan.raku() cmp -Inf";

        is-deeply  NaN cmp $nan, Same, " NaN cmp $nan.raku()";
        is-deeply   42 cmp $nan, Less, "  42 cmp $nan.raku()";
        is-deeply  -42 cmp $nan, Less, " -42 cmp $nan.raku()";
        is-deeply  Inf cmp $nan, Less, " Inf cmp $nan.raku()";
        is-deeply -Inf cmp $nan, Less, "-Inf cmp $nan.raku()";
    }

    subtest "$ninf.raku() (behaves like -Inf)" => {
        plan 10;
        is-deeply $ninf cmp  NaN, Less, "$ninf.raku() cmp NaN";
        is-deeply $ninf cmp   42, Less, "$ninf.raku() cmp 42";
        is-deeply $ninf cmp  -42, Less, "$ninf.raku() cmp -42";
        is-deeply $ninf cmp  Inf, Less, "$ninf.raku() cmp Inf";
        is-deeply $ninf cmp -Inf, Same, "$ninf.raku() cmp -Inf";

        is-deeply  NaN cmp $ninf, More, " NaN cmp $ninf.raku()";
        is-deeply   42 cmp $ninf, More, "  42 cmp $ninf.raku()";
        is-deeply  -42 cmp $ninf, More, " -42 cmp $ninf.raku()";
        is-deeply  Inf cmp $ninf, More, " Inf cmp $ninf.raku()";
        is-deeply -Inf cmp $ninf, Same, "-Inf cmp $ninf.raku()";
    }

    subtest "$inf.raku() Rat (behaves like Inf)" => {
        plan 10;
        is-deeply $inf cmp  NaN, Less, "$inf.raku() cmp NaN";
        is-deeply $inf cmp   42, More, "$inf.raku() cmp 42";
        is-deeply $inf cmp  -42, More, "$inf.raku() cmp -42";
        is-deeply $inf cmp  Inf, Same, "$inf.raku() cmp Inf";
        is-deeply $inf cmp -Inf, More, "$inf.raku() cmp -Inf";

        is-deeply  NaN cmp $inf, More, " NaN cmp $inf.raku()";
        is-deeply   42 cmp $inf, Less, "  42 cmp $inf.raku()";
        is-deeply  -42 cmp $inf, Less, " -42 cmp $inf.raku()";
        is-deeply  Inf cmp $inf, Same, " Inf cmp $inf.raku()";
        is-deeply -Inf cmp $inf, Less, "-Inf cmp $inf.raku()";
    }
}

subtest 'no precision loss in infix:<cmp> with Rational and Ints' => {
    plan 8;
    constant  r4 = 4.999999999999999999;
    constant  r5 = 5.0;
    constant fr4 = r4.FatRat;
    constant fr5 = r5.FatRat;

    is-deeply  r4 cmp   5, Less,    'Rat cmp Int';
    is-deeply   5 cmp  r4, More,    'Int cmp Rat';
    is-deeply  r5 cmp  r4, More,    'Rat cmp Rat';

    is-deeply fr4 cmp   5, Less, 'FatRat cmp Int';
    is-deeply   5 cmp fr4, More, 'Int    cmp FatRat';
    is-deeply fr5 cmp fr4, More, 'FatRat cmp FatRat';

    is-deeply fr4 cmp  r5, Less, 'FatRat cmp Rat';
    is-deeply  r5 cmp fr4, More, 'Rat    cmp FatRat';
}

subtest 'lazy array comparisons' => {
    plan 11;
    is-deeply [lazy 1, 2   ]  cmp [lazy 1, 2, 3], Less, 'shorter array';
    is-deeply [lazy 1, 2, 3]  cmp [lazy 1, 2   ], More, 'longer array';
    is-deeply [lazy 1, 2   ]  cmp [lazy 1, 2   ], Same, 'identical; same length';

    is-deeply [lazy -1, 2   ] cmp [lazy 1, 2   ], Less, 'Less; differ at pos 0';
    is-deeply [lazy  2, 2   ] cmp [lazy 1, 2   ], More, 'More; differ at pos 0';
    is-deeply [lazy  1, 1   ] cmp [lazy 1, 2   ], Less, 'Less; differ at pos 1';
    is-deeply [lazy  1, 3   ] cmp [lazy 1, 2   ], More, 'More; differ at pos 1';
    is-deeply [lazy  1, 1, 3] cmp [lazy 1, 2   ], Less, 'Less; differ at pos 1; ignore lengths';
    is-deeply [lazy  1, 3   ] cmp [lazy 1, 2, 3], More, 'More; differ at pos 1; ignore lengths';

    is-deeply [lazy 1, 1, 3]  cmp [lazy 1, 2, 1], Less, 'Less; differ at pos 1; ignore later elems';
    is-deeply [lazy 1, 3, 1]  cmp [lazy 1, 2, 3], More, 'More; differ at pos 1; ignore later elems';
}

# vim: expandtab shiftwidth=4
