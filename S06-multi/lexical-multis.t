use Test;

plan 15;

# basic test that multi is lexical
{
    {
        my multi foo() { 42 }
        is(foo(), 42, 'can call lexically scoped multi');
    }
    throws-like q{ foo() }, X::Undeclared::Symbols,
        'lexical multi not callable outside of lexical scope';
}

# test that lexical multis in inner scopes add to those in outer scopes
{
    {
        my multi bar() { 1 }

        {
            my multi bar($x) { 2 }    #OK not used

            is(bar(),      1, 'outer lexical multi callable');
            is(bar('syr'), 2, 'new inner lexical multi callable');
        }

        is(bar(), 1, 'in outer scope, can call the multi that is in scope');
        dies-ok { EVAL("bar('pivo')") }, 'multi variant from inner scope not callable in outer';
    }

    dies-ok { EVAL q{ bar() }},    'no multi variants callable outside of lexical scope';
    dies-ok { EVAL q{ bar('kava')} }, 'no multi variants callable outside of lexical scope';
}

# an inner multi with a signature matching an outer will hide it
{
    my multi baz() { 1 }
    {
        my multi baz() { 2 }   #OK not used
        #?rakudo todo 'lexical scope as tie breaker'
        lives-ok({ baz() }, 'inner multi conflicts with outer one');
    }
    is(baz(), 1, 'in outer scope, no inner multi, so no conflict');
}

# lexical multi can add to package multi if no outer lexical ones
multi waz() { 1 }
{
    my multi waz($x) { 2 }   #OK not used
    is(waz(),       1, 'got multi from package');
    is(waz('slon'), 2, 'lexical multi also callable');
}
is(waz(), 1,             'multi from package still callable outside the inner scope...');
dies-ok { EVAL("waz('vtak')") }, '...but lexical multi no longer callable';


{
    dies-ok { multi foo() { }; multi foo($x) { }; +&foo }, 'die in numification of proto';   #OK not used
}

# vim: expandtab shiftwidth=4
