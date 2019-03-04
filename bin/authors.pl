#!/usr/bin/perl

# Creates an HTML author index.  Prints it to stdout.

use utf8;
use open qw(:std :utf8);

use Unicode::Collate;
$Collator = Unicode::Collate->new();

my($db, $meta) = @ARGV;

my($title,$url,$abbrev,$chairs);
open(META, "$ENV{ACLPUB}/bin/db-to-html.pl $meta |") || die;
while (<META>) {
    chomp;
    my ($key,$value) = split(/\s+/,$_,2);
    $value =~ s/\s+$//;
    $abbrev = $value if $key eq 'abbrev';
    $type = $value if $key eq 'type';
    $title = $value if $key eq 'title';
    $booktitle = $value if $key eq 'booktitle';
}
close(META);

#add header information
open(HEADER, "$ENV{ACLPUB}/templates/authors.html.head") || die;
while (<HEADER>) {
    s/<XXX TITLE>/$title/g;
    s/<XXX BOOKTITLE>/$booktitle/g;
    s/<XXX TYPE>/$type/g;
    print;
}
close HEADER;

my $text;
my @classes;
$classes[0] = "bg1";
$classes[1] = "bg2";
my $count = 0;
my ($title,$author,$length);
my ($start,$end);
$start = 1;
$end = 0;

my (%authors,@authors);

open(DB,"$ENV{ACLPUB}/bin/db-to-html.pl $db |") || die;
while (<DB>) {
  $line = $_;
  chomp $line;
  if (($line !~ /\S/) && ($author ne "")) {
    if ($count >0) {
      $start = $end + 1;
    }
    $end = $end + $length;
    $author =~ s/ and /<>/g;
    $author =~ s/\t//g;
    #	    print "author = $author\n";	
	
    @authors = split("<>",$author);
    foreach my $item (@authors) {
      #print "item = $item\n";
      $item =~ s/^ | $//g;
      if (($item ne "") && ($item !~ /^L$/)) {
	$authors{$item} .= "$start<>";	
      }
    }
	
    $author = "";
    $count++;
    next;
  }
  if ($line =~ /^T:/) {
    $title = "$line\n";
  }
  if ($line =~ /^A:/) {

    $line =~ s/^A://g;
    ## uncomment following to alphabetize on first capital in surname:
    ## "von der X, Y" gets listed under X as "X, von der, Y"
    ## "Von Der X, Y" gets listed under V as "Von Der X, Y"
    #if ($line =~ /^\s*[a-z]/) {
    #    $line =~ s/^(\s*)(.*?)\s+([A-Z].*?),/$1$3, $2,/g;
    #}
    #$line =~ /(.*),(.*)/;
    $author .= "$line and ";

  }

  $title =~ s/^T:|\n|^\s//;

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
}
close(DB);

$count = 0;
my $text = "<tr class=\"$temp\">";
foreach my $key (sort { $Collator->cmp($a,$b) } keys %authors) {
  #print STDERR $key, "\n" if($key =~ m/\&/);
  my $temp = $classes[$count % 2];
  #print "count = $count, mod = " .$count % 3 . "\n";
  if (($count % 3) == 0) {
    $text .= "</tr>\n<tr class=\"$temp\">\n";
  }
	
  #print "key = $key, val = $authors{$key}\n";
  $authors{$key} =~ s/<>/,/g;
  $authors{$key} =~ s/,$//;
  my $name = $key;
  $name =~ s/^ | $//g;
	
  my @numbers = split(",",$authors{$key});   # dangerous if this is doing what I think: how about , Jr.?
  my $number;
  foreach my $item (@numbers) {
    $number .= "<a href=\"index.html#$item\">$item</a>, ";
  }

  $number =~ s/, $//;

  $text .= <<EOD;
	<td>$name $number</td>
EOD

  $count++;
}
print $text;

#add footer

print "</tr>
</table>
</center>
</body>
</html>
";
