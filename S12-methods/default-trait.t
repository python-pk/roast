use Test;

plan 7;

# L<S12/Candidate Tiebreaking/"only candidates marked with the default
# trait">

class Something {
    multi method doit(Int $x)            { 2 * $x };
    multi method doit(Int $x) is default { 3 * $x };
}

my $obj = Something.new();
lives-ok { $obj.doit(3) }, "'is default' trait makes otherwise ambiguous method dispatch live";
is $obj.doit(3), 9, "'is default' trait tie-breaks on method dispatch";

multi sub doit_sub(Int $x)            { 2 * $x };
multi sub doit_sub(Int $x) is default { 3 * $x };

lives-ok { doit_sub(3) }, "'is default' trait makes otherwise ambiguous method dispatch live";
is doit_sub(3), 9, "'is default' trait on subs";

multi sub slurpy() is default { return 'a' };
multi sub slurpy(*@args)      { return 'b' };   #OK not used

is slurpy(2), 'b', 'basic sanity with arity based dispatch and slurpies';
is slurpy(),  'a', '"is default" trait wins against empty slurpy param';


throws-like 'my $a of Int is default("foo")', X::Parameter::Default::TypeCheck,
    expected => Int,
'error message for default() type mismatch indicates correct expected type';

# vim: expandtab shiftwidth=4
