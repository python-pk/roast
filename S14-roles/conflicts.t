use Test;

plan 12;

=begin pod

Conflict resolution role tests, see L<S14/Roles>

=end pod

# L<S14/Roles>

my ($was_in_sentry_shake, $was_in_pet_shake, $was_in_general_shake) = 0, 0, 0;
role Sentry { method shake() { $was_in_sentry_shake++; "A" } }
role Pet    { method shake() { $was_in_pet_shake++;    "B" } }

class General does Sentry does Pet {

    method shake(Str $what) {
        $was_in_general_shake++;
        given $what {
            when "sentry" { return self.Sentry::shake() }
            when "pet"    { return self.Pet::shake()    }
        }
    }
}
lives-ok {Pet.new}, "role and class definition worked";

my $a;
ok(($a = General.new()),      "basic class instantiation works");
is $a.shake("sentry"), "A", "conflict resolution works (1-1)";
is      $was_in_general_shake,  1, "conflict resolution works (1-2)";
is      $was_in_sentry_shake,   1, "conflict resolution works (1-3)";
# As usual, is instead of todo_is to avoid unexpected suceedings.
is      $was_in_pet_shake,      0, "conflict resolution works (1-4)";
is $a.shake("pet"),    "B", "conflict resolution works (2-1)";
is      $was_in_general_shake,  2, "conflict resolution works (2-2)";
is      $was_in_sentry_shake,   1, "conflict resolution works (2-3)";
is      $was_in_pet_shake,      1, "conflict resolution works (2-4)";


throws-like q[
    role R1 { method !foo() { 1 }}
    role R2 { method !foo() { 2 } }
    class A does R1 does R2 { }
    ], Exception, 'private roles can cause conflicts too';


throws-like q[
    role R { has $.grfuffle };
    role S does R { has $.grfuffle };
    S.new
    ], Exception, :message{.lc.contains: all <attribute conflict grfuffle>},
'attribute conflict with pun';

# vim: expandtab shiftwidth=4
