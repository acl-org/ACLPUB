#!/usr/bin/perl -p

# Filters a metadata file from START, to translate its
# accented characters into latex format for the DB file.
#
# !!! Isn't there a Perl module that could handle this?

s/Ä/\\\"\{A\}/g;
s/Ë/\\\"{E}/g;
s/Ï/\\\"{I}/g;
s/Ö/\\\"{O}/g;
s/Ü/\\\"{U}/g;
s/ä/\\\"{a}/g;
s/ë/\\\"{e}/g;
s/ï/\\\"{i}/g;
s/ö/\\\"{o}/g;
s/ü/\\\"{u}/g;
s/ÿ/\\\"{y}/g;
s/Æ/{\\AE}/g;
s/æ/{\\ae}/g;
s/ß/{\\ss}/g;
s/Á/\\\'{A}/g;
s/É/\\\'{E}/g;
s/Í/\\\'{I}/g;
s/Ó/\\\'{O}/g;
s/Ú/\\\'{U}/g;
s/Ý/\\\'{Y}/g;
s/á/\\\'{a}/g;
s/é/\\\'{e}/g;
s/í/\\\'{i}/g;
s/ń/\\\'{n}/g;
s/ó/\\\'{o}/g;
s/ú/\\\'{u}/g;
s/ý/\\\'{y}/g;
s/Ś/\\\'{S}/g;
s/ś/\\\'{s}/g;
s/ć/\\\'{c}/g;
s/À/\\\`{A}/g;
s/È/\\\`{E}/g;
s/Ì/\\\`{I}/g;
s/Ò/\\\`{O}/g;
s/Ù/\\\`{U}/g;
s/à/\\\`{a}/g;
s/è/\\\`{e}/g;
s/ì/\\\`{i}/g;
s/ò/\\\`{o}/g;
s/ù/\\\`{u}/g;
s/Â/\\\^{A}/g;
s/Ê/\\\^{E}/g;
s/Î/\\\^{I}/g;
s/Ô/\\\^{O}/g;
s/Û/\\\^{U}/g;
s/â/\\\^{a}/g;
s/ê/\\\^{e}/g;
s/î/\\\^{i}/g;
s/ô/\\\^{o}/g;
s/û/\\\^{u}/g;
s/Ã/\\\~{A}/g;
s/Ñ/\\\~{N}/g;
s/Õ/\\\~{O}/g;
s/ã/\\\~{a}/g;
s/ũ/\\\~{u}/g;
s/ĩ/\\\~{i}/g;
s/ñ/\\\~{n}/g;
s/õ/\\\~{o}/g;
s/Å/\\r{A}/g;
s/å/\\r{a}/g;
s/Ç/\\c{C}/g;
s/ç/\\c{c}/g;
s/Ø/{\\O}/g;
s/ø/{\\o}/g;
s/Š/\\v{S}/g;
s/ř/\\v{r}/g;
s/š/\\v{s}/g;
s/č/\\v{c}/g;
s/ň/\\v{n}/g;
s/ă/\\v{a}/g;
s/ă/\\u{a}/g;
s/ğ/\\u{g}/g;
s/®/\\textregistered\~/g;
s/–/--/g;
s/ł/{\\l}/g;
s/ē/\\={e}/g;
s/ū/\\={u}/g;
s/ī/\\={\\i}/g;
s/ā/\\={a}/g;
s/š/\\v{s}/g;
s/ģ/\\v{g}/g;
s/ķ/\\c{k}/g;
s/ļ/\\c{l}/g;
s/ž/\\v{z}/g;
s/č/\\v{c}/g;
s/ņ/\\c{n}/g;
s/Ē/\\={E}/g;
s/Ū/\\={U}/g;
s/Ī/\\={I}/g;
s/Ā/\\={A}/g;
s/Š/\\v{S}/g;
s/Ģ/\\c{G}/g;
s/Ķ/\\c{K}/g;
s/Ļ/\\c{L}/g;
s/Ž/\\v{Z}/g;
s/Č/\\v{C}/g;
s/Ņ/\\c{N}/g;
s/Ş/\\c{S}/g;
s/ș/\\c{s}/g;
s/ț/\\c{t}/g;
s/ę/\\k{e}/g;

s/ﬁ/fi/g;
#
# Latex Chars
s/([^\\])(_)/$1\\$2/g;   # unescaped underscore
s/([^\\])(\&)/$1\\$2/g;  # unescaped ampersand
s/([^\\])(\^)/$1\\^{}/g; # unescaped carrot

s/([^=#])(\#)([^=#])/${1}\\#${3}/g;    # pound sign - watch out for separator #=%=#
s/^(\#)([^=#])/\\#${2}/g;
s/([^=#])(\#)$/${1}\\#/g;
s/#=%=##/#=%=#\\#/g;
s/##=%=#/\\##=%=#/g;

s/([^\\])(\@)/$1\$@\$/g;  # unescaped at-sign
