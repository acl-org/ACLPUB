# ACLPUB package

This is the official ACLPUB package for *ACL conferences.
Its primary role is to package up the PDF files, BibTeX files, and optional extra files into a format that can be ingested by the [ACL Anthology](https://www.aclweb.org/anthology/).
The latest version can always be found [on Github](https://github.com/acl-org/ACLPUB).

ACLPUB is run within Softconf's STARTv2 system, assisting book/publication chairs in producing PDF proceedings.
It can also be run directly from this package.

## Instructions for START

Instructions on how to use ACLPUB within START are contained within START itself and [the file https://github.com/acl-org/acl-pub/blob/gh-pages/aclpub-start.md](https://github.com/acl-org/acl-pub/blob/gh-pages/aclpub-start.md).

## Instructions for submitting to the Anthology

Please see [anthology/README.md](https://github.com/acl-org/ACLPUB/blob/master/anthology/README.md) for how to bundle up your existing proceedings.
(Note that these instructions were simplified in March of 2020 to accommodate the Anthology's [new ID format](https://www.aclweb.org/anthology/info/ids/)).
For more complete information on the overall process, please see the Anthology's [Information for Submitters](https://www.aclweb.org/anthology/info/contrib/).

## Branch Convention

The `master` branch is used for main development.
The `start` branch reflects the current code being used by [Softconf's](http://softconf.com) [STARTv2](http://softconf.com/about/start-v2-mainmenu-26).
It is brought in sync with `master` at regular intervals.

## History

- 2005: The ACLPUB package and documentation were built in by Jason Eisner and Philipp Koehn, based in part on scripts by David Yarowsky that had been used for several years previously.
- 2019: the code underwent substantial modernization and revision by David Chiang and Dan Gildea.
- 2020: revisions were put in place to work with the Anthology's [new ID format](https://www.aclweb.org/anthology/info/ids/)) by Matt Post.
