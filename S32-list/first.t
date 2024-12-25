use Test;

# L<S32::Containers/"List"/"=item first">

plan 31;

my @list = (1 ... 10);

{
    my $result = first { ($^a % 2) }, |@list;
    ok($result ~~ Int, "first() returns an Int");
    is($result, 1, "returned value by first() is correct");
}

{
    my $result = first { ($^a % 2) }, 1, 2, 3, 4, 5, 6, 7, 8;
    ok($result ~~ Int, "first() returns an Int");
    is($result, 1, "returned value by first() is correct");
}


{
    my $result = @list.first( { ($^a == 4)});
    ok($result ~~ Int, "method form of first returns an Int");
    is($result, 4, "method form of first returns the expected item");
}

#?rakudo skip "adverbial block"
{
    my $result = @list.first():{ ($^a == 4) };
    ok($result ~~ Int, "first():<block> returns an Int");
    is($result, 4, "first() returned the expected value");
}

{
    nok(@list.first( { ($^a == 11) }).defined, 'first returns undefined unsuccessful match');
}

{
    my $count = 0;
    my $matcher = sub (Int $x) { $count++; $x % 2 };
    is(@list.first($matcher), 1, 'first() search for odd elements successful');
    is($count, 1, 'Matching closure in first() is only executed once');
}

{
    is(@list.first(4..6), 4, "method form of first with range returns the expected item");
    is(@list.first(4^..6), 5, "method form of first with range returns the expected item");
}

{
    my @fancy_list = (1, 2, "Hello", 3/4, 4.Num);
    is(@fancy_list.first(Str), "Hello", "Looking up first by type Str works");
    is(@fancy_list.first(Int), 1, "Looking up first by type Int works");
    is(@fancy_list.first(Rat), 3/4, "Looking up first by type Rat works");
}

{
    my @fancy_list = <Philosopher Goblet Prince>;
    is(@fancy_list.first(/o/), "Philosopher", "Looking up first by regex /o/");
    is(@fancy_list.first(/ob/), "Goblet", "Looking up first by regex /ob/");
    is(@fancy_list.first(/l.*o/), "Philosopher", "Looking up first by regex /l.*o/");
}

{
    is <a b c b a>.first('c' | 'b').join('|'),
        'b', '.first also takes a junction as matcher';

    is (first 'c'| 'b', <a b c b a>).join('|'),
        'b', '.first also takes a junction as matcher (sub form)';
}


{
    isa-ok (first * > 20, @list), Nil, "first() returns Nil when no values match";
    isa-ok @list.first(* < 0 ), Nil, ".first returns Nil when no values match"
}

# Bool handling
{
    throws-like { first $_ == 1, 1,2,3 }, X::Match::Bool;
    throws-like { (1,2,3).first: $_== 1 }, X::Match::Bool;
    is first( Bool,True,False,Int ), True, 'can we match on Bool as type';
    is (True,False,Int).first(Bool), True, 'can we match on Bool as type';
}


{
    my @a = 1..10;
    @a.first(* %% 2).++;
    is @a, <1 3 3 4 5 6 7 8 9 10>,
        'first is rw-like, can chain it to modify one element of grepped list/array';
}

subtest 'Junctions work correctly as a matcher in .first' => {
    plan 2;
    subtest 'method form' => {
        plan 6;
        is <a b c d e>.first(<c e>.any),    'c', 'matcher only (1)';
        is <a b c d e>.first(<e d>.any),    'd', 'matcher only (2)';
        is <a b c d e>.first(<c e>.any, :k), 2,  'with :k (1)';
        is <a b c d e>.first(<b d>.any, :k), 1,  'with :k (2)';
        is-deeply <a b c d e>.first(<c e>.any, :kv), (2, 'c'), 'with :kv (1)';
        is-deeply <a b c d e>.first(<a d>.any, :kv), (0, 'a'), 'with :kv (2)';
    }
    subtest 'sub form' => {
        plan 6;
        is first(<c e>.any, <a b c d e>),    'c', 'matcher only (1)';
        is first(<e d>.any, <a b c d e>),    'd', 'matcher only (2)';
        is first(<c e>.any, :k, <a b c d e>), 2,  'with :k (1)';
        is first(<b d>.any, :k, <a b c d e>), 1,  'with :k (2)';
        is-deeply first(<c e>.any, :kv, <a b c d e>), (2, 'c'), 'with :kv (1)';
        is-deeply first(<a d>.any, :kv, <a b c d e>), (0, 'a'), 'with :kv (2)';
    }
}

# https://irclog.perlgeek.de/perl6/2016-12-08#i_13705826
subtest '.first works on correctly when called on Numerics' => {
    plan 12;
    is-deeply 3.first,               3,      'no args';
    is-deeply 3.first(/3/),          3,      'Regex matcher';
    is-deeply 3.first(2|3),          3,      'Junction matcher';
    is-deeply 3.first(3, :k),        0,      ':k';
    is-deeply 3.first(3, :p),        0 => 3, ':p';
    is-deeply 3.first(3, :kv),       (0, 3), ':kv';

    is-deeply 3.first(:end),         3,      ':end, no args';
    is-deeply 3.first(:end, /3/),    3,      ':end, Regex matcher';
    is-deeply 3.first(:end, 2|3),    3,      ':end, Junction matcher';
    is-deeply 3.first(:end, 3, :k),  0,      ':end, :k';
    is-deeply 3.first(:end, 3, :p),  0 => 3, ':end, :p';
    is-deeply 3.first(:end, 3, :kv), (0, 3), ':end, :kv';
}

# https://irclog.perlgeek.de/perl6-dev/2016-12-08#i_13706306
subtest 'adverbs work on .first without matcher' => {
    plan 14;
    constant $l = <a b c>;

    is-deeply $l.first,      'a',      'no args';
    is-deeply $l.first(:k ), 0,        ':k';
    is-deeply $l.first(:kv), (0, 'a'), ':kv';
    is-deeply $l.first(:p ), 0 => 'a', ':p';
    throws-like { $l.first(:k, :kv) }, X::Adverb, ':k + :kv throws';
    throws-like { $l.first(:k, :p ) }, X::Adverb, ':k + :p throws';
    throws-like { $l.first(:p, :kv) }, X::Adverb, ':P + :kv throws';

    is-deeply $l.first(:end     ), 'c',      ':end, no args';
    is-deeply $l.first(:end, :k ), 2,        ':end, :k';
    is-deeply $l.first(:end, :kv), (2, 'c'), ':end, :kv';
    is-deeply $l.first(:end, :p ), 2 => 'c', ':end, :p';
    throws-like { $l.first(:end, :k, :kv) }, X::Adverb, ':end, :k + :kv throws';
    throws-like { $l.first(:end, :k, :p ) }, X::Adverb, ':end, :k + :p throws';
    throws-like { $l.first(:end, :p, :kv) }, X::Adverb, ':end, :P + :kv throws';
}

#vim: ft=perl6

# vim: expandtab shiftwidth=4
