#!/usr/bin/perl

# READ META FILE FROM STDIN

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my ($db,$meta) = @ARGV;

my(@titles,$title,$abbrev,$volume,$month,$year,$location,$publisher,$booktitle,$shortbooktitle,@authors);
my $urlpattern = "https://aclanthology.org/%s";
open(META,$meta) || die;
while(<META>) {
  my ($key,$value) = split(/\s+/,$_,2);
  $value =~ s/\(.*// if $key eq 'chairs';    # remove parenthetical affiliation
  $value = &db_to_bib($value);
  #print STDERR "Found in meta: (\"$key\", \"$value\")\n";

  $abbrev = $value if $key eq 'abbrev';
  $volume = $value if $key eq 'volume';
  if (!$volume) {$volume=1;}
  $title = $value if $key eq 'title';
  $month = $value if $key eq 'month';
  $year = $value if $key eq 'year';
  $location = $value if $key eq 'location';
  $publisher = $value if $key eq 'publisher';
  $booktitle = $titles[0] = $value if $key eq 'booktitle';   # booktitle is also title of "paper 0"
  $shortbooktitle = $value if $key eq 'shortbooktitle';   # reserved for future use
  push @{$authors[0]}, $value if $key eq 'chairs';  # chairs are authors of "paper 0"
}
close(META);

if (!$publisher) {
    $publisher = 'Association for Computational Linguistics';
}

my $venue = lc $abbrev;

# should check that const fields actually get defined?
my @constfields =  ("booktitle      = {$booktitle}",
                    "month          = {$month}",
                    "year           = {$year}",
                    "address        = {$location}",
                    "publisher      = {$publisher}");

# READ DB FILE

my $pn=0;       # paper number
my $curpage=1;

open (DB,$db) || die;
my @flat = <DB>;
close DB;
my $stringfile = join("",@flat);
my @entries = split(/^\s+/m, $stringfile); # this should yield records for each paper, etc.
my (@pid, @startpage, @endpage, @file);

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
	    warn "double title for paper $pn: $titles[$pn], $_"
		if defined $titles[$pn];
	    $titles[$pn] = $_;
	}
	if (s/^P: *//) {
	    warn "double pid for paper $pn: $pid[$pn], $_"
		if defined $pid[$pn];
	    $pid[$pn] = $_;
	}
	elsif (s/^A: *//) {
	    my $_name = $_;
	    if ($_name !~ /^(.+), (.+)$/) {
		if ($_name =~ /^(.*)/) {
		    $_name = $1;
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

my (@key, %clients);
$key[0] = sprintf "%s:%d", $abbrev, $year; # don't bother remembering clients (there can be only one in this case)

for ($pn = 1; $pn <= $#titles; $pn++) {

  # extract last names of authors, lowercased and alpha-only; use EtAl
  my @keyauthors = @{$authors[$pn]};
  map { s/,.*//; tr /A-Z/a-z/; tr/a-z//cd } @keyauthors;
  if (@keyauthors > 3) {
    splice @keyauthors,1,@keyauthors,"EtAl"; # replace all after first
  }

  # now construct the key
  my $key = $key[$pn] = sprintf "%s:%d:%s", join("-",@keyauthors), $year, $abbrev;
  $clients{$key} = ($clients{$key} || 0) + 1; # keep track of conflicts to resolve later -- paper keys must be unique.
}

# OK, NOW GENERATE THE BIB ENTRIES.
# Start with an entry for the whole volume (paper number "0").

system("mkdir -p cdrom/bib")==0 || die;

my (%seq);

for ($pn = 0; $pn <= $#titles; $pn++) {

  my $anth_id = "$year.$venue-$volume.$pn";

  my $fn = "cdrom/bib/$anth_id.bib";
  open(FILE,"> $fn") || printf(STDERR "Can't open $fn: $!\n");

  ### GET CITATION KEY, adding a distinguishing number if
  ###   necessary to resolve a conflict (rare).

  my $key = $key[$pn];
  $key .= ++$seq{$key} if ($clients{$key} || 0) > 1;

  printf FILE "\@%s{%s,\n", $pn==0 ? "Book" : "InProceedings", $key;
  printf FILE "  %s    = {%s},\n",
    ($pn==0?"editor":"author"), join("  and  ",@{$authors[$pn]})
      if defined $authors[$pn];
  print  FILE "  title     = {$titles[$pn]},\n" if defined $titles[$pn];
  foreach (@constfields) {
    print  FILE "  $_,\n" unless $pn==0 && /booktitle/;
  }

  if (defined $startpage[$pn]) {
    printf FILE "  pages     = {%s},\n",
       $startpage[$pn]==$endpage[$pn] ? $startpage[$pn] : "$startpage[$pn]--$endpage[$pn]";
  }

  if (defined $pid[$pn] and -e "abstracts/$pid[$pn].abs") {
      open(ABS,"<abstracts/$pid[$pn].abs");
      my @lines = <ABS>;
      close(ABS);
      my $abstract = join("",@lines);
      $abstract =~ s/\s+/ /g;  # no linefeeds in bib entry.
      print FILE "  abstract  = {$abstract},\n";
  }

  printf FILE "  url       = {".&url($urlpattern,$anth_id)."}\n" if defined $urlpattern;
  print  FILE "}\n\n";

  close(FILE);
}

# Finally, make a concatenated bib file with all the entries at once,
# in order.

my $fn = "cdrom/$year.$venue-$volume.0.bib";
unlink($fn);
system("cat cdrom/bib/* > $fn");

######################################################################
sub url {
  my ($urlpattern, $anthid) = @_;
  my @tokens = split /\./, $anthid;
  my $pn = int($tokens[-1]);

  if ($pn != 0) {

    # ordinary paper.  Use $urlpattern to get the URL.
    # Ordinarily this will be an ACL Anthology URL, but maybe
    # someone will want to use these scripts for other purposes one day,
    # so any printf format string is allowed.

    my $fn = sprintf $urlpattern, $anthid;
    return $fn;

  } else {

    # For the book as a whole ($pn==0), remove the paper number
    # to just return the entire volume name.
    my @parts = split /\./, $anthid;
    pop(@parts);
    my $fn = sprintf $urlpattern, join(".", @parts);
    return $fn;
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
  s/\015//g;           # kill CR from DOS format files
  s/\\\\/ /g;          # latex newline: convert to ordinary space
  s/\s+/ /g;           # collapse whitespace
  s/^\s+//;
  s/\s+$//;
  return $_;
}  

