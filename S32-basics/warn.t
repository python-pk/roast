use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 9;


{
    my $alive = 0;
    my $exception-produced = 0;
    my $warn-msg = "# It's OK to see this warning during a test run";
    CONTROL {
        when CX::Warn { $exception-produced = .message }
        default { .rethrow }
    }
    try {
        warn $warn-msg;
        $alive = 1;
    }
    ok $alive, 'warn in try blocks do not interrupt execution';
    like $exception-produced, /$warn-msg/, q<try don't catch warn's control exception>;
}

{
    my $caught = 0;
    {
        CONTROL { default { $caught = 1 } };
        warn "# You shouldn't see this warning";
    }
    ok $caught, 'CONTROL catches exceptions'
}


{
    my $caught = 0;
    {
        CONTROL {
            when CX::Warn { $caught = .message; }
            default { .rethrow }
        };
        EVAL '~Any';
    }
    like $caught,
        /'Use of uninitialized value of type Any in string context.'/,
        'Stringifying Any warns';
}

is_run 'warn; say "alive"',
    {
        status => 0,
        out => rx/alive/,
        err => /:i Warning/,
    },
    'warn() without arguments';


is_run 'warn("OH NOEZ"); say "alive"',
    {
        status => 0,
        out => rx/alive/,
        err => rx/ 'OH NOEZ'/ & rx/:i \W '1'>>/,
    },
    'warn() with arguments; line number';

is_run 'try {warn("OH NOEZ") }; say "alive"',
    {
        status => 0,
        out => rx/alive/,
        err => rx/ 'OH NOEZ'/,
    },
    'try does not suppress warnings';

is_run 'quietly {warn("OH NOEZ") }; say "alive"',
    {
        status => 0,
        out => rx/alive/,
        err => '',
    },
    'quietly suppresses warnings';


is_run ｢
    warn <foo-1  foo-2  foo-3>.all;
    warn ('foo-4',  ('foo-5', 'foo-6').any).all
｣, {:out(''), :0status, :err{
    .contains: <foo-1  foo-2  foo-3  foo-4  foo-5  foo-6>.all
}}, 'no crashes or hangs with Junctions in warn()';


{
    my int $warnings;
    {
        nok List ~~ List.new, 'did the smartmatch work out';
        CONTROL { ++$warnings if $_ ~~ CX::Warn; .resume }
    }
    is $warnings, 0, 'should not have warned';
}

# vim: expandtab shiftwidth=4
