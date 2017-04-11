#!/usr/bin/perl

$curpage = 1;
$papnum = 0;
$authornum = 0;
$prevblank = 1;


$fn = "$ENV{ACLPUB}/templates/toc.tex.head";
open(FILE,$fn) || die "Can't open $fn: $!\n";
while(<FILE>) {
  printf("%s",$_);
}
printf("\n");


while(<STDIN>) {
   chop;
   $line=$_;

   if ($line =~ /^T:/) {
      $line =~ s/^T:[ ]*//;
      $titles[$papnum] = $line;
      $startauthor[$papnum] = $authornum;
      $prevblank = 0;
   }
   elsif ($line =~ /^A:/) {
       $line =~ s/^A:[ ]*//;
       # test for only last name
       if ($line =~ /^(.+), (.+)$/) {
	   $ln = $1; $fns = $2;
	   $_name = $fns . " " . $ln;
       }
       elsif ($line =~ /^(.*),/) {
	   $_name = $1;
       }
       else {
	   $_name = 'unknown';
       }
       $authors[$authornum++] = $_name;
   }
   elsif ($line =~ /^L:/) {
      $line =~ s/^L:[ ]*//;
      $length[$papnum] = $line;
      $endauthor[$papnum] = $authornum-1;
   }
   elsif ($line =~ /^P:/) {
      $line =~ s/^P:[ ]*//;
      $id[$papnum] = $line;
   }
   elsif ($line =~ /^[ \t]*$/ && !($prevblank)) {
      $prevblank = 1;
      $papnum++;
   }
}

&print_table_of_contents;

sub print_table_of_contents {

   for ($pn = 0; $pn < $papnum; $pn++) {

       if ($length[$pn] > 0) {

	   ### PRINT TITLE LINE FOR TABLE OF CONTENTS
	   $line = $titles[$pn];
	   printf("\\hyperlink{page.$curpage}{");
	   if ($line =~ /Invited Talk:/ || $line =~ /Panel:/) {
	       $line =~ s/: /: {\\em /;
	       printf("%s}}\\samepage \\\\\n",$line);
	   }
	   else {
	       printf("\\em %s}\\samepage \\\\\n",$line);
	   }

	   ### PRINT AUTHORS FOR TABLE OF CONTENTS

	   $num_authors = $endauthor[$pn] - $startauthor[$pn] + 1;

	   printf("\\hspace*{7mm} ");
	   if ($num_authors == 1) {
	       printf("%s",$authors[$startauthor[$pn]]);
	   }
	   else { 
	       $endauth = $endauthor[$pn];
	       for($i = $startauthor[$pn]; $i < $endauth-1; $i++) {
		   printf("%s, ",$authors[$i]);
	       }
	       printf("%s and %s",$authors[$endauth-1],$authors[$endauth]);
	   }

	   ### PRINT STARTING PAGE FOR TABLE OF CONTENTS

	   $paplength = $length[$pn];
	   printf("\\dotfill \\hyperpage{%s}\n\n",$curpage);
	   $curpage += $paplength; 
       }
   }
}
