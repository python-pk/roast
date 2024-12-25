use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 36;

# this used to segfault in rakudo
is_run(
       'try { die 42 }; my $x = $!.WHAT; say $x',
       { status => 0, out => -> $o {  $o.chars > 2 }},
       'Can stringify $!.WHAT without segfault',
);

is_run(
       'try { die 42; CATCH { when * { say $!.WHAT } }; };',
       { status => 0, out => -> $o { $o.chars > 2 }},
       'Can say $!.WHAT in a CATCH block',
);

is_run(
       '[].WHAT.say',
       { status => 0, out => "(Array)\n"},
       'Can [].WHAT.say',
);


is_run(
    'class A { method postcircumfix:<{ }>() {} }; my &r = {;}; if 0 { if 0 { my $a #OK not used' ~
     "\n" ~ '} }',
    { status => 0, out => '', err => ''},
    'presence of postcircumfix does not lead to redeclaration warnings',
);

my $code = q:to'--END--';
    my $x;
    multi sub foo($n where True) { temp $x; }
    foo($_) for 1 ... 1000;
    print 'alive';
    --END--



is_run(
       $code,
       { status => 0, out => "alive"},
       'multi sub with where clause + temp stress',
);

throws-like { EVAL 'time(1, 2, 3)' },
  X::Undeclared::Symbols,
  'time() with arguments dies';


lives-ok { 1.^methods>>.sort }, 'can use >>.method on result of introspection';


throws-like ｢Any .= ()｣, Exception, :message{.contains: 'Any'},
    'typed, non-internal exception';


{
    my $i = 0;
    sub foo {
        return if ++$i == 50;
        EVAL 'foo';
    }
    lives-ok { foo }, 'can recurse many times into &EVAL';
}


{
    throws-like { EVAL '_~*.A' },
      X::Undeclared::Symbols,
      'weird string that once parsed in rakudo';
}


{
    lives-ok { EVAL 'say(;:[])' }, 'weird code that used to parsefail rakudo';
}


{
    lives-ok { EVAL 'class A {
        has %!x;

        method m {
            sub foo {
            }

            %!x<bar> = 42;
        }
    }' }, "still able to parse statement after sub decl ending in newline";
}


{
    try EVAL '
        proto bar {*}
        multi bar ($baz) { "BAZ" }
        class Blorg {
            method do_stuff { bar "baz" }
        }
        Blorg.new.do_stuff
    ';
    ok ~$! ~~ / 'Calling bar(' .*? 'will never work' .*? 'proto' /, "fails correctly";
}


{
    is ((((6103515625/5) * 4 + 123327057) ** 2) % 6103515625),
        (((1220703125 * 4 + 123327057) ** 2) % 6103515625),
        "at one point rakudo evaluated the first expression to 0"
}


is_run(
       'quietly note 0.^methods(:all).sort.elems',
       { status => 0, err => -> $o { $o ~~ / ^ \d+ \n $ / }},
       'sorting method list does not segfault',
);


is_run '{;}',
    {
        status => 0,
        err    => '',
    },
    'empty code block does not crash (used to do that on JVM)';


{
    my $code = q:to'--END--';
        class C {
            has $!x is rw;
        }
        --END--
    is_run(
        $code,
        { status => 0, err => -> $o { $o ~~ /useless/ && $o ~~ /':2'/ } },
        'useless use of is rw reported on meaningful line'
    );
}

{
    is_run('(1,2,3).map({ die "oh noes" })',
    {
        out => '',
        err => { .chars < 256 && m/'oh noes'/ },
    },
    'concise error message when sinking last statement in a file' );
}


#?rakudo todo 'Feels like a bogus test in light of recent changes'
throws-like { EVAL '&&::{}[];;' },
  X::Undeclared::Symbols,
  "Doesn't die with weird internal error";


{
    throws-like { "::a".EVAL }, X::NoSuchSymbol, symbol => "a",
      "test throwing for ::a";
}


{
    is_run(q:to/SEGV/, { out => "360360\n" }, 'Correct result instead of SEGV');
        my $a = 14;
        while (True) {
            my $z = (2..13).first(-> $x { !($a %% $x) });
            last if (!$z);
            $a += 14
        }
        say $a
        SEGV
}


sub decode_utf8c {
    my @ints = 103, 248, 111, 217, 210, 97;
    my $b = Buf.new(@ints);
    my Str $u=$b.decode("utf8-c8");
    $u.=subst("a","b");
}

#?rakudo.jvm todo "Unknown encoding 'utf8-c8'"
lives-ok &decode_utf8c, 'Can decode and work with interesting byte sequences';


{
    sub bar() { foo; return 6 }
    sub foo() { return 42 }
    my $a = 0;
    $a += bar for ^158;  # 157 iterations works fine

    is $a, 158 * 6, 'SPESH inline works correctly after 158 iterations';
}


eval-lives-ok '(;)', '(;) does not explode the compiler';
eval-lives-ok '(;;)', '(;;) does not explode the compiler';
eval-lives-ok '[;]', '[;] does not explode the compiler';
eval-lives-ok '[;0]', '[;0] does not explode the compiler';


#?rakudo skip 'non-deterministic segfaults in parallel code'
#?DOES 1
{
    # Purpose of the test is to check that despite having a race
    # condition we don't get a SEGV. Other failures are acceptable.
    group-of 20 => 'accessing Seq from multiple threads does not segfault' => {
        my $code = Q:to/CODE_END/;
            my @primes = grep { .is-prime }, 1 .. *;
            my @p = gather for 4000, 5, 100, 2000 -> $n {
                take start { @primes[$n] }
            }
            .say for await @p;
            CODE_END

        is_run($code, { :status(1|0) }, 'no segfaults') for ^20;
    }
}


throws-like q:to/CODE_END/,
            class A114672 {};
            class B114672 is A114672 {
                has $!x = 5;
                our method foo(A114672:) { say $!x }
            };
            &B114672::foo(A114672.new)
            CODE_END
    Exception,
    'no segfault';

{
    # Purpose of the test is to check that despite having a race
    # condition we don't get a SEGV. Other failures are acceptable.
    my $code = Q:to/CODE_END/;
        class HasNativeStr { has str $.attr }
        my %h;
        %h{HasNativeStr.new().attr} = 1;
        CODE_END

    is_run $code, { :status(1|0) },
        'using a null string to access a hash does not segfault';
}


is (^1000 .grep: -> $n {([+] ^$n .grep: -> $m {$m and $n %% $m}) == $n }), (0, 6, 28, 496),
    'No SEGV/crash on reduction in grep using %%';

# https://irclog.perlgeek.de/perl6/2017-04-18#i_14443061
is_run ｢class Foo {}; $ = new Foo:｣, {:out(''), :err(''), :0status },
    'new Foo: calling form does not produce unwanted output';


is_run ｢sub f1 { hash a=>1 }; f1 for ^100000｣, {:out(''), :err(''), :0status },
    'no segfault when using `hash` in a function';


{
    sub foo($x, $y) { True };
    sub bar($x, $y, $w) {
        {
            my int $x2 = 1;
            my int $y2 = 2;
            if foo($x, $y) == foo($x, $y2) == foo($x2, $y2) == foo($x2, $y) {
                2;
            } else {
                1
            }
        }
    }

    is bar(1, 2, 25), 2, 'no miscompilation issue with chain ops';
}


is_run ｢class Foo {}; -> Foo() $x { $x.say }("42")｣, {:out(''), :err(*), :1status },
    'no segfault when using coercers';

# https://github.com/MoarVM/MoarVM/issues/1223
{
    my $lot-of-variables = "";
    $lot-of-variables ~= "my \$x$_ = $_;\n" for ^9_000;
    $lot-of-variables ~= "exit 42";
    #?rakudo.jvm todo 'dies with `java.lang.OutOfMemoryError: Java heap space`'
    is_run($lot-of-variables, { :42status }, "no segv or throw with lots of variables");
}

# vim: expandtab shiftwidth=4
