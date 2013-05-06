#!/bin/bash
# Rename all given files making them web-friendly
# I.e., ascii, lowercase, remove punctuation and dashes for spaces

for f in "$@" ; do

    # Break up argument into component parts
    # Automator requires quotations around variable for _dirname_. why?
    file=`basename "$f"`
    dir=`dirname "$f"`/

    #  if file extract extension
    if [[ -f $f ]]; then
      filename="${file%%.*}"
      ext=".${file##*.}"
    else
      filename=$file
      ext=""
    fi

    # Transliterate the string
    new_filename=`iconv -t ascii//translit//ignore -f utf-8 <<< $filename`

    # Replace punctuation with dash character
    # Remove duplicate dashes
    # And strip dash from end of string
    new_filename=`sed -E -e "s/[ _[:punct:]]/-/g" -e "s/(-+)/-/g" -e "s/-$//g" <<< "$new_filename"`

    # Lowercase string
    new_filename=`tr '[A-Z]' '[a-z]' <<< "$new_filename$ext"`

    # Escape spaces in original filename for rename
    # Automator requires two extra backslashes. why?
    #f=`echo $f | sed -e "s/ /\\\\\ /g"`

    # Automator requires full path for rename
    # TODO: check for duplicate names and increment accordingly
    mv "$f" "$dir$new_filename"

done