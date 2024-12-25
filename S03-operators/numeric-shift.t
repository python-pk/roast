use Test;

plan 38;

sub check ($a, $b, $ls, $rs) is test-assertion {
    is $a * 2**$b, $ls, "expected value for shl $a by $b is sane";

    # assume two's complement semantics for negative $a
    is floor($a / 2**$b), $rs, "expected value for shr $a by $b is sane";

    is $a +<  $b, $ls, "got expected value for shl $a by $b";

    is $a +< -$b, $rs, "got expected value for shl $a by -$b";

    is $a +>  $b, $rs, "got expected value for shr $a by $b";

    is $a +> -$b, $ls, "got expected value for shr $a by -$b";
}

check 15, 3, 120, 1;
check 16, 3, 128, 2;
check 17, 3, 136, 2;

check -15, 3, -120, -2;
check -16, 3, -128, -2;
check -17, 3, -136, -3;


my int $t = 10;
is (2 * $t) + ($t +> 2), 22;


is -123 +> 32, -1, "too large right shift for Int should be -1";

# vim: expandtab shiftwidth=4
