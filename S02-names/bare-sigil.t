use Test;

plan 11;

# L<S02/Names/"In declarative constructs bare sigils">

lives-ok { my $ }, 'basic bare sigil $';
lives-ok { my @ }, 'basic bare sigil @';
lives-ok { my % }, 'basic bare sigil %';

is (my $ = "foo"), "foo", 'initialized bare sigil scalar $';
ok (my @ = 1, 2, 3), 'initialized bare sigil array @';
ok (my % = baz => "luhrman"), 'initialized bare sigil hash %';


# 'state' with anonymous scalars works more like 'my' in Rakudo
{
    sub f { ++state $ ; }
    is (f, f, f), (1, 2, 3), "anonymous 'state' bare sigil scalar retains state";
    sub g { ++state $ = 3; }
    is (g, g, g), (4, 5, 6), "anonymous 'state' bare sigil scalar is initialized once";
}

{
    sub d { state $i = 0; (state @).push( $i++ ) }
    d;
    is +d(), 2, "anonymous 'state' bare sigil array retains state";
    is d()[2], 2, "anonymous 'state' bare sigil array can grow";
}


lives-ok { sub f { f(|$) } },
    'no misleading warning about P5 special var \'$)\'';

# vim: expandtab shiftwidth=4
