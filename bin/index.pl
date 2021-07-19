#!/usr/bin/perl

# Creates an HTML table of contents.  Prints it to stdout.

use utf8;
use open qw(:std :utf8);

# if there are multiple attachments, we cannot use the columned header for the index.
my $single = q{<table cellspacing="0" cellpadding="5" border="1">
  <tr class="bg1">
    <td valign="top"><a href="pdf/<XXX ABBREV>.pdf">pdf</a></td>
    <td valign="top"><a href="bib/<XXX ABBREV>.bib">bib</a></td>
    <td valign="top"><a href="pdf/<XXX ABBREV>.pdf"><b>Front matter<b></a></td>
    <td valign="top">pages</td>
  </tr>
};


my $multiple = q{<table cellspacing="0" cellpadding="5" border="1">
  <tr class="bg1">
    <td valign="top"><a href="pdf/<XXX ABBREV>.pdf"><b>Front matter<b></a>
      [<a href="pdf/<XXX ABBREV>.pdf">pdf</a>] [<a href="bib/<XXX ABBREV>.bib">bib</a>]
    </td>
    <td valign="top">pages</td>
  </tr>
};

my($db, $meta) = @ARGV;

my($title,$url,$abbrev,$year,$volume,$chairs);
open(META, "$ENV{ACLPUB}/bin/db-to-html.pl $meta |") || die;
while (<META>) {
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

my $urlpattern = "https://aclanthology.org/%s";
my $venue = lc $abbrev;

my $digits = $1; # checked in bib.pl

my $fileprefix = "$year.$venue-$volume.0";

# Initialize Type to account for old templates.
#    linktype = old: Original layout with 4 columns.
#    linktype = new; New layout with brackets for links, to accommodate unlimited number of attachments.
#

#add header information
open(HEADER, "$ENV{ACLPUB}/templates/proceedings/index.html.head") || die;
my $out = join("",<HEADER>);
close HEADER;

$out =~ s/(\<br\>\<\/br\>)((.|[\n\s])*)/$1/;

$out =~ s/\Q>\E000/>/g;

$out =~ s/\Q-<XXX YEAR>\E//g;

if (glob("cdrom/additional/*")) {
    $linktype = 'new';
    $out .= $multiple;
}
else {
    $linktype = 'old';
    $out .= $single;
}

$out =~ s/<XXX TITLE>/$title/g;
$out =~ s/<XXX TYPE>/$type/g;
$out =~ s/<XXX ABBREV>/$fileprefix/g;
$out =~ s/<XXX YEAR>/$year/g;
$out =~ s/<XXX BOOKTITLE>/$booktitle/g;
$out =~ s/<XXX URL>/$url/g;
$out =~ s/<XXX CHAIRS>/$chairs/g;

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

    $author =~ s/and$|and $//;

    my (@words,$new,$and_counter);
    $and_counter = 0;
    $new = $author;

    @words = split(" ",$new);
    foreach my $word (@words) {
      if ($word eq "and") {
	$and_counter++
      }
    }

    # print "and_counter = $and_counter\n";
    if ($and_counter >= 2) {
      $new =~ s/ and /, /g;
      $new =~ s/(.*), (.*)$/$1 and $2/;
    }

    $file = "$year.$venue-$volume.$papnum";

    # This for the old-style templates, with 4 column format
    if ($linktype eq 'old') {

	$text .=<<EOD;
		<tr class="$temp">
			<td valign="top"><a href="pdf/$file.pdf">pdf</a></td>
			<td valign="top"><a href="bib/$file.bib">bib</a></td>
			<td valign="top" align="left"><a href="pdf/$file.pdf"><i>$title</i></a><br>$new</td>
			<td valign="top" align="left"><a name="$start">pp.&nbsp;$start&#8209;$end</a></td>
		</tr>\n
EOD

    }

    # For the new-style templates with 2 columns, to accommodate additional file attachments
    else {
        # Initially the minimal links.
        my $listoflinks = qq{[<a href="pdf/$file.pdf">pdf</a>] [<a href="bib/$file.bib">bib</a>]};

        # Other possibilities.
        $possibleFinalAttachments = 'dataset|notes|software|optional|supplementary|optionalattachment';

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
	    <td valign="top" align="left"><a name="$start">pp.&nbsp;$start&#8209;$end</a></td>
	    </tr>\n
EOD

    }

    $out .= $text;   # !!! should deal with special case of a 1-page paper, as we do elsewhere
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
    if ($line =~ /(.*),(.*)/) {
	$author .= "$2 $1 and ";
    }
    else {
	$author .= "$line and ";
    }

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
$out .= "</table><p>
Last modified on $date{mdy}, $date{time}<p>&nbsp;
</center>
</body>
</html>
";

print $out;

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
