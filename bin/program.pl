#!/usr/bin/perl

$curpage = 1;
$papnum = 0;
$authornum = 0;
$prevblank = 1;

$fn = "$ENV{ACLPUB}/templates/program.tex.head";
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
   elsif ($line =~ /^H:/) {
      $line =~ s/^H:[ ]*//;
      $hours[$papnum] = $line;
   }
   elsif ($line =~ /^X:/) {
      $line =~ s/^X:[ ]*//;
      $extra[$papnum] = $line;
      $prevblank = 0;
  }
   elsif ($line =~ /^[ \t]*$/ && !($prevblank)) {
      $prevblank = 1;
      $papnum++;
   }
   elsif($line =~ m/^F:/ or $line =~ m/^M:/) {}
   else {
       print STDERR "warning:  not sure what to do with this line:  ``$line''\n";
   }
}

&print_program;

printf("\n\n\\end{tabular}\n");

sub print_program {

    my $day = "No Day Set";
    
   for ($pn = 0; $pn < $papnum; $pn++) {
    
     ### Day (*), Sesion Titles (=), and Misc (+)
       if (defined($extra[$pn])) {
	   if ($extra[$pn] !~ /^(.) (.+)$/) {
	       print STDERR "format error in extra line: $extra[$pn]\n";
	   }
	   my $type = $1;
	   my $content = $2;
	   ## DAY
	   if ($type eq '*') {
	       printf("\\multicolumn{2}{l}{\\bf $content} \\\\\n");
	       $day = $content;
	   }

	   ## SESSION TITLE
	   elsif ($type eq '=') {
	        printf(" & {\\bf %s} \\\\\n",$content);
	    }

	   ## EXTRA (Breaks, Invited Talks, Business Meeting, ...)
	   elsif ($type eq '+') {
	       if ($content !~ /^(\S+) (.+)$/) {
		   print STDERR "format error in extra (+) line: $extra[$pn]\n";
	       }
	       my ($time,$description) = ($1,$2);
	       printf("%s & %s \\\\\n",$time,$description);
               $numlines += 0.8 if $description =~ /\\\\/;
	   }
	   else {
	   }
	   $numlines += 2;
	   printf("\\\\\n");
       }
       else {

      ### PRINT HOURS IN PROGRAM

	   if (defined($hours[$pn]) && $hours[$pn] ne 'none') {
	       printf("%s & ",$hours[$pn]);
	   }
	   else {
	       print " & ";
	   }

      ### PRINT TITLE LINE FOR PROGRAM

	   $line = $titles[$pn];
	   $line =~ s/[ \t]*\\\\[ \t]*/ \} \\\\ & \{\\em /g;
	   printf("\\hyperlink{page.$curpage}{");
	   if ($line =~ /Invited Talk:/ || $line =~ /Panel:/) {
	       $line =~ s/: /: \{\\em /;
	       printf("%s}}\\\\\n",$line);
	   }
	   else {
	       printf("\\em %s}\\\\\n",$line);
	   }
	   $curpage += $length[$pn];

      ### PRINT AUTHORS FOR PROGRAM

	   $num_authors = $endauthor[$pn] - $startauthor[$pn] + 1;
	   
	   printf("         & ");
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
	   printf(" \\\\\n\\\\\n\n");
	   
	   $numlines += 3;
       }

      if ($numlines > 35 || ($numlines > 25 && defined($extra[$pn+1]) && $extra[$pn+1] =~ /^[\*\=]/)) {
          printf("\\end{tabular}\n");
          printf("\\newpage\n");
          
          printf("\\begin{tabular}{p{20mm}p{128mm}}\n");
          printf("\\\\\n");
	  if (!defined($extra[$pn+1]) || $extra[$pn+1] !~ /^\*/) {
	      printf("\\multicolumn{2}{l}{\\bf $day (continued)} \\\\");
	      printf("\\\\\n");
	  }
          $numlines = 0;
      }
  }
}
