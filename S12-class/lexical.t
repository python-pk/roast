use Test;

plan 14;

=begin pod

Tests for lexical classes delcared with 'my class'

=end pod

# L<S12/Classes>

# A few basic tests.
eval-lives-ok 'my class A {}', 'my class parses OK';
eval-lives-ok '{ my class B {} }; { my class B {} }',
              'declare classes with the same name in two scopes.';
eval-lives-ok '{ my class B {}; B.new; }',
              'can instantiate lexical class';
throws-like '{ my class B {}; B.new; }; B.new', X::Undeclared::Symbols,
              'scope is correctly restricted';

{
    my class WeissBier {
        has $.name;
        method describe() { 'outstanding flavour' }
    }
    my $pint = WeissBier.new(name => 'Erdinger');
    ok $pint ~~ WeissBier,                    'can smart-match against lexical class';
    is $pint.name, 'Erdinger',                'attribute in lexical class works';
    is $pint.describe, 'outstanding flavour', 'method call on lexical class works';
    is WeissBier.gist, '(WeissBier)',         'lexical type object stringifies correct';

    my class LessThanAmazingWeissBier is WeissBier {
        method describe() { 'tastes like sweetcorn' }
    }
    ok LessThanAmazingWeissBier ~~ WeissBier,      'inehritance between lexical classes works';
    my $ltapint = LessThanAmazingWeissBier.new(name => 'Baltika 7');
    ok $ltapint ~~ LessThanAmazingWeissBier,       'can smart-match class that inherits';
    ok $ltapint ~~ WeissBier,                      'can smart-match against parent class too';
    is $ltapint.describe, 'tastes like sweetcorn', 'can call overridden method';
    is $ltapint.name, 'Baltika 7',                 'can call inherited method that accesses inherited attribute';
}


{
    class Forest {
        class Frog {
            method speak { "ribbit ribbit" }
        };
        has Frog $.frog;
        method new() {
            my Frog $frog .=  new;
            self.bless(:$frog);
        };
    }
    is Forest.new.frog.speak, 'ribbit ribbit',
        'can construct objects of inner class in outer constructor';
}

# vim: expandtab shiftwidth=4
