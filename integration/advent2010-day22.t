# http://perl6advent.wordpress.com/2010/12/22/day-22-the-meta-object-protocol/
use Test;
plan 3;

my $rat-atts = join(', ', Rat.^attributes);
ok ($rat-atts ~~ /'$!numerator'<wb>/ && $rat-atts ~~ /'$!denominator'<wb>/), 'Rat $!numerator $!denominator& attributes'
   or diag "Rat attributes: $rat-atts";

my $rat-methods = join ', ', Rat.^methods(:local).map({.name});
ok ($rat-methods ~~ /<wb>'Str'<wb>/ && $rat-methods ~~ /<wb>'round'<wb>/), 'Rat Str and round methods'
   or diag "Rat methods: $rat-methods";

ok Rat.^methods(:local).grep({.name eq 'log'}).[0].signature.raku, 'log signature';

# sub log-calls($obj, Role $r) { ... }
# wrapper example omitted - see


# vim: expandtab shiftwidth=4
