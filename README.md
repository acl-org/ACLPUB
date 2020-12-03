# ACLPUB package

This is the official ACLPUB package for *ACL conferences.
Its primary role is to package up the PDF files, BibTeX files, and optional extra files into a format that can be ingested by the [ACL Anthology](https://www.aclweb.org/anthology/).
Documentation can found under `docs/` and view [on the web](https://acl-org.github.io/ACLPUB/).
The latest version can always be found [on Github](https://github.com/acl-org/ACLPUB).

## Instructions for START

[Softconf's](http://softconf.com) [STARTv2](http://softconf.com/about/start-v2-mainmenu-26) system is the main system used for conference management within the ACL community.
It includes extensive integration around the ACLPUB package.
Information about how to use ACLPUB within START [can be found here](https://acl-org.github.io/ACLPUB/start.html).

ACLPUB can also be run from the command line, which facilitates use with third-party conference management software.

## Instructions for submitting to the Anthology

Instructions for submitting proceedings to the Anthology [can be found here](https://acl-org.github.io/ACLPUB/anthology.html).
These instructions were simplified in March of 2020 to accommodate the Anthology's [new ID format](https://www.aclweb.org/anthology/info/ids/)).
For more complete information on the overall process, please see the Anthology's [Information for Submitters](https://www.aclweb.org/anthology/info/contrib/).

## Branch Convention

The following branches have special import:

- The `master` branch is used for main development and contains the official stable release.
- The `start` branch reflects the current code being used in START.
  It is brought in sync with `master` at regular intervals.

## History

- 2005: The ACLPUB package and documentation were built in by Jason Eisner and Philipp Koehn, based in part on scripts by David Yarowsky that had been used for several years previously.
- 2019: the code underwent substantial modernization and revision by David Chiang and Dan Gildea.
- 2020: revisions were put in place to work with the Anthology's [new ID format](https://www.aclweb.org/anthology/info/ids/) by Matt Post.
