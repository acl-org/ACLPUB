#!/usr/bin/perl

use utf8;
use open qw(:std :utf8);

my ($db,$meta) = @ARGV;

my($title,$url,$abbrev,$year,$volume,$chairs,$type,$booktitle);
open(META, "$ENV{ACLPUB}/bin/db-to-html.pl $meta |") || die "can't open meta";
while(<META>) {
    chomp;
    my ($key,$value) = split(/\s+/,$_,2);
    $value =~ s/\s+$//;
    $abbrev = $value if $key eq 'abbrev';
    $type = $value if $key eq 'type';
    $volume = $value if $key eq "volume";
    if (!$volume) {$volume=1;}
    $year = $value if $key eq 'year';
    $title = $value if $key eq 'title';
    $booktitle = $value if $key eq 'booktitle';
    $url = $value if $key eq 'url';
    $chairs .= $value."<BR>\n" if $key eq 'chairs';
}
close(META);
my $day = "No Day Set";

my $urlpattern = "https://aclanthology.org/%s";
my $venue = lc $abbrev;

open(DB, "$ENV{ACLPUB}/bin/db-to-html.pl $db |") || die;

# Get the "DB" file.
my @data = <DB>;
my $dbstring = join("",@data);
$dbstring =~ s/\r//g; # possible windows entered

# Now get the various records in the DB. Two linefeeds are used to
# separate them.
my @records = split(/\n[ ]*\n/,$dbstring);

my $curpage = 1;
my $papnum = 0;
my $authornum = 0;
my $prevblank = 1;


# Now we have to process one record at a time.  The paper
# records will have P,M,T,A,F,L,Z,H. If a record starts with X,
# it is something else.

my %deposit = ();    # To deposit program entries.
my $id = -1;
@records = grep {($_)} @records;

foreach my $record (@records) {
    $id++;
    $deposit{$id}{id} = $id;

    # extra
    if ($record =~ /^X/) {
	$record =~ s/^X:[ ]*//;
	$deposit{$id}{type} = 'extra';
	$deposit{$id}{extra} = $record;
    }
    # paper
    else {
	$deposit{$id}{type} = 'paper';
	my @paprec = split(/\n/,$record);

	foreach my $line (@paprec) {
	    if ($line =~ /^T:/) {
		$line =~ s/^T:[ ]*//;
		$deposit{$id}{title} = $line;
		$deposit{$id}{startauthor} = $authornum;
	    } elsif ($line =~ /^A:/) {
		$line =~ s/^A:[ ]*//;
		# test for only last name
		if ($line =~ /^(.+), (.+)$/) {
		    $ln = $1; $fns = $2;
		    $_name = $fns . " " . $ln;
		}
		else {
		    $_name = $line;
		}
		$deposit{$id}{author}{$authornum++} = $_name;
	    }
	    elsif ($line =~ /^L:/) {
		$line =~ s/^L:[ ]*//;
		$deposit{$id}{length} = $line;
		$deposit{$id}{endauthor} = $authornum-1;
		if ($line > 0) {
		    $deposit{$id}{haspaper} = 1;
		    my $fnum = $papnum+1;
		    $deposit{$id}{file} = "$year.$venue-$volume.$fnum";
		}
	    } elsif ($line =~ /^H:/) {
		$line =~ s/^H:[ ]*//;
		$deposit{$id}{hours} = $line;
	    }
	}
	$papnum++;
    }
}


## PROGRAM HTML HEADER TO STDOUT
# !!! should have a generic translation mechanism here,
# not hardcoding specific subsets of the fields everywhere
open(HEADER, "$ENV{ACLPUB}/templates/proceedings/program.html.head") || die;
while (<HEADER>) {
  s/<XXX TITLE>/$title/g;
  s/<XXX TYPE>/$type/g;
  s/<XXX BOOKTITLE>/$booktitle/g;
  s/<XXX CHAIRS>/$chairs/g;
  print;
}
close(HEADER);

## PROGRAM HTML BODY AND FOOTER TO STDOUT

# These are not papers, they are now records.
for (my $pn = 0; $pn <= $id; $pn++) {

  ### Day (*), Session Titles (=), and Misc (+)

    if ($deposit{$pn}{type} eq 'extra') {
	my $thisone = $deposit{$pn}{extra};
	if ($thisone !~ /^(.) (.+)$/) {
	    print STDERR "format error in extra line: $deposit{$pn}{extra}\n";
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
		print STDERR "format error in extra (+) line: $deposit{$pn}{extra} || $content\n";
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
    }
    else {

    ### PRINT HOURS IN PROGRAM

      if (($deposit{$pn}{hours}) && ($deposit{$pn}{hours} ne 'none')) { 
	  my $hours = $deposit{$pn}{hours};
	  printf("<tr><td valign=top width=100>%s</td><td valign=top align=left>",$hours);

      } else {
	  print "<tr><td valign=top width=100>&nbsp;</td><td valign=top align=left>";
	  ### -2009/6/17- left justified titles
	  ### -2009/6/22- min. width reserved
      }

      ### PRINT TITLE LINE FOR PROGRAM

      if ($deposit{$pn}{haspaper}) {

	printf("<a href=\"pdf/$deposit{$pn}{file}.pdf\">");
	$line = $deposit{$pn}{title};
	$line =~ s/[ \t]*\\\\[ \t]*/ \} \\\\ & \{\\em /g;
	if ($line =~ /Invited Talk:/ || $line =~ /Panel:/) {
	    $line =~ s/: /:<i> /;
	    printf("%s</i></a><br>\n",$line);
	} else {
	    printf("<i>%s</i></a><br>\n",$line);
	}
    }
    else {
	$line = $deposit{$pn}{title};
	$line =~ s/[ \t]*\\\\[ \t]*/ \} \\\\ & \{\\em /g;
	printf("<i>%s</i><br>\n",$line);
    }


    $curpage += $length[$pn];

    ### PRINT AUTHORS FOR PROGRAM

      my $startauthor = $deposit{$pn}{startauthor};
      my $endauthor = $deposit{$pn}{endauthor};
      my $num_authors = $endauthor - $startauthor + 1;
	   
      if ($num_authors == 1) {
	  printf("%s",$deposit{$pn}{author}{$startauthor});
      } else { 

      for (my $i = $startauthor; $i < $endauthor-1; $i++) {
	printf("%s, ",$deposit{$pn}{author}{$i});
      }
      printf("%s and %s",$deposit{$pn}{author}{$endauthor-1},$deposit{$pn}{author}{$endauthor});

    }
    print "</td></tr>\n";
	   
    $numlines += 3;
  }
       
}

### -2009/06/22- opeing <center> had never been closed
### since 2006 or earlier. add </center>
### should detect then close??
printf("</table></center><p>&nbsp;</body></html>\n");
