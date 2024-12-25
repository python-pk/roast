use Test;

plan 33;

=begin desc

Tests C<CATCH> blocks.

=end desc



# L<S04/"Exception handlers"/If you define a CATCH block within the try, it replaces the default CATCH>

dies-ok { die 'blah'; CATCH {} }, 'Empty CATCH rethrows exception';
dies-ok { try {die 'blah'; CATCH {}} }, 'CATCH in try overrides default exception handling';

# L<S04/"Exception handlers"/any block can function as a try block if you put a CATCH block within it>

lives-ok { die 'blah'; CATCH {default {}} }, 'Closure with CATCH {default {}} ignores exceptions';
lives-ok { do {die 'blah'; CATCH {default {}}}; }, 'do block with CATCH {default {}} ignores exceptions';

{
    my $f = sub { die 'blah'; CATCH {default {}} };
    lives-ok $f, 'Subroutine with CATCH {default {}} ignores exceptions';

    $f = sub ($x) {
        if $x {
            die 'blah';
            CATCH { default {} }
        }
        else {
            die 'blah';
        }
    };
    lives-ok { $f(1) }, 'if block with CATCH {default {}} ignores exceptions...';
    dies-ok { $f(0) }, "...but the CATCH doesn't affect exceptions thrown in an attached else";
}



#L<S04/"Exception handlers"/An exception handler is just a switch statement>

#unless EVAL 'Exception.new' {
#    skip-rest "No Exception objects"; exit;
#}

{
    # exception classes
    class Naughty is Exception {};

    my ($not_died, $caught);
    {
        die Naughty.new();

        $not_died = 1;

        CATCH {
            when Naughty {
                $caught = 1;
            }
        }
    };

    ok(!$not_died, "did not live after death");
    ok($caught, "caught exception of class Naughty");
};

{
    # exception superclass
    class Naughty::Specific is Naughty {};
    class Naughty::Other is Naughty {};

    my ($other, $naughty);
    {
        die Naughty::Specific.new();

        CATCH {
            when Naughty::Other {
                $other = 1;
            }
            when Naughty {
                $naughty = 1;
            }
        }
    };

    ok(!$other, "did not catch sibling error class");
    ok($naughty, "caught superclass");
};

{
    # uncaught class
    class Dandy is Exception {};

    my ($naughty, $lived);
    try {
        {
            die Dandy.new();

            CATCH {
                when Naughty {
                    $naughty = 1;
                }
            }
        };
        $lived = 1;
    }

    ok(!$lived, "did not live past uncaught throw");
    ok(!$naughty, "did not get caught by wrong handler");
    ok(WHAT($!).gist, '$! is an object');
    is(WHAT($!).gist, Dandy.gist, ".. of the right class");
};

{
    my $s = '';
    {
        die 3;
        CATCH {
            when 1 {$s ~= 'a';}
            when 2 {$s ~= 'b';}
            when 3 {$s ~= 'c';}
            when 4 {$s ~= 'd';}
            default {$s ~= 'z';}
        }
    }

    is $s, 'c', 'Caught number';
};

{
    my $catches = 0;
    sub rt63430 {
        {
            return 63430;
            CATCH { return 73313 if ! $catches++; }
        }
    }

    is rt63430().raku, 63430.raku, 'can call rt63430() and examine the result';
    is rt63430(), 63430, 'CATCH does not intercept return from bare block';
    is $catches, 0, 'CATCH block never invoked';
};



# L<S04/"Exception handlers"/a CATCH block never attempts to handle any exception thrown within its own dynamic scope>

{
    my $catches = 0;
    try {
        {
            die 'catch!';
            CATCH { default {die 'caught' if ! $catches++;} }
        };
    }

    is $catches, 1, "CATCH doesn't catch exceptions thrown in its own lexical scope";

    $catches = 0;
    my $f = { die 'caught' if ! $catches++; };
    try {
        {
            die 'catch!';
            CATCH { default {$f()} }
        };
    }

    is $catches, 1, "CATCH doesn't catch exceptions thrown in its own dynamic scope";

    my $s = '';
    {
        die 'alpha';
        CATCH {
            default {
                $s ~= 'a';
                die 'beta';
            }
            CATCH {
                default { $s ~= 'b'; }
            }
        }
    };

    is $s, 'ab', 'CATCH directly nested in CATCH catches exceptions thrown in the outer CATCH';

    $s = '';
    {
        die 'alpha';
        CATCH {
            default {
                $s ~= 'a';
                die 'beta';
                CATCH {
                    default { $s ~= 'b'; }
                }
            }
        }
    };

    is $s, 'ab', 'CATCH indirectly nested in CATCH catches exceptions thrown in the outer CATCH';
};


{
    try { die "Goodbye cruel world!" };
    ok $!.^isa(Exception), '$!.^isa works';
}


{
    dies-ok {
        try {
            die 1;
            CATCH {
                default {
                    die 2;
                }
            }
        }
    }, 'can throw exceptions in CATCH';
}


eval-lives-ok 'my %a; %a{ CATCH { } }', 'can define CATCH bock in .{}';

throws-like 'do { CATCH {}; CATCH { } }', X::Phaser::Multiple, 'only one CATCH per block allowed';

throws-like 'try { CATCH { ~$! }; die }', X::AdHoc, "doesn't segfault";


{
    sub failing-routine {
        try {
            CATCH {
                when 'there' {
                    return False;
                }
            }

            die 'there';
        }
    }

    lives-ok {
        failing-routine;
        failing-routine;
    }, 'Two invocations of a die()ing routine should still hit the CATCH handler';
}


lives-ok { for ^1000 { die Exception.new; CATCH { default {} } } },
    'Hot-path optimization does not break exception hanhttps://github.com/Raku/old-issue-tracker/issues/3330dling';


lives-ok { loop { CATCH { default { say 'hi' } }; last if $++ > 100 } },
    'CATCH in a loop lives';


{
    for ^500000 {
        CATCH {
            default { }
        }
        {
            CATCH { }
            die "foo";
        }
    }
    pass "did not deadlock";
}


{
    my $message = "meh";
    my class E is Exception { method message { "E" } }
    CATCH { when E { $message = .message; .resume } }
    E.new.throw;
    is $message, 'E', 'did the .resume work out ok';
}

# vim: expandtab shiftwidth=4
