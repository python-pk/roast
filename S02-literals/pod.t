use Test;

plan 6;

# See "=begin DATA" at the end of file.

# L<S02/Double-underscore forms/filehandle, "named as" $=pod{'DATA'}>

#?rakudo skip 'postcircumfix:<{ }> not defined for type Array RT #125130'
{
    ok $=pod{'DATA'}, '=begin DATA works and $=pod<DATA> defined';

    my $line = get $=pod<DATA>;
    is($line, "hello, world!", q/$=pod{'DATA'} can be read/);
}

# L<S02/Double-underscore forms/Pod stream as a scalar>
#?v6.0.0+ skip 'isn\'t the iterator exhausted already, since it\'s been used previously?'
{
    my $line = get $=DATA;
    is($line, "hello, world!", q/$=DATA contains the right string/);
}

# L<S02/Double-underscore forms/"Pod stream" "as an array" via @=DATA>
#?v6.0.0+ skip 'isn\'t the iterator exhausted already, since it\'s been used previously?'
{
    is @=DATA.elems, 1, '@=DATA contains a single elem';
    is @=DATA[0], "hello, world!\n", '@=DATA[0] contains the right value';
}

# The following commented-out tests are currnetly unspecified:
# others will be added later, or you can do it.

#ok EVAL('
#=begin DATA LABEL1
#LABEL1.1
#LABEL1.2
#LABEL1.3
#=end DATA

#=begin DATA LABEL2
#LABEL2.1
#LABEL2.2
#=end DATA
#'), "=begin DATA works", :todo;

#is(EVAL('%=DATA<LABEL1>[0]'), 'LABEL1.1', '@=DATA<LABEL1>[0] is correct', :todo);
#is(EVAL('%=DATA<LABEL1>[2]'), 'LABEL1.3', '@=DATA<LABEL1>[2] is correct', :todo);
#is(EVAL('~ %=DATA<LABEL1>'), 'LABEL1.1LABEL1.2LABEL1.3', '~ %=DATA<LABEL1> is correct', :todo);

#is(EVAL('~ $=LABEL2'), 'LABEL2.1LABEL2.2', '~ $=LABEL2 is correct', :todo);
#is(EVAL('$=LABEL2[1]'), 'LABEL2.2', '$=LABEL2[1] is correct', :todo);

=begin DATA
hello, world!
=end DATA


is-deeply $=pod.grep(*.name eq 'SEE-ALSO').head.contents.head.contents.head,
    'foo132339',
    'custom named paras with `-` in identifiers works';
=SEE-ALSO foo132339

# vim: expandtab shiftwidth=4
