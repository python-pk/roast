use MONKEY-TYPING;

use Test;
plan 10;

# L<S12/Open vs Closed Classes>

class Something {
    has $.attribute;
    method in_Something { 'a' ~ $.attribute };
}

my $x = Something.new(attribute => 'b');

is $x.in_Something, 'ab', 'basic OO sanity';

# although we use curlies here to be better fudge-able, remeber
# that 'augment' class extensions are *not* lexically scoped
{
    augment class Something {
        method later_added {
            'later'
        }
        method uses-other-methods {
            'blubb|' ~ self.in_Something;

        }
    }

    my $y = Something.new(attribute => 'c');
    is $y.later_added, 'later', 'can call method that was later added';
    is $y.uses-other-methods, 'blubb|ac', 'can call new method that calls other methods';

    is $x.later_added, 'later', 'can call method on object that was instantiated earlier';
    is $x.uses-other-methods, 'blubb|ab', 'works with other method too';
}

# now try to extend "core" types

{
    augment class Str {
        method mydouble {
            self.uc ~ self.lc;
        }
    }

    is 'aBc'.mydouble, 'ABCabc', 'can extend Str';
}


{
    augment class Int {
        method triple { self * 3 }
    }
    is 3.triple, 9, 'can extend Int';
}

{
    augment class Array {
        method last-and-first {
            self[self - 1] ~ self[0]
        }
    }

    my @a = 1, 3, 7, 0;
    is @a.last-and-first, '01', 'can extend class Array';
}

throws-like 'use MONKEY-TYPING; class RT124017_A {}; augment class RT124017_A:D {}',
  X::Syntax::Augment::Adverb,
  "can't pass :D when augmenting class";
throws-like 'use MONKEY-TYPING; class RT124017_B {}; augment class RT124017_B:auth<random_auth> {}',
  X::Syntax::Augment::Adverb,
  "can't pass :auth when augmenting class";

# vim: expandtab shiftwidth=4
