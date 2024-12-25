use Test;

# L<S02/Bare identifiers/"There are no barewords in Perl">

plan 7;

throws-like { EVAL 'class A { }; class A { }' },
  X::Redeclaration,
  "Can't redeclare a class";
lives-ok { EVAL 'class G { ... }; class G { }' },
  'can redeclare stub classes';
throws-like { EVAL 'class B is C { }' },
  X::Inheritance::UnknownParent,
  "Can't inherit from a non-existing class";
throws-like { EVAL 'class D does E { }' },
  X::InvalidType,
  "Can't do a non-existing role";
throws-like { EVAL 'my F $x;' },
  X::Comp::Group,
  'Unknown types in type constraints are an error';

# integration tests - in Rakudo some class names from Parrot leaked through,

# so you couldn't name a class 'Task' - RT #61128


lives-ok { EVAL 'class Task { has $.a }; Task.new(a => 3 );' },
  'can call a class "Task" - RT #61128';

# L<S02/Bare identifiers/If a postdeclaration is not seen, the compile fails at CHECK
# time>

throws-like { EVAL q[caffeine(EVAL('sub caffeine($a){~$a}'))] },
  X::Undeclared::Symbols,
  'Post declaration necessary';

# vim: ft=perl6


# vim: expandtab shiftwidth=4
