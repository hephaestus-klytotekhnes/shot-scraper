#!/bin/bash

url=$1
output_dir=$2

if [[ ! "$REMOTE_CDP_URL" == wss://* ]]; then
  echo "You need to set the environment variable REMOTE_CDP_URL" >&2
  exit 1
fi

shot-scraper pdf \
  $url \
  -jf readability.js \
  -j "async () => {
  const article = new Readability(document).parse();
  document.body.innerHTML = '<h1>' + article.title + '</h1>' + article.content;
  return article; // only used for title extraction
}" \
  --margin-top=1 --margin-left=1 --margin-right=1 --margin-bottom=1 \
  --save-everything-to $output_dir \
  --wait 10000 \
  --media-screen \
  --format letter \
  --remote-cdp $REMOTE_CDP_URL

  #--media-screen

html_to_print=$(find $output_dir -type f -name '*.html' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2)

#This will run without remote CDP, of course.
#Print an alternate PDF from the (usually good) DOM, because sometimes there's
#rendering issues in main browser page.
shot-scraper pdf $html_to_print \
  --margin-top=1 --margin-left=1 --margin-right=1 --margin-bottom=1 \
  --browser=system-chromium \
  --output ${html_to_print%.html}.alt.pdf
