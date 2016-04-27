#!/bin/bash

# This scripts counts the number of commas per line for all race information
# It outputs a file containing the unique number of commas for each information type

cd
cd 'Google Drive/Betting Research/Data/race_results/'


# 1. Count Number of Commas

echo "Counting commas..."

# For each directory...
for d in */; do

	# For each file...
	for f in $d*.csv; do
	
		# Count the number of commas
		awk -F "," ' { print NF-1 } ' "$f" >> $d"comma_count.txt"
	done
done

echo "Counting commas...Done"


# 2. Get list of unique counts

echo "Get Unique Count..."

# Test to see if all rows are equal
for d in */*.txt; do

	echo $d >> unique_comma_count.txt
	echo Count   Num_commas >> unique_comma_count.txt
	sort $d | uniq -c >> unique_comma_count.txt
	echo >> unique_comma_count.txt
	
done

echo "Get Unique Count...Done"