#!/bin/bash
# pdfconvert.sh 
# converts Din A5 magazines canned as de-stapled A4 pages into correct otientated PDF files
# scan with tittle visible on the lower part of the page, last page of PDF
# Single pages in the middle of the magazine must be scanned first

# set compression as desired
compression=80

# do not edit below this line
inputfile="$1"

pdfpages=`pdfinfo $inputfile | grep Pages: | awk '{print $2}'`
echo "Number of pages: $pdfpages"

# remove old files and create new temporary directory
rm -vrf tempimages
mkdir tempimages


#convert -density 300x300 '/home/johannes/Schreibtisch/2015_04_21_16_08_13.pdf' tempimages/page.pbm
pdfimages $inputfile tempimages/page

# rotate pages
PAGE=0
while [ $PAGE -lt $pdfpages ]; do
  pagezeroed=`printf %03d ${PAGE}`
  odd=$(($PAGE % 2))
  if [ $odd -eq 0 ]; then
    echo "next page is Gerade"
    convert -rotate 270 tempimages/page-$pagezeroed.ppm tempimages/rotated-$pagezeroed.ppm
  else
    echo "next page is Ungerade"
    convert -rotate 90 tempimages/page-$pagezeroed.ppm tempimages/rotated-$pagezeroed.ppm
  fi
  width="`identify -format '%w \n' tempimages/rotated-$pagezeroed.ppm`"
  height="`identify -format '%h \n' tempimages/rotated-$pagezeroed.ppm`"
  echo The counter is $pagezeroed, picture is $width x $height
  let PAGE=PAGE+1 
done

# cut and sort pages
sourcepage=0
while [ $sourcepage -lt $pdfpages ]; do
  pagezeroed=`printf %03d ${sourcepage}`
  odd=$(($sourcepage % 2))
  width="`identify -format '%w \n' tempimages/rotated-$pagezeroed.ppm`"
  height="`identify -format '%h \n' tempimages/rotated-$pagezeroed.ppm`"
  let "halfwidth=$width/2"
  if [ $odd -eq 0 ]; then
    let "leftpage=$pdfpages-$sourcepage-1"
    let "rightpage=$pdfpages+$sourcepage"
    let "singlepage=$pdfpages-$sourcepage"
  else
    let "leftpage=$pdfpages+$sourcepage"
    let "rightpage=$pdfpages-$sourcepage-1"
    let "singlepage=$pdfpages-$sourcepage"
  fi
  leftpagezeroed=`printf %03d ${leftpage}`
  rightpagezeroed=`printf %03d ${rightpage}`
  singlepagezeroed=`printf %03d ${singlepage}`
  if [ $height -lt $width ]; then # normale Doppelseiten
    echo "Source page $sourcepage becomes $leftpagezeroed || $rightpagezeroed"
    convert -crop "$halfwidth"x"$height"+0+0 "tempimages/rotated-$pagezeroed.ppm" "tempimages/cut-$leftpagezeroed.ppm"
    convert -crop "$width"x"$height"+"$halfwidth"+0 "tempimages/rotated-$pagezeroed.ppm" "tempimages/cut-$rightpagezeroed.ppm"
  else # Einzelseiten
    echo "Source page $sourcepage is a single page and becomes $singlepagezeroed"
    cp "tempimages/rotated-$pagezeroed.ppm" "tempimages/cut-$singlepagezeroed.ppm"
  fi
  let sourcepage=sourcepage+1
done

# form new pdf
convert "tempimages/cut-*.ppm" -page A5 -compress jpeg -quality $compression "$inputfile.final.pdf" 

# delete temporary files
rm -r tempimages


