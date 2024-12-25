use Test;

plan 320;

=begin description

This test tests the C<pick> builtin. See S32::Containers#pick.

Previous discussions about pick.

L<"http://groups.google.com/group/perl.perl6.language/tree/browse_frm/thread/24e369fba3ed626e/4e893cad1016ed94?rnum=1&_done=%2Fgroup%2Fperl.perl6.language%2Fbrowse_frm%2Fthread%2F24e369fba3ed626e%2F6e6a2aad1dcc879d%3F#doc_2ed48e2376511fe3">

=end description

# L<S32::Containers/List/=item pick>

my @array = <a b c d>;
ok ?(@array.pick eq any <a b c d>), "pick works on arrays";
ok ().pick === Nil, '.pick on the empty list is Nil';

my @arr = <z z z>;

ok ~(@arr.pick(2)) eq 'z z',   'method pick with $num < +@values';
ok ~(@arr.pick(4)) eq 'z z z', 'method pick with $num > +@values';

is pick(2, @arr), <z z>, 'sub pick with $num < +@values, implicit no-replace';
is pick(4, @arr), <z z z>, 'sub pick with $num > +@values';

is (<a b c d>.pick(*).sort).Str, 'a b c d', 'pick(*) returns all the items in the array (but maybe not in order)';
is (<a b c d>.pick(Inf).sort).Str, 'a b c d', 'pick(Inf) returns all the items in the array (but maybe not in order)';

{
  my @items = <1 2 3 4>;
  my @shuffled_items_10;
  push @shuffled_items_10, @items.pick(*) for ^10;
  isnt(@shuffled_items_10, @items xx 10,
       'pick(*) returned the items of the array in a random order');
}

{
    # Test that List.pick doesn't flatten array refs
    ok ?([[1, 2], [3, 4]].pick.join('|') eq any('1|2', '3|4')), '[[1,2],[3,4]].pick does not flatten';
    ok ?(~([[1, 2], [3, 4]].pick(*)) eq '1 2 3 4' | '3 4 1 2'), '[[1,2],[3,4]].pick(*) does not flatten';
}

{
    ok <5 5>.pick() == 5,
       '.pick() returns something can be used as single scalar';
}

{
    my @a = 1..100;
    my @b = pick(*, @a);
    is @b.elems, 100, "pick(*, @a) returns the correct number of elements";
    is ~@b.sort, ~(1..100), "pick(*, @a) returns the correct elements";
    is ~@b.grep(Int).elems, 100, "pick(*, @a) returns Ints (if @a is Ints)";
}

{
    my @a = 1..100;

    isa-ok @a.pick, Int, "picking a single element from an array of Ints produces an Int";
    ok @a.pick ~~ 1..100, "picking a single element from an array of Ints produces one of them";

    isa-ok @a.pick(1), Seq, "picking 1 from an array of Ints produces a Seq";
    ok @a.pick(1)[0] ~~ 1..100, "picking 1 from an array of Ints produces one of them";

    my @c = @a.pick(2);
    isa-ok @c[0], Int, "picking 2 from an array of Ints produces an Int...";
    isa-ok @c[1], Int, "... and an Int";
    ok (@c[0] ~~ 1..100) && (@c[1] ~~ 1..100), "picking 2 from an array of Ints produces two of them";
    ok @c[0] != @c[1], "picking 2 from an array of Ints produces two distinct results";

    is @a.pick("25").elems, 25, ".pick works Str arguments";
    is pick("25", @a).elems, 25, "pick works Str arguments";
}

# enums + pick
{
    is Bool.pick(*).grep(Bool).elems, 2, 'Bool.pick works';

    enum A <b c d>;
    is A.pick(*).grep(A).elems, 3, 'RandomEnum.pick works';
}

# ranges + pick
{
    my %seen;
    %seen{$_} = 1 for (1..100).pick(50);
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems';
    ok (so 1 <= all(%seen.keys) <= 100), '... and all the elements are in range';
}

{
    my %seen;
    %seen{$_} = 1 for (1..300).pick(50);
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems';
    ok (so 1 <= all(%seen.keys) <= 300), '... and all the elements are in range';
}

{
    my %seen;
    %seen{$_} = 1 for (1..50).pick(*);
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems';
    ok (so 1 <= all(%seen.keys) <= 50), '... and all the elements are in range';
}

{
    ok 1 <= (1..50).pick <= 50, 'Range.pick() works';
}

{
    my %seen;
    %seen{$_} = 1 for (1..1_000_000).pick(50);
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems';
    ok (so 1 <= all(%seen.keys) <= 1_000_000), '... and all the elements are in range';
}

{
    my %seen;
    %seen{$_} = 1 for (1^..1_000_000).pick(50);
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems (lower exclusive)';
    ok (so 1 < all(%seen.keys) <= 1_000_000), '... and all the elements are in range';
}

{
    my %seen;
    %seen{$_} = 1 for (1..^1_000_000).pick(50);
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems (upper exclusive)';
    ok (so 1 <= all(%seen.keys) < 1_000_000), '... and all the elements are in range';
}

{
    my %seen;
    %seen{$_} = 1 for (1^..^1_000_000).pick(50);
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems (both exclusive)';
    ok (so 1 < all(%seen.keys) < 1_000_000), '... and all the elements are in range';
}

{
    my %seen;
    try { %seen{$_} = 1 for (1 .. (10**1000) ).pick(50); }
    is %seen.keys.elems, 50, 'Range.pick produces uniq elems in huge range';
    ok (so 1 <= all(%seen.keys) <= 10**1000), '... and all the elements are in range';
}

is (1..^2).pick, 1, 'pick on 1-elem range';

ok ('a'..'z').pick ~~ /\w/, 'Range.pick on non-Int range';


nok ([==] (^2**64).roll(10).map(* +& 15)), 'Range.pick has enough entropy';

# sanity on Enums
{
    is Order.pick, any(Less,Same,More), 'simple pick on Enum type works';
    is Order.pick(1), any(Less,Same,More), 'one pick on Enum type works';
    is sort(Order.pick(*)), (Less,Same,More), 'all pick on Enum type works';
    is sort(Order.pick(4)), (Less,Same,More), 'too many pick on Enum type works';
    is Order.pick(0), (), 'zero pick on Enum type works';

    is Less.pick, Less, 'simple pick on Enum is sane';
    is Same.pick(1), Same, 'one pick on Enum is sane';
    is More.pick(*), More, 'all pick on Enum is sane';
    is Less.pick(4), Less, 'too many pick on Enum is sane';
    is More.pick(0), (), 'zero pick on Enum is sane';
}


{
    my $v = 2;
    for (1..259) {
        is ([+|] ((^$v).pick for ^200)), $v - 1, "$v.base(16) .pick hits all bits"; $v +<= 1;
    }
}


subtest '.pick on object Hashes' => {
    plan 2;
    my %obj{Any} = question => 42;
    is-deeply %obj.pick, %obj.pairs.pick, 'single-Pair Hash';

    my %h := :{ :42foo, (True) => False, 42e0 => ½ };
    is-deeply gather { %h.pick.take xx 300 }.unique.sort,
        (:42foo, (True) => False, 42e0 => ½).sort, 'many Pairs';
}

{
    my @a  = <a b c d e>;
    my @aa = (|@a, |@a).sort;
    ok @a.pick(**).is-lazy, 'did .pick(**) give a lazy Seq';
    is-deeply [@a.pick(**)[ ^@a].sort],  @a, 'all with .pick(**)';
    is-deeply [@a.pick(**)[^@aa].sort], @aa, 'all with .pick(**) twice';
}

# vim: expandtab shiftwidth=4
