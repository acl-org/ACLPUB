---
layout: default
title: Open Issues
---

## Style file

* Migration to new style files? e.g. the style file at IWPT 2013 has
  many useful functions, while resolving the known bug mentioned below.
* A known bug with the ACL style and hyperref: http://tex.stackexchange.com/questions/124410/hyperref-modifies-bibliography-style-of-acl-style-files
* Inconsistency in font sizes for abstract: style guide says 10pt,
  Latex style says 11pt.  Make sure the tex template (as well as the
  guidelines file) uses the right font sizes for abstract and references.
* Would be nice to get rid of Word.  Maintain some statistics on Word vs Latex usage here.
* Specify formatting of email addresses on first page
* Line spacing in Word template is smaller than in Latex style
* Allow appendices? If yes, how long can they be? Do they count
  towards the 9 pages of content or not?
* Specify reference style?
* Allow captions for tables in smaller font size than 11?
* Appendices before / after acknowledgment?
* Define the font size of acknowledgment
* Define the font size of appendices
* Check in­text citation style in tex template: when there is
  additional text within the parentheses.  \newcite ends up as ( see
  e.g. Author et al., (2006)) instead of (see e.g. Author et al.,
  2006)
* Style guide asks for captions like in the following style: "Figure 1. Caption of the Figure.", "Table 1. Caption of the Table." But
  Latex style uses "Table 1: Font guide."
* Modify the style file to embed meta data (for XML publication)

## START system

* START system: add information on how to proceed with any complexities of name structure (e.g. mid initial).
* Paper format checking function should be made stricter.  At least page
  size should be checked automatically.
* The procedure to upload image files should be improved.  It is too
  tricky.  It's great if web interface is available.
* Some format checking in the schedules? Workshop organizers are
  unfamiliar with START, and often get lost, in particular with the
  specification of schedules. This also causes a problem with the
  handbook generation.  It might be good to integrate Matt Post’s
  Python script to check format of "order" file.
* Make copyright sign mandatory
* The generation page should show a time stamp (and "generating" if
  the process is running). We often get lost when we generated the
  proceedings. What is worse is different people happen to run the
  generation simultaneously.
* Option to remove some sections (e.g. preface and organizers) from
  the proceedings. Some of them can be unnecessary (e.g. we did not
  put preface and organizers in the volume 2)
* The ACLPUB "templates" page might be confusing. One of the workshop
  organizers used default ACLPUB templates rather than specialized
  templates for ACL2014, and this cause a terrible trouble in
  producing their proceedings.

## Process of publishing

* Decouple scheduling from paper order.  Programs will often be
  changed, and it forces publication chairs to reproduce the entire
  proceedings.  The tweaking of the programs and the ordering in the
  proceedings should be processed independently.
* Is full copyright transfer really necessary?  Conditions should be relaxed.
* Author names are normalized within each book, but generalized index
  in conf handbook can still have multiple versions.

