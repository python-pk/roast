use Test;

plan 22;

# L<S12/"Construction and Initialization">

class OwnConstr {
    has $.x = 13;
    my $in_own = 0;
    method own() {
        $in_own++;
        self.bless(:x(42));
    }
    method in_own {
        $in_own;
    }
}
ok OwnConstr.new ~~ OwnConstr, "basic class instantiation";
is OwnConstr.new.x, 13,        "basic attribute access";
# As usual, is instead of todo_is to suppress unexpected succeedings
is OwnConstr.in_own, 0,        "own constructor was not called";

ok OwnConstr.own ~~ OwnConstr, "own construction instantiated its class";
is OwnConstr.own.x, 42,        "attribute was set from our constructor";
is OwnConstr.in_own, 2,        "own constructor was actually called";


# L<"http://www.mail-archive.com/perl6-language@perl.org/msg20241.html">
# provide constructor for single positional argument

class Foo {
  has $.a;

  method new ($self: Str $string) {
    $self.bless(a => $string);
  }
}


ok Foo.new("a string") ~~ Foo, '... our Foo instance was created';

is Foo.new("a string").a, 'a string', "our own 'new' was called";


# Using ".=" to create an object
{
  class Bar { has $.attr }
  my Bar $bar .= new(:attr(42));
  is $bar.attr, 42, "instantiating an object using .= worked (1)";
}
# Using ".=()" to create an object
{
  class Fooz { has $.x }
  my Fooz $f .= new(:x(1));
  is $f.x, 1, "instantiating an object using .=() worked";
}

{
  class Baz { has @.x is rw }
  my Baz $foo .= new(:x(1,2,3));
  lives-ok -> { $foo.x[0] = 3 }, "Array initialized in auto-constructor is not unwritable...";
  is $foo.x[0], 3, "... and keeps its value properly."
}


{
    class RT64116 { has %.env is rw };

    my $a = RT64116.CREATE;

    lives-ok { $a.env = foo => "bar" }, 'assign to attr of .CREATEd class';
    is $a.env<foo>, 'bar', 'assignment works';
}


{
    use MONKEY-TYPING;
    class MonkeyNew { has $.x is rw };
    augment class MonkeyNew {
        method new() {
            self.bless(:x('called'));
        }
    };
    is MonkeyNew.new().x, 'called', 'monkey-typed .new() method is called';
}

{
    class NativeInt {
        has int $.attr;
    }
    lives-ok -> { NativeInt.new(:attr(123)) }, ".new with a native int attribute";
    class NativeNum {
        has num $.attr;
    }
    lives-ok -> { NativeNum.new(:attr(0e0)) }, ".new with a native num attribute";
    class NativeStr {
        has str $.attr;
    }
    lives-ok -> { NativeStr.new(:attr<foo>) }, ".new with a native str attribute";
}

{ 
    class {
        has $.b;
        submethod TWEAK {
            my @a[$!b];
            is-deeply @a, (my @b[42]),
              'can use attributes in TWEAK to declare sized arrays'
        }
    }.new: :42b;

    class {
        has $.b;
        submethod BUILD (:$!b) {
            my @a[$!b];
            is-deeply @a, (my @b[42]),
              'can use attributes in BUILD to declare sized arrays'
        }
    }.new: :42b;
}

# https://irclogs.raku.org/perl6/2018-10-01.html#10:25
# https://github.com/rakudo/rakudo/commit/64137bd21c
{
    class A {
        method bless(*%attrinit) {
            my $o = self.CREATE.BUILDALL(Empty, %attrinit);
            $o
        }
    }
    lives-ok { A.new }, 'can we create with a custom "bless" method';
}


subtest "all parents' attributes are set with .new" => {
    plan 3;
    my class A { has @.a }
    my class B { has @.b }
    my class C { has @.c }
    my class D is A is B {}
    my class E is D is C {}

    with E.new: :a<a b c>, :b<d e f>, :c<g h i> {
        is-deeply .a, [<a b c>], 'ancestor 1';
        is-deeply .b, [<d e f>], 'ancestor 2';
        is-deeply .c, [<g h i>], 'parent';
    }
}

# vim: expandtab shiftwidth=4
