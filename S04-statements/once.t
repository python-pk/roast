use Test;

plan 24;

# L<S04/"Phasers"/once "runs separately for each clone">
{
    is(EVAL(q{{
        my $str;
        for 1..2 {
            my $sub = {
                once { $str ~= $_ };
            };
            $sub();
            $sub();
        }
        $str;
    }}), '12');
};

# L<S04/"Phasers"/once "puts off" initialization till
#   "last possible moment">
{
    my $var;
    my $sub = sub ($x) { once { $var += $x } };

    nok $var.defined, 'once {...} has not run yet';

    $sub(2);
    is $var, 2, 'once {} has executed';

    $sub(3);
    is $var, 2, "once {} only runs once for each clone";
}

# L<S04/"Phasers"/once "on first ever execution">
{
    my $str ~= 'o';
    {
        once { $str ~= 'i' }
    }
    is $str, 'oi', 'once {} runs when we first try to use a block';
}

# L<S04/"Phasers"/once "executes inline">

# Execute the tests twice to make sure that once binds to
# the lexical scope, not the lexical position.
for <first second> {
    my $sub = {
        my $str = 'o';
        once { $str ~= 'I' };
        once { $str ~= 'i' };
        ":$str";
    };

    is $sub(), ':oIi', "once block set \$str to 3     ($_ time)";
    is $sub(), ':o', "once wasn't invoked again (1-1) ($_ time)";
    is $sub(), ':o', "once wasn't invoked again (1-2) ($_ time)";
}

# Some behavior occurs where once does not close over the correct
# pad when closures are cloned

my $ran;
for <first second> {
    my $str = 'bana';
    $ran = 0;
    my $sub = {
        once { $ran++; $str ~= 'na' };
    };

    $sub(); $sub();
    is $ran, 1, "once block ran exactly once ($_ time)";
    is $str, 'banana', "once block modified the correct variable ($_ time)";
}

# L<S04/"Phasers"/once "caches its value for all subsequent calls">
{
    my $was_in_once;
    my $sub = {
      my $var = once { $was_in_once++; 23 };
      $var //= 42;
      $var;
    };

    nok $was_in_once.defined, 'once {} has not run yet';
    is $sub(), 23, 'once {} block set our variable (2)';
    is $sub(), 23, 'the returned value of once {} still there';
    is $was_in_once, 1, 'our once {} block was invoked exactly once';
}

# Test that once {} blocks are executed only once even if they return undefined
# (the first implementation ran them twice instead).
{
    my $was_in_once;
    my $sub = { once { $was_in_once++; Mu } };

    nok $sub().defined, 'once {} returned undefined';
    $sub();
    $sub();
    is $was_in_once, 1,
        'our once { ...; Mu } block was invoked exactly once';
}


{
    my $run = False;
    my $i = 0;
    $i += once { $run = True; 21 } for 1, 2;
    ok $run, 'once block in statement modifier for will be run';
    is $i, 42, 'once block in statement modifier evaluates to correct result';
}


throws-like ｢my \z := once 42; z = 100｣, X::Assignment::RO,
    '`once` does not containerize its values';

# vim: expandtab shiftwidth=4
