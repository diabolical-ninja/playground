#!/bin/sh

cd racing_dates/

export RBENV_VERSION=jruby-1.7.15

# Extract table data to csv
for f in *.pdf; do
 echo Scraping $f ...
 tabula -p all -f CSV $f -o $f.csv -r
 echo ...Done
done


# Adjust extension name from .pdf to .csv
for f in *.csv; do
 mv $f ${f/pdf.}
done