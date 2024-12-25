use Test;
plan 4;

#L<S03/Smart matching/type membership>
subtest "Basics" => {
    plan 3;
    class Dog {}
    class Cat {}
    class Chihuahua is Dog {} # i'm afraid class Pugs will get in the way ;-)
    role SomeRole { };
    class Something does SomeRole { };

    ok (Chihuahua ~~ Dog), "chihuahua isa dog";
    ok (Something ~~ SomeRole), 'something does dog';
    ok !(Chihuahua ~~ Cat), "chihuahua is not a cat";
}


subtest "RT 71462" => {
    plan 10;
    is 'RT71462' ~~ Str,      True,  '~~ Str returns a Bool (1)';
    is 5         ~~ Str,      False, '~~ Str returns a Bool (2)';
    is 'RT71462' ~~ Int,      False, '~~ Int returns a Bool (1)';
    is 5         ~~ Int,      True,  '~~ Int returns a Bool (2)';
    is 'RT71462' ~~ Set,      False, '~~ Set returns a Bool (1)';
    is set(1, 3) ~~ Set,      True,  '~~ Set returns a Bool (2)';
    is 'RT71462' ~~ Numeric,  False, '~~ Numeric returns a Bool (1)';
    is 5         ~~ Numeric,  True,  '~~ Numeric returns a Bool (2)';
    is &say      ~~ Callable, True,  '~~ Callable returns a Bool (1)';
    is 5         ~~ Callable, False, '~~ Callable returns a Bool (2)';
}


subtest "RT 76610" => {
    plan 2;
    module M { };
    lives-ok { 42 ~~ M }, '~~ module lives';
    ok not $/, '42 is not a module';
}


subtest "GH 3383" => {
    plan 6;
    ok Array        ~~ Positional,        "Array ~~ Positional";
    ok Array[Str]   ~~ Positional,        "Array[Str] ~~ Positional";
    ok Array[Str]   ~~ Positional[Str],   "Array[Str] ~~ Positional[Str]";
    ok Array[Str:D] ~~ Positional,        "Array[Str:D] ~~ Positional";
    ok Array[Str:D] ~~ Positional[Str],   "Array[Str:D] ~~ Positional[Str]";
    ok Array[Str:D] ~~ Positional[Str:D], "Array[Str:D] ~~ Positional[Str:D]";
}

# vim: expandtab shiftwidth=4
