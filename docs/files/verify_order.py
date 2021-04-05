#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Matt Post, May 2014

# Verifies that the ACLPUB order file is computer-readable.
#
# Usage:
#   cat proceedings/order | python verify-order-file.py
#
# Output is detailed information about errors found in the file.

import re
import sys

DAYS = 'Sunday Monday Tuesday Wednesday Thursday Friday Saturday'.split(' ')
MONTHS = 'January February March April May June July August September October November December'.split(' ')

def general_error(lineno, found, expected, eg):
    print 'Format error on line %d' % (lineno)
    print '  ->    found: %s' % found
    print '  -> expected: %s' % expected
    print '     e.g.,', eg

    global error_count
    error_count += 1

def star_error(lineno, line):
    general_error(lineno, line, '* DAY, MONTH DATE, YEAR', 'Thursday, June 26, 2014')

def plus_error(lineno, line):
    general_error(lineno, line, '+ HH:MM--HH:MM EVENT TITLE', '+ 14:00-15:30 {\em A Great Talk.} Ellen Elinksy -- Founder, Acme Inc')

TIMERANGE_REGEXP = r'\d+:\d+--\d+:\d+'
def timerange_error(lineno, line):
    general_error(lineno, line, 'HH:MM--HH:MM (time range, 24-hour format, two dashes)', '12:30--13:30')

def header_error(lineno, line):
    print 'Warning on line %d' % (lineno)
    print '  -> Header lines do not contain time ranges'
    print '  -> Use "=" for headers (display only) and "+" for timed events, e.g.,'
    print '     + 11:00--12:30 Poster Session: Shared Task'
    print '     16  # Paper 1'
    print '     18  # Paper 2'
    print '     ...'

error_count = 0
for i, line in enumerate(sys.stdin, 1):
    line = line.rstrip()
    
    # Skip blanks and comments
    if line == '' or line.startswith('#'):
        continue

    if line.startswith('*'):
        try:
            day, date, year = line.split(', ')
            month, date = date.split(' ')
        except ValueError:
            star_error(i, line)
            continue

        if day[2:] not in DAYS:
            star_error(i, day)
        elif month not in MONTHS:
            star_error(i, month)
        elif not re.match(r'\d+', date) or int(date) < 1 or int(date) > 31:
            star_error(i, date)
        elif year != '2015':
            star_error(i, year)

    elif line.startswith('+') or line.startswith('!'):
        try:
            _, timerange, title = line.split(' ', 2)
            if not re.match(TIMERANGE_REGEXP, timerange):
                timerange_error(i, timerange)
                
        except ValueError:
            plus_error(i, line)

    elif line.startswith('='):
        if re.match(r'.*\d:\d.*', line):
            header_error(i, line)

    elif re.match(r'^\d+ ', line):
        try:
            id, timerange, _ = line.split(' ', 2)
        except ValueError:
            paper_error(i, line)

        if re.match(r'\d', timerange) and not re.match(TIMERANGE_REGEXP, timerange):
            timerange_error(i, timerange)
            
print "Found %d errors" % (error_count)
sys.exit(error_count)
