#!/usr/bin/perl -w

# Database Management Script for Generating Proceedings
# written by Philipp Koehn

use Text::PDF::File;
use Text::PDF::SFont;
use Text::PDF::Utils;

my $pagecount = 1;
my $___JUST_COPYRIGHT = 0;

if ($#ARGV == -1) {
    print STDERR "Options:
create < submission-info
   create database from START text file
generate-tex [toc] [program] [index1col] [index2col] [all]
   generate *.tex and *.pdf file from database
join-papers [2|draft|final]
   generate allpapers.tex by joining papers
order < order
   reorder db file (and optionally add time information)
create-cd < meta
   create files for cdrom using meta information in 'meta'
";
} 
elsif ($ARGV[0] eq 'create') {
    &create_db();
}
elsif ($ARGV[0] eq 'generate-tex') {
    &generate_tex();
}
elsif ($ARGV[0] eq 'join-papers') {
    &join_papers();
}
elsif ($ARGV[0] eq 'order') {
    &order();
}
elsif ($ARGV[0] eq 'get-order') {
    &get_order();
}
elsif ($ARGV[0] eq 'get-copyright') {
    $___JUST_COPYRIGHT = 1;
    &create_db();
}
elsif ($ARGV[0] eq 'create-cd') {
    &create_cd();
}
else {
    print STDERR "unknown option $ARGV[0]\n";
}

sub create_db {
    open(DB,">db") || die unless $___JUST_COPYRIGHT;
    if (!(-d "abstracts")) {
	system qq{mkdir abstracts};
    }
    system("chmod u+w copyright-signatures")==0 || die if -e "copyright-signatures";
    open(COPY,">copyright-signatures") || die;
    open(LS,"ls final/ | sort -n |") || die;
    while(<LS>) {
	chop;
	my $metadata = "final/$_/$_"."_metadata.txt";
	if (! -e $metadata) {
	    print STDERR "Paper $_: No metadata file $metadata\n";
	}
	else {
	    open(METADATA,"$ENV{ACLPUB}/bin/ascii-to-db.pl $metadata |") || die;
	    my ($id,$title,$shorttitle,$copyright,$organization,$jobtitle,$abstract,$pagecount,@FIRST,@LAST,@ORG) = (0,"","","","","","",0);
	    while(<METADATA>) {
		s/[\n\r]+//g;
		my ($field,$value) = split(/\#\=\%?\=\#/);
		if ($organization ne "" && ! $value && $field && $field !~ /^\=+$/ && $abstract eq "") {
		    $organization .= "\n\t".$field;
		} elsif ($abstract ne "" && !$value && $field && $field !~ /^\=+$/) {
                    $abstract .= "\n\t".$field;
                }
		next unless $value;
		$id = $value         if $field eq 'SubmissionNumber';
		$title = $value      if $field eq 'FinalPaperTitle';
		$shorttitle = $value if $field eq 'ShortPaperTitle';
		$FIRST[$1] = $value  if $field =~ /Author\{(\d+)\}\{Firstname\}/;
		$LAST[$1]  = $value  if $field =~ /Author\{(\d+)\}\{Lastname\}/;
		$ORG[$1]  = $value   if $field =~ /Author\{(\d+)\}\{Affiliation\}/;
		$copyright = $value  if $field eq 'CopyrightSigned';
		$pagecount = $value  if $field eq 'NumberOfPages';
		$organization = $value  if $field eq 'Organization';
		$jobtitle = $value   if $field eq 'JobTitle';
                $abstract = $value   if $field eq 'Abstract';
	    }
            if (! $___JUST_COPYRIGHT) {
		print DB "P: $id\n";
		print DB "T: $title\n";
		print DB "S: $shorttitle\n" if -e $shorttitle;
		for(my $i=1;$i<=$#LAST;$i++) {
		    if ($LAST[$i] || $FIRST[$i]) {
			print DB "A: $LAST[$i], $FIRST[$i]\n";
#   	                print DB "O: $ORG[$i]\n" if $ORG[$i];
		    }
		}
		open(ABS,">abstracts/$id.abs");
		print ABS $abstract;
		close(ABS);
		my $file = `ls final/$id/*Paper.pdf | head -1`; 
		die unless defined $file;
		chop($file);
		print DB "F: $file\n";
		my $realpagecount = $pagecount;
		if ($file eq "") {
		    print STDERR "paper $id: file missing\n";
		}
		else {
		    $realpagecount = &get_pagecount($file);
		}
		print DB "L: $realpagecount\n";
		if ($pagecount != $realpagecount) {
		    print STDERR "Paper $id: reports $pagecount pages, actually appears to have $realpagecount\nPlease check the paper and enter the correct number of pages into the 'db' file!\n";
		    print DB "Z: metadata says $pagecount pages\n";
		}
		print DB "\n";
            }

	    # !!! this form's contents shouldn't be hardcoded; rather, use a template file
	    # (and instruct proceedings chair to make sure START matches it)
	    print COPY "Submission # $id:
Title: $title
Authors:\n";
	    for(my $i=1;$i<=$#LAST;$i++) {
		$ORG[$i] = "" unless $ORG[$i];
		print COPY "\t$FIRST[$i] $LAST[$i] ($ORG[$i])\n";
	    }
            print COPY "Signature (type your name): $copyright
Your job title (if not one of the authors): $jobtitle
Name and address of your organization:\n\t$organization\n
=================================================================\n\n";
	}
    }
    system("chmod ugo-w copyright-signatures")==0 || die;
}

#
# Use pdfinfo to get page count.
#
sub get_pagecount {
    my ($file) = @_;
    print STDERR "Counting pages for $file ...\n";
    my $res = qx{pdfinfo $file};
    $res =~/^(Pages:)([\t\s ]+)([0-9]+)$/m;
    my $pgCT = $3;
    return $pgCT;
}

# !!! move into makefile
sub generate_tex {
    if ($#ARGV == 0) { push @ARGV,"all"; }
    for(my $i=1;$i<=$#ARGV;$i++) {
	if ($ARGV[$i] eq 'toc') {
	    &generate('toc');
	}
	elsif ($ARGV[$i] eq 'program') {
	    &generate('program');
	}
	elsif ($ARGV[$i] eq 'all') {
	    &generate('program');
	    &generate('toc');
	}
	else {
	    die("unknown tex file: $ARGV[$i]");
	}
    }
}

sub generate {
    my ($file) = @_;
    print "generating $_[0]...\n";
    system("perl $ENV{ACLPUB}/bin/$file.pl < db > $file.tex")==0 || die;
}

sub join_papers {
    my $option = $ARGV[1];
    if ($option && $option ne '2' && $option ne 'draft' && $option ne 'final') {
	die("unknown option: $option (allowed: 2, draft, final)");
    }

    my ($file,$length,$id,$title,$margins,@AUTHOR) = ("",0,0);
    open(TEX,">allpapers.tex") || die;
    open(DB,"db") || die;
    $file = "";
    while(<DB>) {
	chomp;
	$id = $1 if (/^P: *(.+)$/);
	$file = $1 if (/^F: (.+)$/);
	$length = $1 if (/^L: (\d+)/);
	$title = $1 if (/^T: (.+)$/);
	$margins = $1 if (/^M: (.+)$/);
	push @AUTHOR, $1 if (/^A: (.+)$/);
	if (/^ *$/) {
            # include paper and in authorindex only if there is a paper for 
            # this submission.
	    if ($file) {
		&include($option,$file,$length,$id,$title,$margins,@AUTHOR);
	    }
	    ($file,$length,$id,$margins,@AUTHOR) = ("",0,0);
	}
    }
    close(DB);
    &include($option,$file,$length,$id,$title,$margins,@AUTHOR) if $file ne "";
    close(TEX);
}

sub include {
    my ($option,$file,$length,$id,$title,$margins,@AUTHORS) = @_;
    my $m="";
    if ($margins) {
	if ($margins =~ /^ *(\-?\d+) +(\-?\d+) *(.*)$/) {
	    $m = "offset=$1mm $2mm";
	    $m .= ",$3" if $3;
	}
	else {
	    die("buggy margin definition '$margins' for paper $id\n");
	}
    }

    foreach my $author (@AUTHORS) {
        if ($author =~ /\\/) {
            # remove accents, which screw up alphabetization
            my $author_clean = $author;
            $author_clean =~ s/[\{\}]//g;
            $author_clean =~ s/\\.//g;
            $author = "$author_clean\@$author";
        }
	my $_name = $author;
	if ($_name !~ /^(.+), (.+)$/) {
	    if ($_name =~ /^(.*),/) {
		$_name = $1;
	    }
	    else {
		$_name = 'unknown';
	    }
	}
	print TEX "\\index{$_name}\n" unless $option eq 'cd';
    }
    $addtotoc = "addtotoc={1,chapter,1,{$title},ref:paper_$id}";

    if ($option && ($option eq 'draft' || $option eq '2')) {
#        for(my $i=1;$i<=(($option eq '2' && $length>=2)?$length:$length);$i++) {
#
#       Include full papers in draft, not just the first two pages.
#       We have to include a draft frame for each page; hence the loop.
        for(my $i=1;$i<= $length;$i++) {
            print TEX "\\citeinfo{$pagecount}{".($pagecount+$length-1)."}\n" if $i==1;
            print TEX "\\draftframe[$id]\n";
            print TEX "\\includepdf[pages=$i".(($m ne "")?",$m":"").(($i==1)?",$addtotoc":"")."]{$file}\n";
            print TEX "\\ClearShipoutPicture\n";
        }
    }
    else {
        print TEX "\\citeinfo{$pagecount}{".($pagecount+$length-1)."}\n";
        print TEX "\\includepdf[pages=1,".(($m ne "")?"$m,":"").(($option ne 'cd')?$addtotoc:"")."]{$file}\n";
		print TEX "\\ClearShipoutPicture\n";
		if ($length>1) {
		    print TEX "\\includepdf[pages=2-".(($m ne "")?",$m":"")."]{$file}\n";
		}
    }
    $pagecount += $length;
} 

sub order {
    my %DB = load_db(0,0);
    my (@ORDER,@SCHEDULE,%TIME,%DUP_CHECK);
    while(<STDIN>) {
	chomp;
	s/\S*\#.*$//;
	next if /^\s*$/;
	my ($id,$time,$title) = split(/ +/,$_,3);
	if ($id eq '*' || $id eq '=' || $id eq '+' || $id eq '!') {
	    push @SCHEDULE,$_;
	    next;
	}
	else {
	    push @SCHEDULE,$id;
	}
	die("unknown paper id in order: $id") if ! defined($DB{$id});
#
#  9 May 2013 - allow duplicates
# 14 May 2013 - they changed their mind .  No more duplicates.

#	die("duplicate paper id in order: $id") if defined($DUP_CHECK{$id});
	push @ORDER,$id;
	$TIME{$id} = $time if $time && ($time =~ /[0-9]/ || $time eq 'none');
	$DUP_CHECK{$id}++;
    }
    foreach my $id (keys %DB) {
	die("missing paper in order: $id") if ! defined($DUP_CHECK{$id});
	$DB{$id}{"H"}[0] = $TIME{$id} if defined($TIME{$id});
    }
    open(DB,">db") || die;
    foreach my $id (@SCHEDULE) {
	if ($id =~ /^\d+$/) {
            my $got_time = 0;
	    foreach my $field (@{$DB{$id}{"ALL"}}) {
		$field =~ /^(.):\s*(.+)/ ;
		if ($1 eq 'H') {
		    if (defined($TIME{$id})) {
		      print DB "H: $TIME{$id}\n";
                    }
                    else {
		      print DB "H: none\n";
                    }
                    $got_time = 1;
		}
		else {
		    print DB $field;
		}
	    }
            if (!$got_time && defined($TIME{$id})) {
              print DB "H: $TIME{$id}\n";
	    }
	}
	else {
	    print DB "X: $id\n";
	}
	print DB "\n";
    }
    close(DB);
}

sub get_order {
    open(DB,"db") || die;
    my (%PAPER,%DB,$id);
    print "# Edit this file: 
# reorder the lines that correspond to papers 
#   and modify time slot, e.g. 9:00--9:30 
# add lines for 
#   start of new day, format: * DAY
#   session headline, format: = HEADLINE 
#   additional items, format: + TIME DESCRIPTION
* Wednesday, June 29, 2005
+ 8:45--9:00 Opening Remarks
! 9:00--10:00 Invited Talk by John Doe
= 9:00--10:00 Session 1: Important Matters Unresolved
= Session 1: Important Matters Resolved\n";
    while(<DB>) {
	chomp;
	if (/^X: (.+)/) { 
	    print $1."\n";
	}
	elsif (/^A: (.+), / && $id) {
	    print "$id 10:00--10:30 # $1: $title\n";
	    $id = 0;
	    $title = "";
	}
	elsif (/^P: (.+)/) {
	    $id = $1;
	}
	elsif (/^T: (.+)/) {
	    $title = $1;
	    if (length($title)>30) {
		$title = substr($title,0,30)."...";
	    }
	}
    }
    close(DB);
}

sub fname {
    $_ = shift @_;
    @_ = split (/\/|\\/, $_);
    $_ = pop @_;
    return $_;
}

sub create_cd {
    my %DB = load_db(1,1);

    # with content not latex-stripped, for the cd.tex
    my %DBTEX = load_db(1,0);

    my($abbrev,$year,$title,$url,$urlpattern);
    while(<STDIN>) {
	my $meta .= $_;
	chomp;
	my ($key,$value) = split(/\s+/,$_,2);
	$value =~ s/\s+$//;
	$abbrev = $value if $key eq 'abbrev';
	$year = $value if $key eq 'year';
	$title = $value if $key eq 'title';
	$url = $value if $key eq 'url';
    $urlpattern = $value if $key eq 'bib_url';
    }

    die(    "url of workshop not specified") unless $url;
    die(  "title of workshop not specified") unless $title;
    die(    "year of workshop not specified") unless $year;
    die("abbrev of workshop not specified") unless $abbrev;
    die("abbrev of workshop contains slashes/spaces") if $abbrev =~ /[ \/\\]/;
    die("bib_url of workshop not specified") unless $urlpattern;

    $urlpattern =~ m/\%0(\d)d/;
    my $digits = $1; # checked in bib.pl

    print STDERR "linking proceedings volume...\n";   # !!! move into makefile
    system("ln -sf ../book.pdf cdrom/$abbrev-$year.pdf")==0 || die;

    system("rm -rf cdrom/pdf; mkdir -p cdrom/pdf")==0 || die;

    print STDERR "producing front matter...\n";   
    open(TEX,">frontmatter.tex") || die;   # stripped-down version of book.tex; note dependency for makefile (!!! move into makefile?)
    foreach (`cat book.tex`) {
	$skip = 1 if /INCLUDED PAPERS/;
	$skip = 1 if /{allpapers}/;
	$skip = 0 if /end\{document}/;
	$_ .= "\\hypersetup{pdfpagemode=none}\n" if /{hyperref}/;  # don't show bookmarks
	print TEX $_ unless $skip;
    } 
    close(TEX);
    system("pdflatex --interaction batchmode frontmatter; pdflatex --interaction batchmode frontmatter")==0 || die "pdflatex failed on frontmatter; see frontmatter.log for details\n";
    my $frontmatter_papnum = sprintf("${abbrev}%0${digits}d.pdf",0);
    system("mv frontmatter.pdf cdrom/pdf/${frontmatter_papnum}")==0 || die;

    print STDERR "creating pdf files stamped with citation info...\n";
    my $papnum = 0;
    open(PAPERMAP, ">id_map.txt") || die;

    # cycle through all the papers, but only generate the ones that
    # have a pdf Paper file.
    foreach my $id (@{$DB{"paper-order"}}) {
	if (!$DB{$id}{"L"}[0]) {
	    next;
	}
        open(TEXTEMPLATE, "<$ENV{ACLPUB}/templates/cd.tex.head") || die;
        open(TEX,">cd.tex") || die;

        my $pdf_title = $DB{$id}{"T"}[0];

	# to handle titles with hashes
        my $pdf_title_tex = $DBTEX{$id}{"T"}[0];

        #my $pdf_authors = join("; ", @{$DB{$id}{"A"}});
        my @authors;
        foreach my $author (@{$DB{$id}{"A"}}) {
            $author =~ m/\s*([^,]*)\s*,\s*(.*)\s*/;
            my $fn = $2;
            my $ln = $1;
            my $name = "$fn $ln";
            push @authors, $name;
        }
        my $pdf_authors = join(" ; ", @authors);
        my $pdf_subject = "$abbrev $year";
        while (<TEXTEMPLATE>) {
            s/__PDFTITLE__/$pdf_title_tex/;
            s/__PDFAUTHOR__/$pdf_authors/;
            s/__PDFSUBJECT__/$pdf_subject/;
            print TEX;
        }
        print STDERR "PDF meta-data:\n";
        print STDERR "  title: $pdf_title\n";
        print STDERR "  author(s): $pdf_authors\n";
        print STDERR "  subject (venue): $pdf_subject\n\n";
        print TEX "\\setcounter{page}{$pagecount}\n";
        &include('cd',$DB{$id}{"F"}[0],
                 $DB{$id}{"L"}[0],
                 $DB{$id}{"P"}[0],
                 $DB{$id}{"T"}[0],
                 $DB{$id}{"M"}[0],
                 @{$DB{$id}{"A"}});
        print TEX "\\end{document}\n";
        close(TEX);
        close(TEXTEMPLATE);
        system("pdflatex --interaction batchmode cd.tex")==0 || die "pdflatex failed on cd.tex; see cd.log for details\n";
        $papnum++;
        my $papnum_formatted = sprintf("%0${digits}d",$papnum);
        # cd.txt is the paper.
        system("mv cd.pdf cdrom/pdf/$abbrev$papnum_formatted.pdf")==0 || die;

        # Copy additional files (other than paper) into a directory called "additional"
        # Rename the files to conform to the paper numbering/codes for the pdfs and bib files.
        # 
        # Important:  For now, we will have a fixed set of possible file names, taken from 
        # recent ACL conferences.  We separate them by '|' for regex search.  This string
        # will also be included in the script index.pl .  We can eventually make this 
        # a parameter in the UI.
        #
        $possibleFinalAttachments = 'datasets|notes|software|optional';

	my $pid = $DB{$id}{"P"}[0];         # Get START paperid.
        my @files = glob("final/$pid/*");   # Get the files in the final place for the paperid.

        # paper map - maps the ACL IDs to START IDs.  For external use.
	print PAPERMAP "$abbrev$papnum_formatted $pid\n";

        
	@files = grep(/$possibleFinalAttachments/i, @files);       # Limit the files to the choices we want.
	if (@files) {
	    my $oldprefix = $pid . '_';
	    my $newprefix = $abbrev . $papnum_formatted . '_';
	    mkdir("cdrom/additional") || 0;
	    foreach my $file (@files) {
		my $newname = fname($file);
		$newname =~ s/^$oldprefix/$newprefix/;
		system "cp $file cdrom/additional/$newname";
	    }
	}
    }
    close(PAPERMAP);
}



sub load_db {
    my ($ordered, $strip_latex) = @_;
    my $input;
    if ($strip_latex) {
        $input = "$ENV{ACLPUB}/bin/db-to-pdfmetadata.pl db |";
    } else {
        $input = "db";
    }
    open(DB,$input) || die;
    my (%PAPER,%DB,$id);
    while(<DB>) {
	next if /^X:/;
	s/[\s\r\n]+$//;
	if (/^(.):\s*(.+)/) {
	    push @{$PAPER{"ALL"}}, "$1: $2\n"; # Putting labels/values in hash.
	    push @{$PAPER{$1}}, $2;           
	    $id = $2 if $1 eq 'P';   # this is the submission ID.
	}
	elsif (/^\s*$/) {
	    if (scalar keys %PAPER) {
		&store_in_db($id,\%DB,\%PAPER);
		push @{$DB{"paper-order"}},$id if $id && $ordered;
		$id=0;
	    }
	}
    }
    &store_in_db($id,\%DB,\%PAPER) if $id;
    push @{$DB{"paper-order"}},$id if $id && $ordered;
    close(DB);
    return %DB;
}

sub store_in_db {
    my ($id,$DB,$PAPER) = @_;
    if (!$id) {
	print STDERR "error in db: no paper id:\n";
	foreach (keys %{$$PAPER{"ALL"}}) {
	    print STDERR $_;
	}
	exit;
    }
    else {

#  9 May 2013 - allow duplicates
# 14 May 2013 - they changed their mind .  No more duplicates.

#	if (defined($$DB{$id})) {
#	    die("duplicate paper id in db: $id");
#	}
	foreach (keys %{$PAPER}) {
	    $$DB{$id}{$_} = $$PAPER{$_};
	}
	%{$PAPER} = ();
    }
}
