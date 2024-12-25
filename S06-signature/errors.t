use Test;

plan 25;

=begin pod

These are misc. sub argument errors.

=end pod

sub bar (*@x) { 1 }   #OK not used
lives-ok { bar(reverse(1,2)) }, 'slurpy args are not bounded (2)';

throws-like 'sub quuux ($?VERSION) { ... }', X::Parameter::Twigil,
    'parser rejects magicals as args (1)';
eval-lives-ok 'sub quuuux ($!) { ... }', 'but $! is OK';


{
    sub empty_sig() { return };
    dies-ok { EVAL('empty_sig("RT #64344")') },
            'argument passed to sub with empty signature';
}


{
    dies-ok { EVAL 'sub foo(%h) { %h }; foo(1, 2); 1' },
        "Passing two arguments to a function expecting one hash is an error";

    try { EVAL 'sub foo(%h) { %h }; foo(1, 2); 1' };
    my $error   = "$!";
    ok $error ~~ / '(%h)' /,   '... error message mentions signature';
    ok $error ~~ / :i call /, '... error message mentions "call"';
    ok $error ~~ /'foo(Int, Int)' /, '... error message mentions call profile';
}


throws-like 'my class A { submethod BUILD(:$!notthere = 10) { } }; A.new',
    X::Attribute::Undeclared,
    'named parameter of undeclared attribute dies';


{
    try { EVAL 'sub rt72082(@a, $b) {}; rt72082(5)' }
    my $error = ~$!;
    ok $error ~~ /:i 'rt72082(Int)' .*? /, "too few args reports call profile";
    ok $error ~~ /:i '(@a, $b)' /, "too few args reports declared signature";
    ok $error ~~ /signature/, "too few args mentions signature";
    ok $error ~~ / :i call /, '... error message mentions "call"';
}


{
    try { EVAL 'sub foo(Str) {}; foo 42' }
    my $error = ~$!;
    ok $error ~~ /:i 'foo(Int)' /, "simple Str vs Int reports call profile";
    ok $error ~~ /:i '(Str)' /, "simple Str vs Int reports signature";
    ok $error ~~ /signature/, "simple Str vs Int mentions signature";
    ok $error ~~ / :i call /, '... error message mentions "call"';
}


{
    try { EVAL 'multi rt78670(Int) {}; my $str = "foo"; rt78670 $str' }
    my $error = ~$!;
    ok $error ~~ /:i 'rt78670(Str' /, "fails multi sigs reports call profile";
    ok $error ~~ /signature/, "mentions signature";
    ok $error ~~ /^^ \h* '(Int'/, "Error mentions Int";
    ok $error ~~ / :i call /, '... error message mentions "call"';
}

throws-like 'sub foo($a:) { }', X::Syntax::Signature::InvocantNotAllowed;
throws-like 'sub foo($a: $b) { }', X::Syntax::Signature::InvocantNotAllowed;
throws-like '-> $a: { }', X::Syntax::Signature::InvocantNotAllowed;
throws-like '-> $a: $b { }', X::Syntax::Signature::InvocantNotAllowed;

# vim: expandtab shiftwidth=4
