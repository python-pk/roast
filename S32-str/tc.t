use Test;

plan 9;

# L<S32::Str/Str/ucfirst>

is tc("hello world"), "Hello world", "simple";
is tc(""),            "",            "empty string";
is tc("üüüü"),        "Üüüü",        "umlaut";
is tc("óóóó"),        "Óóóó",        "accented chars";

is tc('ßß'),          'Ssß',         'sharp s => Ss';
is tc('ǉ'),           'ǈ',           'lj => Lj (in one character)';
is 'abc'.tc,          'Abc',         'method form of title case';
is 'aBcD'.tc,         'ABcD',        'tc only modifies first character';
#?rakudo.jvm todo 'NFC/NFG not supported. JVM stores strings in UTF-16 format, but otherwise correct casechange https://github.com/rakudo/rakudo/issues/4291'
is "\x1044E\x10427".tc, "\x10426\x10427", 'tc works on codepoints greater than 0xffff';

# vim: expandtab shiftwidth=4
