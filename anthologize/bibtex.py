import copy
import re
import logging
import pybtex, pybtex.database.input.bibtex
import latex

def fake_parse(s):
    """Regexp-based parsing of possibly malformed BibTeX."""

    # Bugs:
    # - author and editor are stored as fields, not persons.
    
    entries = {}
    fields = {}
    bibtype = bibkey = field = None
    value = ""

    def flush_field():
        nonlocal field, value
        value = value.strip()
        if field is not None:
            # Comma after value optional
            if value.endswith(","): value = value[:-1]
            # Enclosing braces or quotes optional
            value = value.strip()
            if value.startswith("{") and value.endswith("}"): value = value[1:-1]
            elif value.startswith('"') and value.endswith('"'): value = value[1:-1]
            fields[field] = value
        elif value != "":
            logging.warning("discarded text: {}".format(value))
        field = None
        value = ""

    def flush_entry():
        nonlocal fields
        flush_field()
        if len(fields) > 0:
            entry = pybtex.database.Entry(bibtype, fields)
            if bibkey in entries:
                logging.warning("duplicate key: {}".format(bibkey))
            logging.info(str(entry))
            entries[bibkey] = entry
            fields = {}
    
    for line in s.splitlines():
        logging.info(line)
        # Comma after bibkey is optional
        m = re.fullmatch('\s*@([A-Za-z]+)\s*\{\s*([^\s,]*),?\s*', line)
        if m:
            flush_entry() # Closing brace optional
            bibtype = m.group(1)
            bibkey = m.group(2)
            continue
        
        m = re.fullmatch('\s*([A-Za-z]+)\s*=\s*(.*)', line)
        if m:
            flush_field()
            field = m.group(1)
            value = m.group(2)
            continue

        if line.strip() == '}':
            flush_entry()
        else: # Continuation of previous line
            value += '\n' + line

    flush_entry() # Closing brace optional
    return pybtex.database.BibliographyData(entries)

def read_bibtex(bibfilename):
    # Guess encoding. BibTeX is theoretically always in ASCII

    global location
    location = bibfilename
    bibbytes = open(bibfilename, "rb").read()
    bibstring = None
    for encoding in ['ascii', 'utf8', 'cp1252']:
        try:
            bibstring = bibbytes.decode(encoding)
        except UnicodeDecodeError:
            continue
        logging.debug("{}: using {} encoding".format(bibfilename, encoding))
        break
    else:
        logging.warning("couldn't figure out encoding; using ascii with escapes")
        bibstring = bibbytes.decode('ascii', 'backslashreplace')

    if bibstring.startswith('\uFEFF'): bibstring = bibstring[1:] # Unicode BOM
        
    for parser in [lambda s: pybtex.database.parse_string(s, 'bibtex'),
                   fake_parse]:
        try:
            bibdata = parser(bibstring)
        except KeyboardInterrupt:
            raise
        except Exception as e:
            logging.warning("BibTeX parser raised exception '{}'; trying alternate parser".format(e))
        else:
            break
    else:
        logging.error('No more parsers; giving up.')
        return pybtex.database.BibliographyData(dict())

    return bibdata

def find_fixed_case(node, conservative=False):
    def visit(cur, prev):
        if isinstance(cur, str):
            return cur

        if cur[0] == '{':
            if (isinstance(cur[1], str) and cur[1].startswith('\\') or
                isinstance(cur[1], list) and cur[1][0].startswith('\\')):
                # {\...} does *not* protect case
                return # and don't recurse
            elif conservative and isinstance(prev, str) and prev.startswith('\\'):
                # \cmd{...} does protect case, but in practice,
                # this never seems to be the intent.
                pass
            elif conservative and len(cur) == 3 and isinstance(cur[1], list) and cur[1][0] in ['$', r'\)']:
                # Don't mark {$...$}
                pass
            else:
                cur[:] = [r'\fixedcase', cur[:], '']
            
        elif cur[0] in ['$', r'\)']:
            return # Don't recurse into math

        prev = cur[0]
        for child in cur[1:-1]:
            visit(child, prev)
            prev = child

    if conservative:
        # Check if whole field is surrounded with braces
        braces = 0
        text = False
        for child in node[1:-1]:
            if isinstance(child, str) and not child.isspace():
                text = True
            if isinstance(child, list) and child[0] == '{':
                braces += 1
        if not text and braces == 1:
            return node

    node = copy.deepcopy(node)
    visit(node, None)
    return node
