use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 1;


is_run 'BEGIN { BEGIN { q{S11modulesRakuLibTest.rakumod}.IO.spurt(q{package { say q{all your base} }}); %*ENV<RAKULIB>=qq{}; }; use S11modulesRakuLibTest }',
{
    out    => "",
    status => * != 0,
}, 'RT 130883 is fixed';

unlink "S11modulesRakuLibTest.rakumod";

# vim: expandtab shiftwidth=4
