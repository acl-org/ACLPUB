#!/usr/bin/perl

# Filters a DB (or meta) file so that its entries are more HTML-friendly.
# The result is still a DB (or meta) file.
#
# This file gets most common cases but is still slightly incomplete.
# Also, the HTML specification does get extended from time to time.
#
# Doubtful that the diacritics need to be translated anymore, since HTML
# is unicode friendly.  However, the latex versions of the diacritics will
# need to be translated, if any were present in the metadata.

use utf8;
use open qw(:std :utf8);

use HTML::Entities;

while (<>) {
    if (/^(url|bib_url) /) {
        # don't mess with url or bib_url lines in meta (e.g., don't delete ~)
        print;
        next;
    }

    s/\r//g;         # kill CR from DOS format files

    # latex cruft
    s/\\@//g;          # kill latex \@, sometimes used after periods
    s/\\,//g;          # kill latex \, sometimes used to widen titles in TOC
    s/\\\\|\\newline\b/<br>/g;    # latex newlines: convert to <br>
    s/\\ / /g;         # latex hard space: convert to ordinary space
    s/(?<!\\)~/ /g;    # latex hard space ~ unless preceded by backslash: convert to ordinary space
    s/\\&/&/g;         # latex \&
    s/(?<!\\)~/ /g;    # latex hard space ~ unless preceded by backslash: convert to ordinary space

    # common latex glyphs
    s/---/&#8212;/g;   # the name "&mdash;" will only be supported in HTML 4
    s/--/&#8211;/g;    # the name "&ndash;" will only be supported in HTML 4
    s/(?<!\\)\`\`/&ldquo;/g;  # smart quotes (also single apostrophe), unless preceded by backslash
    s/(?<!\\)\'\'/&rdquo;/g;
    s/(?<!\\)\`/&lsquo;/g;
    s/(?<!\\)\'/&rsquo;/g;

    # collapse whitespace
    s/[ \t]+/ /g;
    s/^ //;
    s/ $//;

    # diacritics.  Pretty good, but:
    # - Still not quite complete:
    #   Check out http://www.htmlhelp.com/reference/html40/entities/latin1.html
    #   and http://molspect.mps.ohio-state.edu/symposium/latexinstruct.html .
    # - Redundancy is not exploited.
    #   It may be helpful to use more regexp features, like $1 and /e.
    # - The optional braces around \'a are not required to match.
    # - The braces around \AA, etc., should be optional: an alternative
    #   is to follow with a non-letter (typically whitespace, which should then be deleted).
    #   In general, the regexps should be rewritten to parse first (the way latex does)
    #   and interpret second.
    # - There are some characters, like \c{s}, that don't appear 
    #   to admit a Latin-1 encoding (see the entry for Dan Tufi\c{s} at W03-0308 
    #   in http://acl.ldc.upenn.edu/W/W03/ ).

    s/\\\'\{a}/&aacute;/g;
    s/\\\'\{e}/&eacute;/g;
    s/\\\'\{i}/&iacute;/g;
    s/\\\'\{\\i}/&iacute;/g;
    s/\\\'\{o}/&oacute;/g;
    s/\\\'\{u}/&uacute;/g;
    s/\\\'\{y}/&yacute;/g;

    s/\\\'\{n}/&#324;/g;

    s/\\\`\{a}/&agrave;/g;
    s/\\\`\{e}/&egrave;/g;
    s/\\\`\{i}/&igrave;/g;
    s/\\\`\{\\i}/&igrave;/g;
    s/\\\`\{o}/&ograve;/g;
    s/\\\`\{u}/&ugrave;/g;

    s/\\\^\{a}/&acirc;/g;
    s/\\\^\{e}/&ecirc;/g;
    s/\\\^\{i}/&icirc;/g;
    s/\\\^\{\\i}/&icirc;/g;
    s/\\\^\{o}/&ocirc;/g;
    s/\\\^\{u}/&ucirc;/g;

    s/\\\"\{a}/&auml;/g;
    s/\\\"\{e}/&euml;/g;
    s/\\\"\{i}/&iuml;/g;
    s/\\\"\{\\i}/&iuml;/g;
    s/\\\"\{o}/&ouml;/g;
    s/\\\"\{u}/&uuml;/g;

    s/\{\\\"a}/&auml;/g;
    s/\{\\\"e}/&euml;/g;
    s/\{\\\"i}/&iuml;/g;
    s/\{\\\"o}/&ouml;/g;
    s/\{\\\"u}/&uuml;/g;

    s/\\\~\{a}/&atilde;/g;
    s/\\\~\{o}/&otilde;/g;
    s/\\\~\{n}/&ntilde;/g;
    s/\\\~\{i}/&itilde;/g;
    s/\\\~\{u}/&utilde;/g;
    s/\\c\{c}/&ccedil;/g;
    s/\\c\{s}/&#351;/g;

    s/\\v\{C}/&#268;/g;
    s/\\v\{c}/&#269;/g;
    s/\\v\{E}/&#282;/g;
    s/\\v\{e}/&#283;/g;
    s/\\v\{N}/&#327;/g;
    s/\\v\{n}/&#328;/g;
    s/\\v\{R}/&#344;/g;
    s/\\v\{r}/&#345;/g;
    s/\\v\{S}/&#352;/g;
    s/\\v\{s}/&#353;/g;
    s/\\v\{Z}/&#381;/g;
    s/\\v\{z}/&#158;/g;
    s/\{\\AA}/&Aring;/g;
    s/\{\\aa}/&aring;/g;
    s/\{\\AE}/&AElig;/g;
    s/\{\\ae}/&aelig;/g;
    s/\{\\ss}/&szlig;/g;

    s/\{?\\\'a}?/&aacute;/g;    
    s/\{?\\\'e}?/&eacute;/g;
    s/\{?\\\'i}?/&iacute;/g;
    s/\{?\\\'\\i}?/&iacute;/g;
    s/\{?\\\'o}?/&oacute;/g;
    s/\{?\\\'u}?/&uacute;/g;
    s/\{?\\\'y}?/&yacute;/g;

    s/\{?\\\`a}?/&agrave;/g;
    s/\{?\\\`e}?/&egrave;/g;
    s/\{?\\\`i}?/&igrave;/g;
    s/\{?\\\`\\i}?/&igrave;/g;
    s/\{?\\\`o}?/&ograve;/g;
    s/\{?\\\`u}?/&ugrave;/g;

    s/\{?\\\^a}?/&acirc;/g;
    s/\{?\\\^e}?/&ecirc;/g;
    s/\{?\\\^i}?/&icirc;/g;
    s/\{?\\\^\\i}?/&icirc;/g;
    s/\{?\\\^o}?/&ocirc;/g;
    s/\{?\\\^u}?/&ucirc;/g;

    s/\{?\\\"a}?/&auml;/g;
    s/\{?\\\"e}?/&euml;/g;
    s/\{?\\\"i}?/&iuml;/g;
    s/\{?\\\"\\i}?/&iuml;/g;
    s/\{?\\\"o}?/&ouml;/g;
    s/\{?\\\"u}?/&uuml;/g;

    s/\{?\\\~a}?/&atilde;/g;
    s/\{?\\\~o}?/&otilde;/g;
    s/\{?\\\~n}?/&ntilde;/g;

    s/\\\'\{A}/&Aacute;/g;
    s/\\\'\{E}/&Eacute;/g;
    s/\\\'\{I}/&Iacute;/g;
    s/\\\'\{O}/&Oacute;/g;
    s/\\\'\{U}/&Uacute;/g;
    s/\\\'\{Y}/&Yacute;/g;

    s/\\\`\{A}/&Agrave;/g;
    s/\\\`\{E}/&Egrave;/g;
    s/\\\`\{I}/&Igrave;/g;
    s/\\\`\{O}/&Ograve;/g;
    s/\\\`\{U}/&Ugrave;/g;

    s/\\\^\{A}/&Acirc;/g;
    s/\\\^\{E}/&Ecirc;/g;
    s/\\\^\{I}/&Icirc;/g;
    s/\\\^\{O}/&Ocirc;/g;
    s/\\\^\{U}/&Ucirc;/g;

    s/\\\"\{A}/&Auml;/g;
    s/\\\"\{E}/&Euml;/g;
    s/\\\"\{I}/&Iuml;/g;
    s/\\\"\{O}/&Ouml;/g;
    s/\\\"\{U}/&Uuml;/g;

    s/\{\\o\}/&oslash;/g; 
    s/\{\\O\}/&Oslash;/g;  

    s/\\o/&oslash;/g;
    s/\\O/&Oslash;/g;
    s/\\u\{g}/&#287;/g;

    s/\\\~\{A}/&Atilde;/g;
    s/\\\~\{O}/&Otilde;/g;
    s/\\\~\{N}/&Ntilde;/g;
    s/\\c\{C}/&Ccedil;/g;
    s/\\\'\{S}/&#346;/g;
    s/\\\'\{C}/&#262;/g;
    s/\\\'\{s}/&#347;/g;
    s/\\\'\{c}/&#263;/g;

    s/\{?\\\'C}?/&#262;/g;
    s/\{?\\\'c}?/&#263;/g;
    s/\{?\\\'S}?/&#346;/g;
    s/\{?\\\'s}?/&#347;/g;

    s/\\\=\{a}/&#257;/g;
    s/\\\=\{e}/&#275;/g;
    s/\\\=\{i}/&#299;/g;
    s/\\\=\{o}/&#333;/g;
    s/\\\=\{u}/&#363;/g;

    s/\\\=\{A}/&#256;/g;
    s/\\\=\{E}/&#274;/g;
    s/\\\=\{I}/&#298;/g;
    s/\\\=\{O}/&#332;/g;
    s/\\\=\{U}/&#362;/g;

    s/\{\\L\}/&#0321/g; 
    s/\{\\l\}/&#0322/g; 

    s/\{\\l}/&#322;/g;

    s/\\v\{a}/&#259;/g;

    s/\\\=\{e}/&#275;/g;
    s/\\\=\{u}/&#363;/g;
    s/\\\=\{\\\i}/&#299;/g;
    s/\\\=\{a}/&#257;/g;

    s/\\v\{s}/&#353;/g;
    s/\\v\{g}/&#289;/g;

    s/\\c\{k}/&#311;/g;
    s/\\c\{l}/&#316;/g;

    s/\\v\{z}/&#158;/g;
    s/\\v\{c}/&#269;/g;

    s/\\c\{n}/&#316;/g;

    s/\\\=\{E}/&#274;/g;
    s/\\\=\{U}/&#362;/g;
    s/\\\=\{I}/&#298;/g;
    s/\\\=\{A}/&#256;/g;

    s/\\v\{S}/&#352;/g;

    s/\\c\{G}/&#290;/g;
    s/\\c\{K}/&#310;/g;
    s/\\c\{L}/&#315;/g;

    s/\\v\{Z}/&#381;/g;
    s/\\v\{C}/&#268;/g;

    s/\\c\{N}/&#325;/g;
    s/\\c\{S}/&#350;/g;

    # Latex chars
    s/\\_/_/g;     # Underscore.
                   # Ampersand done above.
    s/\Q\^{}\E/&#94;/g; # Caret
    s/\Q\#\E/&#35;/g;   # Pound
    s/\$@\$/&#64;/g;    # AT

    do {
        $in = $_;		# process innermost tags until none left
        # italicization
        # !!! could also try to fix math, e.g., "$n$-gram"
        s/{\\em ([^\{\}]+)}/$1/g;
        s/\\textit\{([^\{\}]+)}/$1/g;
        s/\\emph\{([^\{\}]+)}/$1/g;

        # boldface
        s/{\\bf ([^\{\}]+)}/$1/g;
        s/\\textbf\{([^\{\}]+)}/$1/g;

        # small caps - just print normally
        s/\\textsc\{([^\{\}]+)}/$1/g;
    } until ($in eq $_);

    # Any remaining backslashed sequences get deleted with a WARNING
    warn "Don't know how to translate $& to HTML; deleting it" while s/\\[A-Za-z]+//;

    # eliminate any remaining curly braces (usually used to protect capitalization in bibtex).
    # Unless preceded by backslash.
    s/(?<!\\)[{}]//g;

    # Finally, convert HTML entities to their Unicode equivalents.
    $_ = decode_entities($_);

    print;

}
