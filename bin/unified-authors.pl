#!/usr/bin/perl

# Command-line arguments: a list of db files.
# Generates unified author index from these.
# Prints it to stdout.

system("cat $ENV{ACLPUB}/templates/unified-authors.html.head")==0 || die;

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
    while ($line = <DB>) {
	chomp $line;

	if($line =~ /^P:/) {
	    $paper_link = sprintf("%s/pdf/%s%0${digits}d.pdf",$abbrev,$abbrev,++$papnum);
	}

	if($line =~ /^A: *(\S.+\S) *$/) {
	    push @{$author{$1}}, $paper_link;
	}
    }
    close(DB);
}

$count = 0;
print "<tr class=\"$classes[$c++ % 2]\">";

foreach my $author (sort { my_alpha($a) cmp my_alpha($b) } keys %author) {
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

sub my_alpha {
# this function is used to clean up author names for the purposes of
# alphabetizing them in the author index.  basically it's undoing
# much of the work of db-to-html.pl, but is lossy - it removes
# diacritics.  because I did this at the last minute before the
# ACL 2008 publishing deadline, only characters that show up in the
# ACL 2008 (and associated) author list are corrected here.
# Noah Smith, 5/18/08
# NOTE:  similar function in authors.pl

  my $t = shift;
  $t =~ s/\&\#352;/S/g;
  $t =~ s/\&\#353;/s/g;
  $t =~ s/\&\#351;/s/g;
  $t =~ s/\&\#345;/r/g;
  $t =~ s/\&\#263;/c/g;
  $t =~ s/\&\#332;/O/g;
  $t =~ s/\&\#269;/c/g;
  $t =~ s/\&(.)acute;/\1/g;
  $t =~ s/\&(.)uml;/\1/g;
  $t =~ s/\&(..)lig;/\1/g;
  $t =~ s/\&(.)grave;/\1/g;
  $t =~ s/\&(.)cedil;/\1/g;
  $t =~ s/\&(.)tilde;/\1/g;
  $t =~ s/\&rsquo/\'/g;
  $t =~ s/\&lsquo/\`/g;
#  $t =~ s/\\[a-z]//g;
#  $t =~ s/[^a-zA-Z ]//g;
  $t =~ y/A-Z/a-z]/;
  return $t;
}
