use Test;
plan 43;

# L<S05/Match objects/"$/.caps">

sub ca(@x) {
    join '|', gather {
        for @x -> $p {
            take $p.key ~ ':' ~ $p.value;
        }
    }
}

ok 'a b c d' ~~ /(.*)/, 'basic sanity';
ok $/.caps ~~ Iterable, '$/.caps returns something Iterable';
ok $/.chunks ~~ Iterable, '$/.chunks returns something Iterable';
isa-ok $/.caps.[0],   Pair, '.. and the items are Pairs (caps);';
isa-ok $/.chunks.[0], Pair, '.. and the items are Pairs (chunks);';
isa-ok $/.caps.[0].value,   Match, '.. and the values are Matches (caps);';
isa-ok $/.chunks.[0].value, Match, '.. and the values are Matches (chunks);';

is ca($/.caps),     '0:a b c d', '$/.caps is one item for (.*)';
is ca($/.chunks),   '0:a b c d', '$/.chunks is one item for (.*)';

my token wc { \w };

ok 'a b c' ~~ /:s <wc=&wc> (\w) <wc=&wc> /, 'regex matches';
is ca($/.caps), 'wc:a|0:b|wc:c', 'named and positional captures mix correctly';
is ca($/.chunks), 'wc:a|~: |0:b|~: |wc:c',
                  'named and positional captures mix correctly (chunks)';

ok 'a b c d' ~~ /[(\w) \s*]+/, 'regex matches';
is ca($/.caps), '0:a|0:b|0:c|0:d', '[(\w)* \s*]+ flattens (...)* for .caps';
is ca($/.chunks), '0:a|~: |0:b|~: |0:c|~: |0:d',
                '[(\w)* \s*]+ flattens (...)* for .chunks';

ok 'a b c' ~~ /[ (\S) \s ] ** 2 (\S)/, 'regex matches';
is ca($/.caps), '0:a|0:b|1:c', '.caps distinguishes quantified () and multiple ()';
is ca($/.chunks), '0:a|~: |0:b|~: |1:c', '.chunks distinguishes quantified () and multiple ()';

ok 'a b c d' ~~ /:s [(\w) <wc=&wc> ]+/, 'regex matches';

#'RT #75484 (fails randomly) (noauto)'
is ca($/.caps), '0:a|wc:b|0:c|wc:d',
                      'mixed named/positional flattening with quantifiers';
is ca($/.chunks), '0:a|~: |wc:b|~: |0:c|~: |wc:d',
                      'mixed named/positional flattening with quantifiers';

# .caps and .chunks on submatches

ok '  abcdef' ~~ m/.*?(a(.).)/, 'Regex matches';
is ca($0.caps),     '0:b',      '.caps on submatches';
is ca($0.chunks),   '~:a|0:b|~:c',  '.chunks on submatches';


ok 'a;b,c,' ~~ m/(<.alpha>) +% (<.punct>)/, 'Regex matches';
is ca($/.caps),     '0:a|1:;|0:b|1:,|0:c',  '.caps on % separator';
is ca($/.chunks),   '0:a|1:;|0:b|1:,|0:c',  '.chunks on % separator';

ok 'a;b,c,' ~~ m/(<.alpha>) +%% (<.punct>)/, 'Regex matches';
is ca($/.caps),     '0:a|1:;|0:b|1:,|0:c|1:,',      '.caps on %% separator';
is ca($/.chunks),   '0:a|1:;|0:b|1:,|0:c|1:,',  '.chunks on %% separator';

{
    ok 'a' ~~ m/a && <alpha>/, 'Regex matches';
    is ca($/.caps),     'alpha:a',  '.caps && - first term';

    ok 'a' ~~ m/<alpha> && a/,  'Regex matches';
    is ca($/.caps),     'alpha:a',  '.caps && - last term';

    ok 'a' ~~ m/<alpha> & <ident>/,  'Regex matches';
    is ca($/.caps.sort(*.key)),     'alpha:a|ident:a',  '.caps & - multiple terms';

    ok 'a' ~~ m/<alpha> && <ident>/,  'Regex matches';
    is ca($/.caps.sort(*.key)),     'alpha:a|ident:a',  '.caps && - multiple terms';

    ok 'ab' ~~ m/([a|b] && <alpha>)**1..2/,  'Regex matches';
    is ca($/.caps),     '0:a|0:b',    '.caps on quantified &&';

    ok 'ab' ~~ m/[[a|b] && <alpha>]**1..2/,  'Regex matches';
    is ca($/.caps),     'alpha:a|alpha:b',    '.caps on quantified &&';
}


{
    my grammar Gram {
        regex TOP { ('XX')+ %% $<delim>=<[a..z]>* }
    }
    is Gram.parse('XXXXXX').caps.map(*.key), (0, "delim", 0, "delim", 0, "delim"),
        '.caps respects order of matching even with zero-width delimeters';
}

# vim: expandtab shiftwidth=4
