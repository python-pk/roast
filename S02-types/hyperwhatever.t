use Test;

# Tests for the HyperWhatever type and its curries

plan 2;


throws-like ｢HyperWhatever.new｣, X::Cannot::New,
    '.new throws that it cannot be called';


subtest 'smartmatch with HyperWhatever type object' => {
    plan 6;
    is-deeply (HyperWhatever ~~ HyperWhatever),   True,  'HW (true)';
    is-deeply (42            ~~ HyperWhatever),   False, 'HW (false)';
    is-deeply (HyperWhatever ~~ HyperWhatever:U), True,  'HW:U (true)';
    is-deeply ('meows'       ~~ HyperWhatever:U), False, 'HW:U (false)';
    is-deeply (((**))        ~~ HyperWhatever:D), True,  'HW:D (true)';
    is-deeply (((*))         ~~ HyperWhatever:D), False, 'HW:D (false)';
}


# vim: expandtab shiftwidth=4
