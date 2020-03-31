# Generating proceedings for the ACL Anthology

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

Create a file called `acronyms_list.txt` that contains a list of the START names of all tracks/workshops associated with the conference, one per line, and case-sensitive.
For example, the `acronyms_list` for NAACL 2015 included:

    papers
    shortpapers
    srw
    tutorials
    demos
    WMT14
    BioNLP
    BEA9
    ...

Each of these corresponds to a URL in START. For example, the `papers` track corresponds to `http://softconf.com/naacl2015/papers`.
Next, download all the tarballs.
You can use the provided script:

    download-proceedings.sh <conference> acronyms_list.txt

where `<conference>` is replaced by the START name of the conference, found in the URL of its START page (e.g., `naacl2015`).
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
  meta                         Information about the conference
  cdrom/
    semeval-2018.bib           BibTeX file containing entries for all papers
    semeval-2018.pdf           PDF of whole proceedings
    additional/
      semeval001_Software.tgz  Software attached to paper 1001
      semeval003_Dataset.zip   Dataset attached to paper 1003
      semeval003_Note.pdf      Note attached to paper 1003
    bib/
      semeval000.bib           BibTeX entry for the whole proceedings volume
      semeval001.bib           BibTeX entry for paper 1
      semeval002.bib           etc.
    pdf/
      semeval000.pdf           PDF of frontmatter
      semeval001.pdf           PDF for paper 1
      semeval002.pdf           etc.
```

### The "meta" file

Each `meta` file is just a collection of key/value pairs, one per line, with the key and value separated by whitespace.
The lines of interest are (using `SemEval` as an example):

> **abbrev semeval**
> **volume_name 1**
> title 12th International Workshop on Semantic Evaluation
> **booktitle Proceedings of the 12th International Workshop on Semantic Evaluation**
> **short_booktitle Proceedings of SemEval**
> month January
> year 2018
> sig siglex
> chair Marianna Apidianaki
> chair Mohammad, Saif M.
> chair Jonathan May
> chair Ekaterina Shutova
> chair Steven Bethard
> chair Marine Carpuat
> location Berlin, Germany
> publisher Association for Computational Lingustics
```

**Bolded field** are of special importance:

- **abbrev** and **year* are used to determine your collection ID (e.g., `2020.starsem`) in the [Anthology](https://www.aclweb.org/anthology/).
  This is used to form the start of the [Anthology ID](https://www.aclweb.org/anthology/info/ids/) for the papers in your volumes, and their file names.
- **volume_name** is the name of the volume.
  This is concatenated with consecutive paper IDs to form the complete IDs (e.g., `2020.starsem-1.1`)
  Most workshops have just a single volume, in which case you can just number it.
  For larger conferences with multiple volumes, you may wish to choose short, informative names (e.g., "short" for short papers, "long" for long papers, "srw" for papers in a Student Research Workshop, etc.)

For those using START, these should have been set by publications and book chairs (Publication Console -> ACLPUB -> CDROM).

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
