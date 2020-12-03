#!/usr/bin/perl

# Command-line arguments: a list of db files.
# Generates unified author index from these.
# Prints it to stdout.

use utf8;
use open qw(:std :utf8);

use Unicode::Collate;
$Collator = Unicode::Collate->new();

system("cat $ENV{ACLPUB}/templates/proceedings/unified-authors.html.head")==0 || die;

my $text;
my @classes;
$classes[0] = "bg1";
$classes[1] = "bg2";

my (%authors,@authors);
my @author_names;

foreach my $db (@ARGV) {
    my $meta = $db;
    $meta =~ s/db$/meta/;
    my $abbrev = `grep ^abbrev $meta`;
    die unless defined $abbrev;
    chop($abbrev);
    $abbrev =~ s/^abbrev\s+//;

    my $urlpattern = `grep ^bib_url $meta`;
    die unless defined $urlpattern;
    chop($urlpattern);
    $urlpattern =~ s/^bib_url\s+//;

    $urlpattern =~ m/\%0(\d)d/;
    my $digits = $1; # checked in bib.pl

    my $papnum = 0;

    open(DB,"$ENV{ACLPUB}/bin/db-to-html.pl $db |") || die;
    my @flat = <DB>;
    close DB;
    my $stringfile = join("",@flat);
    my @entries = split(/^\s+/m, $stringfile); # this should yield records for each paper, etc.
    foreach my $entry (@entries) {
	if ($entry =~ /^X:/) { # do not index headers
	    next;
	}
	if ($entry !~ /^F:/m) { # do index when no file exists.
	    next;
	}
	my @lines = split(/\n/,$entry);
	foreach my $line (@lines) {
	    if($line =~ /^P:/) {
		$paper_link = sprintf("%s/pdf/%s%0${digits}d.pdf",$abbrev,$abbrev,++$papnum);
	    }
	    if($line =~ /^A: *(\S.+\S) *$/) {
		push @{$author{$1}}, $paper_link;
	    }
	}
    }
}
$count = 0;
print "<tr class=\"$classes[$c++ % 2]\">";

foreach my $author (sort { $Collator->cmp($a,$b) } keys %author) {
    if($count>0 && (($count % 3) == 0)) {
	print "</tr>\n<tr class=\"$classes[$c++ % 2]\">\n";
    }

    print "<td valign=top>";
    print $author;
    foreach my $link (@{$author{$author}})
    {
	$link =~ /pdf\/(.+).pdf$/;
	my $id = $1;
	print " <a href=\"$link\">$id</a>";
    }
    print "</td>\n";

    $count++;
}
print "</table></body><P>&nbsp;</html>\n";
