use Test;

plan 101;

=begin description

Testing the C<:ignorecase> regex modifier - more tests are always welcome

There are still a few things missing, like lower case <-> title case <-> upper
case tests

Note that the meaning of C<:i> does B<not> descend into subrules.

=end description

# tests for inline modifiers
# L<S05/Modifiers/and Unicode-level modifiers can be>

ok("abcDEFghi" ~~ m/abc (:i def) ghi/, 'Match');
ok(!( "abcDEFGHI" ~~ m/abc (:i def) ghi/ ), 'Mismatch');


#L<S05/Modifiers/"The :i">

my regex mixedcase { Hello };

# without :i

ok "Hello" ~~ m/<&mixedcase>/, "match mixed case (subrule)";
ok 'Hello' ~~ m/Hello/,       "match mixed case (direct)";

ok "hello" !~~ m/<&mixedcase>/, "do not match lowercase (subrule)";
ok "hello" !~~ m/Hello/,       "do not match lowercase (direct)";

ok "hello" !~~ m:i/<&mixedcase>/, "no match with :i if matched by subrule";
ok "hello"  ~~ m:i/Hello/,       "match with :i (direct)";

ok "hello" !~~ m:ignorecase/<&mixedcase>/,  "no match with :ignorecase + subrule";
ok "hello"  ~~ m:ignorecase/Hello/,        "match with :ignorecase (direct)";
ok('Δ' ~~ m:i/δ/, ':i with greek chars');

# The German ß (&szlig;) maps to uppercase SS:

#?rakudo.jvm 2 todo 'ignorecase and SS/&szlig; RT #121377'

ok('ß' ~~ m:i/SS/, "ß matches SS with :ignorecase");
ok('SS' ~~ m:i/ß/, "SS matches ß with :ignorecase");


ok('' ~~ m:i/''/, ':i can match empty string regex to the empty string');


ok('a' ~~ m/:i 'A'/, ':i descends into quotes');


{
    my $matcher = 'aA';
    nok 'aa' ~~ /   $matcher/, 'interpolation: no match without :i';
     ok 'aa' ~~ /:i $matcher/, 'interpolation: match with :i';
}

ok 'a' ~~ /:i A|B /, ':i and LTM sanity';
ok 'a' ~~ /:i < A B > /, ':i and quote words';

ok 'A4' ~~ /:i a[3|4|5] | b[3|4] /, 'alternation sanity';


{
    ok "BLAR" ~~ /:ignorecase [blar | blubb]/, ":ignorecase works with |";
    ok "BluBb" ~~ /:ignorecase [blar || blubb]/, ":ignorecase works with |";
}


{
    try EVAL '"ABC" ~~ /:iabc/';
    ok $!, "need whitespace after modifier";
}


{
    ok  "m" ~~ /:i <[M]>/, "ignore case of character classes";
    nok "m" ~~ /<[M]>/,    "ignore case of character classes";
    nok "n" ~~ /:i <[M]>/, "ignore case of character classes";
}


{
#?rakudo.jvm 1 todo "ligatures don't casefold on JVM"
ok 'ﬆ' ~~ /:i st/, ":i haystack 'ﬆ' needle 'st'";
    #?rakudo.jvm 1 todo "ligatures in the haystack of case insensensitive regex don't work"
    for 1..10 {
        my $haystack;
        repeat {
            $haystack = ('a'..'z').pick($_).join ~ 'ﬆ';
        }  while $haystack.contains('st');
        ok $haystack ~~ /:i st/, ":i haystack: '$haystack' needle: 'st'";
    }
}
# The below test attaches codepoints which combine with the X, so it should not
# match. When the 'x' is added on the end, and is its own grapheme, then it should
# match
#?rakudo.jvm 1 todo "NFG NYI on JVM"
nok ('X' ~ 875.chr ~ 8413.chr) ~~ /:i x /, 'case insensitive regex works for haystacks which have synthetic graphemes';
ok  ('X' ~ 875.chr ~ 8413.chr ~ 'x') ~~ /:i x /, 'case insensitive regex works for haystacks which have synthetic graphemes';
# If the beginning of the needle matches towards the end of the haystack,
# it can return a partial match, when it hasn't traversed the needle fully
nok "aaaaaaaabcd" ~~ m:i/abcd111111/, "case insensitive regex will not return a match beyond the haystack end";
for 'a'..'z' -> $a {
  my $s;
  my $s1;
  my $tag;
  for 'a'..'z' {
    next if $a eq $_;
    my $left = "$a";
    my $right = "$_$a";
    $tag ~= "$left <-> $right, ";
    my $e = qq«("$left" ~~ m:i/$right/) ?? '$_' !! '_'»;
    $s ~= $e.EVAL;
    $s1 ~= ($left ~~ m:i/$right/) ?? '$_' !! '_';
  }
  is $s, '_' x 25, "× = a-z; × ~~ m:i/×$a/; EVAL";
  is $s1, '_' x 25, "× = a-z; × ~~ m:i/×$a/;";
}
#?rakudo.jvm 9 todo "ignorecase doesn't match foldcase on jvm"
ok 'ﬁ' ~~ /:i fi /, "ignorecase with ligature haystack matches";
ok 'fi' ~~ /:i ﬁ /, "ignorecase with ligature needle matches";
my $fi   = 'fi';
my $fi_d = 'ﬁ';
ok $fi   ~~ /:i $fi_d /, "ignorecase with ligature needle in variable matches";
ok 'fi'   ~~ /:i $fi_d /, "ignorecase with ligature needle in variable matches (literal haystack)";

#?rakudo.moar 2 todo "ignorecase doesn't use foldcase semantics when the haystack is interpolated RT132233"
#?rakudo.js 2 todo "ignorecase doesn't use foldcase semantics when the haystack is interpolated RT132233"
ok $fi_d ~~ /:i $fi /, "ignorecase with ligature haystack in variable matches";
ok 'ﬁ' ~~ /:i $fi /, "ignorecase with ligature literal haystack matches";
ok $fi_d ~~ /:i  fi /, "ignorecase with ligature haystack in variable matches";

is 'ﬁ' ~~ /:i fi /, "ﬁ", "ignorecase with ligature haystack returns ligature match";

#?rakudo.moar 1 todo "ignorecase returns too many graphemes for expanding foldcase graphemes. RT132232"
is '_ﬁ_' ~~ /:i fi /, "ﬁ", "ignorecase with ligature haystack matches only ligature needle";
# vim: expandtab shiftwidth=4
