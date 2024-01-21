#!/bin/bash

for l in "$@"
do
    dest_file="$l.po"
    if [ -f $dest_file ]; then
        msgmerge --update --backup=none $dest_file strings.pot
    else
        msginit --no-translator --input=strings.pot --locale=$l -o $dest_file
    fi
done