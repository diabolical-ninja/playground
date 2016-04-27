#!/bin/bash

# Create file name for Racing NSW CSV race results

# Output strings
mysql -u root -e "select concat(date_format(race_schedule.race_date, '%Y%m%d'),race_tracks.web_code)
into outfile '/usr/local/dbout/download_strings.txt'
from horse_racing.race_schedule
left join horse_racing.race_tracks
on race_schedule.venue = race_tracks.track_name"


# Move string to Data folder
mv /usr/local/dbout/download_strings.txt cd "Google Drive/Betting Research/Data/"