#!/usr/bin/perl

# Filters a DB (or meta) file so that its entries are more HTML-friendly.
# The result is still a DB (or meta) file.
#
# There is a module, TeX::Encode, that does most of this, but it
# currently (Mar 2019) has a bug, mapping (for example) \it to ıt.

use utf8;
use open qw(:std :utf8);

use Unicode::Normalize;
use HTML::Entities;

while (<>) {
    if (/^(url|bib_url) /) {
        # don't mess with url or bib_url lines in meta (e.g., don't delete ~)
        print;
        next;
    }

    chomp;

    # The following two changes make later processing simpler.
    
    # Exactly one space after every control word
    s/(\\[A-Za-z]+)\s*/$1 /g;

    # Remove curly braces around single characters
    s/\{([^\\{}])\}/$1/g;

    # latex cruft
    s/\\@//g;          # \@, sometimes used after periods
    s/\\-//g;          # soft hyphen
    s/\\,//g;          # \, sometimes used to widen titles in TOC
    s/\\ / /g;         # hard space: convert to ordinary space
    s/(?<!\\)~/ /g;    # tie (~) unless preceded by backslash: convert to ordinary space
    
    # Latex chars
    s/\\&/&/g;
    s/\\#/#/g;
    s/\\%/%/g;
    s/\\\^\{}/^/g;
    s/\\_/_/g;
    s/\\\$/\$/g;
    
    # common latex glyphs
    s/---/—/g;
    s/--/–/g;
    s/(?<!\\)``/“/g;  # smart quotes (also single apostrophe), unless preceded by backslash
    s/(?<!\\)''/”/g;
    s/(?<!\\)`/‘/g;
    s/(?<!\\)'/’/g; # bug: 'foo' -> ’foo’

    s/\\AA /Å/g;
    s/\\aa /å/g;
    s/\\AE /Æ/g;
    s/\\ae /æ/g;
    s/\\DH /Ð/g;
    s/\\dh /ð/g;
    s/\\i /ı/g; # keep this before translation of accents
    s/\\L /Ł/g; 
    s/\\l /ł/g;
    s/\\O /Ø/g;  
    s/\\o /ø/g; 
    s/\\ss /ß/g;
    s/\\TH /Þ/g;
    s/\\th /þ/g;

    # Convert TeX accents to Unicode combining accents (which come after)
    s/\\'\s*([^\\{}])/$1\N{COMBINING ACUTE ACCENT}/g;
    s/\\`\s*([^\\{}])/$1\N{COMBINING GRAVE ACCENT}/g;
    s/\\\^\s*([^\\{}])/$1\N{COMBINING CIRCUMFLEX ACCENT}/g;
    s/\\~\s*([^\\{}])/$1\N{COMBINING TILDE}/g;
    s/\\=\s*([^\\{}])/$1\N{COMBINING MACRON}/g;
    s/\\u ([^\\{}])/$1\N{COMBINING BREVE}/g;
    s/\\d ([^\\{}])/$1\N{COMBINING DOT ABOVE}/g;
    s/\\"\s*([^\\{}])/$1\N{COMBINING DIAERESIS}/g;
    s/\\r ([^\\{}])/$1\N{COMBINING RING ABOVE}/g;
    s/\\H ([^\\{}])/$1\N{COMBINING DOUBLE ACUTE ACCENT}/g;
    s/\\v ([^\\{}])/$1\N{COMBINING CARON}/g;
    s/\\\.\s*([^\\{}])/$1\N{COMBINING DOT BELOW}/g;
    s/\\c ([^\\{}])/$1\N{COMBINING CEDILLA}/g;
    s/\\k ([^\\{}])/$1\N{COMBINING OGONEK}/g;

    # Convert letter + combining accent to composed character
    $_ = NFC($_);
    
    # HTML escaping
    $_ = encode_entities($_, '<>&"\'');

    # Now introduce HTML tags

    s/\\\\|\\newline /<br>/g;    # latex newlines: convert to <br>
    
    do {
        $in = $_;		# process innermost tags until none left
        # !!! could also try to fix math, e.g., "$n$-gram"
        
        # italics
        s/\\em ([^{}]+)(?=})/<i>$1<\/i>/g;
        s/\\emph \{([^{}]+)}/<i>$1<\/i>/g;
        s/\\it ([^{}]+)(?=})/<i>$1<\/i>/g;
        s/\\textit \{([^{}]+)}/<i>$1<\/i>/g;

        # boldface
        s/\\bf ([^{}]+)(?=})/<b>$1<\/b>/g;
        s/\\textbf \{([^{}]+)}/<b>$1<\/b>/g;

        # small caps - just print normally
        s/\\sc ([^{}]+)(?=})/$1/g;
        s/\\textsc \{([^{}]+)}/$1/g;
    } until ($in eq $_);

    # eliminate any remaining curly braces (usually used to protect capitalization in bibtex).
    # Unless preceded by backslash.
    s/(?<!\\)[{}]//g;
    
    s/\\\{/{/g;
    s/\\\}/}/g;

    # Any remaining backslashed sequences get deleted with a WARNING
    warn "Don't know how to translate $& to HTML; deleting it" while s/\\[A-Za-z]+ |\\.//;

    print "$_\n";

}
