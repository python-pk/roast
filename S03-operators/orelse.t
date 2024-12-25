use Test;

plan 16;

is (1 orelse 2), 1, 'orelse basics';
is (1 orelse 2 orelse 3), 1, 'orelse chained';
is (Any orelse Int orelse 3), 3, 'orelse chained';
is (1 orelse 0), 1, 'definedness, not truthness';
ok 1 === (1 orelse Any), 'first defined value (1)';
ok 2 === (Any orelse 2), 'first defined value (2)';
my $tracker = 0;
ok (1 orelse ($tracker = 1)), 'sanity';
nok $tracker, 'orelse thunks';

{
    try { die "oh noes!" } orelse
        ok(~$! eq "oh noes!", 'orelse sets $! after an exception');
}

{
    Failure.new("oh noes!") orelse -> $foo {
        ok $foo.gist.match('oh noes!'),
          'orelse passes lhs to one argument after an exception';
    };
}


is-deeply (Str andthen .uc orelse "foo"), 'foo',
    'orelse can be chained after andthen';


is-deeply (Nil andthen 'foo' orelse Nil orelse 'bar'), 'bar',
    'chain: andthen + orelse + orelse';

# https://irclog.perlgeek.de/perl6-dev/2017-04-29#i_14507232
cmp-ok infix:<orelse>( %(:42a, :72b) ), 'eqv', :42a.Pair | :72b.Pair,
    '1-arg Hash is broken down into Pairs, like +@foo slurpy does it';

is-deeply infix:<orelse>([Int, 42]), (Int orelse 42),
    '1-arg Iterable gets flattened (like +@foo slurpy)';

{
    my $calls = 0;
    my class Foo { method defined { $calls++; False } };
    sub meow { $^a };
    Foo orelse meow $_;
    is-deeply $calls, 1, 'orelse does not call .defined on last arg (1)';

    $calls = 0;
    Foo orelse .&meow;
    is-deeply $calls, 1, 'orelse does not call .defined on last arg (1)';
}

# vim: expandtab shiftwidth=4
