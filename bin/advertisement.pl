#!/usr/bin/perl

# Create pre-conference "advertisement" version of HTML program.
# Usage: advertisement.pl index.html < program.html > advertisement.html
#
# Basically, this just filters program.html to remove the links to
# actual papers.  We also replace the nav line at the top with a
# modified version of the one from index.html, and correct the directory
# in the stylesheet location.

$indexfile = shift(@ARGV);

while (<>) {
   if (/<td.* CD/) {   # nav line
     $_ = `cat $indexfile | grep "<td.*CD" | head -1`;  # replace with nav line from index.html.  (!!! Error-prone hack ...)
     die unless defined $_;
     s{<a href="(?!http:).*?">(.*?)</a>[\s|]*}{}g;  # remove relative links and their anchors \s{<a href="(?!http:).*?">(.*?)</a>[\s|]*}{}g;  # remove relative links and their anchors
   }

   s{../(?=\S+.css)}{}g;                     # stylesheet location: remove ../ from the front of ../*.css
   s{<a href="(?!http:).*?">(.*?)</a>}{$1}g; # kill relative links (to papers), keeping anchor text
   print;
 }
