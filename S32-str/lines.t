use v6;

use lib $?FILE.IO.parent(2).add("packages");

use Test;
use Test::Util;

plan 25;

is "a\nb\n\nc".lines.join('|'),
  'a|b||c', 'LF .lines without trailing';
is "a\nb\n\nc\n".lines.join('|'),
  'a|b||c', 'LF .lines with trailing';
is "a\nb\n\nc\n".lines(Inf).join('|'),
  'a|b||c', 'LF .lines with Inf';
is "a\nb\n\nc\n".lines(*).join('|'),
  'a|b||c', 'LF .lines with *';
is "a\nb\n\nc\n".lines(2).join('|'),
  'a|b',    'LF .lines with limit';

is "a\rb\r\rc".lines.join('|'),
  'a|b||c', 'CR .lines without trailing';
is "a\rb\r\rc\r".lines.join('|'),
  'a|b||c', 'CR .lines with trailing';
is "a\rb\r\rc\r".lines(Inf).join('|'),
  'a|b||c', 'CR .lines with Inf';
is "a\rb\r\rc\r".lines(*).join('|'),
  'a|b||c', 'CR .lines with *';
is "a\rb\r\rc\r".lines(2).join('|'),
  'a|b',    'CR .lines with limit';

#?rakudo.jvm 5 todo '\r\n not yet handled as grapheme'
is "a\r\nb\r\n\r\nc".lines.join('|'), 'a|b||c',
  'CRLF .lines without trailing';
is "a\r\nb\r\n\r\nc\r\n".lines.join('|'), 'a|b||c',
  'CRLF .lines with trailing';
is "a\r\nb\r\n\r\nc\r\n".lines(Inf).join('|'), 'a|b||c',
  'CRLF .lines with Inf';
is "a\r\nb\r\n\r\nc\r\n".lines(*).join('|'), 'a|b||c',
  'CRLF .lines with *';
is "a\r\nb\r\n\r\nc\r\n".lines(2).join('|'), 'a|b',
  'CRLF .lines with limit';

is "a\nb\r\rc".lines.join('|'),
  'a|b||c', 'mixed .lines without trailing';
is "a\nb\r\rc\r".lines.join('|'),
  'a|b||c', 'mixed .lines with trailing';
is "a\nb\r\rc\r".lines(Inf).join('|'),
  'a|b||c', 'mixed .lines with Inf';
is "a\nb\r\rc\r".lines(*).join('|'),
  'a|b||c', 'mixed .lines with *';
is "a\nb\r\rc\r".lines(2).join('|'),
  'a|b',    'mixed .lines with limit';

is lines("a\nb\nc\n").join('|'), 'a|b|c', '&lines';
is lines("a\nb\nc\n",2).join('|'), 'a|b', '&lines(2)';

# RT #115136
is_run( 'print lines[0]',
        "abcd\nefgh\nijkl\n",
        { out => "abcd", err => '', status => 0 },
        'lines returns things in lines' );

# RT #126270 [BUG] Something fishy with lines() and looping over two items at a time in Rakudo
{
    my $expected = "A, then B\nC, then D\n";
    my $result;

    # This used to fail, saying "Too few positionals passed; expected 2 arguments but got 0"
    for "A\nB\nC\nD".lines() -> $x, $y { $result ~= "$x, then $y\n" }

    is $result, $expected, 'lines iterates correctly with for block taking two arguments at a time';
}

# RT #130430
is-deeply "a\nb\nc".lines(2000), ('a', 'b', 'c'),
    'we stop when data ends, even if limit has not been reached yet';

# vim: ft=perl6
