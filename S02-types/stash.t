use Test;

plan 1;

#L<S02/Mutable Types>


{
    sub S (Stash $s) { $s.WHAT.raku };
    is S(Stash.new), 'Stash', 'Stash.new creates Stash, not a Hash';
}

# vim: expandtab shiftwidth=4
