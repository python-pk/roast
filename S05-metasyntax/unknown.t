use Test;

plan 13;

# L<S05/Simplified lexical parsing of patterns/not all non-identifier glyphs are currently meaningful as metasyntax>

# testing unknown metasyntax handling

throws-like '"aa!" ~~ /!/', X::Syntax::Regex::UnrecognizedMetachar,
    '"!" is not valid metasyntax';
lives-ok({"aa!" ~~ /\!/}, 'escaped "!" is valid');
lives-ok({"aa!" ~~ /'!'/}, 'quoted "!" is valid');

throws-like '"aa!" ~~ /\a/', Exception, 'escaped "a" is not valid metasyntax';
lives-ok({"aa!" ~~ /a/}, '"a" is valid');
lives-ok({"aa!" ~~ /'a'/}, 'quoted "a" is valid');

{
    my rule foo { \{ };
    ok '{'  ~~ /<foo>/, '\\{ in a rule (+)';
    ok '!' !~~ /<foo>/, '\\{ in a rule (-)';
}


{
    dies-ok {EVAL('/ a+ + /')}, 'Cannot parse regex a+ +';
    #?rakudo todo 'faulty regex error'
    ok "$!" ~~ /:i quantif/, 'error message mentions quantif{y,ier}';
}



#?DOES 3
{
    throws-like '$_ = "0"; s/-/1/', X::Syntax::Regex::UnrecognizedMetachar, metachar => '-';
}


# not sure this is the right place for this test
{
    lives-ok { /$'x'/ }, 'can parse /$\'x\'/';
}


throws-like '/00:11:22/', X::Syntax::Regex::UnrecognizedModifier, modifier => '11';

# vim: expandtab shiftwidth=4
