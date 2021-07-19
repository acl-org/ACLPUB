---
layout: default
title: Generating proceedings for the ACL Anthology
---

The ACL Anthology requires a particular file layout in order to ingest material (described in Step 3 below).
This README describes how to produce this layout from files exported from STARTv2 or EasyChair, or manually.

## 1. Installation and setup

First, clone the official repository:

    git clone https://github.com/acl-org/ACLPUB

The scripts you will be using are in the subdirectory `ACLPUB/anthologize`.
Below, we assume that you have this directory in your `PATH`; if not, you'll need to provide full pathnames to scripts.

## 2. Assembling the data

If you are using:

- STARTv2: follow the instructions in Step 2(a), then 2(c).
- EasyChair: follow the instructions in Step 2(b), then 2(c).
- Another system: you will need to manually arrange your files into the layout described in Step 2(c), then continue to Step 2.

### 2a. Instructions for users of Softconf's STARTv2

Create a file called `start_urls.txt` that contains a list of the START urls for all volumes associated with the conference.
As an example, the `start_urls.txt` file in the current directory contains many of the NAACL 2015 volumes:

    https://www.softconf.com/naacl2015/papers
    https://www.softconf.com/naacl2015/shortpapers
    https://www.softconf.com/naacl2015/srw
    https://www.softconf.com/naacl2015/tutorials
    https://www.softconf.com/naacl2015/demos
    https://www.softconf.com/naacl2015/WMT14
    https://www.softconf.com/naacl2015/BioNLP
    https://www.softconf.com/naacl2015/BEA9

Next, download all the tarballs.
You can use the provided script:

    bin/download-proceedings.sh start_urls.txt

This automatic downloading is provided as a convenience; you could also do it manually (and may need to do so, if there are workshops that assemble their proceedings outside of START).

This downloads each track/workshop's proceedings.
The result should be something like the file structure in Step 2(c).

### 2b. Instructions for users of EasyChair

If you are using EasyChair, please see the [instructions in the easy2acl repository](https://github.com/acl-org/easy2acl/blob/master/README.md).
The documentation there describes how to assemble the Easychair output and run the `easy2acl.py` script in order to generate a layout similar to what START exports.
That code helps you produce a file format similar to Step 2(c).

### 2c. The file format

The ACLPUB scripts work from a conference organized in the following file format.
A conference is one or more main conference volumes, along with zero or more workshop volumes.
Each volume gets its own top-level directory underneath `data/`.
For example:

```
data/
  naacl2018-longpapers/
    proceedings/
      meta
      cdrom/
        ...
  naacl2018-shortpapers/
    proceedings/
      meta
      cdrom/
        ...
  SemEval-2018/
    proceedings/
      meta
      cdrom/
        ...
  starsem/
    proceedings/
      meta
      cdrom/
        ...
```

Looking within each of these `proceedings` directories, we see the following format, which is the STARTv2 export format for a single volume:

```
proceedings/
  meta                               Information about the conference
  cdrom/
    semeval-2018.bib                 BibTeX file containing entries for all papers
    semeval-2018.pdf                 PDF of whole proceedings
    additional/
      2018.semeval-1.1_Software.tgz  Software attached to paper 1
      2018.semeval-1.3_Dataset.zip   Dataset attached to paper 3
      2018.semeval-1.3_Note.pdf      Note attached to paper 1003
    bib/
      2018.semeval-1.0.bib           BibTeX entry for the whole proceedings volume
      2018.semeval-1.1.bib           BibTeX entry for paper 1
      2018.semeval-1.2.bib           etc.
    pdf/
      2018.semeval-1.0.pdf           PDF of frontmatter
      2018.semeval-1.1.pdf           PDF for paper 1
      2018.semeval-1.2.pdf           etc.
```

### The "meta" file

Each `meta` file is just a collection of key/value pairs, one per line, with the key and value separated by whitespace.
The lines of interest are (using `SemEval` as an example):

```
abbrev SemEval
volume 1
title 12th International Workshop on Semantic Evaluation
booktitle Proceedings of the 12th International Workshop on Semantic Evaluation
shortbooktitle Proceedings of SemEval
month January
year 2018
sig siglex
chairs Marianna Apidianaki
chairs Mohammad, Saif M.
chairs Jonathan May
chairs Ekaterina Shutova
chairs Steven Bethard
chairs Marine Carpuat
location Berlin, Germany
publisher Association for Computational Lingustics
```

The following fields are of special importance:

- **abbrev**, **year**, and **volume** are used to assemble the [Anthology ID](https://aclanthology.org/info/ids/) in the [ACL Anthology](https://aclanthology.org/).
  These three constitute the volume ID (e.g., `2018.semeval-1`), which is prefixed to the paper ID to form the complete paper identifiers (e.g., `2018.semeval-1.19` for the 19th paper).
- **abbrev** is the venue for this volume.
  It will be lowercased when forming file names, and will appear at `https://aclanthology.org/venues/{abbrev}`.
  It can only contain ASCII letters and numbers ([A-Za-z0-9]+).
  *A common mistake is to include the year (e.g., SemEval20). Since it is a venue name, it should not contain the year*.
- **year** is the four-digit year.
- **volume** is the name of the volume.
  Most workshops have just a single volume, in which case you can just use "1".
  For larger conferences with multiple volumes, you may wish to choose short, informative names (e.g., "short" for short papers, "long" for long papers, "srw" for papers in a Student Research Workshop, etc.)

For those using START, these should have been set by publications and book chairs (Publication Console -> ACLPUB -> CDROM).

In addition, please ensure that the **chairs** lines are BibTeX-formatted names as above.
If there are just two names, we can easily format it into BibTeX's "family name, given name" format.
If there are more than three names (e.g., "Mohammad, Saif M."), please format this way yourself.
Do not add affiliations as these are not used and they complicate parsing.

**NOTE**: If you are wondering what happened to the `bib_url` field, it is no longer used.
  If it's present in START, you can ignore it.

## 3. Sanity check

After assembling your data to look like Step 2(c), please run the following script, which runs some basic sanity checks that may save you and the Anthology Director some grief.

    ./bin/sanity_check.py /path/to/data

## 4. Package and send the `data/` directory

Package up the anthology directory:

    tar czvf <conference>_data.tgz data

Upload the resulting file (`<conference>_data.tgz`) to a file server or cloud storage (e.g. Google Drive) and email the link to it to the Anthology Director.
Please do not send the file as an email attachment.

## Notes on supported attachment formats

Current attachment types supported by the Anthology are:

+ Dataset
+ Note
+ Poster
+ Presentation
+ Software
+ Attachment (this is for generic attachments; best to be specific and avoid using this when possible)
