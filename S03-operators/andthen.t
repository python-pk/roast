use Test;
plan 14;

is (1 andthen 2), 2, 'andthen basics';
is (1 andthen 2 andthen 3), 3, 'andthen chained';
is (0 andthen 1), 1, 'definedness, not truthness';
ok Any === (1 andthen Any), 'first undefined value (1)';
ok Empty === (Any andthen 2), 'first undefined value (2)';
my $tracker = 0;
nok (Int andthen ($tracker = 1)), 'sanity';
nok $tracker, 'andthen thunks';

my $ = 'some arg' andthen -> $x { is $x, 'some arg', 'andthen passes on arguments' };


is (S/a/A/ andthen S/b/B/ given "ab"), "AB", 'andthen with two S///';

subtest 'Empty in args to andthen/with does not disappear' => {
    plan 3;
    my $r := do 42 with Empty;
    is-deeply $r,                         Empty, 'postfix `with`';
    is-deeply infix:<andthen>(Empty, 42), Empty, 'sub call';
    is-deeply (Empty andthen 42),         Empty, 'op';
}

# https://irclog.perlgeek.de/perl6-dev/2017-04-29#i_14507232
cmp-ok infix:<andthen>( %(:42a, :72b) ), 'eqv', :42a.Pair | :72b.Pair,
    '1-arg Hash is broken down into Pairs, like +@foo slurpy does it';

is-deeply infix:<andthen>([42, 70]), (42 andthen 70),
    '1-arg Iterable gets flattened (like +@foo slurpy)';

{
    my $calls = 0;
    my class Foo { method defined { $calls++; True } };
    sub meow { $^a };
    Foo andthen meow $_;
    is-deeply $calls, 1, 'andthen does not call .defined on last arg (1)';

    $calls = 0;
    Foo andthen .&meow;
    is-deeply $calls, 1, 'andthen does not call .defined on last arg (2)';
}

# vim: expandtab shiftwidth=4
