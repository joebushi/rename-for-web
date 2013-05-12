#!/bin/bash
# Rename all given files making them web-friendly
# I.e., ascii, lowercase, remove punctuation and replace spaces with dashes


# If the filename already exists we need to generate a unique one
find_unique_name () {
    # Increment for file name
    i=1

    # Find a unique file name by adding an increment
    until [ ! -e "$new_filename" ]
    do
        # TODO: check for an existing number on end of file name
        #       if exists take that and increment

        # Pad numbers under 10
        local padding=""
        if [[ $i -lt 10 ]]; then
            padding=0
        fi

        # File and directories require different replacement patterns
        # Note double quotes required for sed variable interpolation
        if [[ $new_filename =~ \. ]]; then
            new_filename=`sed -E "s/(\.)/-$padding$i\1/" <<< $new_filename`
        else
            new_filename=`sed -E "s/$/-$padding$i/" <<< $new_filename`
        fi

        # Increment the counter
        let i=i+1
    done

    # Okay we have a unique filename
    # Reset the counter
    i=1
    # return
}

# # Alert user as to whether original files should be backed up or not
# alert=$( osascript \
# -e 'tell application "Finder"' \
# -e 'activate' \
# -e 'set dialog_result to display dialog "Do you want to retain original files?" with title "Warning" buttons {"Yes","No"}' \
# -e 'end tell' \
# -e 'get button returned of dialog_result'
# )
# echo $alert

for f in "$@" ; do

    # Break up argument into component parts
    # Automator requires quotations around variable for _dirname_. why?
    file=`basename "$f"`
    dir=`dirname "$f"`/

    #  If file extract extension
    if [[ -f $f ]]; then
        filename="${file%%.*}"
        ext=".${file##*.}"
    else
        # Is a directory
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
    new_filename="$dir$new_filename"


    # Note: Automator requires full path for rename
    #       and quotes around files with spaces
    find_unique_name

    # if [[ $alert == "Yes" ]]; then
        # Use cp and retain original files
        # Add -R option if directory
        if [[ -d "$f" ]]; then
            cmd="cp -R"
        else
            cmd="cp"
        fi
    # else
    #     # Use mv and rename files
    #     cmd="mv"
    # fi
    $cmd "$f" $new_filename

done