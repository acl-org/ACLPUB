###  Makefile for generating ACL proceedings

# !!! WARNING: Not all the dependencies on the aclpub package itself
# are correct yet, since some of the scripts call one another (should
# search for this) or reference .head files, and the Makefile itself
# might change.  Maybe we should just make everything depend on
# PKG = $(shell find $(ACLPUB)) ?

#================================================================ 
# Platform detection 

HOSTNAME  := $(shell hostname) 
WHOAMI    := $(shell whoami) 
HOSTTYPE  := $(shell uname) 
CURDIR    := $(shell pwd) 
INVOCATION := "Build:\n HOSTNAME=$(HOSTNAME) \n HOSTTYPE=$(HOSTTYPE) \n WHOAMI=$(WHOAMI) \n CURDIR=$(CURDIR)"

#================================================================ 

default: 
	@echo "Please see the HOWTO webpage for instructions:"
	@echo "   $(ACLPUB)/doc/bookchairs/index.html"
	@echo "(Yes, \"make all\" will work if you're really curious to"
	@echo "see an approximate version of the end product right away.)"
	@echo
	@echo -e $(INVOCATION) 
.PHONY: default

####################
# Global variables.

SHELL = bash
VIEW = acroread

# Where to find the remaining aclpub materials

ACLPUB ?= ~/aclpub
ifneq (ok,$(shell if [ -d $(ACLPUB) ]; then echo ok; fi ))
	ACLPUB = $(error Please set the environment variable ACLPUB to the aclpub package directory)
endif
BIN = $(ACLPUB)/bin
TEMPLATES = $(ACLPUB)/templates

# Where to find inputs.
# Updates will be triggered if files in the final/ directory
# are added, deleted, or modified.

metadata=final $(wildcard final/*.txt) $(wildcard final/*/*.txt)
papers=final $(wildcard final/*.pdf) $(wildcard final/*/*.pdf)
templates = book.tex citation-stamp.tex spine.tex \
	titlepage.tex copyright.tex preface.tex organizers.tex \
	just-program.tex just-toc.tex

# Consult the draftflag.sty file to find out if we are currently
# in draft or shipout mode.

mode=$(shell if [ -e draftflag.sty ] && grep -q 0 draftflag.sty; \
             then echo shipout; \
             else echo draft; fi)

####################
# Installing software
# !!! for cdrom, also need acroread or xpdf's pdftops

Makefile: $(ACLPUB)/make/Makefile_bookchair  # update this makefile itself if necessary
	cp $< $@   # !!! shouldn't just copy

update:     # update the aclpub software from CVS repository
	cd $(ACLPUB); cvs -d :pserver:anoncvs@ftp.clsp.jhu.edu:/aclpub update -d

.PHONY: perl-modules install-perl-modules unpack-perl-modules

perl-modules: .perl-modules   # friendlier name for outside use

.perl-modules:    # dummy file exists if we have the modules
	@if perl -e 'use Text::PDF::File; use Text::PDF::SFont; use Text::PDF::Utils' 2>/dev/null; \
	then : ; \
	else \
	echo "You will need to get a few Perl modules to proceed"; \
	echo "   (Text::PDF, plus Compress:Zlib, which it depends on)."; \
	echo "To just download and unpack them in `pwd`, type"; \
	echo "   \"make unpack-perl-modules\""; \
	echo "To install them system-wide, become superuser and type";\
	echo "   \"make install-perl-modules\"";\
	echo "Then, to check that the modules now work, type";\
	echo "   \"make perl-modules\"";\
	exit 1; fi
	@touch .perl-modules

install-perl-modules:
	perl -MCPAN -e 'install Text::PDF::File, Text::PDF::SFont,\
				Text::PDF::Utils'

# !!! should actually unpack these under $(ACLPUB), or else just distribute
# them with aclpub package
unpack-perl-modules:
# These are the most current versions as of May 2005
# You can check http://search.cpan.org for more recent versions
	wget http://search.cpan.org/CPAN/authors/id/M/MH/MHOSKEN/Text-PDF-0.29a.tar.gz
	tar xzf Text-PDF-0.29a.tar.gz
	cd Text-PDF-0.29; perl Makefile.PL; make
###
	wget http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/Compress-Zlib-1.34.tar.gz
	tar xzf Compress-Zlib-1.34.tar.gz
	cd Compress-Zlib-1.34; perl Makefile.PL; make; ln -s blib/lib

# Environment variable, in case user did "make unpack-perl-modules"

export PERL5LIB:=$(shell pwd)/Text-PDF-0.29a/lib:$(shell pwd)/Compress-Zlib-1.34/lib:$(PERL5LIB)

####################
# Unpack the submissions

final: final.tgz
	@if [ -e final ]; then mv final final.bak; \
		echo "Backed up old final directory as final.bak"; fi
	tar xfz final.tgz final
	@if [ ! -d final ]; then echo "Error: Unpacking final.tgz didn't \
		create a directory called final"; exit 1; fi
	@touch final    # make top dir more recent than tarball\
			# (overwrite original timestamp), so that we\
			# know it's up to date

final.tgz:               # in case tarball was named something else instead
	@if [ -e final.tar ]; then gzip final.tar; fi
	@if [ -e final.tar.gz ]; then mv final.tar.gz final.tgz; fi
	@if [ ! -e final.tgz ]; then \
	echo "First, download the tarball final.tgz of camera-ready submissions from START"; \
	echo "   (or type \"touch final.tgz\" to fool me into thinking it exists,"; \
	echo "   then manually create the \"final\" directory and a \"db\" file,"; \
	echo "   and remember to gather hardcopy copyright forms)."; \
        exit 1; fi

####################
# A read-only file for you to check carefully and 
# send to publications chairs

copyright-signatures: $(BIN)/manage-db.pl $(metadata) .perl-modules
	$< get-copyright
	@echo "Please check the copyright-signatures file carefully\
		(do not edit),"
	@echo "and email it to the publications chairs with a\
		thumbs-up or thumbs-down."

####################
# "db" database file with all information about the papers.
# Once you create this, you can hand-edit it.
# Optionally, you can also create and hand-edit an "order" file.

db:: $(BIN)/manage-db.pl $(metadata) $(papers) .perl-modules
	@# Note that db depends on the metadata AND the papers themselves,
	@# since we will consult the actual lengths of the latter.
	@$(quit-if-exists)
	@echo "Creating db file ..."
	$(backup-db)
	$< create
	@# generate "new" order file identical to old one
	@# (thus, next rule will apply the "new" order file)
	@if [ -e order ]; then touch order; fi \

db:: $(BIN)/manage-db.pl order .perl-modules
	@# Furthermore, db should be reordered if the order file has changed.
	@# (The two db:: rules specify different actions for different prerequisites.)
	@# It is possible that the order and db files will become
	@# inconsistent if the user edits them badly or the submissions change.
	@# In this case, the command below will report an error.
	@if [ -e db ] && [ -e order ]; then \
		echo "Restructuring db file based on order file ..."; \
		$(backup-db); \
		$< order < order; \
	fi

order:
# order is initially derived from db, but we don't give a dependency
# on db.  It can't be rebuilt automatically after it's hand-edited;
# nor does it need to be rebuilt manually after most changes to db.
# (However, it's true that some changes to db will make order obsolete.)
# 
# In any case, we can't have order <- db since we already have
# db <- order (okay since there is a safe way to rebuild db after
# changes to order).
#
# Even when the order file doesn't yet exist, we don't build it
# automatically; we just tell the user how to, via the following message.
ifndef GETTING_ORDER
	@echo "Note: You may want to create an order file\
		with \"make get-order\""  
endif

.PHONY: get-order

get-order:  # explicit request to create or update order file
	@if [ -e order ]; then mv order order.bak; echo "Backed up old order file as order.bak"; fi
	@# recursively ensure that db is up to date with submissions
	@# (didn't make this a dependency since first we wanted to
	@# move aside the old order file, if any)
	@make db GETTING_ORDER=1 --no-print-directory
	$(BIN)/manage-db.pl get-order > order
	@echo "Now you can edit the order file if you like."

####################
# Any template file that we need comes from the templates directory.

$(templates): %: $(TEMPLATES)/%
	cp $< $@  # !!! shouldn't just copy

####################
# Individual front-matter sections of proceedings

titlepage.pdf copyright.pdf preface.pdf organizers.pdf: %.pdf: %.tex
	$(call pdflatex,$<)

####################
# More front-matter sections of proceedings.  You can generate these
# as standalone PDF files for proofreading.  However, these PDF files
# are not used in the final version; the .tex files are included into
# book.tex instead.
# !!! could use a static pattern rule

toc.pdf program.pdf: %.pdf: just-%.tex %.tex 
	$(call pdflatex,$<)
	mv just-$@ $@

####################
# Automatically-generated tex files.  Once these .tex
# files are generated, you can hand-edit them if you want.

toc.tex: $(BIN)/manage-db.pl db .perl-modules $(TEMPLATES)/toc.tex.head
	@$(quit-if-exists)
	$< generate-tex toc

program.tex: $(BIN)/manage-db.pl db .perl-modules $(TEMPLATES)/program.html.head
	@$(quit-if-exists)
	$< generate-tex program

allpapers.tex: $(BIN)/manage-db.pl db draftflag.sty .perl-modules
ifeq ($(mode),draft)    # consults draftflag.sty; !!! maybe shouldn't use conditional compilation for this, rather use $(if ...)?
	$< join-papers 2 
else
	@$(quit-if-exists)
	$< join-papers final
	@echo "You may now edit allpapers.tex if you like."
endif

####################
# Index generation using standard LaTex method
# Note: ACL proceedings through 2004 generated a custom 
# solution with a different look (index1col or index2col).  

book.ind: book.idx
ifeq ($(HOSTTYPE),CYGWIN_NT-5.1)
	dos2unix book.idx
endif 
	makeindex book

book.idx: allpapers.tex
	$(call pdflatex,book.tex)

####################
# The full book (draft or shipout according to our current mode).
# If you also want to bring it up in acroread, try "make view".

.PHONY: view

view: book.pdf
	$(VIEW) book.pdf

book.pdf: book.tex draftflag.sty citation-stamp.tex \
	titlepage.pdf copyright.pdf preface.pdf organizers.pdf \
	toc.tex program.tex allpapers.tex $(papers) book.ind   
# pdflatex regenerates book.idx.
# But if the new version is identical to the old, let's keep the old timestamp.
# Otherwise the next "make" will think that the change requires us
# to rerun makeindex and pdflatex.
# !!! Should do something similar with .aux, and add a dependency on .aux?
	@mv book.idx book.idx.bak    # must already exist because of deps
	$(call pdflatex,book.tex)
	@if diff book.idx book.idx.bak > /dev/null;\
		then mv -f book.idx.bak book.idx; else rm book.idx.bak; fi

####################
# Making draft vs. final versions.

.PHONY: draft shipout draft-mode shipout-mode

draft: draft-mode
	@make book.pdf --no-print-directory  # recurse

shipout: shipout-mode
	@make book.pdf --no-print-directory  # recurse

draft-mode: draftflag.sty
ifneq ($(mode),draft)     # if we are actually switching modes
	@# save old edited shipout version if we had one
	@if [ -e allpapers.tex ]; then \
		mv -f allpapers.tex allpapers.tex.shipout; fi
	echo '\def\draftflag{1}' > draftflag.sty
endif

shipout-mode: draftflag.sty
ifneq ($(mode),shipout)   # if we are actually switching modes
	@if [ -e allpapers.tex ]; then rm allpapers.tex; fi
	@# restore old edited shipout version if we had one
	@if [ -e allpapers.tex.shipout ]; then \
		mv allpapers.tex.shipout allpapers.tex; \
		touch allpapers.tex; fi
	echo '\def\draftflag{0}' > draftflag.sty
endif

draftflag.sty:            # start out in draft mode if file doesn't exist
	echo '\def\draftflag{1}' > draftflag.sty

####################
# The spine text (for the binding)

.PHONY: spine

spine: spine.ps

spine.ps: spine.tex
	latex spine.tex
	dvips -t landscape -o spine.ps spine.dvi


####################
# This book's contribution to the CD-ROM

cdrom: cdrom/program.html cdrom/authors.html cdrom/bib cdrom/pdf cdrom/index.html

cdrom/index.html: $(BIN)/index.pl db meta $(TEMPLATES)/index.html.head
	@$(quit-if-exists)
	$(cdrom-dir)
	@echo creating HTML index page ...
	$< db meta > $@

cdrom/program.html: $(BIN)/program-html.pl db meta $(TEMPLATES)/program.html.head
	@$(quit-if-exists)
	$(cdrom-dir)
	@echo creating HTML program ...
	$< db meta > $@

cdrom/bib: $(BIN)/bib.pl db meta
	$(cdrom-dir)
	rm -rf cdrom/bib
	@echo creating bib files ...
	$< db meta

cdrom/authors.html: $(BIN)/authors.pl db meta $(TEMPLATES)/authors.html.head
	@$(quit-if-exists)
	$(cdrom-dir)
	@echo creating author index page ...
	$< db meta > $@

cdrom/pdf: $(BIN)/manage-db.pl book.tex book.pdf $(TEMPLATES)/cd.tex.head
ifeq ($(mode),draft)
# would be better to handle this by having different names for
# draft and shipout pdf files
	$(error You are still in draft mode!  You should switch to "make shipout" before building the cdrom pdf files)
endif
	$(cdrom-dir)
	@echo creating pdf files ...
	$< create-cd < meta

define cdrom-dir  # initialize cdrom directory
@mkdir -p cdrom
@# add *.css files (only) to PARENT directory (not cdrom directory)
@# since they will be referenced there as ../standard.css
@# in preparation for eventual layout on full CD-ROM
@# !!! shouldn't just copy here: use auto mechanism
cp $(TEMPLATES)/cdrom-root-files/*.css .  
endef

####################
# Pre-conference "advertisement" version of HTML program.
# Derived directly from the corresponding program.html on the CD-ROM
# (which may have been hand-edited).  The main difference is that we
# have removed the links to actual papers.  We also replace the nav line
# at the top with a modified version of the one from index.html.

.PHONY: advertisement

advertisement: advertisement.html

advertisement.html: $(BIN)/advertisement.pl cdrom/index.html cdrom/program.html 
	@$(quit-if-exists)
	@echo creating $@ ...
	$< cdrom/index.html < cdrom/program.html > $@

#################
# Check that everything is up-to-date, and package it up!

all: ../proceedings.tgz

../proceedings.tgz: shipout copyright-signatures book.pdf spine cdrom advertisement
	@echo "Almost done ... ready to package things up ...";
	@if pwd | grep -vq /proceedings; then \
		echo "Error: Please rename the current directory to\
		\"proceedings\" and re-run make."; exit 1; fi
	cd ..; tar cfz proceedings.tgz proceedings; cd proceedings
	@echo "Successfully updated and packaged everything.";
	@echo "Please recheck the HOWTO webpage to make sure you did\
		everything you needed."
	@echo "Then send ../proceedings.tgz to the publications chairs. \
		Thank you!"

####################
# Included by convention, but overall, it's probably 
# safer NOT to run this (to avoid problems where latex
# has to be run multiple times to regenerate everything properly).

.PHONY: clean cleanmostly

# intermediate and backup files only
mostlyclean:
	rm -f *.aux *.dvi *.idx *.ilg *.ind *.log *.out   # latex intermediate files
	rm -f db.[0-9][0-9]*	# old saved versions of db file (!!! stop keeping these?)
	rm -f toc.pdf program.pdf just-*.pdf just-*.tex  # for viewing these portions separately
	rm -f cd.tex frontmatter.tex                     # temporarily used to create CD-ROM files
	rm -f titlepage.pdf copyright.pdf preface.pdf organizers.pdf 
	find . -name "*~" -o -name "\#*\#" -o -name "*.bak" | xargs --no-run-if-empty rm -r # backups

# all files that can be created entirely by the makefile
# !!! should delete an edited file only if it is identical to its auto
#    (leave behind a patch??).   
clean: mostlyclean
	rm -f draftflag.sty 
	rm -f book.pdf spine.ps 
	rm -f copyright-signatures 
	rm -f *.css
	if [ -e cdrom ]; then cd cdrom; rm -rf index.html program.html bib authors.html pdf *.bib *.pdf; fi   # !!! should only delete abbrev-year.bib, abbrev-year.pdf
	-if [ -e cdrom ]; then rmdir cdrom; fi   # only succeeds if dir is empty (maybe user added custom files)
	rm -f advertisement.html

####################
# Utilities

define quit-if-exists
	if [ -e $@ ]; then echo -e "$(warning)"; exit 1; fi
endef

define backup-db
	if [ -e "db" ]; then cp -p db db.`perl -e "print time()"`; fi
endef

define warning
Attention: The file \"$@\" is out of date.\n\
Not updating it automatically because you may have edited it.\n\
Either hand-edit $@ (if you want to update it manually)\n\
or type \"rm $@\" (if you want it to be rebuilt)\n\
or type \"touch $@\" (if you think it is okay as it stands).\n\
Then run the make command again.
endef

define pdflatex
	@echo quietly running pdflatex $(1) ...
	@pdflatex --shell-escape --interaction batchmode $(1) || (echo "pdflatex failed on $(1); see $(1:%.tex=%).log for details"; exit 1)
endef

# In general, throw away a target if only partly built.

.DELETE_ON_ERROR:

