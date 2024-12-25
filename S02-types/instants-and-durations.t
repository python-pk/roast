use Test;

plan 36;

# L<S02/Immutable types/'term now'>

{
    my $i = now;
    isa-ok $i, Instant, 'now returns an Instant';
    isa-ok 5 + $i, Instant, 'Int + Instant ~~ Instant';
    isa-ok $i - 1/3, Instant, 'Instant - Rat ~~ Instant';
    my $later = now;
    is-approx $i, $later, 'now and just now are close';
    ok $later >= $i, 'time does not move backwards';
}

isa-ok EVAL('now +300'), Instant, 'now is a term, not a function';

# L<S02/Immutable types/'must be explicitly created via any of'>
throws-like { Instant.new(123) }, X::Cannot::New, 'Instant.new is illegal';

# L<S02/Immutable types/'you may not add two instants'>

{
    my $t0 = Instant.from-posix(1295002122);

    my $t1 = Instant.from-posix(1303059935);

    my $d = $t1 - $t0;

    ok $t0 < $t1, 'later Instants are greater';
    dies-ok { $t0 + $t1 }, 'Instant + Instant is illegal';
    isa-ok $d, Duration, 'Instant - Instant ~~ Duration';
    ok $d ~~ Real, 'Durations are Real';
    isa-ok $d + $t0, Instant, 'Instant + Duration ~~ Instant';
    isa-ok $d + $t0, Instant, 'Duration + Instant ~~ Instant';
    isa-ok $t0 - $d, Instant, 'Instant - Duration ~~ Instant';
    is $t0 + ($t1 - $t0), $t1, 'Instant A + (Instant B - Instant A) == Instant B';
}

for -2**63, -400.2, -33/7, -1, 0, 1, 33/7, 400.2, 2**32 -> $e {
    is-deeply .raku.EVAL, $_, "Instant round trips properly .($e, False)"
        with Instant.from-posix: $e, False;
    is-deeply .raku.EVAL, $_, "Instant round trips properly .($e, True)"
        with Instant.from-posix: $e, True;
}


isa-ok now.Instant, Instant, "Instant.Instant";
ok (Instant.Instant ~~ Instant:U), "Instant.Instant (undefined)";
ok (now.Instant ~~ Instant:D), "Instant.Instant (defined)";

# See S32-temporal/DateTime-Instant-Duration.t for more.

# vim: expandtab shiftwidth=4
