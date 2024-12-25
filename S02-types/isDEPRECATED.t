BEGIN %*ENV<RAKUDO_DEPRECATIONS_FATAL>:delete; # disable fatal setting for tests

use Test;

plan 14;

# L<S02/Deprecations>

my $line;

# just a sub
{
    my $a;
    my $awith;
    sub a     is DEPRECATED              { $a++     };
    sub awith is DEPRECATED("'fnorkle'") { $awith++ };

    $line = $?LINE; a();
    is $a, 1, 'was "a" really called';
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation for a()';
Saw 1 occurrence of deprecated code.
================================================================================
Sub a (from GLOBAL) seen at:
  $*PROGRAM, line $line
Please use something else instead.
--------------------------------------------------------------------------------
TEXT

    $line = $?LINE; awith();
    awith();
    is $awith, 2, 'was "awith" really called';
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation for awith()';
Saw 1 occurrence of deprecated code.
================================================================================
Sub awith (from GLOBAL) seen at:
  $*PROGRAM, lines $line,{$line + 1}
Please use 'fnorkle' instead.
--------------------------------------------------------------------------------
TEXT
} #4

# class with auto/inherited new()
{
    class A     is DEPRECATED                  { };
    class Awith is DEPRECATED("'Fnorkle.new'") { };

    $line = $?LINE; A.new;
    #?rakudo todo 'NYI'
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation for A.new';
Saw 1 occurrence of deprecated code.
================================================================================
Method new (from A) seen at:
  $*PROGRAM, line $line
Please use something else instead.
--------------------------------------------------------------------------------
TEXT

    $line = $?LINE; Awith.new;
    Awith.new;
    #?rakudo todo 'NYI'
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation for Awith.new';
Saw 1 occurrence of deprecated code.
================================================================================
Method new (from Awith) seen at:
  $*PROGRAM, lines $line,{$line + 1}
Please use 'Fnorkle.new' instead.
--------------------------------------------------------------------------------
TEXT
} #2

# method in class
{
    my $C;
    my $Cwith;
    class C     { method foo is DEPRECATED          { $C++     } };
    class Cwith { method foo is DEPRECATED("'bar'") { $Cwith++ } };

    $line = $?LINE; C.new.foo;
    is $C, 1, 'was "C.new.foo" really called';
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation for C.new.foo';
Saw 1 occurrence of deprecated code.
================================================================================
Method foo (from C) seen at:
  $*PROGRAM, line $line
Please use something else instead.
--------------------------------------------------------------------------------
TEXT

    $line = $?LINE; Cwith.new.foo;
    Cwith.new.foo;
    is $Cwith, 2, 'was "Cwith.new.foo" really called';
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation Cwith.new.foo';
Saw 1 occurrence of deprecated code.
================================================================================
Method foo (from Cwith) seen at:
  $*PROGRAM, lines $line,{$line + 1}
Please use 'bar' instead.
--------------------------------------------------------------------------------
TEXT
} #4

# class with auto-generated public attribute
{
    class D     { has $.foo is DEPRECATED          };
    class Dwith { has $.foo is DEPRECATED("'bar'") };

    $line = $?LINE; D.new.foo;
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation for D.new.foo';
Saw 1 occurrence of deprecated code.
================================================================================
Method foo (from D) seen at:
  $*PROGRAM, line $line
Please use something else instead.
--------------------------------------------------------------------------------
TEXT

    $line = $?LINE; Dwith.new;
    Dwith.new;
    #?rakudo todo 'NYI'
    is Deprecation.report, qq:to/TEXT/.chop.subst("\r\n", "\n", :g), 'right deprecation Dwith.new.foo';
Saw 1 occurrence of deprecated code.
================================================================================
Method foo (from Dwith) seen at:
  $*PROGRAM, lines $line,{$line + 1}
Please use 'bar' instead.
--------------------------------------------------------------------------------
TEXT
} #2


{
    sub rt120908 is DEPRECATED((sub { "a" })()) { };
    rt120908();
    ok Deprecation.report ~~ m/'Sub rt120908 (from GLOBAL) seen at:'/,
        'right deprecation for rt120908()';
}


{
    sub gh5055() is DEPRECATED('the literal 42') is hidden-from-backtrace { 42 }
	gh5055();
    ok Deprecation.report ~~ m/'Sub gh5055 (from GLOBAL) seen at:'/,
        'right deprecation for gh5055()';
}

# vim: expandtab shiftwidth=4
