#!/usr/bin/perl

my ($db,$meta) = @ARGV;

my ($title,$booktitle, $urlpattern);
open(META, "$ENV{ACLPUB}/bin/db-to-html.pl $meta |") || die "can't open meta";
while(<META>) {
    chomp;
    my ($key,$value) = split(/\s+/,$_,2);
    $title = $value if $key eq 'title';
    $type = $value if $key eq 'type';
    $abbrev = $value if $key eq 'abbrev';
    $booktitle = $value if $key eq 'booktitle';
    $chairs .= $value."<BR>\n" if $key eq 'chairs';
    $urlpattern = $value if $key eq 'bib_url';
}
close(META);
my $day = "No Day Set";

$urlpattern =~ m/\%0(\d)d/;
my $digits = $1; # checked in bib.pl

$curpage = 1;
$papnum = 0;
$authornum = 0;
$prevblank = 1;

open(DB, "$ENV{ACLPUB}/bin/db-to-html.pl $db |") || die;
while(<DB>) {
  chomp;
  $line = $_;

  if ($line =~ /^T:/) {
    $line =~ s/^T:[ ]*//;
    $titles[$papnum] = $line;
    $startauthor[$papnum] = $authornum;
    $prevblank = 0;
  } elsif ($line =~ /^A:/) {
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
    if ($length[$papnum] > 0) {
	$haspaper[$papnum] = 1;
    }
  } elsif ($line =~ /^P:/) {
    $line =~ s/^P:[ ]*//;
    $id[$papnum] = $line;
  } elsif ($line =~ /^H:/) {
    $line =~ s/^H:[ ]*//;
    $hours[$papnum] = $line;
  } elsif ($line =~ /^X:/) {
    $line =~ s/^X:[ ]*//;
    $extra[$papnum] = $line;
    $prevblank = 0;
  } elsif ($line =~ /^[ \t]*$/ && !($prevblank)) {
    $prevblank = 1;
    $papnum++;
  }
}
close(DB);


## PROGRAM HTML HEADER TO STDOUT
# !!! should have a generic translation mechanism here,
# not hardcoding specific subsets of the fields everywhere
open(HEADER, "$ENV{ACLPUB}/templates/program.html.head") || die;
while (<HEADER>) {
  s/<XXX TITLE>/$title/g;
  s/<XXX TYPE>/$type/g;
  s/<XXX BOOKTITLE>/$booktitle/g;
  s/<XXX CHAIRS>/$chairs/g;
  print;
}
close(HEADER);

## PROGRAM HTML BODY AND FOOTER TO STDOUT

for ($pn = 0; $pn < $papnum; $pn++) {

  ### Day (*), Session Titles (=), and Misc (+)
  if (defined($extra[$pn])) {
    if ($extra[$pn] !~ /^(.) (.+)$/) {
      print STDERR "format error in extra line: $extra[$pn]\n";
    }
    my $type = $1;
    my $content = $2;

    ## DAY
    if ($type eq '*') {
      print ("<tr><td colspan=2 style=\"padding-top: 14px;\"><h4>$content</h4></td></tr>\n");
      $day = $content;
    }

    ## SESSION TITLE
    elsif ($type eq '=') {
	# look for time if exists
	if ($content =~ /^([0-9,\.\:]+)(\Q&#8211;\E)([0-9,\.\:]+) (.*)$/) {
	    my $time = "$1$2$3";
	    my $description = $4;
	    print("<tr><td valign=top style=\"padding-top: 14px;\"><b>$time</b></td><td valign=top style=\"padding-top: 14px;\"><b>$description</b></td></tr>\n");
	}
	else {
	    print ("<tr><td valign=top style=\"padding-top: 14px;\">&nbsp;</td><td valign=top style=\"padding-top: 14px;\"><b>$content</b></td></tr>\n");
	}
    }

    ## EXTRA (Breaks, Invited Talks, Business Meeting, ...)
    elsif ($type eq '+') {
      if ($content !~ /^(\S+) (.+)$/) {
	print STDERR "format error in extra (+) line: $extra[$pn] || $content\n";
      }
      my ($time,$description) = ($1,$2);
      print ("<tr><td valign=top style=\"padding-top: 14px;\"><b>$time</b></td><td valign=top style=\"padding-top: 14px;\"><b><em>$description</em></b></td></tr>\n");
    }
    ## EXTRA TYPE 2 - generic speech with special % tags.
    elsif ($type eq '!') {
	my $time = $description = ();
	if ($content =~ /^([0-9,\.\:]+)/) {
	    if ($content =~ /^(\S+) (.+)$/) {
		($time,$description) = ($1,$2);
	    }
	}
	else {
	    $description = $content;
	}
	print ("<tr><td valign=top>$time</td>");

	# Get title, presenter, affiliation, url out of title.
	$description =~ /([^%]+) %by (.+)$/;

	my ($title,$rest) = ($1,$2);

	$rest =~ /[\s ]*([^%]+)[\s ]*/;
	my $xauthors = $1;

	if ($rest =~ /[\s ]*%u[\s ]*([^%]+)/) {
	    my $url = $1;
	    print "<td valign=top><em><a href=\"$url\">$title</a></em><br>$xauthors</td></tr>\n";
	}
	else {
	    print "<td valign=top><em>$title</em><br>$xauthors</td></tr>\n";
	}
    }

  } else {

    ### PRINT HOURS IN PROGRAM

    if (defined($hours[$pn]) && $hours[$pn] ne 'none') {
      printf("<tr><td valign=top width=100>%s</td><td valign=top align=left>",$hours[$pn]);
      ### -2009/6/12- left justified titles
      ### -2009/6/22- min. width reserved
    } else {
      print "<tr><td valign=top width=100>&nbsp;</td><td valign=top align=left>";
      ### -2009/6/17- left justified titles
      ### -2009/6/22- min. width reserved
    }

    ### PRINT TITLE LINE FOR PROGRAM

    if ($haspaper[$pn]) {
	printf("<a href=\"pdf/${abbrev}%0${digits}d.pdf\">",++$pp);
	$line = $titles[$pn];
	$line =~ s/[ \t]*\\\\[ \t]*/ \} \\\\ & \{\\em /g;
	if ($line =~ /Invited Talk:/ || $line =~ /Panel:/) {
	    $line =~ s/: /:<i> /;
	    printf("%s</i></a><br>\n",$line);
	} else {
	    printf("<i>%s</i></a><br>\n",$line);
	}
    }
    else {
	$line = $titles[$pn];
	$line =~ s/[ \t]*\\\\[ \t]*/ \} \\\\ & \{\\em /g;
	printf("<i>%s</i><br>\n",$line);
    }


    $curpage += $length[$pn];

    ### PRINT AUTHORS FOR PROGRAM

    $num_authors = $endauthor[$pn] - $startauthor[$pn] + 1;
	   
    if ($num_authors == 1) {
      printf("%s",$authors[$startauthor[$pn]]);
    } else { 
      $endauth = $endauthor[$pn];
      for ($i = $startauthor[$pn]; $i < $endauth-1; $i++) {
	printf("%s, ",$authors[$i]);
      }
      printf("%s and %s",$authors[$endauth-1],$authors[$endauth]);
    }
    print "</td></tr>\n";
	   
    $numlines += 3;
  }
       
}

### -2009/06/22- opeing <center> had never been closed
### since 2006 or earlier. add </center>
### should detect then close??
printf("</table></center><p>&nbsp;</body></html>\n");
