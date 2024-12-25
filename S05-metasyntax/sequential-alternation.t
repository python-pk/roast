use Test;
plan 14;

#L<S05/New metacharacters/"As with the disjunctions | and ||">

{
    my $str = 'x' x 7;

    ok $str ~~ m/x||xx||xxxx/;
    is ~$/,  'x',  'first || alternative matches';
    ok $str ~~ m/xx||x||xxxx/;
    is ~$/,  'xx', 'first || alternative matches';
}

{
    my $str = 'x' x 3;
    ok $str ~~ m/xxxx||xx||x/;
    is ~$/, 'xx', 'second alternative || matches if first fails';
}

#L<S05/"Variable (non-)interpolation"/"An interpolated array:">

{
    my $str = 'x' x 7;
    my @list = <x xx xxxx>;

    ok $str ~~ m/ ||@list /;
    is ~$/,  'x',  'first ||@list alternative matches';

    @list = <xx x xxxx>;

    ok $str ~~ m/ ||@list /;
    is ~$/,  'xx', 'first ||@list alternative matches';
}


# L<S05/Backtracking control>



{
    is 'ab' ~~ / [ab || a ] b /,       'ab', 'backtrack into ||';
    is 'ab' ~~ / [ab || a ]: b /,      Nil,  'don\'t backtrack into [ || ]:';
    is 'ab' ~~ / :r [ab || a ] b /,    Nil,  'don\'t backtrack into || under :r';
    is 'ab' ~~ / :r [ab || a ]:! b /,  'ab', 'backtrack into [ || ]:! despite :r';
}

# vim: expandtab shiftwidth=4
