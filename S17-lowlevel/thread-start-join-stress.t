use Test;

plan 1;


for ^1000 { Thread.start(-> {}).join; }
pass "Can start/join 1000 threads without running out of handles, etc.";

# vim: expandtab shiftwidth=4
