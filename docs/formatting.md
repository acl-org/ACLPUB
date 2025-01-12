---
layout: default
title: Paper formatting guidelines
---

The following instructions are for authors of papers submitted for review to ACL conferences (hereafter, "review version") or paper accepted for publication in its proceedings (hereafter, "final version").
All authors are required to adhere to these specifications.

Authors submitting papers for review must also follow: [Submitting your paper for review](review-version.html).

Authors of accepted papers must also follow: [Submitting the final version of your paper](final-version.html).

## Outline
{: .no_toc}

- TOC
{:toc}

## Style Files

*ACL provides style files for LaTeX and Microsoft Word that meet these requirements. They can be found at [https://github.com/acl-org/acl-style-files](https://github.com/acl-org/acl-style-files).

We strongly recommend the use of these style files, which have been appropriately tailored for the *ACL proceedings.

## Paper Length

The conference accepts submissions of long papers and short papers.
Review versions of long papers may have up to eight (8) pages of content plus unlimited pages for references.
Upon acceptance, final versions of long papers will be given one additional page – up to nine (9) pages of content plus unlimited pages for acknowledgments and references – so that reviewers' comments can be taken into account.
Review versions of short papers may have up to four (4) pages of content, plus unlimited pages for references.
Final versions of short papers may have up to five (5) pages, plus unlimited pages for acknowledgments and references.
For both long and short papers, all figures and tables that are part of the main text must fit within these page limits.

The conference encourages submission of appendices and supplementary material, which are not required to fit within these page limits. However, review versions of papers must be self-contained: it is optional for reviewers to look at appendices or supplementary material. Please see [Appendices](#appendices) and [Supplementary Material](#supplementary-material) for more information.

Review versions should not refer, for further detail, to documents, code or data resources that are not available to the reviewers.

Papers that do not conform to these requirements may be rejected without review.

Workshop chairs may have different rules for allowed length and whether appendices or supplementary materials are welcome.
As always, the respective call for papers is the authoritative source.

## File Format

Papers must be in Adobe Portable Document Format (PDF).
Some word processors may generate very large PDF files, where each page is rendered as an image.
Such images may reproduce poorly.
In this case, try alternative ways to obtain the PDF.

Please make sure that your PDF file embeds all necessary fonts, especially for tree diagrams, symbols, and Asian languages.
If your paper uses Asian fonts, they must be embedded in the PDF file so that they can be displayed by non-Asian versions of the PDF reader (Asian versions ship with a larger set of default fonts).
START will not let you upload your final PDF without all fonts embedded.
When you print or create the PDF file, there is usually an option in your printer setup to include none, all or just non-standard fonts.
Please make sure that you select the option of including *all* the fonts.
If your paper includes PDF graphics, these files must also have embedded fonts.

You can check your final PDF with the command `pdffonts mypaper.pdf` and confirm that all the fonts say "yes" under "emb".
You can also test your PDF by viewing it and printing it on a different computer from the one where it was created.

All papers must use **A4 paper format** (21 cm x 29.7 cm).
Papers must not be submitted with any other paper size.
Here are a couple of ways to check this:

- Using pdfinfo: The `pdfinfo` command should include

      Page size:      595.276 x 841.89 pts

  in its output.

- Using Apple's Preview.app:
  Open the PDF, and select Tools &rarr; Show Inspector or type ⌘I.
  It should report a page size of 8.27 x 11.7 inches.

- Using Adobe Acrobat: Open the PDF, navigate to File &rarr; Properties... &rarr; Description.
  The field labeled "Page Size" should read 8.27 × 11.69 in.

If you cannot meet the above requirements, please contact the publication chairs as soon as possible.

## Paper Format

### Layout

All text except for page numbers must fit within the margins.

Review versions should have page numbers, centered in the bottom margin, but **pages should not be numbered in the final version.**

Manuscripts must be set in two columns.
Exceptions to the two-column format include the title, authors' names and complete addresses, which must be centered at the top of the first page, and any full-width figures or tables.

The exact dimensions for a page on A4 paper are:

* Left margin: 2.5 cm
* Right margin: 2.5 cm
* Top margin: 2.5 cm
* Bottom margin: 2.5 cm
* Column width: 7.7 cm
* Column height: 24.7 cm
* Gap between columns: 0.6 cm

In the review version, a ruler (line numbers in the left and right margins of the article) should be printed, so that reviewers may comment on particular lines in the paper.
The ruler should not change the appearance of any other content on the page.
The final version should not contain a ruler.

**Reviewers:**
If the ruler measurements do not align well with lines in the paper, you can also use fractional references (e.g., "line 295.5").

### Fonts

All text (except non-Latin scripts and mathematical formulas) should be set in **Times Roman**.
If Times Roman is unavailable, you may use **Times New Roman** or **Computer Modern Roman.**

The following table specifies what font sizes and styles must be used for each type of text in the manuscript.

| Type of Text          | Font Size | Style |
| --------------------- | --------- | ----- |
| paper title           | 15 pt     | bold  |
| author names          | 12 pt     | bold  |
| author affiliation    | 12 pt     |       |
| the word "Abstract"   | 12 pt     | bold  |
| section titles        | 12 pt     | bold  |
| subsection titles     | 11 pt     | bold  |
| document text         | 11 pt     |       |
| captions              | 10 pt     |       |
| abstract text         | 10 pt     |       |
| bibliography          | 10 pt     |       |
| footnotes             | 9 pt      |       |

For any text or numbers in tables and figures, whenever possible, please use the font size of the document text. As a rule of thumb, any text or numbers should be clearly readable when the paper is printed on A4 paper. Submissions that abuse the font size or spacing for figures/tables may be desk rejected.

### Title and Authors

Center the title and the author name(s) and affiliation(s) across both columns.

Place the title centered at the top of the first page, in 15-point bold.
Long titles should be typed on two lines without a blank line intervening.
Put the title 2.5 cm from the top of the page.
Write the title in [title case](https://apastyle.apa.org/style-grammar-guidelines/capitalization/title-case); do not write the title in all capital letters, except for acronyms and names (e.g., "BLEU") that are normally written in all capitals.

Place the author name(s) and affiliation(s) under the title.
Write authors' full names; do not abbreviate given names to initials, unless they are normally written as initials ("Margaret Mitchell", not "M. Mitchell").
Do not format surnames in all capitals ("Mitchell", not "MITCHELL").

Do not use footnotes for affiliations.
The affiliation should contain the author's complete address, and if possible, an electronic mail address.

The title, author names and addresses should be completely identical to those entered to the paper submission website in order to maintain the consistency of author information among all publications of the conference.
If they are different, the publication chairs may resolve the difference without consulting with you; so it is in your own interest to double-check that the information is consistent.

Start the body of the first page 7.5 cm from the top of the page.
**Even in the review version of the paper, you should maintain space for names and addresses so that they will fit in the final version.**

### Abstract

Type the abstract at the beginning of the first column.
Center the word **Abstract** in 12 point bold above the body of the abstract.
The width of the abstract should be smaller than the
normal column width by 0.6 cm on each side.
The abstract text should be 10 point roman, single-spaced.

The abstract should be a concise summary of the general thesis and conclusions of the paper.
It should be no longer than 200 words.

### Text

Begin typing the main body of the text immediately after the abstract, continuing in two columns.
The text should be 11 point roman, single-spaced.

Indent 0.4 cm when starting a new paragraph, except for the first paragraph in a section.

### Sections

Use numbered sections (Arabic numerals) to facilitate cross references.
Number subsections with the section number and the subsection number separated by a dot, in Arabic numerals, e.g.,

> 1 Introduction

or

> 6.1 File Format

### Footnotes

Put footnotes at the bottom of the page and use 9 point font.
They may be numbered or referred to by asterisks or other symbols.
Footnotes should be separated from the text by a line.

### Figures and tables

Place figures and tables in the paper near where they are first discussed, rather than at the end, if possible.
Wide figures/tables may run across both columns.

Graphics and photos should, if possible, use vector graphic formats (PDF,
EPS), which allow the graphics to scale arbitrarily. Avoid GIF or
JPEG images that are low resolution or highly compressed.

Your paper must look good both when printed (A4 size) and when viewed onscreen as PDF (zoomable to any
size). Please check that graphics and photos
are legible when printed and in a PDF viewer at different resolutions.
At the same time, keep file sizes manageable.

**Accessibility:**
Please prioritise the accessibility of your paper. The Diversity & Inclusion committee for ACL2020 has provided some [tips](https://acl2020.org/blog/accessibility-for-camera-ready/) on how to do this. To accommodate people who are color-blind (as well as those printing with black-and-white printers), grayscale readability is strongly encouraged.
Color is not forbidden, but authors should ensure that tables and figures do not rely solely on color to convey critical distinctions.

**Captions:**
Provide a caption for every figure/table; number each one sequentially in the form:

> Figure 1: Caption of the Figure.

and

> Table 1: Caption of the Table.

Captions should be placed below figures/tables, in 10 point roman type.
Captions that are one line are centered.
Captions longer than one line are left-aligned.

### Hyperlinks

Within-document and external hyperlinks should be dark blue (hex #000099), not underlined or boxed.

### Non-English Text

Text in languages other than English should be accompanied by translations into English, and text in scripts other than Latin should *also* be accompanied by transliterations into Latin script, since not all readers can recognize non-Latin characters easily.

For example, παράδειγμα *paradeigma* ‘example’ is a Greek word, and this is a Greek sentence:

> Αυτό είναι ένα παράδειγμα.  
> auto einai ena paradeigma.  
> ‘This is an example.’

### Citations

Citations within the text appear in parentheses (Gusfield, 1997), or, if the author's name appears in the text itself: Gusfield (1997).
Append lowercase letters to the year in cases of ambiguities.
Cite papers with two authors using both authors' names (Aho and Ullman, 1972), but cite papers with more than two authors by the first author's name and "et al." (Chandra et al., 1981).
Collapse multiple citations into a single pair of parentheses (Gusfield, 1997; Aho and Ullman, 1972).

Refrain from using full citations as sentence constituents.
Instead of

> (Gusfield, 1997) showed that ...  
> In (Gusfield, 1997), ...''

write

> Gusfield (1997) showed that ...  
> In Gusfield (1997), ...

Submissions should accurately reference prior and related work, including code and data.
If a piece of prior work appeared in multiple venues, the version that appeared in a refereed, archival venue should be referenced.
If multiple versions of a piece of prior work exist, the one used by the authors should be referenced.

### Limitations

ACL currently requires all submissions to have a section titled "Limitations", which discusses the limitations of the work. It may *not* contain any additional experiments, figures or analysis. It should be placed after the conclusion section and before references, without page breaks. It does not count towards the page limit. 

### Ethical Considerations

ACL encourages the authors to include an optional section dedicated to discussing the broader impacts and ethical considerations of the submission. Likewise, it may *not* contain any additional experiments, figures or analysis. This section should be placed after the conclusion and before references, without page breaks. Its content does not count towards the page limit.

### Acknowledgments

The acknowledgments should go immediately before the references. Their content does not count towards the page limit.
Do not number the acknowledgments section.
Do not include this section in the review version.

### References

Gather the full set of references together under the unnumbered section heading **References**.
Place the References section before any Appendices.
Arrange the references alphabetically by first author, rather than by order of occurrence in the text.

Provide as complete a citation as possible, using a consistent format, such as the [one for Computational Linguistics](http://cljournal.org/style_guide_refs.html) or the one in the [Publication Manual of the American Psychological Association](https://apastyle.apa.org/products/publication-manual-7th-edition).
Use full names for authors, not just initials.
Authors should not rely on automated citation indices to provide accurate references for prior and related work.

As part of our work to make ACL materials more widely used and cited outside of our discipline, ACL has registered as a CrossRef member, as a registrant of Digital Object Identifiers (DOIs), the standard for registering permanent URNs for referencing scholarly materials.

All references are required to contain DOIs of all cited works when possible, or, as a second resort, links to ACL Anthology pages.
Appropriate records should be found for most materials in the current [ACL Anthology](https://aclanthology.org/).

Example article in a journal:

> Rie Kubota Ando and Tong Zhang. 2005. [A framework for learning predictive structures from multiple tasks and unlabeled data](https://www.jmlr.org/papers/v6/ando05a.html). *Journal of Machine Learning Research*, 6:1817–1853.

Example paper in non-ACL proceedings, with DOI:

> Galen Andrew and Jianfeng Gao. 2007. [Scalable training of L1-regularized log-linear models](https://doi.org/10.1145/1273496.1273501). In *Proceedings of the 24th International Conference on Machine Learning*, pages 33–40.

Example ACL Anthology paper with DOI:

> James Goodman, Andreas Vlachos, and Jason Naradowsky. 2016. [Noise reduction and targeted exploration in imitation learning for Abstract Meaning Representation parsing](http://dx.doi.org/10.18653/v1/P16-1001). In *Proceedings of the 54th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)*, pages 1–45711, Berlin, Germany. Association for Computational Linguistics.

Example ACL Anthology paper without DOI:

> Benjamin Börschinger and Mark Johnson. 2011. [A particle filter algorithm for Bayesian word segmentation](https://aclanthology.org/U11-1004/). In *Proceedings of the Australasian Language Technology Association Workshop 2011*, pages 10–44718, Canberra, Australia.

Example arXiv paper:

> Mohammad Sadegh Rasooli and Joel R. Tetreault. 2015. [Yara parser: A fast and accurate dependency parser](http://arxiv.org/abs/1503.06733). *Computing Research Repository*, arXiv:1503.06733. Version 2.

## Appendices

Appendices are material that can be read, and include lemmas, formulas, proofs, and tables that are not critical to the reading and understanding of the paper. They should conform to the 2-column format. 
Letter them in sequence and provide an informative title:

> Appendix A. Title of Appendix

The appendices come after the references.

Review versions of appendices must follow the same anonymity guidelines as the main paper.

## Supplementary material

Submissions may include non-readable supplementary material used in the work and described in the paper.
Any accompanying software and/or data should include licenses and documentation of research review as appropriate.
Supplementary material may report preprocessing decisions, model parameters, and other details necessary for the replication of the experiments reported in the paper.
Seemingly small preprocessing decisions can sometimes make a large difference in performance, so it is crucial to record such decisions to precisely characterize state-of-the-art methods.

Nonetheless, supplementary material should be supplementary (rather than central) to the paper.
**Submissions that misuse the supplementary material may be rejected without review.**
Supplementary material may include explanations or details of proofs or derivations that do not fit into the paper, lists of features or feature templates, sample inputs and outputs for a system, pseudo-code or source code, and data.
(Source code and data should be separate uploads, rather than part of the paper).

The paper should not rely on the supplementary material: while the paper may refer to and cite the supplementary material and the supplementary material will be available to the reviewers, they will not be asked to review the supplementary material.

Review versions of supplementary material must follow the same anonymity guidelines as the main paper.

## Credits

This document has been adapted from the instructions for earlier ACL and NAACL proceedings, including those for
ACL 2020 by Steven Bethard, Ryan Cotterell and Rui Yan,
ACL 2019 by Douwe Kiela and Ivan Ivan Vulić,
NAACL 2019 by Stephanie Lukin and Alla Roskovskaya,
ACL 2018 by Shay Cohen, Kevin Gimpel, and Wei Lu,
NAACL 2018 by Margaret Mitchell and Stephanie Lukin,
BibTeX suggestions for (NA)ACL 2017/2018 from Jason Eisner,
ACL 2017 by Dan Gildea and Min-Yen Kan,
NAACL 2017 by Margaret Mitchell,
ACL 2012 by Maggie Li and Michael White,
ACL 2010 by Jing-Shin Chang and Philipp Koehn,
ACL 2008 by Johanna D. Moore, Simone Teufel, James Allan, and Sadaoki Furui,
ACL 2005 by Hwee Tou Ng and Kemal Oflazer,
ACL 2002 by Eugene Charniak and Dekang Lin,
and earlier ACL and EACL formats written by several people, including
John Chen, Henry S. Thompson and Donald Walker.
Additional elements were taken from the formatting instructions of the *International Joint Conference on Artificial Intelligence* and the *Conference on Computer Vision and Pattern Recognition*.
