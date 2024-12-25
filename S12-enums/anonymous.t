use Test;
plan 10;

# Tests for anonymous enumerations.

# L<S12/Anonymous Enumerations/An anonymous enum just makes sure each string turns into a pair>

my $e = enum < ook! ook. ook? >;
is $e.keys.elems, 3, 'anonymous enum created correct sized hash';
is $e<ook!>,      0, 'anonymous enum created correctly';
is $e<ook.>,      1, 'anonymous enum created correctly';
is $e<ook?>,      2, 'anonymous enum created correctly';
isa-ok $e, Map, 'anonymous enum returns an Map';

my %e1 = enum <foo>;
is %e1.keys.elems, 1, 'single-value anonymous enum created correct sized hash';
is %e1<foo>,       0, 'single-value anonymous enum created correctly';


{
    anon enum <un>;
    is +un, 0, 'anon enum <un> is identical to enum :: <un>';

    my %e = enum :: < foo bar baz >;
    is +%e<bar>, 1, 'my %e = enum :: works';
    is +baz, 2, 'my %e = enum :: works';
}

# vim: expandtab shiftwidth=4
