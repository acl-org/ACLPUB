---
layout: default
title: Final paper submissions
---

Below are the general *ACL policies for preparing the final version of your paper (sometimes still anachronistically called the "camera-ready").

If your question is not answered here, please email the current publications chairs for any questions or clarifications.
We will update this page if new issues arise.

## Outline
{: .no_toc}

- TOC
{:toc}

## General information

### How should the final version differ from the submitted version?

The final version of your paper should incorporate the comments of the reviewers as well as other changes you see fit to make. 
In addition, be sure to do all of the following:

- Ensure that your paper conforms to the provided styles, font and page size.
- Include the authors' names and affiliations under the title.
- De-anonymize references to your own work in the body of the paper.
- If appropriate, add an Acknowledgments section for colleagues, reviewers, and grants.
  Do not number the Acknowledgments section.
- Ensure that all tables, graphs, and figures are readable at standard resolutions.
- If you have supplemental material (including written material, data, and/or code) ensure that all the components are put at the right place
 (see the [Appendices and supplemental material](#where-do-appendices-and-supplemental-material-go) section below for more details).

###  How can I make my final paper version more accessible?

As a central venue of publication for our community, please prioritise the accessibility of your final version.
The Diversity & Inclusion committee for ACL2020 has outlined some tips on how to do this: https://acl2020.org/blog/accessibility-for-camera-ready/

### Where do appendices and supplemental material go?

Supplemental material can be divided into two types: appendices and non-readable supplemental material.

- Appendices are material that can be read, and include lemmas, formulas, proofs, and tables that are not critical to the reading and understanding of the paper. In your final camera-ready paper, appendices come after the references in the main paper and use the same two-column format as the rest of the paper (see the ACL 2020 style files for an example).
  Appendices do not count towards the page limit.
- Non-readable supplemental material (data, software, all other material) is uploaded separately.

### How long can it be?

For both long and short papers, most *ACL conferences allow one extra page to help address reviewer comments.
So long papers are permitted at most 9 pages of text while short papers may use up to 5 pages of text.
Please use the extra space to help address reviewer comments.
For both long and short papers, there is no page limit for acknowledgements, references or appendices.

If you are unsure about the page limit for the conference, please contact your conference publication chairs.

###  What is the format for the camera-ready copy?

The file must be in Portable Document Format (PDF) on A4 paper.
We strongly recommend the use of ACL LaTeX style files (or Microsoft Word Style files) tailored for this year's conference.
You can view the style files and detailed formatting instructions on your conference website.

If you are using LaTeX, please create the PDF file with `pdflatex` or `xelatex`.
This ensures use of the proper fonts and also takes advantage of other PDF features.
You will have the best results using a modern LaTeX distribution, in particular, [TeX Live](http://www.tug.org/texlive/).
Using the geometry package to set the A4 format is recommended.

###  How do I ensure that my file is correctly formatted?

- [Make sure the paper is A4](#format-size)
- [Embed custom fonts](#format-fonts)

   <a name="format-size"></a>
-  **Checking the paper size**.
   Your paper needs to be formatted to A4.
   Here are a couple of ways to check this:
      <ul>
      <li>    
      Using pdfinfo. The `pdfinfo` command should include

            Page size:      595.276 x 841.89 pts

        in its output.
      </li>
      <li>
      Using Apple's Preview.app. Open the PDF, and type &#8984-I. It should report the
        correct page size.

      </li>
      <li>
      Using Adobe Acrobat. Open the PDF, navigate to File, Properties..., Description. The
        field labeled "Page Size" should read 8.27 × 11.69 in.

      </li>
      </ul>

   <a name="format-fonts"></a>
- **Embedding Fonts**.
  You can check your final PDF with the command `pdffonts mypaper.pdf` and confirm that all the fonts say "yes" under "emb".
  START will not let you upload your final PDF otherwise.
  If you are including graphics with the PDF extension, these files must also have embedded fonts.
  If your paper uses Asian fonts, they must be embedded in the PDF file so that they can be displayed by non-Asian versions of the PDF reader (Asian versions ship with a larger set of default fonts.)

###  What if my paper includes graphics?

Remember that you are providing a camera-ready copy.  Thus, artwork
and photos should be included directly in the paper in their final
positions.  Ideally, you should use vector graphic formats (PDF,
EPS), which allow the graphics to scale arbitrarily. Avoid GIF or
JPEG images that are low resolution or highly compressed.

Your paper must look good both when printed (A4 size) and when viewed onscreen as PDF (zoomable to any
size, color okay).  Thus, you may want to use color high-resolution
graphics, allowing onscreen readers to zoom in on a graph and study
it.  However, *please* check that the same graph or photograph
is legible when printed and in a PDF viewer at different resolutions.
Don't go overboard on resolution; keep file sizes manageable.  Note
that vector graphics (e.g., encapsulated PostScript) look good at
any scale and take up little space (unless you are plotting many
thousands of data points).

### How do I record metadata?

It is very important that your paper's metadata (title, author names, and abstract) is entered correctly.
It is used in a number of places, including generating the BibTeX and in creating the paper page, which is crawled by search engines such as DBLP, Semantic Scholar, and Google Scholar.

Please note carefully the following information:

* Unicode (UTF-8) can be used for accented or special characters.

* Names are **not** written in all caps or all lowercase.

* The "Last Name" is the name(s) by which your paper is to be cited.
  It is usually a family name, even for authors from cultures where the family name is written first.
  If you have only one name, please enter it here.

* The "First Name" is usually a given name or names, including middle names/initials.

The metadata should be written using Unicode (UTF-8) with LaTeX commands.
Please try to follow these guidelines:

 - In titles, please capitalize the first word, the first word
   after a colon (`:`), and all other words except the following
   "little words": articles, prepositions, coordinating
   conjunctions, and the infinitive marker "to." This includes
   hyphenated words like `Mixed-Case`.

 - In many bibliography styles, including ACL's, BibTeX lowercases
   the titles of conference papers, and needs to be told which letters
   _not_ to lowercase. This is handled by using curly braces around
   such terms: e.g., `{E}nglish`, `{C}homsky`, `{IBM}`, `{CFG}s`, `{HMM}s`.
   *As of 2020, this protection is now applied automatically* upon
   ingestion to the Anthology by means of heuristics (applied to CamelCase
   and UPPERCASE terms, and after punctuation) and a [very long curated list](https://github.com/acl-org/acl-anthology/blob/master/bin/fixedcase/truelist) of proper nouns and phrases. As such there is *no need
   for you to apply your own case protection*, unless your paper
   title contains a very uncommon proper noun.

   Note that curly braces will _not_ appear in the online conference
   program or proceedings. They will only appear in the BibTeX file
   that others will use to cite your paper.

 - If you need literal curly braces, please escape them like this:
   `\{` `\}`

 - Please don't use any nonstandard LaTeX commands, and there should
   be no `\footnote`s or citations using `\cite` or related commands.

 - You can use LaTeX math mode where appropriate: `An $O(n^2)$
   Algorithm for $n$-gram Smoothing`.

 - You can use Unicode (UTF-8) for accented or special characters.

 - If you copy-and-paste from your PDF file, please be sure to rejoin words broken by hyphenation.

###  What about copyright?

When you submit the paper, you will be asked to sign the [ACL Copyright Transfer Agreement](https://github.com/ACLPUB/blob/master/templates/copyright/acl-copyright-transfer.pdf) on behalf of all authors, either electronically (via the START Conference Manager) or physically.
Authors retain many rights under this agreement and it is appropriate in the vast majority of cases.
Please contact the publication chairs with any concerns regarding copyright.

Before signing this form, please confirm with your co-authors (and, if applicable, your and their employers) that they authorize you to
sign on their behalf.
Please sign your full name (not just your first or last initials).

## START users

### When and where do I send the final version of my paper?

You may submit the final version of your paper by navigating to your conference START login (for example, for ACL 2020, it was here: [https://www.softconf.com/acl2020/papers/user].
From there, follow internal links.
You should have received an email with more information about this procedure.

### How should I enter metadata on the START system?

The metadata (title, author, abstract) that you enter into START is very important, because it is used on the conference website, handbook, mobile app, and the [ACL Anthology](https://www.aclweb.org/anthology/) (and propagates to [DBLP](https://dblp.uni-trier.de), Semantic Scholar, Google Scholar, etc).

![Picture of Softconf user info fields](images/userinfo.png)

Before the metadata is entered, please have all authors ensure that their names are correctly set in [their Global START profiles](https://www.softconf.com/l/super/scmd.cgi?ucmd=updateProfile).

###  What if my paper's title or other metadata has changed since submission?

Then please edit those metadata fields when you upload the camera-ready version, so that they will appear correctly in the table of contents, author index, conference schedule, etc.
<font color="red">Please also note that your name will appear in conference metadata as you have configured it in START</font>, so make sure that it is correct there (e.g., capitalization, full name, etc).
You can change this on [user settings page](https://www.softconf.com/naacl2015/papers/user/scmd.cgi?scmd=updateProfile) of the START conference manager, under "User" &rarr; "Account Information" &rarr; "Update Profile".

Note: Your conference may or may not allow authors to be added or reordered after submission.
Please check with your conference.
