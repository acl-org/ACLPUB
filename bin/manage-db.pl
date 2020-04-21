#!/usr/bin/perl -w

use utf8;
use open qw(:std :utf8);

use Unicode::Normalize;

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
            my %meta;
	    open(METADATA,"$ENV{ACLPUB}/bin/ascii-to-db.pl $metadata |") || die;
            my $field = "";
            my $value;
            while (<METADATA>) {
                chomp;

                # End marker
                if ($_ eq "==========") { 
                    last;

                # Field/value pair
                } elsif (/(.*?)#=%?=#(.*)/) { 
                    $field = $1;
                    $value = $2;
                    $meta{$field} = $value;

                # Continuation of previous field
                } else { 
                    $meta{$field} .= "\n\t".$_;
                }
            }

	    my ($id,$title,$shorttitle,$copyright,$organization,$jobtitle,$abstract,$pagecount,@FIRST,@LAST,@ORG) = (0,"","","","","","",0);

            while (($field, $value) = each %meta) {
                next if $value =~ /^\s*$/;

                if (!($field eq 'Abstract' || $field eq 'Organization')) {
                    # Fields destined for the db file should not have newlines
                    $value =~ s/\s+/ /g;
                    $value =~ s/^\s*//;
                    $value =~ s/\s*$//;
                }

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
		my $numauths = ($#LAST > $#FIRST) ?  $#LAST : $#FIRST;
		for(my $i=1;$i<=$numauths;$i++) {
		    if ($LAST[$i] && $FIRST[$i]) {
			print DB "A: $LAST[$i], $FIRST[$i]\n";
		    }
                    # May be mononym
		    elsif ($LAST[$i]) {
			print DB "A: $LAST[$i]\n";
		    }
                    # May be mononym
		    elsif ($FIRST[$i]) {
			print DB "A: $FIRST[$i]\n";
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

	    print COPY "Submission # $id:
Title: $title
Authors:\n";
	    my $numauths = ($#LAST > $#FIRST) ?  $#LAST : $#FIRST;
	    for(my $i=1;$i<=$numauths;$i++) {
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
		my $out = &include($option,$file,$length,$id,$title,$margins,@AUTHOR);
		print TEX $out;
	    }
	    ($file,$length,$id,$margins,@AUTHOR) = ("",0,0);
	}
    }
    close(DB);
    if ($file ne "") {
	my $out = &include($option,$file,$length,$id,$title,$margins,@AUTHOR);
	print TEX $out;
    }
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

    my $retval = "";

    foreach my $author (@AUTHORS) {
        # remove accents, which screw up alphabetization
        
        my $author_clean = $author;
        
        # decompose Unicode accents (to be removed later)
        $author_clean = NFKD($author_clean);
        
        # decompose a few that NFKD doesn't get
        # http://zderadicka.eu/removing-diacritics-marks-from-strings/
        $author_clean =~ tr/ĐđĦħıȷŁłØøŦŧ/DdHhijLlOoTt/;
        $author_clean =~ s/Æ/AE/g; $author_clean =~ s/æ/ae/g;
        $author_clean =~ s/Œ/OE/g; $author_clean =~ s/œ/oe/g;
        $author_clean =~ s/ẞ/SS/g; $author_clean =~ s/ß/ss/g;
        $author_clean =~ s/Þ/Th/g; $author_clean =~ s/þ/th/g;
        $author_clean =~ s/Ŋ/Ng/g; $author_clean =~ s/ŋ/ng/g;
        
        # remove TeX accents
        # this is similar to what BibTeX does
        # http://tug.ctan.org/info/bibtex/tamethebeast/ttb_en.pdf, page 22, 34
        $author_clean =~ s/\\(i|j|oe|OE|ae|AE|aa|AA|o|O|l|L|ss)(?![A-Za-z])\s*/$1/g;
        $author_clean =~ s/[\t~-]/ /g;
        # there are some cases where a control character won't eat spaces,
        # but I think they are unlikely in an author name
        $author_clean =~ s/\\([A-Za-z]+|.)\s*//g;
        # BibTeX keeps only ASCII alphanumerics; keep all Unicode alphanumerics
        $author_clean =~ s/[^\pL\d, ]//g;
        
        $author_clean =~ s/\s+/ /g;
        $author_clean =~ s/^\s*//g;
        $author_clean =~ s/\s*$//g;

        if ($author_clean ne $author) {
            print STDERR "$author -> $author_clean\n";
            $author = "$author_clean\@$author";
        }
	my $_name = $author;
	if ($_name !~ /^(.+), (.+)$/) {
	    if ($_name =~ /^(.*)/) {
		$_name = $1;
	    }
	}
	$retval .=  "\\index{$_name}\n" unless $option eq 'cd';
    }
    $addtotoc = "addtotoc={1,chapter,1,{$title},ref:paper_$id}";

    if ($option && ($option eq 'draft' || $option eq '2')) {

#       Include full papers in draft, not just the first two pages.
#       We have to include a draft frame for each page; hence the loop.
        for(my $i=1;$i<= $length;$i++) {
            $retval .=  "\\citeinfo{$pagecount}{".($pagecount+$length-1)."}\n" if $i==1;
            $retval .=  "\\draftframe[$id]\n";
            $retval .=  "\\includepdf[pages=$i".(($m ne "")?",$m":"").(($i==1)?",$addtotoc":"")."]{$file}\n";
            $retval .=  "\\ClearShipoutPicture\n";
        }
    }
    else {
        $retval .=  "\\citeinfo{$pagecount}{".($pagecount+$length-1)."}\n";
        $retval .=  "\\includepdf[pages=1,".(($m ne "")?"$m,":"").(($option ne 'cd')?$addtotoc:"")."]{$file}\n";
		$retval .=  "\\ClearShipoutPicture\n";
		if ($length>1) {
		    $retval .=  "\\includepdf[pages=2-".(($m ne "")?",$m":"")."]{$file}\n";
		}
    }
    $pagecount += $length;
    return $retval;
} 

sub order {
    my %DB = load_db(0);
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
#     There are cases where we will want to have an incomplete order
#     file, despite the metadata in the final directories.  So we should not
#     just die if the order file is incomplete, as we were doing below.
#	die("missing paper in order: $id") if ! defined($DUP_CHECK{$id});
	if (defined($DUP_CHECK{$id})) {
	    $DB{$id}{"H"}[0] = $TIME{$id} if defined($TIME{$id});
	}
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
    my %DB = load_db(1);

    my($abbrev,$volume,$year,$title,$url);
    while(<STDIN>) {
	my $meta .= $_;
	chomp;
	my ($key,$value) = split(/\s+/,$_,2);
	$value =~ s/\s+$//;
	$abbrev = $value if $key eq 'abbrev';
	$volume = $value if $key eq "volume";
	if (!$volume) {$volume=1;}
	$year = $value if $key eq 'year';
	$title = $value if $key eq 'title';
	$url = $value if $key eq 'url';
    }

    die(    "url of workshop not specified") unless $url;
    die(  "title of workshop not specified") unless $title;
    die(    "year of workshop not specified") unless $year;
    die("abbrev of workshop not specified") unless $abbrev;
    die("volume name of workshop not specified") unless $volume;
    die("abbrev of workshop not correct ([A-Za-z0-9]+") unless $abbrev =~ /^[A-Za-z0-9]+$/;

    $venue = lc $abbrev;

    print STDERR "linking proceedings volume...\n";   # !!! move into makefile
    system("ln -sf ../book.pdf cdrom/$venue-$year.pdf")==0 || die;

    system("rm -rf cdrom/pdf; mkdir -p cdrom/pdf")==0 || die;

    print STDERR "producing front matter...\n";   
    open(TEX,">frontmatter.tex") || die;   # stripped-down version of book.tex; note dependency for makefile
    foreach (`cat book.tex`) {
	$skip = 1 if /INCLUDED PAPERS/;
	$skip = 1 if /{allpapers}/;
	$skip = 0 if /end\{document}/;
	$_ .= "\\hypersetup{pdfpagemode=none}\n" if /{hyperref}/;  # don't show bookmarks
	print TEX $_ unless $skip;
    } 
    close(TEX);
    system("pdflatex --interaction batchmode frontmatter; pdflatex --interaction batchmode frontmatter")==0 || die "pdflatex failed on frontmatter; see frontmatter.log for details\n";
    my $frontmatter_path = sprintf("$year.$venue-$volume.0.pdf",0);
    system("mv frontmatter.pdf cdrom/pdf/${frontmatter_path}")==0 || die;

    print STDERR "creating pdf files stamped with citation info...\n";
    my $papnum = 0;
    open(PAPERMAP, ">id_map.txt") || die;

    # cycle through all the papers, but only generate the ones that
    # have a pdf Paper file.
    foreach my $id (@{$DB{"paper-order"}}) {
	if (!$DB{$id}{"L"}[0]) {
	    next;
	}
        my $pdf_title = $DB{$id}{"T"}[0];

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
        
        open(TEXTEMPLATE, "<$ENV{ACLPUB}/templates/cd.tex.head") || die;
	my $textemplate = join("",<TEXTEMPLATE>);
	close TEXTEMPLATE;

        # Need to ensure that hyperref definition is correct, if we are using old
        # templates.

	my $substring = q{\hypersetup{
            plainpages=false,
            pdfpagemode=none,
            colorlinks=true,
            unicode=true,
            pdftitle={__PDFTITLE__},
            pdfauthor={__PDFAUTHOR__},
            pdfsubject={__PDFSUBJECT__}
            }
        };

	$textemplate =~ s/\\usepackage\[[^\]]+\]\s*\{hyperref\}/\\usepackage{hyperref}/;
	$textemplate =~ /(hypersetup((.|\n)+))/;
	if ($1 !~ /PDFTITLE/) {
	    $textemplate =~ s/\\hypersetup\{[^\}]+\}/$substring/x;
	}

	$textemplate =~ s/__PDFTITLE__/$pdf_title/;
	$textemplate =~ s/__PDFAUTHOR__/$pdf_authors/;
        $textemplate =~ s/__PDFSUBJECT__/$pdf_subject/;

        print STDERR "PDF meta-data:\n";
        print STDERR "  title: $pdf_title\n";
        print STDERR "  author(s): $pdf_authors\n";
        print STDERR "  subject (venue): $pdf_subject\n\n";
	$textemplate .= "\\setcounter{page}{$pagecount}\n";

 	my $length = $DB{$id}{"L"}[0];
 	my $file = $DB{$id}{"F"}[0];
 	$textemplate .= "\\citeinfo{$pagecount}{".($pagecount+$length-1)."}\n";
        $textemplate .= "~\\newpage\n";	# create page with citation stamp
        $textemplate .= "\\ClearShipoutPicture\n";
 	foreach (2..$length) {
 	    $textemplate .= "~\\newpage"; # create pages with nothing but page number
 	}

        $textemplate .= "\\end{document}\n";

        # For RANLP: They use DOIcounter as the counter for the papers.  So we adjust
        # the DOIcounter to make it the one before the current paper num for the DOI.
	$textemplate =~ s/(\\newcounter\{DOIcounter\})/$1\n\\setcounter{DOIcounter}{$papnum}/;

        open(TEX1,">cd.tex");
	print TEX1 $textemplate;
	close TEX1;

	$pagecount += $length;

        # This will print just an overlay with page numbers and citation at bottom.
	system("pdflatex --interaction batchmode cd.tex")==0 || die "pdflatex failed on cd.tex; see cd.log for details\n";
        $papnum++;

        my $pdfdest = "cdrom/pdf/$year.$venue-$volume.$papnum.pdf";
	system("PYTHONPATH=$ENV{PYTHONPATH}; export PYTHONPATH; $ENV{ACLPUB}/bin/pdfunderneath.py $file ./cd.pdf -o $pdfdest")==0 || die;

        # Copy additional files (other than paper) into a directory called "additional"
        # Rename the files to conform to the paper numbering/codes for the pdfs and bib files.
        #
        # Important:  For now, we will have a fixed set of possible file names, taken from
        # recent ACL conferences.  We separate them by '|' for regex search.  This string
        # will also be included in the script index.pl .  We can eventually make this
        # a parameter in the UI.
        #
	$possibleFinalAttachments = 'datasets|notes|software|optional|supplementary|optionalattachment';

	my $pid = $DB{$id}{"P"}[0];         # Get START paperid.
        my @files = glob("final/$pid/*");   # Get the files in the final place for the paperid.

        # paper map - maps the ACL IDs to START IDs.  For external use.
	print PAPERMAP "$abbrev$papnum $pid\n";

	@files = grep(/$possibleFinalAttachments/i, @files);       # Limit the files to the choices we want.
	if (@files) {
	    my $oldprefix = $pid . '_';
	    my $newprefix = "$year.$venue-$volume.$papnum";
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
    my ($ordered) = @_;
    my $input = "db";
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

#       Don't allow duplicates
#	if (defined($$DB{$id})) {
#	    die("duplicate paper id in db: $id");
#	}
	foreach (keys %{$PAPER}) {
	    $$DB{$id}{$_} = $$PAPER{$_};
	}
	%{$PAPER} = ();
    }
}
