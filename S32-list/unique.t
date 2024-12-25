use Test;

plan 40;

=begin description

This test tests the C<unique> builtin.

=end description

{
    my @array = <a b b c d e b b b b f b>;
    is-deeply @array.unique.List,  <a b c d e f>,
      "method form of unique works";
    is-deeply unique(@array).List, <a b c d e f>,
      "subroutine form of unique works";
    is-deeply @array .= unique, [<a b c d e f>],
      "inplace form of unique works";
    is-deeply @array, [<a b c d e f>],
      "final result of in place";
} #4

{
    is-deeply unique('a', 'b', 'b', 'c', 'd', 'e', 'b', 'b', 'b', 'b', 'f', 'b').List,
      <a b c d e f>.list.item,
      'slurpy subroutine form of unique works';
} #1

# With a userspecified criterion
{
    my @array = <a b d A c b>;
    # Semantics w/o junctions
    is ~@array.unique( with => { lc($^a) eq lc($^b) } ),  "a b d c",
      "method form of unique with own comparator works";
    is ~unique(@array, with => { lc($^a) eq lc($^b) }), "a b d c",
      "subroutine form of unique with own comparator works";

    # Semantics w/ junctions
    is EVAL('~@array.unique(with => { lc($^a) eq lc($^b) }).values.sort'), "a b c d", 'sorting the result';
} #3

{
    is 42.unique, 42,    ".unique can work on scalars";
    is (42,).unique, 42, ".unique can work on one-elem arrays";
} #2

# http://irclog.perlgeek.de/perl6/2009-10-31#i_1669037
{
    my $range = [1..4];
    my @array = $range, $range.WHICH;
    is @array.elems, 2,      ".unique does not use naive WHICH (1)";
    is @array.unique.elems, 2, ".unique does not use naive WHICH (2)";
} #2


{
    my class A { method Str { '' } };
    is (A.new, A.new).unique.elems, 2, 'unique has === semantics';
} #1


{
    my @list = 1, "1";
    my @unique = unique(@list);
    is @unique, @list, "unique has === semantics";
} #1


{
    my $a = <a b c b d>;
    $a .= unique;
    is-deeply( $a.List, <a b c d>, '.= unique in sink context works on $a' );
    my @a = <a b c b d>;
    @a .= unique;
    is-deeply( @a, [<a b c d>], '.= unique in sink context works on @a' );
} #2

{
    my @array = <a b bb c d e b bbbb b b f b>;
    my $as    = *.substr: 0,1;
    is-deeply @array.unique(:$as).List,  <a b c d e f>,
      "method form of unique with :as works";
    is-deeply unique(@array,:$as).List, <a b c d e f>,
      "subroutine form of unique with :as works";
    is-deeply @array .= unique(:$as), [<a b c d e f>],
      "inplace form of unique with :as works";
    is-deeply @array, [<a b c d e f>],
      "final result with :as in place";
} #4

{
    my @array = <a b bb c d e b bbbb b b f b>;
    my $with  = { substr($^a,0,1) eq substr($^b,0,1) }
    is-deeply @array.unique(:$with).List,  <a b c d e f>,
      "method form of unique with :with works";
    is-deeply unique(@array,:$with).List, <a b c d e f>,
      "subroutine form of unique with :with works";
    is-deeply @array .= unique(:$with), [<a b c d e f>],
      "inplace form of unique with :with works";
    is-deeply @array, [<a b c d e f>],
      "final result with :with in place";
} #4

{
    my @array = <a b bb c d e b bbbb b b f b>;
    my $as    = *.substr(0,1).ord;
    my $with  = &[==];
    is-deeply @array.unique(:$as).List,  <a b c d e f>,
      "method form of unique with :as works";
    is-deeply unique(@array,:$as).List, <a b c d e f>,
      "subroutine form of unique with :as works";
    is-deeply @array .= unique(:$as), [<a b c d e f>],
      "inplace form of unique with :as works";
    is-deeply @array, [<a b c d e f>],
      "final result with :as in place";
} #4

{
    my @array = ({:a<1>}, {:b<1>}, {:a<1>});
    my $with  = &[eqv];
    is-deeply @array.unique(:$with).List,  ({:a<1>}, {:b<1>}),
      "method form of unique with [eqv] and objects works";
    is-deeply unique(@array,:$with).List, ({:a<1>}, {:b<1>}),
      "subroutine form of unique with [eqv] and objects works";
    is-deeply @array .= unique(:$with), [{:a<1>}, {:b<1>}],
      "inplace form of unique with [eqv] and objects works";
    is-deeply @array, [{:a<1>}, {:b<1>}],
      "final result with [eqv] and objects in place";
} #4

# :with and :as
{
    my @array = ({:a<1>}, {:b<1>}, {:A<1>});
    my $as = &lc;
    my $with = &[eqv];
    is-deeply @array.unique(:$as, :$with).List,  ({:a<1>}, {:b<1>}),
      "method form of unique with :as and :with and objects works";
    is-deeply unique(@array, :$as, :$with).List, ({:a<1>}, {:b<1>}),
      "subroutine form of unique with :as and :with and objects works";
    is-deeply @array .= unique(:$as, :$with), [{:a<1>}, {:b<1>}],
      "inplace form of unique with :as and :with and objects works";
    is-deeply @array, [{:a<1>}, {:b<1>}],
      "final result with :as and :with and objects in place";
} #4


{
    my %a;
    %a<foo> = <a b c>;
    %a<foo>.=unique;
    is-deeply %a<foo>.List, <a b c>,
      "\%a<foo> not clobbered by .=unique";
} # 1

is ((1,2,3),(1,2),(1,2)).unique(:with({$^a eqv $^b})), "1 2 3 1 2", ".unique doesn't flatten";


eval-lives-ok ｢Scalar.unique｣, 'no SEGV with Scalar.unique';


{
    is-deeply
      [[1], ['1'], [4]].unique(:as(*.map(&[~])), :with(&[eqv])),
      ([1], [4]),
      'Seq as the result of an :as caches the Seq';
}

# vim: expandtab shiftwidth=4
