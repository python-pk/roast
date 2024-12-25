use Test;

plan 23;

=begin pod

#Basic C<keys> and C<values> tests for hashes and pairs, see S32::Containers.

=end pod

my %hash = (a => 1, b => 2, c => 3, d => 4);

# L<S32::Containers/"Hash"/=item keys>
is(~%hash.keys.sort, "a b c d", '%hash.keys works');
is(~sort(keys(%hash)), "a b c d", 'keys(%hash) on hashes');
is(+%hash.keys, +%hash, 'we have the same number of keys as elements in the hash');

# L<S32::Containers/"Hash"/=item values>
is(~%hash.values.sort, "1 2 3 4", '%hash.values works');
is(~sort(values(%hash)), "1 2 3 4", 'values(%hash) works');
is(+%hash.values, +%hash, 'we have the same number of keys as elements in the hash');

# keys and values on Pairs
my $pair = (a => 42);
is(~$pair.keys,     "a", '$pair.keys works');
is(~keys($pair),    "a", 'keys($pair) works');
is($pair.keys.elems, 1, 'we have one key');

is(~$pair.values,       42, '$pair.values works');
is(~values($pair),      42, 'values($pair) works');
is($pair.values.elems,  1,  'we have one value');

# test that .keys and .values work on Any values as well;

{
    my $x;
    lives-ok { $x.values }, 'Can call Any.values';
    lives-ok { $x.keys },   'Can call Any.keys';

}
#vim: ft=perl6


{
    is (4    => Mu).kv.raku, (4,  Mu).Seq.raku, ".kv on pair with Mu in value";
    is ((Mu) => 4 ).kv.raku, (Mu,  4).Seq.raku, ".kv on pair with Mu in key";
    is ((Mu) => Mu).kv.raku, (Mu, Mu).Seq.raku,
        ".kv on pair with Mu in key and value";
    is (  4  => Mu).keys.raku, (4, ).Seq.raku, ".keys on pair with Mu in value";
    is ((Mu) => 4 ).keys.raku, (Mu,).Seq.raku, ".keys on pair with Mu in key";
    is ((Mu) => Mu).keys.raku, (Mu,).Seq.raku,
        ".keys on pair with Mu in key and value";
    is (4 => Mu).values.raku, (Mu,).Seq.raku,
        ".values on pair with Mu in value";
    is ((Mu) => 4 ).values.raku, (4,).Seq.raku,
        ".values on pair with Mu in key";
    is ((Mu) => Mu).values.raku, (Mu,).Seq.raku,
        ".values on pair with Mu in key and value";
}

# vim: expandtab shiftwidth=4
