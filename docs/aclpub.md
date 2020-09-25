---
layout: default
title: ACLPUB
---

The ACLPUB package, a set of scripts, templates, and makefiles, was
originally created by Jason Eisner and Philipp Koehn for ACL 2005 and
subsequently modified by other pub chairs.  The latest version is
integrated into the START system, and you can produce the PDF and
CD-ROM versions of proceedings via a simple web interface.  This page
explains the process of producing proceedings using the ACLPUB package
in START.

## Overview

All contents of proceedings are prepared as latex sources (title page,
preface, etc.) or PDF files (main papers), and Makefiles are
responsible for processing them and combine them into proceedings.
However, you don't have to compile latex sources and run Makefiles on
your machine, because the START system has a web interface for
proceedings production and runs Makefiles on a server.

The ACLPUB package produces two versions of proceedings.  One is
"PDF", which is a traditional format that contains all papers and
front matters in one PDF file.  The other is "CD-ROM", which consists
of a set of HTML files and PDF files for individual papers.  These
years ACL conferences do not provide CD-ROMs, but this version of
proceedings is called "CD-ROM" historically.

Go to the "ACLPUB" page and you will see all the necessary functions
for producing PDF and CD-ROM versions of proceedings.  The production
process is summarized as below:

1. Fill meta data: the "CD-ROM" tab shows you fields for meta data
   such as abbreviation, title, location, publisher, etc.  They are
   automatically used in producing a CD-ROM version of proceedings.

1. Prepare front matters: title page, copyright page, preface by
   general/program chairs, and list of organizers, are prepared by
   publication chairs.  You can input them in the "template" tab.

1. Specify a program: this is mostly done by program chairs, but you
   might have to do this to fix errors and minor updates.  This can be
   done in the tab "Order".  You have several ways to specify the
   program.  See [order file]({{ site.baseurl }}/order.html) for
   details.

1. Generate proceedings: push the button "All" in the "Generate" tab.
   Wait a moment (this might take several minutes).  If all the
   production process successful, a link to a .tgz file containing
   PDF/CD-ROM version of proceedings appears.  Check log files if the
   process failed.

## Tips

You will need some efforts if you have anything that deviates from the
above process.  Here are some tips.

* How to add image files (e.g. sponsor logos)?

This is a little tricky.  Here is an answer from the ACLPUB manual.

> You can completely customize the templates directory adding new
>   pictures. To add new pictures, and in general to add separate
>   files to the templates, you can do the following steps:  
> - First, download the templates zip file from the "Dwnl templates"
>   tab  
> - Then, add the image in PDF format to the unpacked archive. (NOTE:
>   any format accepted by graphicx works)  
> - After that, you need to include the image in the latex files. To
>   do that, you can do the following:  
> - in the initial part, before \begin{document}, include the line 
>   \usepackage{graphicx}  
> - in the point where the figure needs to appear, use the following code:
>   \includegraphics{../templates/imagename.pdf}  
> where ../templates/ is needed because the make command is not run in the templates directory (where the image is stored).

* How to remove unnecssary sections (e.g. preface) from the proceedings?

Edit "book.tex" and comment out the line "\includepdf{...}", which
includes PDF files created from corresponding latex sources.  You can
do this by editing book.tex in "Templates" -> "Settings" or by
downloaing all source files (see the next tip).

* Can we edit preface.tex etc. on a local machine?

START allows you to download all source files including preface.tex,
etc., and upload edited files.  Download a zip archive of source files
via the link "Current ACLPUB Templates" in "Dwnl Templates".  Make any
changes to the source files, and upload a new zip file via "Import".

*Important note*: do not use a zip file in "Default Templates".  They
 are only for a reference.  If you upload your file based on this
 file, all contents for your specific ACL will be lost.

* Can we order papers differently from the order in the program?

You might want to put a paper independently from the order in the
program; e.g. put a paper of an invited talk as a first paper rather
than in a scheduled position.  You can do this by manually editing
automatically generated programs.  See Tips in
[order file]({{ site.baseurl }}/order.html).

