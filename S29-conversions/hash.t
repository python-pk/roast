use Test;

plan 8;

=begin pod

Basic tests for the hash() built-in

=end pod

# L<S29/Conversions/hash>

{
    ok hash() ~~ Hash, 'hash() makes a hash';
}

{
    "foo" ~~ /foo/;
    is hash().elems, 0, "hash() doesn't auto-hash $/";
}

{
    is flat('a'..'c' Z 1..3).hash.<a>, 1, "hash() builds a sensible hash";
    is flat('a'..'c' Z 1..3).hash.<b>, 2, "hash() builds a sensible hash";
    is flat('a'..'c' Z 1..3).hash.<c>, 3, "hash() builds a sensible hash";
}


{
    lives-ok {(a => 1, b => 2).hash.raku}, 'hash() on list of pairs lives (RT #76826)';
}

{
    dies-ok {hash(<1 2 3>)}, "hash() won't create invalid hash";
}


{
    is ?hash(), Bool::False, "hash() is false";
}

# vim: expandtab shiftwidth=4
