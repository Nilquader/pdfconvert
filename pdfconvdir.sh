IFS="$(printf '\n\t')"   # Remove space.

mkdir cut

#  Correct glob use:
#  Always use for-loop, prefix glob, check if exists file.
for file in ./* ; do         # Use ./* ... NEVER bare *
  if [ -e "$file" ] ; then   # Check whether file exists.
    if [ -f "$file" ] ; then # regular file? 
      len=${#file}
      ext=${file:$len-4:4}
      if [ "$ext" == ".pdf" ]; then
        echo "pdf file: $file"
        /home/johannes/Schreibtisch/pdfconvert.sh "$file"
        file_only=${file##*/}
        len=${#file_only}
        noext=${file:0:$len-9}
        mv "$file.final.pdf" "cut/$file_only"
      fi
    fi
  fi
done

# This example taken from David Wheeler's site, with permission.



