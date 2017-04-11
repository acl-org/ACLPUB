#!/usr/bin/perl

# Creates an HTML table of contents.  Prints it to stdout.

my($db, $meta) = @ARGV;

my($title,$url,$abbrev,$year,$chairs,$urlpattern);
open(META, "$ENV{ACLPUB}/bin/db-to-html.pl $meta |") || die;
while (<META>) {
  chomp;
  my ($key,$value) = split(/\s+/,$_,2);
  $value =~ s/\s+$//;
  $abbrev = $value if $key eq 'abbrev';
  $type = $value if $key eq 'type';
  $year = $value if $key eq 'year';
  $title = $value if $key eq 'title';
  $booktitle = $value if $key eq 'booktitle';
  $url = $value if $key eq 'url';
  $chairs .= $value."<BR>\n" if $key eq 'chairs';
  $urlpattern = $value if $key eq 'bib_url';
}
close(META);

$urlpattern =~ m/\%0(\d)d/;
my $digits = $1; # checked in bib.pl
$fmzeros = sprintf "%0${digits}d", 0;

# Initialize Type to account for old templates.
#    linktype = old: Original layout with 4 columns.
#    linktype = new; New layout with brackets for links, to accommodate unlimited number of attachments.
#
$linktype = 'old';

#add header information
open(HEADER, "$ENV{ACLPUB}/templates/index.html.head") || die;
while (<HEADER>) {
  s/<XXX TITLE>/$title/g;
  s/<XXX TYPE>/$type/g;
  s/<XXX ABBREV>/$abbrev/g;
  s/<XXX YEAR>/$year/g;
  s/<XXX BOOKTITLE>/$booktitle/g;
  s/<XXX URL>/$url/g;
  s/<XXX CHAIRS>/$chairs/g;
  s/000/$fmzeros/g;
  print;
   
  # Determine if the template is old-style or new.  New style has
  # hyperlinks in brackets.
  if (/bib\<\/a\>\]/) {
    $linktype = 'new';
  }

}
close HEADER;

my $text;
my @classes;
$classes[0] = "bg2"; # start with bg2 because front matter (from template) will have been bg1
$classes[1] = "bg1";
my $count = 0;
my ($title,$author,$length,$file);
my ($start,$end);
$start = 1;
$end = 0;

$papnum = 0;

open(DB,"$ENV{ACLPUB}/bin/db-to-html.pl $db |") || die;
while (<DB>) {
  $line = $_;
  chomp $line;
  if (($line !~ /\S/) && ($author ne "")) {  # reached the end of record.
    if ($count >0) {
      $start = $end + 1;
    }
    $end = $end + $length;
    my $temp = $classes[$count % 2];
    #print "author = $author\n";
    $author =~ s/and$|and $//;

    my (@words,$new,$and_counter);
    $and_counter = 0;
    $new = $author;
    #$temp =~ s/and /<>/g;
    @words = split(" ",$new);
    foreach my $word (@words) {
      # print "word = $word\n";
      if ($word eq "and") {
	$and_counter++
      }
    }

    # print "and_counter = $and_counter\n";
    if ($and_counter >= 2) {
      $new =~ s/ and /, /g;
      $new =~ s/(.*), (.*)$/$1 and $2/;
    }
    # print "temp = $new\n";

    my $fn_base = sprintf "%0${digits}d", $papnum;
    $file = "$abbrev$fn_base";

    # This for the old-style templates, with 4 column format
    if ($linktype eq 'old') {

	$text .=<<EOD;
		<tr class="$temp">
			<td valign="top"><a href="pdf/$file.pdf">pdf</a></td>
			<td valign="top"><a href="bib/$file.bib">bib</a></td>
			<td valign="top" align="left"><a href="pdf/$file.pdf"><i>$title</i></a><br>$new</td>
			<td valign="top" align="left"><a name="$start">pp.&nbsp;$start&#8211;$end</a></td>
		</tr>\n
EOD

    }

    # For the new-style templates with 2 columns
    else {
        # Initially the minimal links.
        my $listoflinks = qq{[<a href="pdf/$file.pdf">pdf</a>] [<a href="bib/$file.bib">bib</a>]};

        # Other possibilities.
        $possibleFinalAttachments = 'datasets|notes|software|optional';

        # Find if this submission has any additional files.
        my @files = glob("cdrom/additional/$file*");

        # If so, add them to the list of links.
	if (@files) {
	    my @filechoices = split(/\|/,$possibleFinalAttachments);
	    foreach my $choice (@filechoices) {
		if (my @thisfn = grep(/$choice/i, @files)) {
		    $thisfn[0] =~ s/^cdrom\///;
		    $listoflinks .= qq{ [<a href="$thisfn[0]">$choice</a>] };
		}
	    }
	}
	$text .=<<EOD;

	<tr class="$temp">
	    <td valign="top" align="left"><a href="pdf/$file.pdf"><i>$title</i></a><br>$new<br>
	    $listoflinks
	    </td>
	    <td valign="top" align="left"><a name="$start">pp.&nbsp;$start&#8211;$end</a></td>
	    </tr>\n
EOD

    }

    print $text;   # !!! should deal with special case of a 1-page paper, as we do elsewhere
    $text = "";
    $author = "";
    $count++;
    next;
  }
  if ($line =~ /^T:/) {
    $title = "$line\n";
  }
  if ($line =~ /^A:/) {
    $line =~ s/^A://g;
    $line =~ /(.*),(.*)/;
    $author .= "$2 $1 and ";
  }
  if ($line =~ /^L:/) {
    $length = $line;
    $length =~ s/^L://;
    if ($length == 0) {  # if there is no paper, then don't put in index.
	$author = "";
	$text = "";
	$author = "";
	next;
    }
    else {
	$papnum++;
    }
  }
  $title =~ s/^T:|\n|^\s//;
}

close(DB);

my $time = time;
my %date = read_timestamp($time);
print "</table><p>
Last modified on $date{mdy}, $date{time}<p>&nbsp;
</center>
</body>
</html>
";

##############################################################################################################
sub read_timestamp { 
  # reads a standard perl timestamp, and returns a hash of the time/date in various formats.

  my $time = $_[0];
  my @x = localtime($time);
  my %return = ();
  if (length $x[0] == 1) {
    $x[0] = "0" . $x[0];
  }
  $return{'seconds'} = $x[0];
  if (length $x[1] == 1) {
    $x[1] = "0" . $x[1];
  }
  $return{'minutes'} = $x[1];
  $return{'hour'} = $x[2];
  if ($return{'hour'} > 12) {
    $return{'hour12'} = $return{'hour'} - 12;
  } else {
    $return{'hour12'} = $return{'hour'};
  }
  $return{'day'} = $x[3];
  $return{'month'} = $x[4] + 1;
  $return{'monthname'} = ('January','February','March','April','May','June','July','August','September','October','November','December')[$x[4]];
  $return{'year'} = $x[5] + 1900;
  $return{'year_2digit'} = substr $return{'year'},2;
  $return{'weekday'} = $x[6];
  $return{'yearday'} = $x[7];
  if (($return{'hour'} >= 12) && ($return{'hour'} != 24)) {
    $return{'ampm'} = "p.m.";
  } else {
    $return{'ampm'} = "a.m.";
  }
	
  # a couple often used formats
  $return{'mdy'} = "$return{'monthname'} $return{'day'}, $return{'year'}";
  $return{'time'} = "$return{'hour12'}:$return{'minutes'} $return{'ampm'}";

  return %return;
}
