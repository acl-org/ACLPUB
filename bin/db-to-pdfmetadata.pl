#!/usr/bin/perl -p

# Filters a DB (or meta) file so that its entries are friendly for inclusion
# in PDF metadata.

next if /^url/;    # don't mess with url or bib_url lines (e.g., don't delete ~)

s/\r//g;         # kill CR from DOS format files

# latex cruft
s/\\@//g;          # kill latex \@, sometimes used after periods
s/\\,//g;          # kill latex \, sometimes used to widen titles in TOC
s/\\\\|\\newline\b//g;    # kill latex newlines
s/\\ / /g;         # latex hard space: convert to ordinary space
s/(?<!\\)~/ /g;    # latex hard space ~ unless preceded by backslash: convert to ordinary space
s/\\&/&/g;         # latex \&

# common latex glyphs
s/---/-/g;         # emdash
s/--/-/g;          # endash
s/(?<!\\)\`\`/"/g;  # smart quotes (also single apostrophe), unless preceded by backslash
s/(?<!\\)\'\'/"/g;
s/(?<!\\)\`/'/g;
s/(?<!\\)\'/'/g;

# collapse whitespace
s/[ \t]+/ /g;
s/^ //;
s/ $//;

#Latex chars
s/\\_/_/g;      # Underscore
                # Ampersand done above.
s/\Q\^{}\E/^/g; # Caret
s/\Q\#\E/#/g;   # Pound
s/\$@\$/@/g;    # AT

# italicization (not too careful about nested {}).

s/{\\em (.+)}/$1/;
s/\\textit\{(.+)}/$1/;
s/\$(.+)\$/$1/;

# Any remaining backslashed sequences get deleted with a WARNING
warn "Don't know how to translate $& to PDF metadata; deleting it" while s/\\[A-Za-z]+//;

# eliminate any remaining curly braces (usually used to protect capitalization in bibtex).
# Unless preceded by backslash.
s/(?<!\\)[{}]//g;

