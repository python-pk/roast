use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

=begin description

This test tests the C<reduce> builtin.

Reference:
L<"http://groups.google.com/groups?selm=420DB295.3000902%40conway.org">

=end description

plan 24;

# L<S32::Containers/List/=item reduce>

{
  my @array = <5 -3 7 0 1 -9>;
  my $sum   = 5 + -3 + 7 + 0 + 1 + -9; # laziness :)


  is((reduce { $^a + $^b }, 0, |@array), $sum, "basic reduce works (1)");
}

# Reduce with n-ary functions
{
  my @array  = <1 2 3 4 5 6 7 8 9>;
  my $result = (((1 + 2 * 3) + 4 * 5) + 6 * 7) + 8 * 9;

  is (@array.reduce: { $^a + $^b * $^c }), $result, "n-ary reduce() works";
}

# Reduce with n-ary operator
{
  my @array  = <1 2 3 4 5 6 7 8 9>;
  my $result = (((1 + 2 * 3) + 4 * 5) + 6 * 7) + 8 * 9;

  sub infix:<leftly> { $^a + $^b * $^c }

  is ([leftly] @array), $result, "n-ary reduce() works";
}

# Reduce with right associative n-ary functions
{
  my @array  = <1 2 3 4 5 6 7 8 9>;
  my $result = 1 + 2 * (3 + 4 * (5 + 6 * (7 + 8 * 9)));
  sub rightly is assoc<right> { $^a + $^b * $^c }

  is (@array.reduce: &rightly).gist, $result.gist, "right assoc n-ary reduce() works";
}

{
  my @array  = <1 2 3 4 5 6 7 8 9>;
  my $result = 1 + 2 * (3 + 4 * (5 + 6 * (7 + 8 * 9)));
  sub infix:<rightly> is assoc<right> { $^a + $^b * $^c }

  is ([rightly] @array).gist, $result.gist, "right assoc n-ary reduce() works";
}


{
  is( 42.reduce( {$^a+$^b} ), 42,  "method form of reduce works on numbers");
  is( 'str'.reduce( {$^a+$^b} ), 'str', "method form of reduce works on strings");
  is ((42,).reduce: { $^a + $^b }), 42,      "method form of reduce should work on arrays";
}

{
  my $hash = {a => {b => {c => 42}}};
  my @reftypes;
  sub foo (Hash $hash, Str $key) {
    push @reftypes, $hash ~~ Hash;
    $hash.{$key};
  }
  is((reduce(&foo, flat $hash, <a b c>)), 42, 'reduce(&foo) (foo ~~ .{}) works three levels deep');
  ok ([&&] @reftypes), "All the types were hashes";
}

is( (1).list.reduce({$^a * $^b}), 1, "Reduce of one element list produces correct result");
is-deeply(reduce(&infix:<+>, 72), 72, "reduce with one item returns that item");

eval-lives-ok( 'reduce -> $a, $b, $c? { $a + $b * ($c//1) }, 1, 2', 'Use proper arity calculation');

{
    is( ((1..10).list.reduce: &infix:<+>), 55, '.reduce: &infix:<+> works' );
    is( ((1..4).list.reduce: &infix:<*>), 24, '.reduce: &infix:<*> works' );
}


{
    multi a (Str $a, Str $b) { [+$a, +$b] };
    multi a (Array $a,$b where "+") { [+] @($a) };  #OK not used
    is ("1", "2", "+").reduce(&a), 3, 'reduce and multi subs';
}

{
    doesn't-warn {
        (^10).reduce(sub f ($a, $b) is assoc<right> {"Tuple $a ($b)"})
    }, 'no warnings when setting associativity on the reduce &with';
}


{
    sub infix:<eog> ( $a,  $b ) is assoc<chain> is pure {
        so $a == $b+1
    }
    ok (5,4,3,2,1).reduce(&infix:<eog>),
        'Reduce method respects chain associativity';
}


{
    is-deeply (True, True, True, True).permutations».reduce(&infix:<&&>).reduce(&infix:<&&>),
    True,
    '.reduce with infix:<&&> returns True';

    is-deeply
      (True, True, True, False).permutations».reduce(&infix:<&&>).reduce(&infix:<&&>),
      False,
      '.reduce with infix:<&&> returns False';

    my &falseish = { False };
    my &trueish = { True };
    is-deeply (True, True, True, &falseish).permutations».reduce(&infix:<&&>).reduce(&infix:<&&>),
    False,
    '.reduce with infix:<&&> and callable returns False';

    is-deeply (True, True, True, &trueish).permutations».reduce(&infix:<&&>).reduce(&infix:<&&>),
    True,
    '.reduce with infix:<&&> and callable returns True';
}


{
    my %hash;
    my @path = <a b c>;
    my $slot := (%hash, |@path).reduce: -> $h is raw, $k { $h{$k} };
    $slot = 42;
    is-deeply %hash, %(:a(%(:b(%(:c(42)))))), "reduce returns raw containers when specified"
}


{
    is-deeply (True, True, False).reduce(&infix:<&&>), False,
      'reduce handled && correctly';
}

# vim: expandtab shiftwidth=4
