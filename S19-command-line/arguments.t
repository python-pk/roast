use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 6;


{
    my Str $x;
    my $file = 'ThisDoesNotExistAtAll.raku';
    if $file.IO.e {
        skip "could not run test since file $file exists";
    }
    else {
        is_run( $x, :args[$file],
        {
            out => '',
            err => { .chars < 256 && m/"Could not open $file"|"Can not run directory $file"/ },
        },
        'concise error message when called script not found' );
    }
}


{
    my $cmd = $*DISTRO.is-win
        ?? 'echo exit(42) | \qq[$*EXECUTABLE] -'
        !! 'echo "exit(42)" | \qq[$*EXECUTABLE] -';

    is shell($cmd).exitcode, 42, "'-' as argument means STDIN";
}


{
    my $dir = 'omg-a-directory';
    mkdir $dir;
    LEAVE rmdir 'omg-a-directory';
    my Str $x;
    is_run( $x, :args[$dir],
    {
        out => '',
        err => { .chars < 256 && m/$dir/ && m/directory/ },
    },
    'concise error message when called script is a directory' );
}

{
    # MoarVM #482
    is run($*EXECUTABLE, '-e', ｢print '“Hello world”'｣, :out).out.slurp,
        '“Hello world”',
        'UTF-8 in arguments is decoded correctly';
}



is_run ｢@*ARGS.head.print｣, :args[<yağmur>],
    { :err(''), :out<yağmur>, :0status },
    'printed chars match input';


is_run(Str, :args['--nosucharg=foo', 'foo.raku'],
    { out => '' },
    'Unknown options do not spit warnings to stdout');

# vim: expandtab shiftwidth=4
