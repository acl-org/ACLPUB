#!/bin/bash

BINDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -e anthology ]; then
  echo "Directory \"anthology\" already exists; please remove or rename it first." 1>&2
  exit 1
fi

for DIR in data/*; do
  [[ -d $DIR/proceedings ]] || continue
  echo "Creating symlinks for $DIR"
  perl $BINDIR/anthologize.pl $DIR/proceedings anthology
done

for DIR in anthology/*/*; do 
  [[ -d $DIR ]] || continue
  echo "Creating Anthology XML for $DIR"
  python3 $BINDIR/anthology_xml.py $DIR -o $DIR/$(basename $DIR).xml
done    
