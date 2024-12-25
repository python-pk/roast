use Test;

plan 43;

=begin pod

Very basic class tests from L<S12/Classes>

=end pod

# L<S12/Classes>
class Foo {}

is Foo.raku, 'Foo', 'Classname.raku produces the class name';
is Foo.new.raku, 'Foo.new', 'Classname.new.raku just adds .new';

my $foo = Foo.new();
ok($foo ~~ Foo, '... smartmatch our $foo to the Foo class');

# note that S12 says that .isa() should be called on metaclasses.
# However, making it an object .isa() means that classes are free to
# override the behaviour without playing with the metamodel via traits
ok($foo.isa(Foo), '.isa(Foo)');
ok($foo.isa(::Foo), '.isa(::Foo)');
ok($foo.isa("Foo"), '.isa("Foo")');
ok(!$foo.isa("Bar"), '!.isa("Bar")');

{
    my $foo_clone = $foo.clone();
    ok($foo_clone ~~ Foo, '... smartmatch our $foo_clone to the Foo class');
}

# Definedness of proto-objects and objects.
ok(!Foo.defined,    'proto-objects are undefined');
my Foo $ut1;
ok(!$ut1.defined,   'proto-objects are undefined');
ok(Foo.new.defined, 'instances of the object are defined');

class Foo::Bar {}

my $foo_bar = Foo::Bar.new();
ok($foo_bar ~~ Foo::Bar, '... smartmatch our $foo_bar to the Foo::Bar class');

ok($foo_bar.isa(Foo::Bar), '.isa(Foo::Bar)');
ok(!$foo_bar.isa(::Foo), '!Foo::Bar.new.isa(::Foo)');


# L<S12/Classes/An isa is just a trait that happens to be another class>
class Bar is Foo {}

ok(Bar ~~ Foo, '... smartmatch our Bar to the Foo class');

my $bar = Bar.new();
ok($bar ~~ Bar, '... smartmatch our $bar to the Bar class');
ok($bar.isa(Bar), "... .isa(Bar)");
ok($bar ~~ Foo, '... smartmatch our $bar to the Foo class');
ok($bar.isa(Foo), "new Bar .isa(Foo)");

{
    my $bar_clone = $bar.clone();
    ok($bar_clone ~~ Bar, '... smartmatch our $bar_clone to the Bar class');
    ok($bar_clone.isa(Bar), "... .isa(Bar)");
    ok($bar_clone ~~ Foo, '... smartmatch our $bar_clone to the Foo class');
    ok($bar_clone.isa(Foo), "... .isa(Foo)");
}

# Same, but with the "also is Foo" declaration inline
{
    class Baz { also is Foo }
    ok(Baz ~~ Foo, '... smartmatch our Baz to the Foo class');
    my $baz = Baz.new();
    ok($baz ~~ Baz, '... smartmatch our $baz to the Baz class');
    ok($baz.isa(Baz), "... .isa(Baz)");
}

# test that lcfirst class names and ucfirst method names are allowed

{
    class lowerCase {
        method UPPERcase {
            return 'works';
        }
    }
    is lowerCase.new.UPPERcase, 'works',
       'type distinguishing is not done by case of first letter';
}

throws-like 'my $x; $x ~~ NonExistingClassName', X::Undeclared::Symbols,
    'die on non-existing class names';

# you can declare classes over vivified namespaces, but not over other classes

class One::Two::Three { }  # auto-vivifies package One::Two
class One::Two { }
ok(One::Two.new, 'created One::Two after One::Two::Three');
dies-ok { EVAL 'class One::Two { }' }, 'cannot redeclare an existing class';

eval-lives-ok q[BEGIN {class Level1::Level2::Level3 {};}; class Level1::Level2 {};], 'A after A::B';

{
    class A61354_1 {
        EVAL('method x { "OH HAI" }')
    };
    is A61354_1.x, "OH HAI", "can just use EVAL to add method to class";
}


{
    class class {}
    isa-ok( class.new, 'class' );
}


throws-like 'class Romeo::Tango {}; Romeo::Juliet.rt64686', Exception,
             'call to method in undeclared A::B dies after class A::C defined';


throws-like 'class WritableSelf { method f { self = 5 } }; WritableSelf.new.f',
    X::Assignment::RO, 'self is not writable';


eval-lives-ok 'class Test1 { class A {};}; class Test2 {class A {};};',
                'Nested classes in different classes can have the same name';


{
    my $x = class Named { };
    isa-ok $x, Named, 'named class declaration returns the class object';
}


{
    eval-lives-ok 'Rat.^add_method("lol", method ($what) { say "lol$what" }) ~~ Method',
          'add_method returns a Method object';
}


{
    my $rt72338;
    class x {
        multi method y { self.y("void") }
        multi method y (Str $arg) { $rt72338 = $arg }
    }
    x.new.y;
    is $rt72338, 'void',
        'no need to add a semicolon after closing brace of class definition followed by newline';
}

is class :: { method foo { 42 }}.foo, 42, "Can call method on class definition without parens";



throws-like 'class RT124017_A:D {}', X::Syntax::Type::Adverb,
             "RT124017 - can't declare Foo:D";


throws-like 'class RT124017_B:no_such_adverb {}', X::Syntax::Type::Adverb,
             "RT124017 - can't declare Foo:no-such-adverb";

{
    eval-lives-ok 'class Adverbed:auth<random_auth>:ver<0.0.1> { }', 'can declare class with :auth and :ver adverbs';
}

# vim: expandtab shiftwidth=4
