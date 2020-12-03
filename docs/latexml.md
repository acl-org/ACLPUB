---
layout: default
title: LaTeXML
---

An effort starting from ACL 2014 is to collect LaTeX sources of
camera-ready papers and produce machine-readable proceedings in
X(HT)ML from them.  In ACL 2014, we applied
[LaTeXML](http://dlmf.nist.gov/LaTeXML/) with several adaptations to
the ACL stylefile (\newcite, etc.), thanks to the help of Deyan Ginev
and Michael Kohlhase.

Here are the steps to produce machine-readable proceedings using
LaTeXML.

## Prepare CFP and submission site

* Ask program chairs to include a text announcing that we are
  collecting LaTeX sources.  Here is a text used in ACL 2014 CFP.

> Papers in XML Format:
> One innovation which we are introducing for ACL 2014 is that we will
> publish papers in machine-readable XML in the ACL Anthology, in
> addition to the traditional PDF format. This will allow us to
> create, over the next few years, a growing corpus of scientific text
> for our own future research, and picks up on recent initiatives on
> converting ACL papers from earlier years to XML. When you submit
> your camera-ready paper, we will automatically convert the LaTeX
> source code into XML using the LaTeXML tool. For now, uploading your
> LaTeX sources along with the camera-ready PDF will be a voluntary
> option. However, the more authors make use of this option, the more
> XML papers we will have in the Anthology, so we encourage everyone
> to participate. More detailed instructions and a link to an online
> tool for previewing the result of the conversion are available on
> the ACL2014 publication chairs website:
> https://sites.google.com/site/acl2014publication/.

* Ask program chairs to put a field to submit latex sources in the
  submission page.  START already has this function and it is easy to
  do this.

## Converting LaTeX sources into X(HT)ML

Once you collected LaTeX sources of camera-ready papers, the next task
is to convert them into X(HT)ML files.  The easiest way at the moment
is to run LaTeXML web interface in a batch style.  Python scripts to
do this batch conversion are found in this repository ("runlatexml/").

1. Obtain latex sources from START  
   "proceedings.tgz" you obtain by creating the proceedings (clicking
   "All" in "ACLPUB > Generate") contains all necessary files for
   producing XML proceedings.  The following steps assume that you
   unpack proceedings.tgz in the directory `$dir`.  Here is a summary
   of directories/files necessary for the following steps.
   * $dir
      * id_map.txt: mapping from submission ID to paper ID
      * final/: zip files of final submissions
      * cdrom/: CD-ROM proceedings.  XML files will be put in this directory finally.
2. mapid: Convert submission IDs to final paper IDs  
   Latex sources are named
   with submission IDs (plain number), while papers in the final proceedings are
   named with final paper IDs (something like "P14-1001").  This can
   be done by using "id_map.txt" (which gives you mapping from
   submission ID to paper ID) in the following way:  
```
python mapid.py $dir/proceedings/id_map.txt $dir/texsrc $dir/proceedings/final/*/*_tex.*
```
3. rezip: Convert submission files into zip  
   LaTeXML accepts only zip files, while actual submissions are in
   various formats like tgz and bz2.  This step converts non-zip files
   into zip.  The script also removes files similar to the ACL2014
   sample tex file ("runlatexml/acl2014.tex").  This is because many
   people put this sample file in the same directory as their main
   paper, and LaTeXML mis-recognizes the sample file as the main paper
   source file.  
   ```
   python rezip.py acl2014.tex $dir/texzip $dir/texsrc/*
   ```
4. runlatexml: Run LaTeXML web interface  
   This step invokes the latexml web interface and converts zipped
   latex sources into zipped X(HT)ML files (and accompanied files like
   images).  
   ```
   python runlatexml.py $dir/xmlzip $dir/texzip/*.zip
   ```
5. merge: Merge and reorganize X(HTML) files into the structure of the
   ACL proceedings  
   This process collects all zipped X(HTML) files and reorganize them
   into the directory structure that fits the ACL CD-ROM proceedings.  
   ```
   python merge.py $dir/xml $dir/xmlzip/*.zip
   ```
6. addindex: Add links to XML files from the index page  
   This step modifies cdrom/index.html to include links to XML files.
   The following script overwrites "index.html", while the original file
   is renamed to "index.html.orig".  
   ```
   python addindex.py $dir/xml $dir/proceedings/cdrom/index.html
   ```
7. Copy XML files to CD-ROM  
   The final step is to copy XML files into "cdrom/", which is the
   directory officially published as CD-ROM proceedings.  
   ```
   cp $dir/xml $dir/proceedings/cdrom
   ```

Running

    run-all.sh $dir

runs the above processes at once, while you may want to re-run some of them as necessary.

## Some info

* [LaTeXML homepage](http://dlmf.nist.gov/LaTeXML/)
* [Web interface for conversion](http://latexml.mathweb.org/upload)
* [List of supported packages](http://dlmf.nist.gov/LaTeXML/manual/included.bindings/)

## Issues

* Improve the support for macros
* Obtain a log file to identify sources of problems: conversion fails
  for some papers, while we could not investigate the reason for time limitation.
* Develop applications using machine-readable proceedings; e.g. mobile-friendly CSS, etc.

