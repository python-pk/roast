use Test;

plan 221;

# L<S02/Names and Variables/:delete>

#-------------------------------------------------------------------------------
# initialisations

my $default = Int;
my $dont    = False;
sub gen_array { (1..10).list }

#-------------------------------------------------------------------------------
# Array

{ # basic sanity
    my @a = gen_array;
    is @a.elems, 10, "do we have a valid array";
} #1

{ # single element
    my Int @a = gen_array;
    my $b     = @a[3];

    is @a[3]:delete, $b, "Test for delete single element";
    is @a[3], $default,  "3 should be deleted now";
    is +@a, 10,          "array still has same length";

    my $c = @a[9];
    is @a[9]:!delete, $c,       "Test non-deletion with ! single elem";
    is @a[9], $c,               "9 should not have been deleted";
    is @a[9]:delete(0), $c,     "Test non-deletion with (0) single elem";
    is @a[9], $c,               "9 should not have been deleted";
    is @a[9]:delete(False), $c, "Test non-deletion with (False) single elem";
    is @a[9], $c,               "9 should not have been deleted";
    is @a[9]:delete($dont), $c, "Test non-deletion with (\$dont) single elem";
    is @a[9], $c,               "9 should not have been deleted";
    is @a[9]:delete(1), $c,     "Test deletion with (1) single elem";
    is @a[9], $default,         "9 should be deleted now";
    is +@a, 9,                  "array should be shortened now";

    my $d = @a[8]:p;
    is-deeply @a[8]:p:!delete, $d,       "return a single pair out";
    ok @a[8]:exists,                     "8 should not have been deleted";
    is-deeply @a[8]:p:delete,  $d,       "slice a single pair out";
    ok !defined(@a[8]),                  "8 should be deleted now";
    is-deeply @a[8]:p:delete,  (),       "slice unexisting single pair out";
    is-deeply @a[8]:!p:delete, (8=>Int), "slice unexisting single pair out";
    is @a.elems, 8, "should have been shortened";

    my $e= (7, @a[7]);
    is-deeply @a[7]:kv:!delete, $e,      "return a single elem/value out";
    ok @a[7]:exists,                     "7 should not have been deleted";
    is-deeply @a[7]:kv:delete,  $e,      "slice a single elem/value out";
    ok @a[7]:!exists,                    "7 should be deleted now";
    is-deeply @a[7]:kv:delete,  (),      "slice unexisting single elem/value";
    is-deeply @a[7]:!kv:delete, (7,Int), "slice unexisting single elem/value";
    is @a.elems, 7, "should have been shortened";

    is @a[6]:k:!delete,        6, "return a single elem out";
    ok @a[6]:exists,              "6 should not have been deleted";
    is @a[6]:k:delete,         6, "slice a single elem out";
    ok @a[6]:!exists,             "6 should be deleted now";
    is-deeply @a[6]:k:delete, (), "slice unexisting single elem";
    is @a[6]:!k:delete,        6, "slice unexisting single elem";
    is @a.elems, 6, "should have been shortened";

    my $g= @a[5];
    is @a[5]:v:!delete,        $g, "return a single value out";
    ok @a[5]:exists,               "5 should not have been deleted";
    is @a[5]:v:delete,         $g, "slice a single value out";
    ok @a[5]:!exists,              "5 should be deleted now";
    is-deeply @a[5]:v:delete,  (), "slice unexisting single elem";
    is @a[5]:!v:delete,       Int, "slice unexisting single elem";
    is @a.elems, 5, "should have been shortened";
} #42

{ # single elem, combinations with :exists
    my @a = gen_array;

    ok (@a[9]:delete:exists) === True,  "9:exists single existing elem";
    ok @a[9]:!exists,                   "9 should be deleted now";
    ok (@a[9]:delete:exists) === False, "9:exists one non-existing elem";
    ok (@a[9]:delete:!exists) === True, "9:!exists one non-existing elem";
    is @a.elems, 9, "should have been shortened";

    is-deeply @a[8]:delete:!exists:kv, (8,False), "8:exists:kv 1 eelem";
    ok @a[8]:!exists,                             "8 should be deleted now";
    is-deeply @a[8]:delete:exists:!kv, (8,False), "1 neelem d:exists:!kv";
    is-deeply @a[8]:delete:!exists:!kv, (8,True), "1 neelem d:!exists:!kv";
    is-deeply @a[8]:delete:exists:kv, (),         "1 neelem d:exists:kv";
    is-deeply @a[8]:delete:!exists:kv, (),        "1 neelem d:!exists:kv";
    is @a.elems, 8, "should have been shortened";

    is-deeply @a[7]:delete:!exists:p, (7=>False), "7:exists:p 1 eelem";
    ok @a[7]:!exists,                             "7 should be deleted now";
    is-deeply @a[7]:delete:exists:!p, (7=>False), "1 neelem exists:!p";
    is-deeply @a[7]:delete:!exists:!p, (7=>True), "1 neelem !exists:!p";
    is-deeply @a[7]:delete:exists:p, (),          "1 neelem exists:p";
    is-deeply @a[7]:delete:!exists:p, (),         "1 neelem !exists:p";
    is @a.elems, 7, "should have been shortened";
} #19

{ # multiple elements, without :exists
    my Int @a = gen_array;
    my $b = @a[1,3];

    is-deeply @a[1,3]:delete, $b, "Test for delete multiple elements";
    is-deeply @a[1,3], (Int,Int), "1 3 should be deleted now";
    is +@a, 10,                   "1 3 should be deleted now";

    my $c = @a[2,4,9];
    is-deeply @a[2,4,9]:!delete,       $c, "Test non-deletion with ! N";
    is-deeply @a[2,4,9],               $c, "2 4 9 should not have been deleted";
    is-deeply @a[2,4,9]:delete(0),     $c, "Test non-deletion with (0) N";
    is-deeply @a[2,4,9],               $c, "2 4 9 should not have been deleted";
    is-deeply @a[2,4,9]:delete(False), $c, "Test non-deletion with (False) N";
    is-deeply @a[2,4,9],               $c, "2 4 9 should not have been deleted";
    is-deeply @a[2,4,9]:delete($dont), $c, "Test non-deletion with (\$dont) N";
    is-deeply @a[2,4,9],               $c, "2 4 9 should not have been deleted";
    is-deeply @a[2,4,9]:delete(1),     $c, "Test deletion with (1) N";
    is-deeply @a[2,4,9], (Int,Int,Int), "2 4 9 should be deleted now";
    is +@a, 9,                          "array should be shortened now";

    my $hi = @a[6,8]:p;
    is-deeply @a[6,8]:p:!delete, $hi, "return pairs";
    is @a[6,8]:p, $hi,                "6 8 should not have been deleted";
    is-deeply @a[6,8]:p:delete,  $hi, "slice pairs out";
    is +@a, 8,                        "8 should be deleted now by count";
} #14

{ # multiple keys, combinations with :exists
    my @a = gen_array;

    is-deeply @a[2,3]:!delete:exists, (True,True),  "!d:exists ekeys";
    is-deeply @a[2,3]:delete:exists, (True,True),   "d:exists ekeys";
    ok @a[2]:!exists,                               "2 should be deleted now";
    ok @a[3]:!exists,                               "3 should be deleted now";
    is-deeply @a[2,3]:delete:exists, (False,False), "d:exists nekeys";
    is-deeply @a[2,3]:delete:!exists, (True,True),  "d:!exists nekeys";
    is-deeply @a[1,2]:delete:exists, (True,False),  "d:exists nekeys";
    is-deeply @a[3,9]:delete:!exists, (True,False), "d:!exists nekeys";
    is +@a, 9,                        "9 should be deleted now by count";
} #9

{
    my @a = gen_array;

    is-deeply @a[4,5]:!delete:!exists:kv,
    (4,False,5,False),              "!d:!exists:kv ekeys";
    is-deeply @a[4,5]:delete:!exists:kv,
    (4,False,5,False),              "d:!exists:kv ekeys";
    ok @a[4]:!exists,               "4 should be deleted now";
    ok @a[5]:!exists,               "5 should be deleted now";
    is-deeply @a[4,5]:delete:exists:!kv,
    (4,False,5,False),              "d:exists:!kv nekeys";
    is-deeply @a[4,5]:delete:!exists:!kv,
    (4,True,5,True),                "d:!exists:!kv nekeys";
    is-deeply @a[4,6]:delete:exists:kv,
    (6,True),                       "d:exists:kv nekey/ekey";
    is-deeply @a[7,4]:delete:!exists:kv,
    (7,False),                      "d:!exists:kv ekey/nekey";
    is +@a, 10,                     "only deletions in middle";
} #9

{
    my @a = gen_array;

    is-deeply @a[4,5]:!delete:!exists:p,
    (4=>False,5=>False),            "!d:!exists:p ekeys";
    is-deeply @a[4,5]:delete:!exists:p,
    (4=>False,5=>False),            "d:!exists:p ekeys";
    ok @a[4]:!exists,               "4 should be deleted now";
    ok @a[5]:!exists,               "5 should be deleted now";
    is-deeply @a[4,5]:delete:exists:!p,
    (4=>False,5=>False),            "d:exists:!p nekeys";
    is-deeply @a[4,5]:delete:!exists:!p,
    (4=>True,5=>True),              "d:!exists:!p nekeys";
    is-deeply @a[4,6]:delete:exists:p,
    (6=>True,),                   "d:exists:p nekey/ekey";
    is-deeply @a[7,4]:delete:!exists:p,
    (7=>False,),                  "d:!exists:p ekey/nekey";
    is +@a, 10,                     "only deletions in middle";
} #9


{ # whatever
    my @a   = gen_array;
    my $all = @a[^@a.elems];

    is-deeply @a[*]:delete, $all, "Test deletion with whatever";
    is +@a, 0,                    "* should be deleted now";
} #2

{
    my @a   = gen_array;
    my $all = @a[^@a.elems];

    is-deeply @a[*]:!delete,       $all, "Test non-deletion with ! *";
    is-deeply @a[*]:delete(0),     $all, "Test non-deletion with (0) *";
    is-deeply @a[*]:delete(False), $all, "Test non-deletion with (False) *";
    is-deeply @a[*]:delete($dont), $all, "Test non-deletion with (\$dont) *";

    is +@a, 10,                      "* should not be deleted now";
    is-deeply @a[*]:delete(1), $all, "Test deletion with (1) whatever";
    is +@a, 0,                       "* should be deleted now";
} #7

{
    my @a   = gen_array;
    my $all = (^10).map: { $_ => @a[$_] };

    is @a[*]:p:!delete, $all, "return all pairs";
    is +@a, 10,               "* should not be deleted";
    is @a[*]:p:delete,  $all, "slice out all pairs";
    is +@a, 0,               "* should be deleted now";
} #4

{
    my @a  = gen_array;
    my @i  = True  xx @a.elems;
    my @ni = False xx @a.elems;

    is @a[*]:!delete:exists, @i,  "!d:exists whatever";
    is +@a, 10,                   "* should not be deleted";
    is @a[*]:delete:!exists, @ni, "d:!exists whatever";
    is +@a, 0,                    "* should be deleted now";
} #4

{
    my @a  = gen_array;
    my @i  = (^10).map: { ($_,True) };
    my @ni = (^10).map: { ($_,False) };

    is @a[*]:!delete:exists:kv, @i,  ":!d:exists:kv whatever";
    is +@a, 10,                      "* should not be deleted";
    is @a[*]:delete:!exists:kv, @ni, "d:!exists:kv whatever";
    is +@a, 0,                       "* should be deleted now";

    @a = gen_array;
    is @a[*]:!delete:exists:!kv, @i,  ":!d:exists:!kv whatever";
    is +@a, 10,                      "* should not be deleted";
    is @a[*]:delete:!exists:!kv, @ni, "d:!exists:!kv whatever";
    is +@a, 0,                       "* should be deleted now";
} #8

{
    my @a  = gen_array;
    my @i  = (^10).map: { ($_ => True) };
    my @ni = (^10).map: { ($_ => False) };

    is @a[*]:!delete:exists:p, @i,  ":!d:exists:p whatever";
    is +@a, 10,                     "* should not be deleted";
    is @a[*]:delete:!exists:p, @ni, "d:!exists:p whatever";
    is +@a, 0,                      "* should be deleted now";

    @a = gen_array;
    is @a[*]:!delete:exists:!p, @i,  ":!d:exists:!p whatever";
    is +@a, 10,                     "* should not be deleted";
    is @a[*]:delete:!exists:!p, @ni, "d:!exists:!p whatever";
    is +@a, 0,                      "* should be deleted now";
} #8

{
    my @a is default(42);
    is @a[0]:delete, 42,  ':delete non-existing';
    is @a.elems, 0,       'should not vivify';
    is @a[0]:!delete, 42, ':!delete non-existing';
    is @a.elems, 0,       'should not vivify';

    is @a[0]:delete:exists, False,  ':delete:exists non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!delete:exists, False, ':!delete:exists non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:delete:!exists, True,  ':delete:!exists non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!delete:!exists, True, ':!delete:!exists non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:delete:exists:kv, (),   ':delete:exists:kv non-existing';
    is @a.elems, 0,                  'should not vivify';
    is @a[0]:!delete:exists:kv, (),  ':!delete:exists:kv non-existing';
    is @a.elems, 0,                  'should not vivify';

    is @a[0]:delete:!exists:kv, (),  ':delete:!exists:kv non-existing';
    is @a.elems, 0,                  'should not vivify';
    is @a[0]:!delete:!exists:kv, (), ':!delete:!exists:kv non-existing';
    is @a.elems, 0,                  'should not vivify';

    is @a[0]:delete:exists:!kv, (0,False),  ':delete:exists:!kv non-existing';
    is @a.elems, 0,                         'should not vivify';
    is @a[0]:!delete:exists:!kv, (0,False), ':!delete:exists:!kv non-existing';
    is @a.elems, 0,                         'should not vivify';

    is @a[0]:delete:!exists:!kv, (0,True),  ':delete:!exists:!kv non-existing';
    is @a.elems, 0,                         'should not vivify';
    is @a[0]:!delete:!exists:!kv, (0,True), ':!delete:!exists:!kv non-existing';
    is @a.elems, 0,                         'should not vivify';

    is @a[0]:delete:exists:p, (),   ':delete:exists:p non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!delete:exists:p, (),  ':!delete:exists:p non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:delete:!exists:p, (),  ':delete:!exists:p non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!delete:!exists:p, (), ':!delete:!exists:p non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:delete:exists:!p, (0=>False),  ':delete:exists:!p non-existing';
    is @a.elems, 0,                         'should not vivify';
    is @a[0]:!delete:exists:!p, (0=>False), ':!delete:exists:!p non-existing';
    is @a.elems, 0,                         'should not vivify';

    is @a[0]:delete:!exists:!p, (0=>True),  ':delete:!exists:!p non-existing';
    is @a.elems, 0,                         'should not vivify';
    is @a[0]:!delete:!exists:!p, (0=>True), ':!delete:!exists:!p non-existing';
    is @a.elems, 0,                         'should not vivify';

    is @a[0]:exists:kv, (),         ':exists:kv non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!exists:kv, (),        ':!exists:kv non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:exists:!kv, (0,False), ':exists:!kv non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!exists:!kv, (0,True), ':!exists:!kv non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:exists:p, (),          ':exists:p non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!exists:p, (),         ':!exists:p non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:exists:!p, (0=>False), ':exists:!p non-existing';
    is @a.elems, 0,                 'should not vivify';
    is @a[0]:!exists:!p, (0=>True), ':!exists:!p non-existing';
    is @a.elems, 0,                 'should not vivify';

    is @a[0]:kv, (),      ':kv non-existing';
    is @a.elems, 0,       'should not vivify';
    is @a[0]:!kv, (0,42), ':!kv non-existing';
    is @a.elems, 0,       'should not vivify';

    is @a[0]:p, (),       ':p non-existing';
    is @a.elems, 0,       'should not vivify';
    is @a[0]:!p, (0=>42), ':!p non-existing';
    is @a.elems, 0,       'should not vivify';

    is @a[0]:k, (), ':k non-existing';
    is @a.elems, 0, 'should not vivify';
    is @a[0]:!k, 0, ':!k non-existing';
    is @a.elems, 0, 'should not vivify';

    is @a[0]:v, (),  ':v non-existing';
    is @a.elems, 0,  'should not vivify';
    is @a[0]:!v, 42, ':!v non-existing';
    is @a.elems, 0,  'should not vivify';
} #86


{
    my Int @a = ^3;
    @a[2] :delete;
    is @a.elems, 2, 'array was shortened';
    @a[3] = 3;
    is @a[2], Int, 'properly nulled even at end of array';
} #2


subtest ':delete on lazy Arrays' => {
    plan 2;
    my @a is default(99) = 1...*;
    @a[2]:delete;

    is @a[2]:exists, False, 'delete element on lazy Arrays succesfully';
    ok @a[2] == 99, 'deleted element replaced with default value';
}


{
    my @a = 3, 4;
    is-deeply @a[1.5, 0.5]:delete, (4,3), 'did :delete return ok';
    is-deeply @a, [], 'did :delete actually delete';
}

# vim: expandtab shiftwidth=4
