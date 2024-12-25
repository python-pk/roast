use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 1;


{
    is_run q[say $\\], { :1status, err => /'Confused'/ },
        'spurious backslash at end of file error must ask for semicolon';
}

# vim: expandtab shiftwidth=4
