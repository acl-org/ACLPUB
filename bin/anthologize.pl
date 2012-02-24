#!/usr/bin/perl

# Usage: anthologize.pl cdrom anthology
#
#    where cdrom is the directory containing the entire CD-ROM and
#    anthology is the directory (which will be created if necessary)
#    that should be sent to the ACL Anthology.
#
# Everything is built entirely off the CD-ROM, using no other files.
# So if the CD-ROM (particularly the bib files) has been hand-edited,
# then the Anthology will follow those edits.
#
# Most of the files in the anthology are just pointers onto the CD-ROM.
# We can follow these links when tarring up the anthology.
# Perhaps the tarball name should have the same base name as the
# bib file at the top level of the CD-ROM.

##### 
# Getting Text::BibTeX (see http://search.cpan.org/~gward/Text-BibTeX-0.34):
#   wget http://search.cpan.org/CPAN/authors/id/G/GW/GWARD/Text-BibTeX-0.34.tar.gz
#   tar xvf Text-BibTeX-0.34
#   cd Text-BibTeX-0.34
#   perl Makefile.PL
#   make
#   sudo make install

use strict 'vars';

use File::Spec;
use Text::BibTeX;

my ($cdrom,$anthology) = @ARGV;
my $tempfile = "/tmp/anthologize.$$";

#### Should leave this to the makefile if we really want to do it
#
# if (-e $anthology) {
#   if (-e "$anthology.bak") {
#     print STDERR "removing old anthology.bak ...\n";
#     system("find $anthology.bak -type d | xargs chmod +w")==0 || die;
#     system("rm -rf $anthology.bak")==0 || die;
#   }
#   print STDERR "moving old anthology to anthology.bak ...\n";
#   `mv $anthology $anthology.bak`;
# }

system("rm -rf $anthology")==0 || die;   # remove old version

for my $dir (glob("$cdrom/*")) {
  next unless -d "$dir/bib";
  print STDERR "Anthologizing $dir ...\n";

  my $urlprefix;   # initially undefined

  for my $bib (glob("$dir/bib/*.bib")) {   # bib entry files in numerically sorted order
    chomp($bib);
    my $pdf = $bib;
    $pdf =~ s{/bib/([^/]*)\.bib$}{/pdf/$1.pdf};     # the corresponding pdf file

    # Parse the bib entry.

    open(BIB,$bib) || die;
    my $bibentry = new Text::BibTeX::Entry;
    $bibentry->parse($bib, \*BIB) && $bibentry->parse_ok || die "Trouble parsing a BibTeX entry from $bib";

    # Extract URL from bib file; translate it to anthology base filename

    warn "Warning: No URL given in $bib (skipping)\n", next unless $bibentry->exists('url');
    my $url = $bibentry->get('url');
    die "Aborting: $url in $bib is not a valid ACL Anthology URL"
	unless $url =~ m{^http://www.aclweb.org/anthology/([A-Z])/(\1\d\d)/(\2-(\d{1,4}))$};
    my $volume = $2;     # anthology terminology
    my $paper_id = $4;   # anthology terminology
    my $anthdir = "$anthology/$1/$2";
    my $anthfile = $3;
    my $anth = "$anthdir/$anthfile";

    if (!defined $urlprefix) {

      # The first bibfile in the directory.  Specially, this is actually an
      # entry for the entire volume corresponding to this directory.  It has
      # a special, shorter URL in this case, such as .../P05-1.

      $urlprefix = $url;    # remember for later
      die "Although $bib is first listed file in its dir, it is not numbered 0"
	unless $dir =~ m{/[^/]+$} && $bib =~ m{\Q$&\E0+\.bib$};   # e.g., in ACL directory, we'd expect bib/ACL00.bib or something

      # First, create if necessary the anthology directory where all
      # these files will go.

      system("mkdir -p $anthdir")==0 || die;

      # Now create the volume-level files in this directory,
      # i.e., $anth.bib for a bib database of all papers in the volume,
      # and $anth.pdf for the entire volume.

      my @bibs = glob("$dir/*.bib");
      die "Aborting: No master .bib file exists in $dir\n" if @bibs < 1;
      die "Aborting: Multiple .bib files exist in $dir\n" if @bibs > 1;
      symlink(File::Spec->abs2rel($bibs[0],$anthdir), "$anth.bib") || die;

      my @pdfs = glob("$dir/*.pdf");
      die "Aborting: No master .bib file exists in $dir\n" if @bibs < 1;
      die "Aborting: Multiple .bib files exist in $dir\n" if @bibs > 1;
      symlink(File::Spec->abs2rel($pdfs[0],$anthdir), "$anth.pdf") || die;

      my $xml = "$anth.xml";
      open(XML,">$xml") || die;
      print XML '<?xml version="1.0" encoding="UTF-8" ?>',"\n";
      print XML " <volume id=\"$volume\">\n";
      # XML to be continued

      # Now pad $anthfile out with zeroes until it has length 8,
      # e.g., from P05-1 to P05-1000.  The padded version
      # will be used as the anthology names for $bib and $pdf, which correspond
      # respectively to the single bib entry for the book, and the
      # front matter of the book.  (The unpadded version corresponded
      # respectively to a complete bib database for the book, and the entire book.)
      die "Although $bib is first file in its dir, it is not a \@Book entry"
	unless $bibentry->type eq 'book';
      die "Although $bib is first file in its dir, its URL $url already has at least an 8-character filename and can't be padded to give individual paper numbers"
	unless length($anthfile) < 8;
      my $padding = "0" x (8 - length($anthfile));
      $anthfile .= $padding;
      $anth .= $padding;
      $url .= $padding;   # for error messages only -- the version that goes into the XML file will come fresh from $bibentry
      $paper_id .= $padding;
    }

    # Link the current .bib file and its corresponding .pdf file into
    # the anthology.

    die "Aborting: $url in $bib is not an extension of the prefix $urlprefix from the first bib entry"
      unless substr($url,0,length($urlprefix)) eq $urlprefix;
    die "Aborting: $url in $bib does not have an 8-char filename" unless $url =~ m{/[^/]{8}$};

    symlink(File::Spec->abs2rel($bib,$anthdir), "$anth.bib");
    symlink(File::Spec->abs2rel($pdf,$anthdir), "$anth.pdf");

    # Convert the current .bib file into XML.

    print XML "   <paper id=\"$paper_id\">\n";

    my %alreadydone;
    for my $field ('title', 'author', 'editor', $bibentry->fieldlist) {   # force order
      next unless $bibentry->exists($field);
      next if $alreadydone{$field}++;
      my @values = ($field eq 'author' || $field eq 'editor') 
               	       ? map { &formatname($_) } $bibentry->names($field)
		       : $bibentry->get($field);
      for my $val (@values) {

	# pass $val through our db-to-html filter.
	# There must be a nicer way to do this, but $htmlval = `echo "$val" | db-to-html.pl`
        # doesn't work because the shell may clobber special chars in $val, such as ``.
	open (TEMP, ">$tempfile") || die;
	print TEMP $val;
	close TEMP;
	my $htmlval = `$ENV{ACLPUB}/bin/db-to-html.pl $tempfile`;
	die unless defined $htmlval;  # check for command error
	chomp($htmlval);
	unlink TEMP;

	# print the filtered val.
	print XML "        <$field>$htmlval</$field>\n";
      }
    }
    print XML "        <bibtype>".$bibentry->type."</bibtype>\n";
    print XML "        <bibkey>".$bibentry->key."</bibkey>\n";
    print XML "   </paper>\n";

    # Finish reading this bib file (there shouldn't be anything else
    # in it, but the underlying bt_parse_entry library insists on reading
    # all of this file (so it can clean up) before it goes on to the next file).

    die "Aborting: $bib had more than one entry" if $bibentry->parse($bib, \*BIB);
    close(BIB);

  }

  print XML " </volume>\n";
  close(XML);
}

###############

# We could use Text::BibTeX::NameFormat for this, i.e., 
#     my $format = new Text::BibTeX::NameFormat ('fvlj',0);
#     return $format->apply($name);
# However, customizing that to put XML tags around the pieces is too annoying.

sub formatname {
  my($name) = @_;
  my $out = "";
  for my $part ('first','von','last','jr') {
    my @tokens = $name->part($part);
    if (@tokens) {   # nonempty
      unshift(@tokens,",") if $part eq 'jr';   # the jr part starts with a comma
      $out .= "<$part>".join(" ",@tokens)."</$part>";
    }
  }
  return $out;
}
