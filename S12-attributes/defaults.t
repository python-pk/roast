use Test;

plan 38;

# L<S12/Attribute default values/The value on the right is evaluated at object build time>

my $got_a_num = 0;  sub get_a_num  { $got_a_num++;  42 }
my $got_a_str = 0;  sub get_a_str  { $got_a_str++;  "Pugs" }

# Everything on the RHS of the = is implicitly a closure.
# Providing a closure means the attribute is a closure!
{
    $got_a_num = 0;
    $got_a_str = 0;

    class Spaceship {
        has $.num  = get_a_num();
        has $.str  = { get_a_str() };
    };

    is $got_a_num, 0, "default should not be called at compile-time";
    is $got_a_str, 0, "default should not be called at compile-time";

    my Spaceship $spaceship .= new;

    is $got_a_num, 1, "default should be called only once in construction";
    is $spaceship.num,  42, "attribute default worked";
    is $got_a_num, 1, "default should be called only once";

    is $got_a_str, 0, "default should not have been called yet";
    ok $spaceship.str ~~ Callable, "attribute default is a closure";
    is $got_a_str, 0, "default should not have been called yet";
    is $spaceship.str()(), "Pugs", "attribute can be called";
    is $got_a_str, 1, "and now get_a_str has run";

    my Spaceship $spaceship2 .= new;

    is $got_a_num, 2, "construction of second object also only calls default closure once";
    is $spaceship2.num,  42, "attribute default worked";
    is $got_a_num, 2, "default should be called only once";

    is $got_a_str, 1, "construction of second object still doesn't call closure";
    is $spaceship2.str.(), "Pugs", "attribute default worked, even called the other way";
    is $got_a_str, 2, "get_a_str now called twice";
}

{
    $got_a_num = 0;
    $got_a_str = 0;

    class Starship {
        has $.num  = get_a_num();
        has $.str  = { get_a_str() };
    };

    is $got_a_num, 0, "default should not be called at compile-time";
    is $got_a_str, 0, "default should not be called at compile-time";

    my Starship $starship .= new(num => 10);

    is $got_a_num, 0, "default should not be called if value provide";
    is $starship.num,  10, "attribute default worked";
    is $got_a_num, 0, "default should still not be called";

    is $got_a_str, 0, "default should not have been called yet";
    ok $starship.str ~~ Callable, "attribute default is a closure";
    is $got_a_str, 0, "default should not have been called yet";
    is $starship.str()(), "Pugs", "attribute can be called";
    is $got_a_str, 1, "and now get_a_str has run";

    my Starship $starship2 .= new(str => "Niecza");

    is $got_a_num, 1, "construction of second object only calls default closure once";
    is $starship2.num,  42, "attribute default worked";
    is $got_a_num, 1, "default should be called only once";

    is $got_a_str, 1, "construction of second object still doesn't call closure";
    is $starship2.str, "Niecza", "attribute default was not used";
    is $got_a_str, 1, "get_a_str now called twice";
}

{
    class Towel {
        has $.self_in_code = { self.echo };

        method echo { "echo" }
    };

    my Towel $towel .= new;

    is $towel.self_in_code()(), "echo", "self is the object being initialized";
}

{
    class Cake {
        has $.a = "echo";
        has $.self_in_code = self.a;
    };

    my Cake $cake .= new;

    is $cake.self_in_code, "echo", "self is the object being initialized";
}


{
    is (42 but role { has int $.x = 100 }).x, 100,
        'Native int default in mixed in role works';
    is (42 but role { has num $.x = 10e0 }).x, 10e0,
        'Native num default in mixed in role works';
    is (42 but role { has str $.x = 'zmrzlina' }).x, 'zmrzlina',
        'Native str default in mixed in role works';
}


{
    class Foo {
        has Int $.a;
        BEGIN ::?CLASS.^attributes.head.set_build: -> |c { "foo" }
    }
    dies-ok { Foo.new }, 'Attribute constraint checked at run-time';
}

# vim: expandtab shiftwidth=4
