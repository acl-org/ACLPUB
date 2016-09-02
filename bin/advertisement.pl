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
   s{<a href="(?!http:)[\.\/]*index.*?">(.*?)</a>[\s|]*}{}g;  # remove relative links and their anchors 

   s{../(?=\S+.css)}{}g;                     # stylesheet location: remove ../ from the front of ../*.css
   s{<a href="(?!http:).*?">(.*?)</a>}{$1}g; # kill relative links (to papers), keeping anchor text
   print;
 }
