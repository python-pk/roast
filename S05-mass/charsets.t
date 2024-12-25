use Test;

# L<S05/Extensible metasyntax (C<< <...> >>)/"The special named assertions include">

plan 17;

{
    my $latin-chars = [~] chr(0)..chr(0xFF);

    is $latin-chars.comb(/<ident>/).join(" "), "ABCDEFGHIJKLMNOPQRSTUVWXYZ _ abcdefghijklmnopqrstuvwxyz ª µ º ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö øùúûüýþÿ", 'ident chars';

    is $latin-chars.comb(/<alpha>/).join, "ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyzªµºÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ", 'alpha chars';

    is $latin-chars.comb(/<space>/)>>.ord.join(","), (flat 9..13,32,133,160).join(","), 'space chars';

    is $latin-chars.comb(/<digit>/).join, "0123456789", 'digit chars';

    is $latin-chars.comb(/<alnum>/).join, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyzªµºÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ", 'alnum chars';

    is $latin-chars.comb(/<blank>/)>>.ord.join(","), '9,32,160', 'blank chars';

    is $latin-chars.comb(/<cntrl>/)>>.ord.join(","), (flat 0..31, 127..159).join(","), 'cntrl chars';

    #?rakudo.jvm todo 'Unicode 6.3 -- lower characters'
    is $latin-chars.comb(/<lower>/).join, "abcdefghijklmnopqrstuvwxyzµßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ", 'lower chars';

    is $latin-chars.comb(/<punct>/).join, q<!"#%&'()*,-./:;?@[\]_{}¡§«¶·»¿>, 'punct chars since unicode 6.1';

    is $latin-chars.comb(/<:Punctuation>/).join, q<!"#%&'()*,-./:;?@[\]_{}¡§«¶·»¿>, ':Punctuation chars since unicode 6.1';

    is $latin-chars.comb(/<upper>/).join, "ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ", 'upper chars';

    is $latin-chars.comb(/<xdigit>/).join, "0123456789ABCDEFabcdef", 'xdigit chars';

    is $latin-chars.comb(/<:Letter>/).join, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzªµºÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ", 'unicode Letter chars';

    is $latin-chars.comb(/<+ xdigit - lower >/).join, "0123456789ABCDEF", 'combined builtin classes';
    is $latin-chars.comb(/<+ :HexDigit - :Upper >/).join, "0123456789abcdef", 'combined unicode classes';
    is $latin-chars.comb(/<+ :HexDigit - lower >/).join, "0123456789ABCDEF", 'combined unicode and builtins';

}


{
    'o' ~~ /<:!Upper>*/;
    is ~$/, 'o', 'Can match negated quantified character class';
}

# vim: expandtab shiftwidth=4
