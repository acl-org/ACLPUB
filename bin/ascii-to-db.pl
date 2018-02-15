#!/usr/bin/perl -p

# Filters a metadata file from START, to translate its
# accented characters into latex format for the DB file.

s/®/\\textregistered\~/g;
s/–/--/g;

s/ﬁ/fi/g;

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
