# na2mobi.sh

The script fetches the show notes and cover art, converts into epub, then into
mobi.  Having the url http://now.nashownotes.com always point to the
latest is what really helps makes this work with no user input.  The
title and art work are picked out of the text.

Past episodes can be downloaded by using the episode number as a parameter.
e.g. ./na2mobi.sh 668

You can put the mobi file onto the Kindle and navigate through the 
articles with the right rocker on the 5 way pad.

## Dependencies
- lynx
- pandoc
- calibre
