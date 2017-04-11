#!/usr/bin/perl

# READ META FILE FROM STDIN

my ($db,$meta) = @ARGV;

my($title,$abbrev,$month,$year,$location,$booktitle,$urlpattern,@authors);
open(META,$meta) || die;
while(<META>) {
  my ($key,$value) = split(/\s+/,$_,2);
  $value =~ s/\(.*// if $key eq 'chairs';    # remove parenthetical affiliation
  $value = &db_to_bib($value);
  #print STDERR "Found in meta: (\"$key\", \"$value\")\n";

  $abbrev = $value if $key eq 'abbrev';
  $title = $value if $key eq 'title';
  $month = $value if $key eq 'month';
  $year = $value if $key eq 'year';
  $location = $value if $key eq 'location';
  $publisher = $value if $key eq 'publisher';
  $booktitle = $title[0] = $value if $key eq 'booktitle';   # booktitle is also title of "paper 0"
  $urlpattern = $value if $key eq 'bib_url';
  push @{$authors[0]}, $value if $key eq 'chairs';  # chairs are authors of "paper 0"
}
close(META);

if (!$publisher) {
    $publisher = 'Association for Computational Linguistics';
}

# should check that const fields actually get defined?
@constfields =  ("booktitle = {$booktitle}",
                 "month     = {$month}",
                 "year      = {$year}",
                 "address   = {$location}",
                 "publisher = {$publisher}");

# changed  15-5-2011 because premise is not clear - what should be a
# valid URL for ACL Anthology?
#
my $digits = 0;
$urlpattern =~ m/\%0(\d)d/;

if ($1) {
    $digits = $1;
}

# 15-5-2011  Commented this part out until we are told to put it back in.
#

#if (($digits != 2) && ($digits != 3)) {
#    warn "\n$0:\n";
#    warn "bib_url in \"meta\" file appears to have an incorrect format.\n";
#    warn "  Should end in either \"%02d\" or \"%03d\":\n";
#    warn "  $urlpattern\n";
#    warn "If you really do want a URL filename with this format,\n";
#    warn "  then comment this message and the accompanying \"exit\" out, and try again.\n";
#
#    exit 1;
#}

# READ DB FILE

#=c

my $pn=0;       # paper number
my $curpage=1;

open (DB,$db) || die;
binmode DB;
my @flat = <DB>;
close DB;
my $stringfile = join("",@flat);
my @entries = split(/^\s+/m, $stringfile); # this should yield records for each paper, etc.

foreach my $entry (@entries) {
    if ($entry =~ /^X:/) { # do not create a bib entry for headers
	next;
    }
    if ($entry !~ /^F:/m) { # do not create bid entries when no file exists.
	next;
    }
    $pn++;
    my @lines = split(/\n/,$entry);
    foreach (@lines) {

	$_ = db_to_bib($_);
	s/^([A-Z]) /$1: /;   # correct possible typo in db line

	if (s/^T: *//) {
	    warn "double title for paper $pn: $title[$pn], $_"
		if defined $title[$pn];
	    $title[$pn] = $_;
	}
	if (s/^P: *//) {
	    warn "double pid for paper $pn: $pid[$pn], $_"
		if defined $pid[$pn];
	    $pid[$pn] = $_;
	}
	elsif (s/^A: *//) {
	    $_name = $_;
	    if ($_name !~ /^(.+), (.+)$/) {
		if ($_name =~ /^(.*),/) {
		    $_name = $1;
		}
		else {
		    $_name = 'unknown';
		}
	    }
	    push @{$authors[$pn]}, $_name;
	}
	elsif (s/^L: *//) {
	    warn "double length for paper $pn: $startpage[$pn], $_"
		if defined $startpage[$pn];
	    $startpage[$pn] = $curpage;
	    $curpage += $_;     # assume it's numeric
	    $endpage[$pn] = $curpage-1;
	}
	elsif (s/^F: *//) {
	    warn "double filename for paper $pn: $file[$pn], $_"
		if defined $file[$pn];
	    $file[$pn] = $_;
	}
    }
}


# FIRST PASS TO FIND BIB KEYS so that we can detect conflicts before printing anything.
# Start with an entry for the whole volume (paper number "0").

$key[0] = sprintf "%s:%d", $abbrev, $year; # don't bother remembering clients (there can be only one in this case)

for ($pn = 1; $pn <= $#title; $pn++) {

  # extract last names of authors, lowercased and alpha-only; use EtAl
  @keyauthors = @{$authors[$pn]};
  map { s/,.*//; tr /A-Z/a-z/; tr/a-z//cd } @keyauthors;
  if (@keyauthors > 3) {
    splice @keyauthors,1,@keyauthors,"EtAl"; # replace all after first
  }

  # now construct the key
  $key[$pn] = sprintf "%s:%d:%s", join("-",@keyauthors), $year, $abbrev;
  $clients{$key[$pn]}++; # keep track of conflicts to resolve later -- paper keys must be unique.
}

# OK, NOW GENERATE THE BIB ENTRIES.
# Start with an entry for the whole volume (paper number "0").

system("mkdir -p cdrom/bib")==0 || die;

for ($pn = 0; $pn <= $#title; $pn++) {

  # pad paper number with zeroes on the left
  my $fn_base = sprintf "%0${digits}d", $pn;
  my $fn = "cdrom/bib/$abbrev$fn_base.bib";
  open(FILE,"> $fn") || printf(STDERR "Can't open $fn: $!\n");

  ### GET CITATION KEY, adding a distinguishing number if
  ###   necessary to resolve a conflict (rare).

  $key = $key[$pn];
  $key .= ++$seq{$key} if $clients{$key} > 1;

  printf FILE "\@%s{%s,\n", $pn==0 ? "Book" : "InProceedings", $key;
  printf FILE "  %s    = {%s},\n",
    ($pn==0?"editor":"author"), join("  and  ",@{$authors[$pn]})
      if defined $authors[$pn];
  print  FILE "  title     = {$title[$pn]},\n" if defined $title[$pn];
  foreach (@constfields) {
    print  FILE "  $_,\n" unless $pn==0 && /booktitle/;
  }
  if (defined $startpage[$pn]) {
    printf FILE "  pages     = {%s},\n",
       $startpage[$pn]==$endpage[$pn] ? $startpage[$pn] : "$startpage[$pn]--$endpage[$pn]";
  }
  if (-e "abstracts/$pid[$pn].abs") {
      open(ABS,"<abstracts/$pid[$pn].abs");
      my @lines = <ABS>;
      close(ABS);
      my $abstract = join("",@lines);
      print FILE "  abstract  = {$abstract},\n";
  }

  printf FILE "  url       = {".&url($urlpattern,$pn)."}\n" if defined $urlpattern;
  print  FILE "}\n\n";

  close(FILE);
}

# Finally, make a concatenated bib file with all the entries at once,
# in order.

my $fn = "cdrom/$abbrev-$year.bib";
unlink($fn);
system("cat cdrom/bib/* > $fn");

######################################################################
sub url {
  my ($urlpattern,$pn) = @_;

  if ($pn != 0) {

    # ordinary paper.  Use $urlpattern to get the URL.
    # Ordinarily this will be an ACL Anthology URL, but maybe
    # someone will want to use these scripts for other purposes one day,
    # so any printf format string is allowed.

    my $fn = sprintf $urlpattern, $pn;
    $fn =~ m/\/([^\/]+)$/;
    my $fn_base = $1;
    if (length($fn_base)!=8) {
        # the error will be printed for the first suspicious URL;
        #   then we'll abort
        warn "\n$0:\n";
        warn "We think you must have gotten bib_url wrong in your \"meta\" file,\n";
        warn "  since the filename for paper $pn came out like this: $fn_base\n";
        if (length($fn) > length(sprintf $urlpattern, 0)) {
            warn "This appears to be because your volume has more papers than expected.\n";
        }
        warn "Please request a new bib_url if necessary to fix the problem.\n";
        warn "Or if you really do want a URL filename of other than 8 characters,\n";
        warn "  then comment out this message and the accompanying \"exit\", and try again.\n";
        exit 1;
    }

    return $fn;

  } else {

# WARNING!  This worked for me in 2008, in lieu of the much more complex
# code below (which did not work for me).  I am not sure what's going on
# here, but since I got the desired effect, I am leaving this in for now,
# to figure out later.  -- Noah Smith, 5/18/08 10:24pm
#    return $urlpattern;
# END Noah's change
# (And it was taken out because it messed up the CD.  Oy. --NAS)

    # For the book as a whole ($pn==0), create a copy of $urlpattern
    # with no number in it at all.  Unfortunately, we can't just sprintf
    # with "" as the number since it will be interpreted as 0.
    #
    # Here is an attempt to use "" for the number.
    # It will work with ACL Anthology URL patterns, and in fact
    # is intended to work with nearly any printf format string
    # (even, say, "%%abc%5lxdef") without actually parsing that string
    # directly.  Maybe the meta file should just be improved
    # so that this skulduggery isn't necessary, but it doesn't seem
    # worth making the user deal with a more complex convention there.

    my $url1 = sprintf $urlpattern, 12345678;  # will fill up any initial spaces (not that we should see any in a URL)
    my $url2 = sprintf $urlpattern, -1;        # will start with - or fff... or 377...
#
#    Too damn picky - don't die if the URL is wrong.
    die "Unexpected error" if $url1 eq $url2;

    # Now extract longest common prefix and longest common suffix.
    my $prefix=0; $prefix++ while substr($url1,0,$prefix+1) eq substr($url2,0,$prefix+1);
    my $suffix=0; $suffix++ while substr($url1,-($suffix+1),$suffix+1) eq substr($url2,-($suffix+1),$suffix+1);
    return substr($url1,0,$prefix).substr($url1,-$suffix,$suffix);
  }
}


######################################################################
sub db_to_bib {
  # Chomps its arg and modifies it for tidiness.
  # Basically a small subset of db-to-html, but output should remain in latex.
  # !!! Should probably convert 8-bit chars to latex, so user of bibfile
  #        doesn't need inputenc package.  But these chars are rare in practice.
  # !!! Conceivably should try to help capitalization of title lines.
  # !!! How about \newline, which is in db_to_html?
  local($_) = @_;
  s/\\textsc\{(.*?)\}/\1/g; # remove textsc (Noah Smith, 5/19/08)
  s/\015//g;           # kill CR from DOS format files
  s/\\\\/ /g;          # latex newline: convert to ordinary space
  s/\s+/ /g;           # collapse whitespace
  s/^\s+//;
  s/\s+$//;
  return $_;
}  

