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

## Formatting

The final version of your paper should incorporate the comments of the reviewers as well as other changes you see fit to make. 
In addition, be sure to do all of the following:

- Ensure that your paper conforms to the [Formatting Guidelines](formatting.html).
- Include the authors' names and affiliations under the title.
- De-anonymize references to your own work in the body of the paper.
- Ensure that all [tables, graphs, and figures](#graphics) are readable at standard resolutions.
- If appropriate, add an Acknowledgments section for colleagues, reviewers, and grants.
  Do not number the Acknowledgments section.

### Paper Length

For both long and short papers, most *ACL conferences allow one extra page to help address reviewer comments.
So long papers are permitted at most 9 pages of text while short papers may use up to 5 pages of text.
Please use the extra space to help address reviewer comments.
For both long and short papers, there is no page limit for acknowledgements, references or appendices.

If you are unsure about the page limit for the conference, please contact your conference publication chairs.

### File Format

The file must be in Portable Document Format (PDF) on A4 paper, with all fonts embedded.

#### Checking the paper size

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
   
#### Embedding Fonts

  You can check your final PDF with the command `pdffonts mypaper.pdf` and confirm that all the fonts say "yes" under "emb".
  START will not let you upload your final PDF otherwise.
  If you are including graphics with the PDF extension, these files must also have embedded fonts.
  If your paper uses Asian fonts, they must be embedded in the PDF file so that they can be displayed by non-Asian versions of the PDF reader (Asian versions ship with a larger set of default fonts.)

### Graphics

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

### Accessibility

As a central venue of publication for our community, please prioritise the accessibility of your final version.
The Diversity & Inclusion committee for ACL2020 has outlined some tips on how to do this: https://acl2020.org/blog/accessibility-for-camera-ready/

## Submitting the final version in START

You may submit the final version of your paper by navigating to your conference START login (for example, for ACL 2020, it was here: [https://www.softconf.com/acl2020/papers/user].
From there, follow internal links.
You should have received an email with more information about this procedure.

### Metadata

It is very important that your paper's metadata (title, author names, and abstract) is entered correctly.
It is used on the conference website, handbook, mobile app, and the [ACL Anthology](https://www.aclweb.org/anthology/) (and propagates to [DBLP](https://dblp.uni-trier.de), Semantic Scholar, Google Scholar, etc).

![Picture of Softconf user info fields](images/userinfo.png)

Before the metadata is entered, please have all authors ensure that their names are correctly set in [their global START profiles](https://www.softconf.com/l/super/scmd.cgi?ucmd=updateProfile), because <font color="red">authors' names will appear in the conference proceedings as set in their global START profiles</font>.

If your paper's title or other metadata has changed since submission, please edit those metadata fields when you upload the camera-ready version, so that they will appear correctly in the table of contents, author index, conference schedule, etc.

Note: Your conference may or may not allow authors to be added or reordered after submission.
Please check with your conference.

When entering author names, please note carefully the following information:

* Unicode (UTF-8) can be used for accented or special characters.

* Names are **not** written in all caps or all lowercase.

* The "Last Name" is the name(s) by which your paper is to be cited.
  It is usually a family name, even for authors from cultures where the family name is written first.
  If you have only one name, please enter it here.

* The "First Name" is usually a given name or names, including middle names/initials.

The title and abstract should be written using Unicode (UTF-8) with LaTeX commands.
Please try to follow these guidelines:

 - In titles, please capitalize the first word, the first word
   after a colon (`:`), and all other words except the following
   "little words": articles, prepositions, coordinating
   conjunctions, and the infinitive marker "to." This includes
   hyphenated words like `Mixed-Case`.

 - The ACL Anthology automatically detects most proper nouns and noun
   phrases that should always be capitalized. However, if your paper
   title contains a very uncommon proper noun, you can put curly
   braces around its first letter, like this:
   `{T}aumatawhakatangihangakoauauotamateaturipukakapikimaungahoronukupokaiwhenuakitanatahu}`.
 
   Note that these curly braces will _not_ appear in the online
   conference program or proceedings. They will only appear in the
   BibTeX file that others will use to cite your paper.

 - If you need literal curly braces, please escape them like this:
   `\{` `\}`

 - Please don't use any nonstandard LaTeX commands.

 - The title and abstract should not contains footnotes or citations.

 - You can use LaTeX math mode where appropriate: `An $O(n^2)$
   Algorithm for $n$-gram Smoothing`.

 - You can use Unicode (UTF-8) for accented or special characters.

 - Please don't copy-and-paste the abstract from your PDF file, but if
   you must, please be sure to rejoin words broken by hyphenation.

## Copyright

When you submit the paper, you will be asked to sign the [ACL Copyright Transfer Agreement](https://github.com/ACLPUB/blob/master/templates/copyright/acl-copyright-transfer.pdf) on behalf of all authors, either electronically (via the START Conference Manager) or physically.
Authors retain many rights under this agreement and it is appropriate in the vast majority of cases.
Please contact the publication chairs with any concerns regarding copyright.

Before signing this form, please confirm with your co-authors (and, if applicable, your and their employers) that they authorize you to
sign on their behalf.
Please sign your full name (not just your first or last initials).

