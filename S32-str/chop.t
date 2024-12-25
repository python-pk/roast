use Test;

# L<S32::Str/Str/"=item chop">

plan 36;

#
# Tests already covered by the specs
#

my $str = "foo";
is chop($str),   "fo", "o removed" ;
is $str,        "foo", "chop() original string unchanged" ;
is chop($str,1), "fo", "o removed" ;
is $str,        "foo", "chop() original string unchanged (1)" ;
is chop($str,2),  "f", "oo removed" ;
is $str,        "foo", "chop() original string unchanged (2)" ;
is chop($str,3),   "", "foo removed" ;
is $str,        "foo", "chop() original string unchanged (3)" ;
is chop($str,4),   "", "foo removed" ;
is $str,        "foo", "chop() original string unchanged (4)" ;

is $str.chop,    "fo", "o removed" ;
is $str,        "foo", ".chop original string unchanged" ;
is $str.chop(1), "fo", "o removed" ;
is $str,        "foo", ".chop original string unchanged (1)" ;
is $str.chop(2),  "f", "oo removed" ;
is $str,        "foo", ".chop original string unchanged (2)" ;
is $str.chop(3),   "", "foo removed" ;
is $str,        "foo", ".chop original string unchanged (3)" ;
is $str.chop(4),   "", "foo removed" ;
is $str,        "foo", ".chop original string unchanged (4)" ;

my Int $int = 42;
is chop($int),   "4", 'chop on Int';
is $int,          42, 'chop() original int unchanged';
is chop($int,1), "4", 'chop on Int';
is $int,          42, 'chop() original int unchanged (1)';

is chop("bar"), "ba", "chop() on string literal";
is "bar".chop, "ba", ".chop on string literal";
is chop(""), "", "chop on empty string literal";
is chop("bar","2"), "b", "check coercion of number of characters";

# temporary, until we have a typed exception
throws-like 'chop(Str)',    Exception;
throws-like 'chop(Str,10)', Exception;
throws-like 'Str.chop',     Exception;
throws-like 'Str.chop(10)', Exception;

# See L<"http://use.perl.org/~autrijus/journal/25351">:
#   &chomp and &wrap are now nondestructive; chomp returns the chomped part,
#   which can be defined by the filehandle that obtains the default string at
#   the first place. To get destructive behaviour, use the .= form.


{
    is 'xx'.chop($_), '', ".chop with large values returns empty string [using $_]"
        for 999_999, 999_999_999, 999_999_999_999,
            9_999_999_999_999_999_999_999_999_999_999_999_999_999_999_999_999;
}

# vim: expandtab shiftwidth=4
