#!/bin/bash
# script depends on lynx, pandoc, and calibre
echo "usage: na2mobi.sh with no parameters will download the latest show notes. Use an episode number to download past show notes, e.g. ./na2mobi.sh 667"
set -x #echo on
if [[ $1 ]]; then
    url=http://$1.nashownotes.com
else 
    url=http://now.nashownotes.com
fi
echo $url

# download the show notes as a text file
lynx -dump $url > na-now-pre.txt
# remove non-printable characters (e.g episode 658) 
tr -cd '\11\12\15\40-\176' < na-now-pre.txt > na-now.txt
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
file=na-now.txt
minimumsize=1000
actualsize=$(wc -c "$file" | cut -f 1 -d ' ')
if [ $actualsize -ge $minimumsize ]; then
    echo size is over $minimumsize bytes
else
    echo size is under $minimumsize bytes
    cat na-now.txt
set +x
    echo "
Try again in a few hours.  A new episode could be uploading now.

"
set -x
    exit
fi
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
