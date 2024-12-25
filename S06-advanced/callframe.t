use Test;

plan 22;

# this test file contains tests for line numbers, among other things
# so it's extremely important not to randomly insert or delete lines.

my $baseline = 10;

isa-ok callframe(), CallFrame, 'callframe() returns a CallFrame';

sub f() is test-assertion {
    is callframe().line, $baseline + 3, 'callframe().line';
    ok callframe().file ~~ /« callframe »/, '.file';

    #?rakudo skip 'Unable to resolve method inline in type CallFrame'
    nok callframe().inline, 'explicitly entered block (.inline)';

    # Note:  According to S02, these should probably fail unless
    # $x is marked 'is dynamic'.  We allow it for now since there's
    # still some uncertainty in the spec in S06, though.
    is callframe(1).my.<$x>, 42, 'can access outer lexicals via .my';
    callframe(1).my.<$x> = 23;

    is callframe(1).my.<$y>, 353, 'can access outer lexicals via .my';
    dies-ok { callframe(1).my.<$y> = 768 }, 'cannot mutate without is dynamic';;

    lower();
}

sub lower() is test-assertion {
    ok callframe(0).code ~~ Sub, 'callframe(0).code returns this Sub';
    ok callframe(1).code ~~ Sub, 'callframe(1).code returns the calling Sub';
    is callframe(0).code.name, 'lower';
    is callframe(1).code.name, 'f';
}

my $x is dynamic = 42;
my $y = 353;

f();

is $x,  23, '$x successfully modified';
is $y, 353, '$y not modified';


ok callframe.raku.starts-with("CallFrame."),   'CallFrame.raku works';
ok callframe.gist.starts-with($*PROGRAM-NAME), 'CallFrame.gist works';


lives-ok { sub{callframe.raku}() }, '.raku on callframe in a sub does not crash';

lives-ok {
    sub foo() { callframe(1).file.ends-with('x') }
    for ^300 { foo() }
}, 'No crash when using callframe(1).file many times in a loop';

lives-ok {
    my $g;
    for ^200 { next if $_ < 199; $g = callframe.gist }
}, 'No crash when using callframe.gist in a hot loop';

# https://github.com/rakudo/rakudo/commit/9a74cd0e51
lives-ok { callframe(1).annotations }, '.annotations does not crash';

# https://github.com/MoarVM/MoarVM/issues/562
lives-ok
    {
        for ^Inf {
            if callframe($_) -> $c {
                $ = $c.code ?? $c.code.name !! "?"
            }
            else {
                last
            }
        }
    },
    "Exploring call frames until no code object does not crash";


{
    my $seen;
    multi sub a() { ++$seen if callframe(1).my.EXISTS-KEY(<$seen>) };

    # call a 300 times
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;a;
    is $seen, 300, 'did we get the right callframe each time?';
}


{
    my $seen;
    multi sub b() { ++$seen if CallFrame.new(1).my.EXISTS-KEY(<$seen>) };

    # call b 300 times
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;
    is $seen, 300, 'did we get the right callframe each time?';
}

# vim: expandtab shiftwidth=4
