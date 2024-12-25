use Test;
use experimental :macros;
plan 6;

# editorial note:
# most macros in this file have been named after 20th-century physicists.

{ # simplest possible unquote splicing
    my $unquote_splicings;
    BEGIN { $unquote_splicings = 0 }; # so it's not Any() if it doesn't work

    macro planck($x) {
        quasi { {{{$unquote_splicings++; $x}}} }
    }

    planck "length";
    is $unquote_splicings, 1, "spliced code runs at parse time";
}

#{ # building an AST from smaller ones
#    macro bohr() {
#        my $q1 = quasi { 6 };
#        my $q2 = quasi { 6 * 10 };
#        my $q3 = quasi { 100 + 200 + 300 };
#        quasi { {{{$q1}}} + {{{$q2}}} + {{{$q3}}} }
#    }
#
#    is bohr(), 666, "building quasis from smaller quasis works";
#}

{ # building an AST incrementally
    macro einstein() {
        my $q = quasi { 2 };
        $q = quasi { 1 + {{{$q}}} };
        $q = quasi { 1 + {{{$q}}} };
        $q;
    }

    is einstein(), 4, "can build ASTs incrementally";
}


#?rakudo.moar skip 'Specified code ref has no outer, RT #121533'
#?rakudo.js skip 'Skipping failed macro test, it fail on moar too'
{ # building an AST incrementally in a for loop
    macro podolsky() {
        my $q = quasi { 2 };
        $q = quasi { 1 + {{{$q}}} } for ^2;
        $q;
    }

    is podolsky(), 4, "can build ASTs in a for loop";
}

{ # using the mainline context from an unquote
    macro rosen($code) {
        my $paradox = "this shouldn't happen";
        quasi {
            {{{$code}}}();
        }
    }

    my $paradox = "EPR";
    is rosen(sub { $paradox }), "EPR", "unquotes retain their lexical context";
}

{ # unquotes must evaluate to ASTs
    throws-like 'macro bohm() { quasi { {{{"not an AST"}}} } }; bohm',
                X::TypeCheck::Splice,
                got      => Str,
                expected => AST,
                action   => 'unquote evaluation',
                line     => 1;
}


{
    macro postfix:<!!>($o) {
        quasi {
            die "Null check failed for ", $o.Str unless defined {{{$o}}};
            {{{$o}}};
        }
    };
    my $cookies;
    throws-like { $cookies!!; }, Exception,
        message => 'Null check failed for $cookies';
}

# vim: expandtab shiftwidth=4
