# Generating proceedings for the ACL Anthology

The ACL Anthology requires a particular file layout in order to ingest material (described in Step 3 below).
This README describes how to produce this layout from files exported from STARTv2 or EasyChair, or manually.

## 1. Installation and setup

First, clone the official repository:

    git clone https://github.com/acl-org/ACLPUB

The scripts you will be using are in the subdirectory `ACLPUB/anthologize`.
Below, we assume that you have this directory in your `PATH`; if not, you'll need to provide full pathnames to scripts.

Next, install dependencies.
You'll need Python >=3.5 and the Python packages `latexcodec` and `pybtex`; these can usually be installed by running:

    cd ACLPUB/anthologize
    pip3 install -r requirements.txt

## 2. Assembling the data

If you are using:

- STARTv2: follow the instructions in Step 2(a), then 2(c).
- EasyChair: follow the instructions in Step 2(b), then 2(a) and 2(c).
- Another system: you will need to manually arrange your files into the layout described in Step 2(c) or 3.

### 2a. Instructions for users of Softconf's STARTv2

Create a file called `acronyms_list` that contains a list of the START names of all tracks/workshops associated with the conference, one per line.
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

    download-proceedings.sh <conference> acronyms_list

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
  meta                          Information about the conference
  cdrom/
    SemEval-2018.bib            BibTeX file for proceedings and all papers
    SemEval-2018.pdf            PDF of whole proceedings
    additional/
      SemEval1001_Software.tgz  Software attached to paper 1001
      SemEval1003_Dataset.zip   Dataset attached to paper 1003
      SemEval1003_Note.pdf      Note attached to paper 1003
    bib/
      S18-1000.bib              BibTeX entry for whole proceedings
      S18-1001.bib              BibTeX entry for paper 1001
      S18-1002.bib               etc.
      S18-1003.bib
    pdf/
      S18-1000.pdf              PDF of front matter
      S18-1001.pdf              PDF for paper 1001
      S18-1002.pdf               etc.
      S18-1003.pdf
```

Each `meta` file is just a collection of key/value pairs, one per line, with the key and value separated by whitespace.
The lines of interest are (using `starsem` as an example):

```
abbrev starsem
year 2018
sig siglex
bib_url http://www.aclweb.org/anthology/S18-1%03d
```

These have all been set by publications and book chairs in START (Publication Console -> ACLPUB -> CDROM).
(The abbreviation has deliberately been altered to make it clear that it may be different from both its START name (`SemEval-2018`) and its Anthology ID (`S18-1`).)

If necessary, set the `bib_url` field to the URL given to you by the Anthology director; if you have forgotten it, you can find it [here in the Anthology Ingestion Prefix spreadsheet](https://docs.google.com/spreadsheets/d/166W-eIJX2rzCACbjpQYOaruJda7bTZrY7MBw_oa7B2E/edit?usp=sharing).
(Take the prefix, e.g., W19-80, and append %02d if there are two digits after the hyphen, and %03d if there is just one).

Please do not edit any other fields.

## 3. Generate the Anthology format

From the START format, you can create all the files needed by the Anthology in one step.
Just run:

    make-anthology.sh

This script does two jobs: first, it runs `anthologize.pl` to generate a particular file layout.
Second, it runs `anthology_xml.py`, which converts this layout to an XML format that can be directly ingested by the Anthology.

Steps 3(a) and 3(b) contain more detailed information. If everything goes smoothly, you can skip to Step 4. If you need to make changes, these substeps document the format that you will need to provide to the Anthology.

### 3a. Creating and populating Anthology directories (`anthologize.pl`)

`anthologize.pl` takes the STARTv2 format and reorganizes it in the following manner, consolidating all files under the their ACL IDs:

```
anthology/
  S/
    S18/
      S18-1.bib                 BibTeX file for proceedings and all papers
      S18-1.pdf                 PDF of whole proceedings
      S18-1000.bib              BibTeX entry for whole proceedings
      S18-1000.pdf              PDF of front matter
      S18-1001.bib               etc.
      S18-1001.pdf
      S18-1001.Software.tgz
      S18-1002.bib
      S18-1002.pdf
      S18-1003.bib
      S18-1003.pdf
      S18-1003.Dataset.zip
      S18-1003.Note.pdf
```

If you need to run this step manually, the usage is `anthologize.pl data/<name>/proceedings anthology`, where `<name>` is the START name of the track/workshop to process.

### 3b. Generating the Anthology XML file and layout (`anthology_xml.py`)

Next, `make-anthology.sh` runs `anthology_xml.py` to generate the XML files that the Anthology uses to store all metadata and pointers to papers and their attachments.
One is generated for each venue+year; in our example, there would be

- `anthology/N/N18/N18.xml` for N18-1 and N18-2,
- `anthology/S/S18/S18.xml` for S18-1 and S18-2.

The XML file lists attachments under several different fields; the most general one looks like

```
  <attachment type="software">S18-1001.Software.tgz</attachment>
```

`anthology_xml.py` will generate these fields automatically by looking at the attachment filename.

If you need to run this step manually, the usage is

    anthology_xml.py anthology/<x>/<x><yy> -o anthology/<x>/<x><yy>/<x><yy>.xml

where `<x>` is the one-letter code of the conference (e.g., `N` for NAACL) and `<yy>` is the two-digit year.

## 4. Package and send the Anthology directory

Package up the anthology directory:

    tar czvf <conference>_anthology.tgz anthology

Upload the resulting file (`<conference>_anthology.tgz`) to a file server or cloud storage (e.g. Google Drive) and email the link to it to the Anthology Director. Please do not send the file as an email attachment.

## Notes on supported attachment formats

If attachments, like software and datasets, were submitted in START,
they will be included in the directory produced by
`make-anthology.sh`. If you need to provide additional attachments,
you'll need to add both the attachment file itself as well as an
`<attachment>` tag in the XML file.

The attachment file should have a name of the form `W11-1001.Dataset.zip`, where `W11-1001` is the Anthology paper ID, `Dataset` is the attachment type, and `zip` is a three-letter extension corresponding to the file type.

Current attachment types supported by the Anthology are:

+ Dataset
+ Note
+ Poster
+ Presentation
+ Software
+ Attachment (this is for generic attachments; best to be specific and avoid using this when possible)

Videos are also accepted, but only as valid hyperlinks. 

Each attachment is limited to 30 MB or a valid hyperlink. We prefer
actual attachments over hyperlinks as we can serve them from the
Anthology directly, but understand that some materials cannot fit
within this size.  Hyperlinks may lead either to the actual attachment
or to a valid containing "home page" for the resource. They should be
maintained in perpetuity, but reasonably maintained for at least 5
years.
