use Test;

plan 28;

=begin pod

Parameterized role tests, see L<S14/Roles>

Might need some more review and love --moritz

=end pod

# L<S14/Run-time Mixins/may be parameterized>
role InitialAttribVal[$val] {
    has $.attr = $val;
}

my $a = 0;
lives-ok {$a does InitialAttribVal[42]},
  "imperative does to apply a parametrized role (1)";
is $a.attr, 42,
  "attribute was initialized correctly (1)";
ok $a.HOW.does($a, InitialAttribVal),
  ".HOW.does gives correct information (1-1)";
ok $a.^does(InitialAttribVal),
  ".^does gives correct information (1-1)";
ok $a.HOW.does($a, InitialAttribVal[42]),
  ".HOW.does gives correct information (1-2)";
ok $a.^does(InitialAttribVal[42]),
  ".^does gives correct information (1-2)";

my $b = 0;
lives-ok { $b does InitialAttribVal[23] },
  "imperative does to apply a parametrized role (2)";
is $b.attr, 23,
  "attribute was initialized correctly (2)";
ok $b.HOW.does($b, InitialAttribVal),
  ".HOW.does gives correct information (2-1)";
ok $b.^does(InitialAttribVal),
  ".^does gives correct information (2-1)";
ok $b.HOW.does($b, InitialAttribVal[23]),
  ".HOW.does gives correct information (2-2)";
ok $b.^does(InitialAttribVal[23]),
  ".^does gives correct information (2-2)";



# L<S14/Parametric Roles/main type is generic by default>
role InitialAttribType[::vartype] {
    method hi(vartype $foo) { 42 }   #OK not used
}
my $c = 0;
lives-ok { $c does InitialAttribType[Code] },
  "imperative does to apply a parametrized role (3)";
ok $c.HOW.does($c, InitialAttribType),
  ".HOW.does gives correct information (3-1)";
ok $c.^does(InitialAttribType),
  ".^does gives correct information (3-1)";
ok $c.HOW.does($c, InitialAttribType[Code]),
  ".HOW.does gives correct information (3-2)";
ok $c.^does(InitialAttribType[Code]),
  ".^does gives correct information (3-2)";
is $c.hi(sub {}), 42,
  "type information was processed correctly (1)";
dies-ok { $c.hi("not a code object") },
  "type information was processed correctly (2)";


# Parameterized role using both a parameter which will add to the "long name"
# of the role and one which doesn't.
# (Explanation: This one is easier. The two attributes $.type and $.name will
# be predefined (using the role parameterization). The $type adds to the long
# name of the role, $name does not. Such:
#   my $a does InitialAttribBoth["foo", "bar"];
#   my $b does InitialAttribBoth["foo", "grtz"];
#   $a ~~ InitialAttribBoth                ==> true
#   $b ~~ InitialAttribBoth                ==> true
#   $a ~~ InitialAttribBoth["foo"]         ==> true
#   $b ~~ InitialAttribBoth["foo"]         ==> true
#   $a ~~ InitialAttribBoth["foo", "bar"]  ==> false
#   $b ~~ InitialAttribBoth["foo", "grtz"] ==> false
# Heavy stuff, eh?)
  role InitialAttribBoth[Str $type;; Str $name] {
    has $.type = $type;
    has $.name = $name;
  }
my $d = 0;
lives-ok { $d does InitialAttribBoth["type1", "name1"] },
  "imperative does to apply a parametrized role (4)";
ok $d.HOW.does($d, InitialAttribBoth),
  ".HOW.does gives correct information (4-1)";
ok $d.^does(InitialAttribBoth),
  ".^does gives correct information (4-1)";
#?rakudo 2 todo '.does with parametric roles'
ok !$d.HOW.does($d, InitialAttribBoth["type1", "name1"]),
  ".HOW.does gives correct information (4-3)";
ok !$d.^does(InitialAttribBoth["type1", "name1"]),
  ".^does gives correct information (4-3)";
is $d.type, "type1", ".type works correctly";
is $d.name, "name1", ".name works correctly";


{
    role A [ :$a = 1, :$b = $a * 2] {
        method foo { $a ~ "-" ~ $b }
    }
    role B does A[:a(1)] { };
    role C does A[:a(2)] { };
    is B.new.foo, '1-2',
        'Parametric role used first time uses correct default value';
    is C.new.foo, '2-4',
        'Parametric role used a second time uses correct default value';
}

# vim: expandtab shiftwidth=4
