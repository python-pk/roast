use Test;

# L<S04/"Statement parsing"/"or try {...}">

plan 40;

{
    # simple try
    my $lived = Mu;
    try { die "foo" };
    ok($! ~~ /foo/, "error var was set");
};

# try should return Nil if an exception was caught
{
    ok (try { die 'foo' }) === Nil, 'try returns Nil when exception was caught';
    ok (try { die 'foo'; CATCH { default { } } }) === Nil, '... even when there was a CATCH block';
}

# try should work when returning an array or hash
{
    my @array = try { 42 };
    is +@array,    1, '@array = try {...} worked (1)';
    is ~@array, "42", '@array = try {...} worked (2)';
}

{
    my @array = try { (42,) };
    is +@array,    1, '@array = try {...} worked (3)';
    is ~@array, "42", '@array = try {...} worked (4)';
}

{
    my %hash = try { 'a', 1 };
    is +%hash,        1, '%hash = try {...} worked (1)';
    is ~%hash.keys, "a", '%hash = try {...} worked (2)';
}

{
    my %hash = try { hash("a", 1) };
    is +%hash,        1, '%hash = try {...} worked (5)';
    is ~%hash.keys, "a", '%hash = try {...} worked (6)';
}

{
    my %hash;
    try { %hash = try { a => 3 } };
    is +%hash,        1, '%hash = try {...} worked (7)';
    is ~%hash.keys, "a", '%hash = try {...} worked (8)';
    is ~%hash<a>,     3, '%hash = try {...} worked (9)';
}

# return inside try{}-blocks
# PIL2JS *seems* to work, but it does not, actually:
# The "return 42" works without problems, and the caller actually sees the
# return value 42. But when the end of the test is reached, &try will
# **resume after the return**, effectively running the tests twice.
# (Therefore I moved the tests to the end, so not all tests are rerun).

{
    my $was_in_foo = 0;
    sub foo {
        $was_in_foo++;
        try { return 42 };
        $was_in_foo++;
        return 23;
    }
    is foo(), 42,      'return() inside try{}-blocks works (1)';
    is $was_in_foo, 1, 'return() inside try{}-blocks works (2)';
}

{
    sub test1 {
        try { return 42 };
        return 23;
    }

    sub test2 {
        test1();
        die 42;
    }

    dies-ok { test2() },
        'return() inside a try{}-block should cause following exceptions to really die';
}

{
    sub argcount { return +@_ }
    is argcount( try { 17 }, 23, 99 ), 3, 'try gets a block, nothing more';
}

{
    my $catches = 0;
    try {
        try {
            die 'catch!';
            CATCH {
                die 'caught' if ! $catches++;
            }
        }
    }
    is $catches, 1, 'CATCH does not catch exceptions thrown within it';
}

{
    my $resumed = 0;
    try {
        die "ohh";
        $resumed = 1;
        CATCH { default { .resume } }
    }
    is $resumed, 1, 'CATCH allows to resume to right after the exception';
}

{
    my $str = '';
    try {
        ().abc;
        CATCH {
            default {
                $str ~= 'A';
                if 'foo' ~~ /foo/ {
                    $str ~= 'B';
                    $str ~= $/;
                }
            }
        }
    }
    is $str, 'ABfoo', 'block including if structure and printing $/ ok';
}

{
    class MyPayload {
        method Str() { 'something exceptional' }
    };
    my $p = MyPayload.new;
    try die $p;
    isa-ok $!, X::AdHoc, 'die($non-exception) creates an X::AdHoc';
    ok $!.payload === $p, '$!.payload is the argument to &die';
    is $!.Str, 'something exceptional', '$!.Str uses the payload';

    try die($p,42);
    isa-ok $!, X::AdHoc, 'die($,$) creates an X::AdHoc';
    ok $!.payload[0] === $p, '$!.payload[0] is the first argument to &die';
    ok $!.payload[1] == 42, '$!.payload[1] is the second argument to &die';
    is $!.Str, 'something exceptional42', '$!.Str culls whitespace';

    try die(X::NYI.new(:feature<fee>),"fee");
    isa-ok $!, X::AdHoc, 'die(Exception,$) creates an X::AdHoc';
    ok $!.payload[0] ~~ X::NYI, '$!.payload[0] is the Exception';

    sub a { # new $!
        try die();
        is $!.Str, 'Died', 'When $! not set, die() has default message "Died"';
        try die("fee");
        die();
        CATCH {
            default {
                is $_.Str, 'fee', 'When $! is set, die() is die($!).';
            }
        };
    }
    a();

    class MyEx is Exception {
        has $.s;
    }
    try MyEx.new(s => 'bar').throw;
    isa-ok $!, MyEx, 'Can throw subtypes of Exception and get them back';
    is $!.s, 'bar', '... and got the right object back';
}


{
    my $x = 0;
    try { $x = $_ } given '42';
    is $x, '42', 'try block in statement-modifying contextualizer';
}


lives-ok { try +'foo' }, 'Failure does not escape try (statement form)';
lives-ok { try { +'foo' } }, 'Failure does not escape try (block form)';
lives-ok { try { +'foo'; CATCH { default { } } } }, 'Failure does not escape try (block form with CATCH)';


lives-ok { try ... }, '... failure does not escape try (statement form)';
lives-ok { try { ... } }, '... failure does not escape try (block form)';

# vim: expandtab shiftwidth=4
