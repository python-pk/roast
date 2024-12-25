use Test;

# TODO: smartlink

# L<"http://use.perl.org/~autrijus/journal/25365">
# Closure composers like anonymous sub, class and module always trumps hash
# dereferences:
#
#   sub{...}
#   module{...}
#   class{...}

plan 11;

ok(sub { 42 }(), 'sub {...}() works'); # TODO: clarify

ok(sub{ 42 }(),  'sub{...}() works'); # TODO: clarify


{
    is sub { 42 }(), 42, 'can invoke sub with "()" directly after declaration';
    is sub ($t) { $t }('arf'), 'arf',
        'can pass argument within "()" directly after sub declaration';
}


throws-like { EVAL q[
    sub x { die }
    x();
] },
  Exception, # no exception object yet
  'block parsing works with newline';

throws-like { EVAL q[
    sub x { die };
    x();
] },
  Exception, # no exception object yet
  'block parsing works with semicolon';


{
    throws-like { EVAL 'sub foo;' },
      X::UnitScope::Invalid,
      'did not call foo';
}


# perl6 - sub/hash syntax
{
    sub to_check_before {
        my %fs = ();
        %fs{ lc( 'A' ) } = &fa;
        sub fa() { return 'fa called.'; }
        ;
        %fs{ lc( 'B' ) } = &fb;
        sub fb() { return 'fb called.'; }

        my $fn = lc( @_[ 0 ] || 'A' );
        return %fs{ $fn }();
    }

    sub to_check_after {
        my %fs = ();
        %fs{ lc( 'A' ) } = &fa;
        sub fa() { return 'fa called.'; }

        %fs{ lc( 'B' ) } = &fb;
        sub fb() { return 'fb called.'; }

        my $fn = lc( @_[ 0 ] || 'A' );
        return %fs{ $fn }();
    }

    is to_check_before, "fa called.", 'fa called in old sub/hash syntax is ok';
    is to_check_before('B'), "fb called.", 'fb called in old sub/hash syntax is ok';
    is to_check_after, "fa called.", 'fa called in sub/hash syntax is ok';
    is to_check_after('B'), "fb called.", 'fb called in sub/hash syntax is ok';
}

# vim: expandtab shiftwidth=4
