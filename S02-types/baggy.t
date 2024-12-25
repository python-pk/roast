use Test;

plan 9;

# Tests of the Baggy role

{ # coverage; 2016-09-23
    my class Foo does Baggy {}
    my $b = Foo.new: <a a b>;
    isnt $b.WHICH, Bag.new(<a a b>).WHICH, '.WHICH';
    is-deeply $b.invert.sort(*.key).list, (1 => "b", 2 => "a"), '.invert';
    is-deeply $b.SetHash, SetHash.new(<a b>),   '.SetHash';
}


{
    subtest 'cloned BagHash gets its own elements storage' => {
        plan 2;
        my $a = BagHash.new: <a b c>;
        my $b = $a.clone;
        $a<a>--; $a<b>++; $a<z> = 42;
        is-deeply $a, BagHash.new-from-pairs("b" => 2, "c" => 1, "z" => 42),
            'modifying first bag works, even after we created its clone';
        is-deeply $b, BagHash.new(<a b c>),
            'modifying first bag does not affect cloned bag';
    }

    subtest 'cloned MixHash gets its own elements storage' => {
        plan 2;
        my $a = MixHash.new: <a b c>;
        my $b = $a.clone;
        $a<a>--; $a<b>++; $a<z> = 42;
        is-deeply $a, MixHash.new-from-pairs("b" => 2, "c" => 1, "z" => 42),
            'modifying first mix works, even after we created its clone';
        is-deeply $b, MixHash.new(<a b c>),
            'modifying first mix does not affect cloned mix';
    }
}

subtest 'Baggy:U forwards methods to Mu where appropriate' => {
    plan 5;
    given Mix {
        is-deeply .Bool,  False, '.Bool';
        is-deeply .so,    False, '.so';
        is-deeply .not,   True,  '.not';
        is-deeply .hash,  {},    '.hash';
        is-deeply .elems, 1,     '.elems';
    }
}


subtest '.pick/.roll/.grab reject NaN count' => {
    plan 3;
    throws-like { ^5 .BagHash.pick: NaN }, Exception, '.pick';
    throws-like { ^5 .BagHash.roll: NaN }, Exception, '.roll';
    throws-like { ^5 .BagHash.grab: NaN }, Exception, '.grab';
}


subtest 'can access key of empty list coerced to type' => {
    my @tests = <Set SetHash  Bag BagHash  Mix MixHash  Map Hash>;
    plan +@tests;
    for @tests {
        lives-ok { my %x := ()."$_"(); %x<a> }, $_
    }
}

subtest 'creating setty/baggy types with lazy iterables throws' => {
    plan +my @tests
    = ｢set *..*｣,          ｢bag *..*｣,          ｢mix *..*｣,
      ｢SetHash.new: *..*｣, ｢BagHash.new: *..*｣, ｢MixHash.new: *..*｣;
    throws-like $_, X::Cannot::Lazy, "$_ throws" for @tests;
}

# vim: expandtab shiftwidth=4
