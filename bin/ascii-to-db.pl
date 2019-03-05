#!/usr/bin/perl

# Filters a paper metadata file from START.

use utf8;
use open qw(:std :utf8);

use Unicode::Normalize;

sub convert {
    my $s = $_[0];

    ### Normalize Unicode

    # We want NFC with *some* aspects of NFKC normalization.
    
    # We want:
    # - fullwidth characters sometimes used with CJK
    # - ligatures like ﬁ that come from copy-and-pasting PDF files
    # But we don't want (for example):
    # - subscripts and superscripts (²)
    
    $s =~ s/(\p{Halfwidth_and_Fullwidth_Forms}|\p{Alphabetic Presentation Forms})/NFKD($1)/ge;
    $s = NFC($s);

    ### Handle characters that have a special meaning in TeX.
    
    # & # % are unlikely to be used with their TeX meanings, so escape them.
    $s =~ s/(?<!\\)([&#%])/\\$1/g;

    # ^ and _ should only be escaped outside of math mode, so hide math, escape, unhide math.
    $s =~ s/\$(.*?)\$/'$'.unpack("H*",$1).'$'/ge;
    $s =~ s/(?<!\\)([\^_])/\\$1/g;
    $s =~ s/\$(.*?)\$/'$'.pack("H*",$1).'$'/ge;

    # But { } $ ~ can be used either as ordinary characters or with their TeX meanings.
    # To do: Rules for determining when to escape these.
    
    return $s;
}

while (<>) {
    # The START metadata file uses #==# and #=%=# as key/value separators.
    # We only want to convert the values.
    if (/^(.*#=%?=#)(.*)$/s) {
        print $1, convert($2);
    } else {
        print convert($_);
    }
}
