use Test;
use soft;

# L<S06/Wrapping>

# TODO
# nextsame, nextwith, callsame
# unwrap with no args pops the top most (is this spec?)
#
# mutating wraps -- those should be "deep", as in not touching coderefs
# but actually mutating how the coderef works.

plan 90;

my @log;

sub foo {
    push @log, "foo";
}

sub wrapper {
    push @log, "wrapper before";
    try { callwith() };
    push @log, "wrapper after";
}

sub other_wrapper () {
    push @log, "wrapper2";
    try { callwith() };
}

foo();
is(+@log, 1, "one event logged");
is(@log[0], "foo", "it's foo");

dies-ok { &foo.unwrap() }, 'cannot upwrap a never-wrapped sub.';

@log = ();

wrapper();
is(+@log, 2, "two events logged");
is(@log[0], "wrapper before", "wrapper before");
is(@log[1], "wrapper after", "wrapper after");

@log = ();

my $wrapped = &foo.wrap(&wrapper);

foo();

is @log.join('|'), 'wrapper before|foo|wrapper after', 'logged the correct events';

@log = ();

my $doublywrapped = &foo.wrap(&other_wrapper);
foo();

is(+@log, 4, "four events");
is(@log[0], "wrapper2", "additional wrapping takes effect");
is(@log[1], "wrapper before", "... on top of initial wrapping");

@log = ();

&foo.unwrap($doublywrapped);
foo();

is(+@log, 3, "old wrapped sub was not destroyed");
is(@log[0], "wrapper before", "the original wrapper is still in effect");

@log = ();

&foo.unwrap($wrapped);
foo();

is(+@log, 1, "one events for unwrapped (should be back to original now)");
is(@log[0], "foo", "got execpted value");

@log = ();

$wrapped = &foo.wrap(&wrapper);
$doublywrapped = &foo.wrap(&other_wrapper);
&foo.unwrap($wrapped);
foo();
is(+@log, 2, "out of order unwrapping gave right number of results");
is(@log[0], "wrapper2", "got execpted value from remaining wrapper");
is(@log[1], "foo", "got execpted value from original sub");

dies-ok { &foo.unwrap($wrapped) }, "can't re-unwrap an already unwrapped sub";

#First level wrapping
sub hi { "Hi" };
is( hi, "Hi", "Basic sub." );
my $handle;
lives-ok( { $handle = &hi.wrap({ callsame() ~ " there" }) },
        "Basic wrapping works ");

ok( $handle, "Recieved handle for unwrapping." );
is( hi, "Hi there", "Function produces expected output after wrapping" );

#unwrap the handle
lives-ok { $handle = &hi.unwrap( $handle )}, "unwrap the function";

is( hi, "Hi", "Function is no longer wrapped." );

#Check 10 levels of wrapping
#useless function.
sub levelwrap($n) {
    return $n;
}

# Make sure useless function does it's job.
is( levelwrap( 1 ), 1, "Sanity test." );
is( levelwrap( 2 ), 2, "Sanity test." );

#?rakudo todo 'callwith'
lives-ok { &levelwrap.callwith( 1 )},
    "Check that functions have a 'callwith' that works. ";

#?DOES 20
{
    for (1..10) -> $num {
        lives-ok {
            &levelwrap.wrap({
                callwith( $^t + 1 );
            }),
            " Wrapping #$num"
        }, "wrapping $num";
        is( levelwrap( 1 ), 1 + $num, "Checking $num level wrapping" );
    }
}

#Check removal of wrap in the middle by handle.
sub functionA {
    return 'z';
}
is( functionA(), 'z', "Sanity." );
my $middle;
lives-ok { $middle = &functionA.wrap(sub { return 'y' ~ callsame })},
        "First wrapping lived";
is( functionA(), "yz", "Middle wrapper sanity." );
lives-ok { &functionA.wrap(sub { return 'x' ~ callsame })},
         'Second wraping lived';
is( functionA(), "xyz", "three wrappers sanity." );
lives-ok { &functionA.unwrap( $middle )}, 'unwrap the middle wrapper.';
is( functionA(), "xz", "First wrapper and final function only, middle removed." );

#temporization (end scope removal of wrapping)
sub functionB {
   return 'xxx';
}
{
    is( functionB, "xxx", "Sanity" );
    {
        try {
            temp &functionB.wrap({ 'yyy' });
        };
        is( functionB, 'yyy', 'Check that function is wrapped.' );
    }
    #?rakudo todo 'temp and wrap'
    is( functionB, 'xxx', "Wrap is now out of scope, should be back to normal." );
}
#?rakudo todo 'temp and wrap'
is( functionB, 'xxx', "Wrap is now out of scope, should be back to normal." );


# call to nextsame with nowhere to go
# - Can't use throws-like() here due to difference in what error you get
# - depending on version of Test.rakumod: https://github.com/rakudo/rakudo/pull/743
try {
    my $msg = '{nextsame}() dies properly';
    {nextsame}();
    flunk $msg;
    skip 'Code did not die, can not check exception', 1;
    CATCH {
        default {
            pass $msg;
            isa-ok $_, X::NoDispatcher, 'right exception type (X::NoDispatcher)';
        }
    }
}


{
    sub meet(  $person ) { return "meet $person"  }
    sub greet( $person ) { return "greet $person" }

    my $wrapped;

    for &greet, &meet -> $wrap {
        my $name = $wrap.name;
        $wrap.wrap({ $wrapped = $name; callsame; });
    }

    ok ! $wrapped.defined, 'wrapper test variable is undefined';
    is greet('japhb'), 'greet japhb', 'wrapped greet() works';
    is $wrapped, 'greet', 'wrapper sees lexical from time of wrap (greet)';

    $wrapped = Nil;

    ok ! $wrapped.defined, 'wrapper test variable is undefined';
    is meet('masak'), 'meet masak', 'wrapped meet() works';
    is $wrapped, 'meet', 'wrapper sees lexical from time of wrap (meet)';
}

{
    sub foo() { 1 }
    my $h = &foo.wrap(-> { 1 + callsame });
    is foo(), 2, 'wrap worked (sanity)';
    $h.restore();
    is foo(), 1, 'could unwrap by calling .restore on the handle';
}


{
    my @t = gather {
        sub triangle { take '=' x 3; }
        for reverse ^3 -> $n {
            &triangle.wrap({
                take '=' x $n;
                callsame;
                take '=' x $n;
            });
        }
        triangle();
    }
    is @t.join("\n"), "\n=\n==\n===\n==\n=\n", 'multiple wrappings in a loop';
}


{
    multi multi-to-wrap($x) {
        $x * 2;
    };
    &multi-to-wrap.wrap({
        2 * callsame;
    });
    
    #?rakudo.jvm todo "still returns 10,"
    is multi-to-wrap(5), 20, 'can wrap a multi';
}

{
    my $didfoo;

    my role SomeTrait {
        method apply_handles($attr: Mu $pkg) {
            my $name = $attr.name;
            my $accessor = $name.subst(/^../, '');
            my $r = sub ($obj, |args) is rw {
                my \c := callsame;
                c
            }
            $pkg.^find_method($accessor).wrap($r);
        }
        method foo { $didfoo++ }
    }

    multi trait_mod:<is>(Attribute $var, :$wtf!) {
        die "Must have accessor" unless $var.has_accessor;
        $var.set_rw;
        $var does SomeTrait;
        $var.foo;
    }

    my class foo {
        has $.x is rw is wtf = 16;
    }

    ok $didfoo, "Did foo, capture return";
    my $foo = foo.new;  # x = 16;
    my $bar = foo.new(x => 32);
    is $foo.x, 16, "default works with wrapped accessor, capture return";
    is $bar.x, 32, "BUILD binding works with wrapped accessor, capture return";
    try $bar.x = 64;
    is $bar.x, 64, "assignment works with wrapped accessor, capture return";
}

{
    my $didfoo;

    my role SomeTrait {
        method apply_handles($attr: Mu $pkg) {
            my $name = $attr.name;
            my $accessor = $name.subst(/^../, '');
            my $r = sub ($obj, |args) is rw {
                return-rw callsame;
            }
            $pkg.^find_method($accessor).wrap($r);
        }
        method foo { $didfoo++ }
    }

    multi trait_mod:<is>(Attribute $var, :$wtf!) {
        die "Must have accessor" unless $var.has_accessor;
        $var.set_rw;
        $var does SomeTrait;
        $var.foo;
    }

    my class foo {
        has $.x is rw is wtf = 16;
    }

    ok $didfoo, "Did foo, return callsame";
    my $foo = foo.new;  # x = 16;
    my $bar = foo.new(x => 32);
    is $foo.x, 16, "default works with wrapped accessor, return callsame";
    is $bar.x, 32, "BUILD binding works with wrapped accessor, return callsame";
    try $bar.x = 64;
    is $bar.x, 64, "assignment works with wrapped accessor, return callsame";
}

{
    my $didfoo;

    my role SomeTrait {
        method apply_handles($attr: Mu $pkg) {
            my $name = $attr.name;
            my $accessor = $name.subst(/^../, '');
            my $r = sub ($obj, |args) is rw {
                callsame;
            }
            $pkg.^find_method($accessor).wrap($r);
        }
        method foo { $didfoo++ }
    }

    multi trait_mod:<is>(Attribute $var, :$wtf!) {
        die "Must have accessor" unless $var.has_accessor;
        $var.set_rw;
        $var does SomeTrait;
        $var.foo;
    }

    my class foo {
        has $.x is rw is wtf = 16;
    }

    ok $didfoo, "Did foo, callsame";
    my $foo = foo.new;  # x = 16;
    my $bar = foo.new(x => 32);
    is $foo.x, 16, "default works with wrapped accessor, callsame";
    is $bar.x, 32, "BUILD binding works with wrapped accessor, callsame";
    try $bar.x = 64;
    is $bar.x, 64, "assignment works with wrapped accessor, callsame";
}

{
    my $didfoo;

    my role SomeTrait {
        method apply_handles($attr: Mu $pkg) {
            my $name = $attr.name;
            my $accessor = $name.subst(/^../, '');
            my $r = sub ($obj, |args) is rw {
                nextsame;
            }
            $pkg.^find_method($accessor).wrap($r);
        }
        method foo { $didfoo++ }
    }

    multi trait_mod:<is>(Attribute $var, :$wtf!) {
        die "Must have accessor" unless $var.has_accessor;
        $var.set_rw;
        $var does SomeTrait;
        $var.foo;
    }

    my class foo {
        has $.x is rw is wtf = 16;
    }

    ok $didfoo, "Did foo, nextsame";
    my $foo = foo.new;  # x = 16;
    my $bar = foo.new(x => 32);
    is $foo.x, 16, "default works with wrapped accessor, nextsame";
    is $bar.x, 32, "BUILD binding works with wrapped accessor, nextsame";
    try $bar.x = 64;
    is $bar.x, 64, "assignment works with wrapped accessor, nextsame";
}

# GH #2178
{
    my @order;
    my class C1 {
        method foo {
            @order.push: 'C1';
            nextsame;
        }

        proto method bar (|) {*}
        multi method bar(Str $s) { @order.push: "C1::bar(Str)" };
        multi method bar(Any $v) { @order.push: "C1::bar(Any:{$v.^name})" };
    }

    my class C2 is C1 {
        method foo {
            @order.push: 'C2';
            nextsame;
        }

        multi method bar(Str:D $s) { @order.push: "C2::bar(Str:D)"; callsame }
        multi method bar(Int $i) { @order.push: "C2::bar(Int)"; callsame }
    }

    my class C3 is C2 {
        method foo {
            @order.push: 'C3';
            nextsame;
        }

        multi method bar (Code $c) { @order.push: "C3::bar(Code)"}
    }

    C2.^find_method('foo', :no_fallback).wrap( my method foo { @order.push: 'wrapper'; nextsame } );
    C2.^find_method('bar', :no_fallback).candidates[0].wrap( my method bar (|) { @order.push: 'wrapper::bar'; callsame } );

    my $inst = C3.new;

    $inst.foo;
    is-deeply @order, ['C3', 'wrapper', 'C2', 'C1'], "methods are in order";

    @order = [];
    $inst.bar(42);
    is-deeply @order, ['C2::bar(Int)', 'C1::bar(Any:Int)'], "multi methods with no wraps are in order";

    @order = [];
    $inst.bar("The Answer");
    is-deeply @order, ['C2::bar(Str:D)', 'wrapper::bar', 'C1::bar(Str)'], "multi methods with a wrapped one are in order";

    $inst = C2.new;
    @order = [];
    $inst.foo;

    is-deeply @order, ['wrapper', 'C2', 'C1'], "methods are in order with the first method wrapped";
}

# vim: expandtab shiftwidth=4
