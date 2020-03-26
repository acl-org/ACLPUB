# ACLPUB package

This is the official ACLPUB package for *ACL conferences.
Its primary role is to package up the PDF files, BibTeX files, and optional extra files into a format that can be ingested by the [ACL Anthology](https://www.aclweb.org/anthology/).

Currently, it has two parts. The first part runs within Softconf's STARTv2 and assists book/publication chairs in producing PDF proceedings. The second part, `anthologize`, runs on the publication chair's computer and converts the proceedings to the format required by the ACL Anthology.

## Instructions for START

Instructions on how to use ACLPUB within START are contained within START itself and [the file https://github.com/acl-org/acl-pub/blob/gh-pages/aclpub-start.md](https://github.com/acl-org/acl-pub/blob/gh-pages/aclpub-start.md).

## Instructions for submitting to the Anthology

Please see [anthology/README.md](https://github.com/acl-org/ACLPUB/blob/master/anthology/README.md) for how to bundle up your existing proceedings.
For more complete information on the overall process, please see the Anthology's [Information for Submitters](https://www.aclweb.org/anthology/info/contrib/).

## Branch Convention

The `master` branch is used for main development.
The `start` branch reflects the current code being used by [Softconf's](http://softconf.com) [STARTv2](http://softconf.com/about/start-v2-mainmenu-26).
It is brought in sync with `master` at regular intervals.

## History

The ACLPUB package and documentation were built in 2005 by Jason Eisner and Philipp Koehn, based in part on scripts by David Yarowsky that had been used for several years previously.

In 2019, the code underwent substantial modernization and revision by David Chiang and Dan Gildea.
