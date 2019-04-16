#!/usr/bin/env python3

"""Convert BibTeX file(s) to Anthology XML."""

import logging
import re
import collections
import os, os.path
import xml.etree.ElementTree as etree
import latex
import bibtex

def parse_paperid(s):
    m = re.fullmatch(r'([A-Z]\d\d)-(\d+)', s)
    if m is None:
        logging.warning("couldn't decode paper id {}".format(s))
    volume_id = m.group(1)
    if volume_id[0] == 'W':
        volume_no = m.group(2)[:2]
        paper_no = m.group(2)[2:]
    else:
        volume_no = m.group(2)[:1]
        paper_no = m.group(2)[1:]
    return (volume_id, volume_no, paper_no)

# Standard ordering for fields
fields = ['title', 'author', 'editor', 'booktitle',
          'month', 'year', 'address', 'publisher',
          'pages', 'abstract', 'url', 'doi',
          'bibtype', 'bibkey']

def process(bibfilename, paperid):
    logging.info("reading {}".format(bibfilename))
    volume_id, volume_no, paper_no = parse_paperid(paperid)
    if paper_no == '': return # skip the master bib file; we only process the individual files

    bibdata = bibtex.read_bibtex(bibfilename)
    if len(bibdata.entries) != 1:
        logging.error("more than one entry in {}".format(bibfilename))
    bibkey, bibentry = bibdata.entries.items()[0]
    
    paper = etree.Element('paper')
    paper.attrib['id'] = volume_no+paper_no
    for field in list(bibentry.fields) + list(bibentry.persons):
        if field not in fields:
            logging.warning("unknown field {}".format(field))
    for field in fields:
        if field in ['author', 'editor']:
            if field in bibentry.persons:
                for person in bibentry.persons[field]:
                    first_text = latex.latex_to_unicode(' '.join(person.bibtex_first_names))
                    last_text = latex.latex_to_unicode(' '.join(person.prelast_names +
                                                                person.last_names))
                    if person.lineage_names:
                        last_text += ', ' + ' '.join(person.lineage_names)

                    # Don't distinguish between authors that have only a first name
                    # vs. authors that have only a last name; always make it a last name.
                    if last_text.strip() in ['', '-']: # Some START users have '-' for null
                        last_text = first_text
                        first_text = ''
                        
                    node = etree.Element(field)
                    first = etree.Element('first')
                    first.text = first_text
                    node.append(first)
                    last = etree.Element('last')
                    last.text = last_text
                    node.append(last)
                    paper.append(node)
        else:
            if field == 'url':
                if bibentry.type in ['book', 'proceedings']:
                    value = 'http://www.aclweb.org/anthology/{}-{}'.format(volume_id, volume_no)
                else:
                    value = 'http://www.aclweb.org/anthology/{}'.format(paperid)
                if 'url' in bibentry.fields and bibentry.fields['url'] != value:
                    logging.warning("rewriting url {} -> {}".format(bibentry.fields['url'], value))
            elif field in bibentry.fields:
                value = bibentry.fields[field]
            elif field == 'bibtype':
                value = bibentry.type
            elif field == 'bibkey':
                value = bibkey
            else:
                continue

            node = etree.Element(field)
            if field in ['title', 'booktitle']:
                newnode = latex.latex_to_xml(value, fixed_case=True, trivial_math=True)
                node.text = newnode.text
                node.extend(newnode)
            elif field == 'abstract':
                newnode = latex.latex_to_xml(value, trivial_math=True)
                node.text = newnode.text
                node.extend(newnode)
            elif field in ['author', 'editor', 'month', 'year', 'address', 'publisher', 'pages']:
                node.text = latex.latex_to_unicode(value)
            else:
                node.text = value

            paper.append(node)

    return paper

def slugify(s):
    s = s.replace('LaTeX', 'latex')
    s = re.sub('([A-Z])', r'-\1', s)
    s = s.lower()
    s = s.replace('_', '-')
    s = '-'.join(p for p in s.split('-') if p)
    return s
        
if __name__ == "__main__":
    import sys
    import argparse

    if sys.version_info < (3,5):
        sys.stderr.write("Python >=3.5 required.\n")
        sys.exit(1)

    # Set up logging
    logging.basicConfig(format='%(levelname)s:%(location)s %(message)s', level=logging.WARNING)
    location = ""
    def filter(r):
        r.location = location
        return True
    logging.getLogger().addFilter(filter)
    
    ap = argparse.ArgumentParser(description='Convert BibTeX file(s) to Anthology XML.')
    ap.add_argument('indir', help='Directory containing BibTeX files and attachments')
    ap.add_argument('--outfile', '-o', default=sys.stdout.buffer, help='Output XML file (default stdout)')
    args = ap.parse_args()

    bibs = {}
    pdfs = {}
    attachments = collections.defaultdict(list)

    for filename in os.listdir(args.indir):
        parts = filename.split('.')
        paperid = parts[0]
        logging.info(os.path.join(args.indir, filename))
        if len(parts) == 2 and parts[1].lower() == 'pdf':
            pdfs[paperid] = True
        elif len(parts) == 2 and parts[1].lower() == 'bib':
            bibs[paperid] = os.path.join(args.indir, filename)
        elif len(parts) == 3:
            attachments[paperid].append((slugify(parts[1]), filename))
        else:
            logging.warning("unrecognized filename: {}".format(filename))

    volume = etree.Element('volume')
    
    for paperid in sorted(bibs):
        v, _, _ = parse_paperid(paperid)
        if 'id' in volume.attrib:
            if v != volume.attrib['id']:
                logging.error('inconsistent volume id')
                sys.exit(1)
        else:
            volume.attrib['id'] = v
        
        location = paperid
        if paperid not in pdfs: logging.error("missing pdf")
        papernode = process(bibs[paperid], paperid)
        if papernode is None: continue
        for atype, aname in attachments[paperid]:
            # Two types of attachments have their own XML tag;
            # maybe this will change in the future
            if atype in ['software', 'dataset']:
                node = etree.Element(atype)
            else:
                node = etree.Element('attachment')
                node.attrib['type'] = atype
            node.text = aname
            papernode.append(node)
        volume.append(papernode)

    for paper in volume:
        for field in paper:
            field.tail = '\n    '
        if len(paper):
            paper.text = '\n    '
            paper[-1].tail = '\n  '
        paper.tail = '\n\n  '
    if len(volume):
        volume.text = '\n  '
        volume[-1].tail = '\n'
    volume.tail = '\n'

    et = etree.ElementTree(volume)
    et.write(args.outfile, encoding="UTF-8", xml_declaration=True)
