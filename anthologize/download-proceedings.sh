#!/bin/bash

if [ $# -ne 2 ]; then
    echo "usage: download-proceedings.sh <conference> <acronyms>" 1>&2
    exit 1
fi

conference=$1
acronyms_list=$2

if [ -e data ]; then
  echo "Directory \"data\" already exists; please remove or rename it first." 1>&2
  exit 1
fi

while read line; do
  set $line    
  acronym=$1
  url="https://www.softconf.com/$conference/$acronym/pub/aclpub/proceedings.tgz"
  echo "Downloading $url -> data/$acronym"
  [[ ! -d "data/$acronym" ]] && mkdir -p data/$acronym
  (cd data/$acronym
  wget -N --no-check-certificate $url
  tar -zxf proceedings.tgz)
done <${acronyms_list}
