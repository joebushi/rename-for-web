#!/usr/bin/env sh
# Rename all given files making them web-friendly
# I.e., ascii, lowercase, remove punctuation and replace spaces with dashes

# If the filename already exists we need to generate a unique one
find_unique_name () {
    # Increment for file name
    local i=1

    # Concat pieces into file path to check for existence
    test_filename="$dir$new_filename$ext"

    # Generate a file name until we find a unique one
    until [[ ! -e $test_filename ]]
    do
        # Extract number from end
        number=`grep -Eo "[0-9]+$" <<< "$new_filename"`

        # Store original number for replace
        local original_number="$number"

        # Strip leading zero to avoid octals
        local number=`sed -E -e 's/^0*//' <<< "$number"`

        # Increment new number
        let new_number=number+1

        # Pad numbers with zero as needed
        # local padding=""
        if [[ $new_number -lt 10 ]]; then
            new_number="0$new_number"
        fi

        # Add separator except when file name is a number
        separator="-"
        if [[ $new_filename =~ ^[0-9]+$ ]]; then
            separator=""
        fi

        # File and directories require different replacement patterns
        # Note double quotes required for sed variable interpolation
        new_filename=`sed -E -e "s/-?$original_number$/$separator$new_number/" -e 's/^0//' <<< $new_filename`

        # Concat pieces into file path to check existence
        test_filename="$dir$new_filename$ext"

        # Increment the counter
        # Store new increment if needed
        if [[ $new_number -gt 0 ]]; then
            let i=new_number
        fi
    done

    # Okay we have a unique file name in $new_filename
    # Reset the counter
    i=1
    return
}


# Alert user as to whether original files should be backed up or not
alert=$( osascript \
-e 'tell application "Finder"' \
-e 'activate' \
-e 'set dialog_result to display dialog "Do you want to retain original files?" with title "Warning" buttons {"Yes","No"}' \
-e 'end tell' \
-e 'get button returned of dialog_result'
)
echo $alert

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
    new_filename=`tr '[A-Z]' '[a-z]' <<< "$new_filename"`
    ext=`tr '[A-Z]' '[a-z]' <<< "$ext"`

    # Check that filename is unique if not generate one
    # Takes $dir, $new_filename and $ext
    find_unique_name

    # Concat full path to file
    # Note: Automator requires full path for rename
    #       and quotes around files with spaces
    new_filename="$dir$new_filename$ext"

    if [[ $alert == "Yes" ]]; then
        # Use cp and retain original files
        # Add -R option if directory
        if [[ -d $f ]]; then
            cmd="cp -R"
        else
            cmd="cp"
        fi
    else
        # Use mv and rename files
        cmd="mv"
    fi
    $cmd "$f" "$new_filename"

done