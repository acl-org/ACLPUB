#!/usr/bin/perl -p

# Filters a DB (or meta) file so that its entries are friendly for inclusion
#   in PDF metadata
# The result is still a DB (or meta) file.
#
# !!! Isn't there a Perl module that could handle this?
#

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

# diacritics
#
# See relevant comments in db-to-html.pl
# Here, we flatten to letter without diacritics, for better or worse.
# Should find out how PDF metadata expects its diacritics

s/Á/A/g; 
s/Â/A/g;
s/À/A/g;
s/Å/A/g;
s/Ã/A/g;
s/Ä/A/g;
s/Ç/C/g;
s/Ð/D/g;
s/É/E/g;
s/Ê/E/g;
s/È/E/g;
s/Ë/E/g;
s/Í/I/g;
s/Î/I/g;
s/Ì/I/g;
s/Ï/I/g;
s/Ñ/N/g;
s/Ó/O/g;
s/Ô/O/g;
s/Ò/O/g;
s/Ø/O/g;
s/Õ/O/g;
s/Ö/O/g;
s/Þ/TH/g;
s/Ú/U/g;
s/Û/U/g;
s/Ù/U/g;
s/Ü/U/g;
s/Ý/Y/g;
s/á/a/g;
s/â/a/g;
s/æ/ae;/g;
s/à/a/g;
s/å/a/g;
s/ã/a/g;
s/ä/a/g;
s/ç/c/g;
s/é/e/g;
s/ê/e/g;
s/è/e/g;
s/ð/e/g;
s/ë/e/g;
s/í/i/g;
s/î/i/g;
s/ì/i/g;
s/ï/i/g;
s/ñ/n/g;
s/ó/o/g;
s/ô/o/g;
s/ò/o/g;
s/ø/o/g;
s/õ/o/g;
s/ö/o/g;
s/ß/ss;/g;
s/þ/th;/g;
s/ú/u/g;
s/û/u/g;
s/ù/u/g;
s/ü/u/g;
s/ý/y/g;
s/ÿ/y/g;
s/ł/l/g;


s/\\\'\{a}/a/g;
s/\\\'\{e}/e/g;
s/\\\'\{i}/i/g;
s/\\\'\{\\i}/i/g;
s/\\\'\{o}/o/g;
s/\\\'\{u}/u/g;
s/\\\'\{y}/y/g;

s/\\\`\{a}/a/g;
s/\\\`\{e}/e/g;
s/\\\`\{i}/i/g;
s/\\\`\{\\i}/i/g;
s/\\\`\{o}/o/g;
s/\\\`\{u}/u/g;

s/\\\^\{a}/a/g;
s/\\\^\{e}/e/g;
s/\\\^\{i}/i/g;
s/\\\^\{\\i}/i/g;
s/\\\^\{o}/o/g;
s/\\\^\{u}/u/g;

s/\\\"\{a}/a/g;
s/\\\"\{e}/e/g;
s/\\\"\{i}/i/g;
s/\\\"\{\\i}/i/g;
s/\\\"\{o}/o/g;
s/\\\"\{u}/u/g;

s/\{\\\"a}/a/g;
s/\{\\\"e}/e/g;
s/\{\\\"i}/i/g;
s/\{\\\"o}/o/g;
s/\{\\\"u}/u/g;

s/\\\~\{a}/a/g;
s/\\\~\{o}/o/g;
s/\\\~\{n}/n/g;
s/\\c\{c}/c/g;

s/\\v\{C}/C/g;
s/\\v\{c}/c/g;
s/\\v\{E}/E/g;
s/\\v\{e}/e/g;
s/\\v\{N}/N/g;
s/\\v\{n}/n/g;
s/\\v\{S}/S/g;
s/\\v\{r}/r/g;
s/\\v\{s}/s/g;
s/\\v\{Z}/Z/g;
s/\\v\{z}/z/g;
s/\{\\AA}/A/g;
s/\{\\aa}/a/g;
s/\{\\AE}/AE/g;
s/\{\\ae}/ae/g;
s/\{\\ss}/ss/g;

s/\{?\\\'a}?/a/g;
s/\{?\\\'e}?/e/g;
s/\{?\\\'i}?/i/g;
s/\{?\\\'\\i}?/i/g;
s/\{?\\\'o}?/o/g;
s/\{?\\\'u}?/u/g;
s/\{?\\\'y}?/y/g;

s/\{?\\\`a}?/a/g;
s/\{?\\\`e}?/e/g;
s/\{?\\\`i}?/i/g;
s/\{?\\\`\\i}?/i/g;
s/\{?\\\`o}?/o/g;
s/\{?\\\`u}?/u/g;

s/\{?\\\^a}?/a/g;
s/\{?\\\^e}?/e/g;
s/\{?\\\^i}?/i/g;
s/\{?\\\^\\i}?/i/g;
s/\{?\\\^o}?/o/g;
s/\{?\\\^u}?/u/g;

s/\{?\\\"a}?/a/g;
s/\{?\\\"e}?/e/g;
s/\{?\\\"i}?/i/g;
s/\{?\\\"\\i}?/i/g;
s/\{?\\\"o}?/o/g;
s/\{?\\\"u}?/u/g;

s/\{?\\\~a}?/a/g;
s/\{?\\\~o}?/o/g;
s/\{?\\\~n}?/n/g;

s/\\\'\{A}/A/g;
s/\\\'\{E}/E/g;
s/\\\'\{I}/I/g;
s/\\\'\{O}/O/g;
s/\\\'\{U}/U/g;

s/\\\`\{A}/A/g;
s/\\\`\{E}/E/g;
s/\\\`\{I}/I/g;
s/\\\`\{O}/O/g;
s/\\\`\{U}/U/g;

s/\\\^\{A}/A/g;
s/\\\^\{E}/E/g;
s/\\\^\{I}/I/g;
s/\\\^\{O}/O/g;
s/\\\^\{U}/U/g;

s/\\\"\{A}/A/g;
s/\\\"\{E}/E/g;
s/\\\"\{I}/I/g;
s/\\\"\{O}/O/g;
s/\\\"\{U}/U/g;

s/\\\~\{A}/A/g;
s/\\\~\{O}/O/g;
s/\\\~\{N}/N/g;
s/\\c\{C}/C/g;
s/\\\'\{S}/S/g;
s/\\\'\{C}/C/g;
s/\\\'\{s}/s/g;
s/\\\'\{c}/c/g;

s/\{\\l}/l/g;
s/\\\=\{e}/e/g;
s/\\\=\{u}/u/g;
s/\\\=\{\\\i}/i/g;
s/\\\=\{a}/a/g;

s/\\v\{s}/s/g;

s/\\v\{g}/g/g;

s/\\c\{k}/k/g;

s/\\c\{l}/l/g;

s/\\v\{z}/z/g;

s/\\v\{c}/c/g;

s/\\c\{n}/n/g;

s/\\\=\{E}/E/g;

s/\\\=\{U}/U/g;

s/\\\=\{I}/I/g;

s/\\\=\{A}/A/g;

s/\\v\{S}/S/g;

s/\\c\{G}/G/g;

s/\\c\{K}/K/g;

s/\\c\{L}/L/g;

s/\\v\{Z}/Z/g;

s/\\v\{C}/C/g;

s/\\c\{N}/N/g;

s/\\c\{S}/S/g;

s/\\v\{a}/a/g;

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

