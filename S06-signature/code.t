use Test;
plan 8;

# TODO: move this test to closure-parameters.t if it works in the future

# L<S06/Closure parameters>

our $collector = 2;
sub to_be_called($x) {
    $collector += $x;
}

sub tester(&my_sub) {
    my_sub(4);
}

tester(&to_be_called);
ok $collector == 6, 'Can call my_sub() if &my_sub was a parameter';

tester(sub ($x) { $collector = 3 * $x });
ok $collector == 12, 'same with anonymous sub';

sub tester2(&my_sub) { 1 }    #OK not used
dies-ok {EVAL 'tester2(42)' }, "can't pass thing that doesn't do Callable";

sub not_returns_a_sub { 3 };
dies-ok { EVAL 'tester2(not_returns_a_sub)' },
        "can't pass thing that doesn't do Callable";

is tester2({ 'block' }), 1, 'Can pass a block to a &parameter';


{
    sub rt68578( Callable &x ) {}   #OK not used
    dies-ok { rt68578({ 'block' }) },
            "Can't pass something that isn't typed as returning Callable";
}


{
    my $tracker;
    sub foo(&foo = &foo) {
        $tracker = &foo
    };
    #?rakudo todo 'RT #67932'
    lives-ok { foo },
        'can call a sub with a code object defaulting to something of its own name';
    ok !$tracker.defined, 'the inner &foo is undefined (scoping)';
}

# vim: expandtab shiftwidth=4
