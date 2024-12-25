use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 4;

# L<S11/Runtime Importation>


subtest 'circular dependencies are detected and reported' => {
    plan 2;

    my $dir = make-temp-dir;
    $dir.add('A.rakumod').spurt: 'unit class A; use B';
    $dir.add('B.rakumod').spurt: 'unit class B; use A';

    is_run ｢use A｣, :compiler-args['-I', $dir.absolute ],
        { :out(''), :err(/:i «circular»/), :status(*.so) },
    "`use` $_" for 'first run', 'second run (precompiled)';
}


throws-like ｢use lib ‘’｣, X::LibEmpty,
    'use lib with empty string throws a useful error';


eval-lives-ok 'my class CompUnit {}; use Test', 'no confusion about CompUnit';

eval-lives-ok 'use lib "' ~ $?FILE.IO.parent(2).add("packages/R3783/lib") ~ '"; use Shadow; $Shadow::debug or die "not ok"',
    'A .rakumod file is not over-shadowed by a .pm file of the same basename in a use statement';

# vim: expandtab shiftwidth=4
