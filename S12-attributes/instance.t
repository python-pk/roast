use v6;

use Test;

plan 90;

=begin pod

Class attributes tests from L<S12/Attributes>

=end pod

eval_dies_ok 'has $.x;', "'has' only works inside of class|role definitions";

# L<S12/Attributes/the automatic generation of an accessor method of the same name>

class Foo1 { has $.bar; };

{
    my $foo = Foo1.new();
    ok($foo ~~ Foo1, '... our Foo1 instance was created');
    my $val;
    #?pugs 2 todo 'feature'
    lives_ok {
        $val = $foo.can("bar")
    }, '.. checking autogenerated accessor existence';
    ok($val, '... $foo.can("bar") should have returned true');
    ok($foo.bar() ~~ undef, '.. autogenerated accessor works');
    ok($foo.bar ~~ undef, '.. autogenerated accessor works w/out parens');    
}

# L<S12/Attributes/Pseudo-assignment to an attribute declaration specifies the default>

{
    class Foo2 { has $.bar = "baz"; };
    my $foo = Foo2.new();
    ok($foo ~~ Foo2, '... our Foo2 instance was created');
    ok($foo.can("bar"), '.. checking autogenerated accessor existence');
    is($foo.bar(), "baz", '.. autogenerated accessor works');
    is($foo.bar, "baz", '.. autogenerated accessor works w/out parens');
    dies_ok { $foo.bar = 'blubb' }, 'attributes are ro by default';
}

# L<S12/Attributes/making it an lvalue method>


#?pugs todo 'instance attributes'
{
    class Foo3 { has $.bar is rw; };
    my $foo = Foo3.new();
    ok($foo ~~ Foo3, '... our Foo3 instance was created');
    my $val;
    lives_ok {
        $val = $foo.can("bar");
    }, '.. checking autogenerated accessor existence';
    ok $val, '... $foo.can("bar") should have returned true';
    ok($foo.bar() ~~ undef, '.. autogenerated accessor works');
    lives_ok {
        $foo.bar = "baz";
    }, '.. autogenerated mutator as lvalue works';
    is($foo.bar, "baz", '.. autogenerated mutator as lvalue set the value correctly');    
    #?rakudo 2 todo 'oo'
    lives_ok { $foo.bar("baz2"); }, '.. autogenerated mutator works as method';
    is $foo.bar, "baz2", '.. autogenerated mutator as method set the value correctly';
}

# L<S12/Attributes/Private attributes use an exclamation to indicate that no public accessor is>


{
    class Foo4 { has $!bar; };
    my $foo = Foo4.new();
    ok($foo ~~ Foo4, '... our Foo4 instance was created');
    #?pugs eval 'todo'
    ok(!$foo.can("bar"), '.. checking autogenerated accessor existence', );
}


{
    class Foo4a { has $!bar = "baz"; };
    my $foo = Foo4a.new();
    ok($foo ~~ Foo4a, '... our Foo4a instance was created');
    #?pugs eval 'todo'
    ok(!$foo.can("bar"), '.. checking autogenerated accessor existence');
}


# L<S12/Attributes>


{
    class Foo5 {
        has $.tail is rw;
        has @.legs;
        has $!brain;

        method set_legs  (*@legs) { @.legs = @legs }
        method inc_brain ()      { $!brain++ }
        method get_brain ()      { $!brain }
    };
    my $foo = Foo5.new();
    ok($foo ~~ Foo5, '... our Foo5 instance was created');
        
    lives_ok {
        $foo.tail = "a";
    }, "setting a public rw attribute";
    is($foo.tail, "a", "getting a public rw attribute");
    
    #?rakudo 2 todo 'oo'
    lives_ok { $foo.set_legs(1,2,3) }, "setting a public ro attribute (1)";
    is($foo.legs.[1], 2, "getting a public ro attribute (1)");
    
    dies_ok {
        $foo.legs = (4,5,6);
    }, "setting a public ro attribute (2)";
    #?rakudo todo 'oo'
    is($foo.legs.[1], 2, "getting a public ro attribute (2)");
    
    lives_ok { $foo.inc_brain(); }, "modifiying a private attribute (1)";
    is($foo.get_brain, 1, "getting a private attribute (1)");
    lives_ok {
        $foo.inc_brain();
    },  "modifiying a private attribute (2)";
    is($foo.get_brain, 2, "getting a private attribute (2)");
}

# L<S12/Construction and Initialization/If you name an attribute as a parameter, that attribute is initialized directly, so>


#?rakudo skip 'parse fail'
{
    class Foo6 {
        has $.bar is rw;
        has $.baz;
        has $!hidden;

        submethod BUILD($.bar, $.baz, $!hidden) {}
        method get_hidden() { $!hidden }
    }

    my $foo = Foo6.new(bar => 1, baz => 2, hidden => 3);
    ok($foo ~~ Foo6, '... our Foo6 instance was created');
        
    is($foo.bar,        1, "getting a public rw attribute (1)"  );
    is($foo.baz,        2, "getting a public ro attribute (2)"  );
    is($foo.get_hidden, 3, "getting a private ro attribute (3)" );
}

# check that doing something in submethod BUILD works

#?rakudo skip 'parse fail'
{
    class Foo6a {
        has $.bar is rw;
        has $.baz;
        has $!hidden;

        submethod BUILD ($!hidden, $.bar = 10, $.baz?) {
            $.baz = 5;
        }
        method get_hidden() { $!hidden }
    }

    my $foo = Foo6a.new(bar => 1, hidden => 3);
    ok($foo ~~ Foo6a, '... our Foo6a instance was created');
        
    is($foo.bar,        1, "getting a public rw attribute (1)"  );
    is($foo.baz,        5, "getting a public rw attribute (2)"  );
    is($foo.get_hidden, 3, "getting a private ro attribute (3)" );
}

# check that assignment in submethod BUILD works with a bare return, too
#?rakudo skip 'parse fail'
{
    class Foo6b {
        has $.bar is rw;
        has $.baz;

        submethod BUILD ($.bar = 10, $.baz?) {
            $.baz = 9;
            return;
        }
    }

    my $foo = Foo6b.new(bar => 7);
    ok($foo ~~ Foo6b, '... our Foo6b instance was created');
        
    is($foo.bar,        7, "getting a public rw attribute (1)"  );
    is($foo.baz,        9, "getting a public rw attribute (2)"  );
}

# L<A12/Default Values>
ok eval('class Foo7 { has $.attr = 42 }; 1'), "class definition worked";
is eval('Foo7.new.attr'), 42,              "default attribute value (1)";

# L<A12/Default Values/is equivalent to this:>
#?rakudo 4 skip 'attribute initialization'
ok eval('class Foo8 { has $.attr is build(42) }; 1'),
  "class definition using 'is build' worked";
is eval('Foo8.new.attr'), 42, "default attribute value (2)";

# L<A12/Default Values/is equivalent to this:>
ok eval('class Foo9 { has $.attr will build(42) }; 1'),
  "class definition using 'will build' worked";
is eval('Foo9.new.attr'), 42, "default attribute value (3)";

#?rakudo skip 'lexicals visible outside eval'
{
    my $was_in_supplier = 0;
    sub forty_two_supplier() { $was_in_supplier++; 42 }
    ok eval('class Foo10 { has $.attr = { forty_two_supplier() } }; 1'),
    'class definition using "= {...}" worked';
    is eval('Foo10.new.attr'), 42, "default attribute value (4)";
    is      $was_in_supplier, 1,  "forty_two_supplier() was actually executed (1)";

# The same, but using 'is build {...}'
# XXX: Currently hard parsefail!
    ok eval('class Foo11 { has $.attr is build { forty_two_supplier() } }; 1'),
    'class definition using "is build {...}" worked';
    is eval('Foo11.new.attr'), 42, "default attribute value (5)";
    is      $was_in_supplier, 2,  "forty_two_supplier() was actually executed (2)";

# The same, but using 'will build {...}'
# XXX: Currently hard parsefail!
    ok eval('class Foo12 { has $.attr will build { forty_two_supplier() } }; 1'),
    "class definition using 'will build {...}' worked";
    is eval('Foo11.new.attr'), 42, "default attribute value (6)";
    is      $was_in_supplier, 3,  "forty_two_supplier() was actually executed (3)";
}

# check that doing something in submethod BUILD works
#?rakudo skip 'parse failure'
{
    class Foo7 {
    has $.bar;
    has $.baz;

    submethod BUILD ($.bar = 5, $baz = 10 ) {
        $.baz = 2 * $baz;
    }
    }

    my $foo7 = Foo7.new();
    is( $foo7.bar, 5,
        'optional attribute should take default value without passed-in value' );
    is( $foo7.baz, 20,
        '... optional non-attribute should too' );
    $foo7    = Foo7.new( :bar(4), :baz(5) );
    is( $foo7.bar, 4,
        'optional attribute should take passed-in value over default' );
    is( $foo7.baz, 10,
        '... optional non-attribute should too' );
}


# check that args are passed to BUILD
#?rakudo skip 'submethod parsing'
{
    class Foo8 {
        has $.a;
        has $.b;
        
        submethod BUILD(:$foo, :$bar) {
            $.a = $foo;
            $.b = $bar;
        }
    }

    my $foo = Foo8.new(foo => 'c', bar => 'd');
    ok($foo.isa(Foo8), '... our Foo8 instance was created');
        
    is($foo.a, 'c', 'BUILD received $foo');
    is($foo.b, 'd', 'BUILD received $bar');
}

# check mixture of positional/named args to BUILD

#?rakudo skip 'submethod parsing'
{
    class Foo9 {
        has $.a;
        has $.b;
        
        submethod BUILD($foo, :$bar) {
            $.a = $foo;
            $.b = $bar;
        }
    }

    dies_ok({ Foo9.new('pos', bar => 'd') }, 'cannot pass positional to .new');
}

# check $self is passed to BUILD
#?rakudo skip 'submethod parsing'
{
    class Foo10 {
    has $.a;
    has $.b;
    has $.c;
    
    submethod BUILD(Class $self: :$foo, :$bar) {
        $.a = $foo;
        $.b = $bar;
        $.c = 'y' if $self.isa(Foo10);
    }
    }

    {
        my $foo = Foo10.new(foo => 'c', bar => 'd');
        ok($foo.isa(Foo10), '... our Foo10 instance was created');
        
        is($foo.a, 'c', 'BUILD received $foo');
        is($foo.b, 'd', 'BUILD received $bar');
        is($foo.c, 'y', 'BUILD received $self');
    }
}

{
    class WHAT_ref {  };
    class WHAT_test {
        has WHAT_ref $.a;
        has WHAT_test $.b is rw;
    }
    my $o = WHAT_test.new(a => WHAT_ref.new(), b => WHAT_test.new());
    is $o.a.WHAT, 'WHAT_ref', '.WHAT on attributes';
    is $o.b.WHAT, 'WHAT_test', '.WHAT on attributes of same type as class';
    my $r = WHAT_test.new();
    #?rakudo 2 todo 'RT #61100'
    lives_ok {$r.b = $r}, 'type check on recursive data structure';
    is $r.b.WHAT, 'WHAT_test', '.WHAT on recursive data structure';

}

# Tests for clone.
{
    class CloneTest { has $.x is rw; has $.y is rw; }
    my $a = CloneTest.new(x => 1, y => 2);
    my $b = $a.clone();
    is $b.x, 1, 'attribute cloned';
    is $b.y, 2, 'attribute cloned';
    $b.x = 3;
    is $b.x, 3, 'changed attribute on clone...';
    is $a.x, 1, '...and original not affected';
    my $c = $a.clone(x => 42);
    is $c.x, 42, 'clone with parameters...';
    is $a.x, 1, '...leaves original intact...';
    is $c.y, 2, '...and copies what we did not change.';
}

# tests for *-1 indexing on classes, RT #61766
{
    class ArrayAttribTest {
        has @.a is rw;
        method init {
            @.a = <a b c>;
        }
        method m0 { @.a[0] };
        method m1 { @.a[*-2] };
        method m2 { @.a[*-1] };
    }
    my $o = ArrayAttribTest.new;
    $o.init;
    is $o.m0, 'a', '@.a[0] works';
    #?rakudo 2 skip 'RT #61766'
    is $o.m1, 'b', '@.a[*-2] works';
    is $o.m2, 'c', '@.a[*-2] works';
}

{
    class AttribWriteTest {
        has @.a;
        has %.h; 
        method set_array1 {
            @.a = <c b a>;
        }
        method set_array2 {
            @!a = <c b a>;
        }
        method set_hash1 {
            %.h = (a => 1, b => 2);
        }
        method set_hash2 {
            %!h = (a => 1, b => 2);
        }
    }

    my $x = AttribWriteTest.new; 
    # see Larry's reply to 
    # http://groups.google.com/group/perl.perl6.language/browse_thread/thread/2bc6dfd8492b87a4/9189d19e30198ebe?pli=1
    # on why these should fail.
    dies_ok { $x.set_array1 }, 'can not assign to @.array attribute';
    dies_ok { $x.set_hash1 },  'can not assign to %.hash attribute';
    lives_ok { $x.set_array2 }, 'can assign to @!array attribute';
    lives_ok { $x.set_hash2 },  'can assign to %!hash attribute';

}
# vim: ft=perl6
