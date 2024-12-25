use Test;
use lib $?FILE.IO.parent(2).add: 'packages/Test-Helpers';
use Test::Util;

# Nil may be a type now.  Required?

plan 67;

sub empty_sub {}
sub empty_do { do {} }
sub empty_branch_true { if 1 {} else { 1; } }
sub empty_branch_false { if 0 { 1; } else {} }
sub bare_return { return; }
sub rt74448 { EVAL '' }

ok empty_sub()          === Nil, 'empty sub returns Nil';
ok empty_do()           === Nil, 'do {} is Nil';
ok empty_branch_true()  === Nil, 'if 1 {} is Nil';
ok empty_branch_false() === Nil, 'else {} is Nil';
ok bare_return()        === Nil, 'bare return returns Nil';
ok rt74448()            === Nil, 'EVAL of empty string is Nil';

nok Nil.defined, 'Nil is not defined';
ok  ().defined,  '() is defined';
nok (my $x = Nil).defined, 'assigning Nil to scalar leaves it undefined'; #OK
ok (my $y = ()).defined, 'assigning () to scalar results in a defined list'; #OK

nok Nil.so,                  'Nil.so is False';
#?rakudo todo 'returns True/False'
ok Nil.ACCEPTS(Any)  === Nil, 'Nil.ACCEPTS always returns Nil';
ok Nil.JustAnyMethod === Nil, 'Any method on Nil should return Nil (no args)';
ok Nil.JustAnyMethod('meows', 42, 'bars', :foos) === Nil,
    'Any method on Nil should return Nil (with args)';


{
    my $calls;
    sub return_nil { $calls++; return; }

    $calls = 0;
    ok return_nil() === Nil, 'return_nil() === Nil';
    is return_nil().raku, 'Nil', 'return_nil().raku says Nil';
    is $calls, 2, 'return_nil() called twice';

    my $n = return_nil();
    nok $n.defined, 'variable holding nil is not defined';
}

{
    my $x = 0;
    $x++ for Nil;
    is $x, 1, '$Statement for Nil; does one iteration';
}


ok Nil.^mro.gist !~~ rx:i/iter/, "Nil is not any sort of Iter*";


ok (my $rt93980 = Nil) === Any, 'Nil assigned to scalar produces an Any'; #OK

ok (my Str $str93980 = Nil) === Str; #OK

is Nil.gist, 'Nil', 'Nil.gist eq "Nil"';
ok !Nil.new.defined, 'Nil.new is not defined';

{
    subset MyInt of Int where True;
    my MyInt $x = 5;

    lives-ok { $x = Nil }, 'can assign Nil to subsets';
    ok $x === MyInt, 'assigns to subset type object';
}

{
    my $z := Nil;
    ok $z === Nil, 'can bind to Nil';
}

{
    sub f1($x) { } #OK
    #?rakudo todo 'triage'
    throws-like { f1(Nil) },
      Exception, # XXX fix when this starts to fail
      'param: dies for mandatory';

    sub f2(Int $x?) { $x }
    my $z;
    #?rakudo skip 'triage'
    lives-ok { $z = f2(Nil) }, 'param: lives for optional';
    #?rakudo todo 'triage'
    ok $z === Int, '... set to type object';
    my $z2 is default(Nil);
    #?rakudo todo 'triage'
    lives-ok { $z = f2($z2) }, 'param: lives for optional from var';
    #?rakudo todo 'triage'
    ok $z === Int, '... set to type object';

    sub f3($x = 123) { $x }
    lives-ok { $z = f3(Nil) }, 'param: lives for with-default';
    #?rakudo todo 'triage'
    is $z, 123, '... set to default';

    sub f4($x = Nil) { $x }
    ok f4() === Nil, 'can use Nil as a default (natural)';
    ok f4(Nil) === Nil, 'can use Nil as a default (nil-triggered)';
}

{
    ok $/ === Nil, '$/ is by default Nil';
    ok $! === Nil, '$! is by default Nil';
    ok $_ === Any, '$_ is by default Any';

    ok $/.VAR.default === Nil, '$/ has Nil as default';
    ok $!.VAR.default === Nil, '$! has Nil as default';
    ok $_.VAR.default === Any, '$_ has Any as default';
}

# calling methods and similar things on Nil should return Nil again
{
    sub niltest { return Nil };

    ok niltest()           === Nil, "sanity";
    ok niltest.foo         === Nil, "calling methods on Nil gives Nil again I";
    ok niltest.foo.bar     === Nil, "calling methods on Nil gives Nil again II";
    ok niltest.foo.bar.baz === Nil, "calling methods on Nil gives Nil again III";

    ok niltest[0]          === Nil, "array access on Nil gives Nil again I";
    ok niltest[0][2]       === Nil, "array access on Nil gives Nil again II";
    ok niltest[0][2][4]    === Nil, "array access on Nil gives Nil again III";

    ok niltest<foo>         === Nil, "hash access on Nil gives Nil again I";
    ok niltest<foo><bar>    === Nil, "hash access on Nil gives Nil again II";
    ok niltest<foo><bar><A> === Nil, "hash access on Nil gives Nil again II";

    ok niltest.foo.bar.<bar>.[12].[99].<foo> === Nil, ".<> and .[] works properly, too";
}

{ # coverage; 2016-10-14
    throws-like { Nil.BIND-POS   }, Exception, '.BIND-POS throws';
    throws-like { Nil.BIND-KEY   }, Exception, '.BIND-KEY throws';
    throws-like { Nil.ASSIGN-POS }, Exception, '.ASSIGN-POS throws';
    throws-like { Nil.ASSIGN-KEY }, Exception, '.ASSIGN-KEY throws';
    throws-like { Nil.STORE      }, Exception, '.STORE throws';
    throws-like { Nil.push       }, Exception, '.push throws';
    throws-like { Nil.append     }, Exception, '.append throws';
    throws-like { Nil.unshift    }, Exception, '.unshift throws';
    throws-like { Nil.prepend    }, Exception, '.prepend throws';

    {
        CONTROL { when CX::Warn { pass 'Nil.ords warns'; .resume; } }
        is-eqv Nil.ords, ().Seq, 'Nil.ords gives an empty Seq';
    }

    {
        CONTROL { when CX::Warn { pass 'Nil.chrs warns'; .resume; } }
        is-deeply Nil.chrs, "\0", 'Nil.chrs gives a null byte';
    }
}

{
    my class F {
        has Exception $!e;
        method set($a) {
            $!e=$a
        }
        method check() {
            so $!e
        }
    }
    my $f = F.new();
    $f.set(Nil);
    $f.set(X::AdHoc.new());
    ok $f.check(), 'Assignment to scalar after assigning Nil takes effect';
}

# vim: expandtab shiftwidth=4
