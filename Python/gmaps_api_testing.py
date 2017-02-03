'''
Testing out the Google Maps API
'''

# Source Required Libraries
import googlemaps
from datetime import datetime


# Source API Key & connect
# Shouldn't be hard coded. Just here for testing
google_key = 'AIzaSyCz99k0qrmN3qc7kL2gI_hViJWOtnm5wnE'
gmaps = googlemaps.Client(key=google_key)


# Define an Address of interest & find its longitude & lattitude
iselect_loc = '294 Bay Rd, Cheltenham VIC 3192'
iselect_encode = gmaps.geocode(iselect_loc)




# Define search parameters
search_loc = 'supermarket'  # What to search for
search_dist = 2000          # Search radius in metres
search_coords = iselect_encode[0]['geometry']['location']

# Find all places within radius of POI
search_results = gmaps.places(query = search_loc
                            , radius = search_dist
                            , location = search_coords)


# For each place, extract the name & location (long/lat)



####################################
####################################
####################################



# -*- coding: utf-8 -*-
"""
Created on Fri Feb 03 14:11:04 2017

@author: yassin.eltahir
"""

import googlemaps
from datetime import datetime
import json

google_key = 'AIzaSyCz99k0qrmN3qc7kL2gI_hViJWOtnm5wnE'



gmaps = googlemaps.Client(key=google_key)

# Geocoding an address
geocode_result = gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')

# Look up an address with reverse geocoding
reverse_geocode_result = gmaps.reverse_geocode((40.714224, -73.961452))

# Request directions via public transit
now = datetime.now()
directions_result = gmaps.directions("Sydney Town Hall",
                                     "Parramatta, NSW",
                                     mode="transit",
                                     departure_time=now)
                                     
                                     
gmaps.places()                                    


iselect_loc = '294 Bay Rd, Cheltenham VIC 3192'
loc_encode = gmaps.geocode(iselect_loc)

places_out = gmaps.places(query = 'supermarket'
#                       , location = ['-37.9557546', '145.036352']
                , location = loc_encode[0]['geometry']['location']
                       , radius = 2000
            #           , language =
            #           , min_price =
            #           , max_price =
            #           , open_now = False
            #           , type = 
            #           , page_token = 
                       )



# For each results, capture the name & coordinates
nearby = [[x['name'],x['geometry']['location']] for x in places_out['results']]




# For each result, find out driving time & distance
results = []
for i in nearby:
    
    # Get Directions
    directions = gmaps.directions(origin = loc_encode[0]['geometry']['location']
                                , destination = i[1]
                                , mode = 'driving')
                                
    # Extract duration & distance
    out = [i[0], 
     directions[0]['legs'][0]['distance'], 
     directions[0]['legs'][0]['duration']]
     
    results.append(out)









[x['name'] for x in places_out['results']]












dirs = gmaps.directions(origin = loc_encode[0]['geometry']['location']
               , destination = nearby[0][1]
               , mode = 'driving')



dirs[0]['legs']

















directions_result = gmaps.directions("Sydney Town Hall",
                                     "Parramatta, NSW",
                                     mode="transit",
                                     departure_time=now)
                                     
                                   











# # Geocoding an address
# geocode_result = gmaps.geocode('1600 Amphitheatre Parkway, Mountain View, CA')

# # Look up an address with reverse geocoding
# reverse_geocode_result = gmaps.reverse_geocode((40.714224, -73.961452))

# # Request directions via public transit
# now = datetime.now()
  
# gmaps.places()                                    