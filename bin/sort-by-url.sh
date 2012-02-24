perl -0777 -ne 'print join("\n\n",sort { url($a) cmp url($b) } split(/\n\n+/))."\n\n"; sub url { $_[0] =~ m/^\s*url\s*=\s*{(.*)}\s*$/m || die; return $1 }' $*
