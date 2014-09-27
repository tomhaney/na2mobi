#!/bin/bash
# script depends on lynx, pandoc, and calibre
set -x #echo on
# download the show notes as a text file
lynx -dump http://now.nashownotes.com > na-now.txt
# prevent seperation lines from being converted to headlines later
sed -i 's/          + --------------------------------------------------------------//' na-now.txt
sed -i 's/            -----------------------------------------------//' na-now.txt
sed -i 's/     +  --------/  /' na-now.txt
# remove emphasis with arrow
sed -i 's/  # /  -> /' na-now.txt
# replace new article indicator with a line break followed by a # to make it a level one headline in markdown
sed -i 's/          + /\r\n# /' na-now.txt
# replace leading spaces with blank line for new paragraph
sed -i 's/               o /\n\n/' na-now.txt
# remove leading spaces
sed -i 's/                 //' na-now.txt
# replace new lines
sed -i ':a;N;$!ba;s/\n   /  \n\t/g' na-now.txt
# find the first mention of a jpg or png and remove everthing before the last space on that line
sed -i 's/               o/   /' na-now.txt
ART=$(grep art na-now.txt | grep -E -m 1 'jpg]|png]' | sed 's/.* \[//')
# Remove trailing white space from file name
ART="${ART%"${ART##*[![:space:]]}"}"
# remove trailing square bracket from file name
ART=${ART%?}
# fetch the cover art
wget http://adam.curry.com/enc/${ART}
# convert what is now close enough to markdown into epub
pandoc -f markdown -t epub na-now.txt -o na-now.epub --epub-cover-image=${ART} --preserve-tabs
# get title
T=$(grep -m 1 -i episode na-now.txt)
# convert epub into mobi with kindle.  Navigate through articles with the 5 way pad.  The commands depends on Calibre.
ebook-convert "na-now.epub" "${T//\"/}.mobi" --title="${T}" --authors="Crackpot & Buzzkill"
