#!/usr/bin/env python

'''
merge two pdf files by overlaying pages pairwise

usage:   pdfunderneath.py my.pdf underneath.pdf [-o output.pdf]

Creates output.pdf, with each page of my.pdf overlaid on
corresponding page from underneath.pdf.

Uses pdfrw library:
https://github.com/pmaupin/pdfrw

NOTE 1: This program assumes that all pages 
        are the same size.  

'''

import sys
import os

from pdfrw import PdfReader, PdfWriter, PageMerge

argv = sys.argv[1:]

if '-o' in argv:
    outfn = argv[argv.index('-o') + 1]
    del argv[argv.index('-o') + 1]
    del argv[argv.index('-o')]
else:
    outfn = 'output.pdf'

inpfn, underfn = argv
under = PdfReader(underfn)
trailer = PdfReader(inpfn)
for page,upage in zip(trailer.pages,under.pages):
    PageMerge(page).add(upage, prepend=1).render()

# meta data comes from underneath.pdf
trailer.Info.Title = under.Info.Title
trailer.Info.Author = under.Info.Author
trailer.Info.Subject = under.Info.Subject

PdfWriter(outfn, trailer=trailer).write()

