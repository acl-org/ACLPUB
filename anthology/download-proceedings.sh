#!/bin/bash

# Downloads proceedings for all volumes in a conference to a data/ directory.
# Requires a list of the volume names (acronyms) in the conference.
#
# Author: Matt Post <post@cs.jhu.edu>

if [ $# -ne 2 ]; then
    echo "usage: download-proceedings.sh <conference> <acronyms>" 1>&2
    exit 1
fi

conference=$1
acronyms_list=$2

cat $acronyms_list | while read acronym; do
  if [[ -s data/$acronym/proceedings.tgz ]]; then
    echo "* Already have $acronym, skipping"
    continue
  fi
  url="https://www.softconf.com/$conference/$acronym/pub/aclpub/proceedings.tgz"
  echo "Downloading $url -> data/$acronym"
  [[ ! -d "data/$acronym" ]] && mkdir -p data/$acronym
  (cd data/$acronym
  wget -N --no-check-certificate $url
  tar -zxf proceedings.tgz)
done
