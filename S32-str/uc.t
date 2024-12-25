use Test;

plan 20;

# L<S32::Str/"Str"/=item uc>

is(uc("Hello World"), "HELLO WORLD", "simple");
is(uc(""), "", "empty string");
{
    is(uc("åäö"), "ÅÄÖ", "some finnish non-ascii chars");
    is(uc("äöü"), "ÄÖÜ", "uc of German Umlauts");
    is(uc("óòúù"), "ÓÒÚÙ", "accented chars");
}
is(uc(lc('HELL..')), 'HELL..', "uc/lc test");

{
    $_ = "Hello World";
    my $x = .uc;
    is $x, "HELLO WORLD", 'uc uses the default $_';
}

{
    my $x = "Hello World";
    is $x.uc, "HELLO WORLD", '$x.uc works';
    is "Hello World".uc, "HELLO WORLD", '"Hello World".uc works';
}

# GERMAN SHARP S ("ß") should uc() to "SS", per SpecialCasing.txt

is(uc("ß"), "SS", "uc() of non-ascii chars may result in two chars");

{
    is("áéíöüóűőú".uc, "ÁÉÍÖÜÓŰŐÚ", ".uc on Hungarian vowels");
}

is ~(0.uc),         ~0, '.uc on Int';
is ~(0.tc),         ~0, '.tc on Int';
is ~(0.lc),         ~0, '.lc on Int';

#?DOES 3
{
    role A {
        has $.thing = 3;
    }
    for <uc lc tc> -> $meth {
        my $str = "('Nothing much' but A).$meth eq 'Nothing much'.$meth";
        ok EVAL($str), $str;
    }
}

# There are a handful of chars that have a precomposed lowercase, but no
# precomposed uppercase. That is, NFC is sufficient for the lowercase to
# be an NFG string, but on uppercasing there's no way to represent it in
# NFC and so we need to produce a synthetic.
{
    my $s = "\c[GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS]";
    is $s.uc, "\c[GREEK CAPITAL LETTER IOTA]\c[COMBINING DIAERESIS]\c[COMBINING ACUTE ACCENT]",
        "Correct uppercasing of char with no precomposed upper";
    #?rakudo.jvm todo 'got 3'
    is $s.uc.chars, 1, "Char with no precomposed upper gets NFG'd so upper is one grapheme";
}
# RT132020
# This test makes sure .uc works properly even when a GCB=Prepend codepoint comes in front of it.
{
    is-deeply "\c[arabic number sign]a".uc, "\c[arabic number sign]A", "Uppercasing works even with prepend codepoints";
}

# vim: expandtab shiftwidth=4
