ACLPUB package
==============

This is the official ACLPUB package for *ACL conferences.
Its primary role is to package up the PDF files, BibTeX files, and optional extra files into a format that can be ingested by the [ACL Anthology](https://www.aclweb.org/anthology/).
The latest version can be found at https://github.com/acl-org/ACLPUB.

Instructions
------------
For the most up-to-date technical documentation on how to produce data for the Anthology, please see [the file anthologize/README.md](https://github.com/acl-org/ACLPUB/blob/master/anthologize/README.md).
Other directories contain scattered outdated information that should probably be removed.

Branch Convention
-----------------
The `master` branch is used for main development.
The `start` branch reflects the current code being used by [Softconf's](http://softconf.com) [STARTv2](http://softconf.com/about/start-v2-mainmenu-26).
It is run within Softconf's STARTv2 system to general the proceedings tarballs that are sent to the publication chair.
`start` is brought in sync with `master` at regular intervals.

History
-------
The ACLPUB package and documentation were built in 2005 by Jason Eisner and Philipp Koehn, based in part on scripts by David Yarowsky that had been used for several years previously.

In 2019, the code underwent substantial modernization and revision by David Chiang and Dan Gildea.
