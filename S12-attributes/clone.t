use Test;

plan 43;

# L<S12/Cloning/You can clone an object, changing some of the attributes:>
class Foo {
    has $.attr;
    method set_attr ($attr) { $.attr = $attr; }
    method get_attr () { $.attr }
}

my $a = Foo.new(:attr(13));
isa-ok($a, Foo);
is($a.get_attr(), 13, '... got the right attr value');

my $c = $a.clone();
isa-ok($c, Foo);
is($c.get_attr(), 13, '... cloned object retained attr value');

my $val;
lives-ok {
    $val = $c === $a;
}, "... cloned object isn't identity equal to the original object";
ok($val.defined && !$val, "... cloned object isn't identity equal to the original object");

my $d;
lives-ok {
    $d = $a.clone(attr => 42)
}, '... cloning with supplying a new attribute value';

my $val2;
lives-ok {
   $val2 = $d.get_attr()
}, '... getting attr from cloned value';
is($val2, 42, '... cloned object has proper attr value');


# Test to cover RT #62828, which exposed a bad interaction between while loops
# and cloning.
{
    class A {
        has $.b;
    };
    while shift [A.new( :b(0) )] -> $a {
        is($a.b, 0, 'sanity before clone');
        my $x = $a.clone( :b($a.b + 1) );
        is($a.b, 0, 'clone did not change value in original object');
        is($x.b, 1, 'however, in the clone it was changed');
        last;
    }
}


{
    my ($p, $q);
    $p = 'a' ~~ /$<foo>='a'/;

    # previously it was timeout on Rakudo
    lives-ok { $q = $p.clone }, 'Match object can be cloned';

    is ~$q{'foo'}, 'a', 'cloned Match object retained named capture value';
}

# test cloning of array and hash attributes
{
    # array
    my class ArrTest {
        has @.array;
    }

    # hash
    my class HshTest {
        has %.hash;
    }

    # when cloning with new versions of attributes, it should not update the original
    my $a1 = ArrTest.new(:array<a b>);
    my $a2 = $a1.clone(:array<c d>);
    is-deeply $a1.array, ['a', 'b'], 'original object has its original array';
    is-deeply $a2.array, ['c', 'd'], 'cloned object has the newly-provided array (1)';
    is $a2.array[0], 'c', 'cloned object has the newly-provided array (2)';
    is $a2.array[1], 'd', 'cloned object has the newly-provided array (3)';

    my $b1 = HshTest.new(hash=> 'a' => 'b' );
    my $b2 = $b1.clone(hash=> 'c' => 'd' );
    is-deeply $b1.hash, {'a' => 'b'}, 'original object has its original hash';
    is-deeply $b2.hash, {'c' => 'd'}, 'cloned object has the newly-provided hash (1)';
    is $b2.hash.elems, 1, 'cloned object has the newly-provided hash (2)';
    is $b2.hash<c>, 'd', 'cloned object has the newly-provided hash (3)';

    # when cloning without new versions of attributes, it should not deep-copy the array/hash
    my $a3 = ArrTest.new(:array<a b>);
    my $a4 = $a3.clone;
    is-deeply $a3.array, ['a', 'b'], 'original array attr sanity test';
    is-deeply $a4.array, ['a', 'b'], 'cloned array attr sanity test';
    push $a3.array, 'c';
    is-deeply $a3.array, ['a', 'b', 'c'], 'array on original is updated';
    is-deeply $a4.array, ['a', 'b', 'c'], 'array on copy is updated';

    my $b3 = HshTest.new(hash=>{'a' => 'b'});
    my $b4 = $b3.clone;
    is-deeply $b3.hash, {'a' => 'b'}, 'original hash attr sanity test';
    is-deeply $b4.hash, {'a' => 'b'}, 'cloned hash attr sanity test';
    $b3.hash{'c'} = 'd';
    is-deeply $b3.hash, {'a' => 'b', 'c' => 'd'}, 'hash on original is updated';
    is-deeply $b4.hash, {'a' => 'b', 'c' => 'd'}, 'hash on copy is updated';
}

# test cloning of custom class objects
{
    my class LeObject {
        has $.identifier;
        has @.arr;
        has %.hsh;
    }

    my class LeContainer { has LeObject $.obj; }

    my $cont = LeContainer.new(obj=>LeObject.new(identifier=>'1234', :arr<a b c>, :hsh{'x'=>'y'}));
    my $cont_clone_diff = $cont.clone(obj=>LeObject.new(identifier=>'4567', :arr<d e f>, :hsh{'z'=>'a'}));
    my $cont_clone_same = $cont.clone;

    # cont_clone_diff should contain a new value, altering its contained values should not alter the original
    is-deeply $cont_clone_diff.obj.arr, ['d', 'e', 'f'], 'cloned object sanity';
    is-deeply $cont.obj.arr, ['a', 'b', 'c'], 'original object is untouched';

    # change the cloned objects contained object, the original should be intact afterwards
    $cont_clone_diff.obj.arr = 'g', 'h', 'i';
    is-deeply $cont_clone_diff.obj.arr, ['g', 'h', 'i'], 'cloned object sanity';
    is-deeply $cont.obj.arr, ['a', 'b', 'c'], 'original object is untouched';

    # change attributes on contained object should change clones if a new object was not assigned
    is-deeply $cont_clone_same.obj.arr, ['a', 'b', 'c'], 'cloned object has identical value';
    is-deeply $cont.obj.arr, ['a', 'b', 'c'], 'original object sanity test';

    $cont.obj.arr = 'j', 'k', 'l';
    is-deeply $cont_clone_same.obj.arr, ['j', 'k', 'l'], 'cloned object has new value';
    is-deeply $cont.obj.arr, ['j', 'k', 'l'], 'original object has new value';
}

lives-ok { Int.clone }, 'cloning a type object does not explode';


{
    my @a = 42;
    lives-ok { try { @a.clone } }, 'calling .clone on array does not die';
    my @b = @a.clone;
    @a.push: 44;
    is @b, <42>, '.clone on array @a works as expected';
}


{
    my %h1 = a => 1;
    my %h2 := %h1.clone;
    %h2<b> = 2;
    is-deeply %h1, { a => 1 }, 'Hash.clone detangles the hashes';
}

subtest 'Array/Hash cloning does not lose the descriptor' => {
    plan 2;
    (my %h is default(Nil))<foo> = Nil;
    my %hc := %h.clone;
    is-deeply %hc<foo bar>, (Nil, Nil), 'Hash';

    my @a is default(Nil) = Nil;
    my @ac := @a.clone;
    is-deeply @ac[0, 1], (Nil, Nil), 'Array';
}

# vim: expandtab shiftwidth=4
