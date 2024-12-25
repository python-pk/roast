use Test;

plan 1;

{
    
    lives-ok { $*USER.gist; $*USER.WHAT.gist; },
        '.WHAT on $*USER after using $*USER values lives';
}

# vim: expandtab shiftwidth=4
