use Test;

plan 27;

my $scalar;
ok $scalar.WHAT === Any, 'unitialized $var does Mu';
$scalar = 1;
ok $scalar ~~ Any, 'value contained in a $var does Mu';



{
    my @array;
    does-ok @array, Positional, 'unitialized @var does Positional';
}
{
    my @array = [];
    does-ok @array, Positional, 'value contained in a @var does Positional';
}
{
    my @array = 1;
    does-ok @array, Positional, 'generic val in a @var is converted to Positional';
}

does-ok EVAL('List'), Positional, "List does Positional";
does-ok EVAL('Array'), Positional, "Array does Positional";
does-ok EVAL('Range'), Positional, "Range does Positional";
does-ok EVAL('Buf'), Positional, "Buf does Positional";
#?rakudo todo "Capture does Positional"
does-ok EVAL('Capture'), Positional, "Capture does Positional";

my %hash;
does-ok %hash, Associative, 'uninitialized %var does Associative';
%hash = a => 1;
does-ok %hash, Associative, 'value in %var does Associative';

does-ok EVAL('Pair'), Associative, "Pair does Associative";
does-ok EVAL('Set'), Associative, "Set does Associative";
does-ok EVAL('Bag'), Associative, "Bag does Associative";
does-ok EVAL('QuantHash'), Associative, "QuantHash does Associative";
#?rakudo todo "Capture does Associative"
does-ok EVAL('Capture'), Associative, "Capture does Associative";


sub foo {}
does-ok &foo, Callable, 'a Sub does Callable';

{
    my method meth {}
    does-ok &meth, Callable, 'a Method does Callable';
}
proto mul(|) {*}
multi mul {}
does-ok &mul, Callable, 'a multi does Callable';
proto pro {}
does-ok &pro, Callable, 'a proto does Callable';

# &token, &rule return a Method?
{
    my token bar {<?>}
    does-ok &bar, Callable, 'a token does Callable';
    my rule baz {<?>}
    does-ok &baz, Callable, 'a rule does Callable';
    # &quux returns a Sub ?
    use experimental :macros;
    macro quux {}
    does-ok &quux, Callable, 'a macro does Callable';
}


{
    sub a { return 'a' };
    sub b { return 'b' };
    dies-ok { &a = &b }, 'cannot just assign &b to &a';
    is a(), 'a', 'and the correct function is still in place';

}


{
    sub f() { '42' };
    my $x = &f;
    is &$x(), '42', 'can use &$x() for invoking';
}

# vim: expandtab shiftwidth=4
