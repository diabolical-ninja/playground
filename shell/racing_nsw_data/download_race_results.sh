#!/bin/bash/

# Download all races from 2014/2015/2016 Seasons from Racing NSW


# Download Location
cd "Google Drive/Betting Research/Data/race_results/"


# For all generated download strings, attempt to download race results
while read p; do
  curl -O 'http://old.racingnsw.com.au/Site/_content/racebooks/'$p'0.csv'
  curl -O 'http://old.racingnsw.com.au/Site/_content/racebooks/'$p'1.csv'
done <download_strings.txt

echo
echo Downloads complete