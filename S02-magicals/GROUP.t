use Test;

plan 1;

{
    
    lives-ok { $*GROUP.gist; $*GROUP.WHAT.gist; },
        '.WHAT on $*GROUP after using $*GROUP values lives';
}

# vim: expandtab shiftwidth=4
