#!/bin/bash

# Move to directory containing all data
cd
cd 'Google Drive/Betting Research/Data/race_results/'
#cd 'Google Drive/Betting Research/tmp/'

# Initiate runtime capture
SECONDS=0
echo "Start Data Split...."


#cat 20140701BATH0.csv| while read line; do
cat *.csv| while read line; do
	
	# Extract first element of line
	first_val=$(echo $line | awk -F, '{print $1}')
	
#	echo $first_val
	
	
	# Test if line contains meeting data
	# If true extract date & output to meetings data file
	#if [ $value -eq 1 ]
	if [ "$first_val" == "Meeting" ]
	then
		
		# Assign race date & venue to a variable	
		raceDate=$(echo $line | awk -F, '{print $2}')
		trackCode=$(echo $line | awk -F, '{print $3}')
		
		# Build Meeting ID
		meeting_id=$(printf "%s_%s" $raceDate $trackCode)

			
		# Output Meeting data to meeting file
		meeting_output=$(printf "%s,%s" "$meeting_id" "$line")
		echo $meeting_output >> split_data/meeting_data.csv		

		
	# Transforms for Race Data			
	elif [ "$first_val" == "Race" ]
	then
		
		# Extract Race Number
		raceNumber=$(echo $line | awk -F, '{print $2}')
		
		# Output with meeting_id attached
		race_output=$(printf "%s,%s" "$meeting_id" "$line")
		echo $race_output >> split_data/race_data.csv
		
		
	# Transforms for Horse Data
	elif [ "$first_val" == "Horse" ]
	then 

		# Output Horse data with meeting_id and raceNumber
		horse_output=$(printf "%s,%s,%s" "$meeting_id" "$raceNumber" "$line")
		echo $horse_output >> split_data/horse_data.csv
		
	fi
	
done

echo "Start Data Split....Done"

# Capture Runtime
duration=$SECONDS
echo "Runtime: $(($duration / 60)) minutes and $(($duration % 60)) seconds"