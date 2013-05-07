#!/bin/bash
# Rename all given files making them web-friendly
# I.e., ascii, lowercase, remove punctuation and replace spaces with dashes

# Alert user as to whether original files should be backed up or not
alert=$( osascript \
-e 'tell application "Finder"' \
-e 'activate' \
-e 'set dialog_result to display dialog "Do you want to retain original files?" with title "Warning" buttons {"Yes","No"}' \
-e 'end tell' \
-e 'get button returned of dialog_result'
)
echo $alert

if [[ $alert == "Yes" ]]; then
    # Use cp and retain original files
    cmd="cp"
else
    # Use mv and rename files
    cmd="mv"
fi

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
    new_filename=`sed -E -e "s/[ _[:punct:]]/-/g" -e "s/(-+)/-/g" -e "s/(^-|-$)//g" <<< "$new_filename"`

    # Lowercase string
    new_filename=`tr '[A-Z]' '[a-z]' <<< "$new_filename$ext"`

    # Escape spaces in original filename for rename
    # Automator requires two extra backslashes. why?
    #f=`echo $f | sed -e "s/ /\\\\\ /g"`

    # Automator requires full path for rename
    # TODO: check for duplicate names and increment accordingly
    $cmd "$f" "$dir$new_filename"

done