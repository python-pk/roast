use Test;
plan 13;

# L<S13/Type Casting/"whose name is a declared type, it is taken as a coercion
# to that type">

class CoercionTest {
    method Stringy  { "foo" };
    method Numeric  { 1.2   };
}

my $o = CoercionTest.new();

is ~$o, 'foo', 'method Stringy takes care of correct stringification';
ok +$o == 1.2, 'method Numeric takes care of correct numification';


{
    class RT69378 {
        has $.x = 'working';
        method Str() { $.x }
    }
    is RT69378.new.Str, 'working', 'call to .Str works';

    class RT69378str is Cool {
        has $.a = 'RT #69378';
        method Str() { $.a }
    }
    is RT69378str.new.a, 'RT #69378', 'call to RT69378str.new properly initializes $.a';
    is RT69378str.new.Str, 'RT #69378', 'call to .Str works on "class is Str"';
    is Str(RT69378str.new), 'RT #69378', 'Str(...) coercion syntax calls our .Str too';
    ok Int() == 0, 'Int()';
}

is 1.Str.Str, "1", ".Str can be called on Str";
is "hello".Str, "hello", ".Str can be called on Str";

{
    # Not sure how to set the derived Str portion to a value, but that would be an
    # additional useful test here.
    class DerivedFromStr is Str {
        has $.a;
    }
    isa-ok DerivedFromStr.new, DerivedFromStr, 'DerivedFromStr.new isa DerivedFromStr';
    isa-ok DerivedFromStr.new, Str, 'DerivedFromStr.new isa DerivedFromStr';
    isa-ok DerivedFromStr.new.Str, DerivedFromStr, 'DerivedFromStr.new.Str isa DerivedFromStr';
    isa-ok DerivedFromStr.new.Str, Str, 'DerivedFromStr.new.Str isa Str';
}

# vim: expandtab shiftwidth=4
