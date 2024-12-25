use Test;

plan 1;


lives-ok {
    await Promise.allof((^3).map: {
        start {
            for ^200 {
                EVAL "True";
            }
        }
    });
}, 'Simple EVAL in a loop does not crash';

# vim: expandtab shiftwidth=4
