#!/bin/bash

# Downloads proceedings for all volumes in a conference to a data/ directory.
# Requires a list of the volume names (acronyms) in the conference.
#
# Author: Matt Post <post@cs.jhu.edu>

if [ $# -ne 1 ]; then
    echo "usage: download-proceedings.sh <start_urls_file>" 1>&2
    exit 1
fi

start_urls_file=$1

cat $start_urls_file | while read url; do
  acronym=$(basename $url)
  if [[ -s data/$acronym/proceedings.tgz ]]; then
    echo "* Already have $acronym, skipping"
    continue
  fi
  url=$url/pub/aclpub/proceedings.tgz
  echo "Downloading $url -> data/$acronym"
  [[ ! -d "data/$acronym" ]] && mkdir -p data/$acronym
  (cd data/$acronym && curl -sS --fail --insecure -O $url && tar -zxf proceedings.tgz)
done
