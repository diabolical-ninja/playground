'''
Testing out the Google Maps API
'''

# Source Required Libraries
import googlemaps
from datetime import datetime
import pandas as pd


# Source API Key & connect
# Shouldn't be hard coded. Just here for testing
google_key = 'AIzaSyCz99k0qrmN3qc7kL2gI_hViJWOtnm5wnE'
gmaps = googlemaps.Client(key=google_key)


# Define an Address of interest & find its longitude & lattitude
iselect_loc = '294 Bay Rd, Cheltenham VIC 3192'
iselect_encode = gmaps.geocode(iselect_loc)[0]['geometry']['location']




def nearest_feature(address, feature, num_sm,sm_pref, con):
    
    # Get Address Coordinates
    address_coords = con.geocode(address)[0]['geometry']['location']
    
    # Find all places within radius of POI
    places_out = gmaps.places(query = feature
                                , radius = 2000   # Search within 2km. Might change later
                                , location = address_coords)
    
    
    # Extract Feature Name & Coordinates
    nearby = [[x['name'],x['geometry']['location']] for x in places_out['results']]
    nearby_coords = [x[1] for x in nearby]
    
    
    # For each place, calculate the travel time
    transport_methods = ['driving','transit','walking']
    
    travel_times = []
    for mode in transport_methods:
        
        # Get distance to all locations      
        
        dmat = gmaps.distance_matrix(origins = address_coords
                        , destinations = nearby_coords
                        , mode = mode
                        , units = 'metric')
        
        # Extract distance & travel time
        tmp = [[x['distance']['value'],x['duration']['value']] for x in dmat['rows'][0]['elements']]

        # Join Back with Nearby Destinations & add in tranit mode
        tmp = zip(nearby, tmp)
        out = [x[0]+x[1]+[mode] for x in tmp]
        
        # Capture
        travel_times.extend(out)
        
        
    # Identify the N closest (travel time) locations
    travel_times = pd.DataFrame(travel_times)
    travel_times.columns = ('loc_name','coords','distance','duration','mode')
    tmp_small = travel_times.groupby('mode')[sm_pref].nsmallest(num_sm)
    
    return travel_times.ix[tmp_small.index.levels[1]]
        
        
        
#        for dest in nearby:
#            
#            # Get Directions
#            directions = gmaps.directions(origin = address_coords
#                            , destination = dest[1]
#                            , mode = mode
#                            , units = 'metric'
#                            #, arrival_time = 9 # This currently isn't working
#                            )
#            
#            # Extract Travel Time & Distance
#            out = [dest[0]                                          # Feature Name
#                   , mode                                           # Transport Method
#                   , directions[0]['legs'][0]['distance']['text']   # Distance (Km)
#                   , directions[0]['legs'][0]['duration']['text']   # Travel Time
#                   ]
#            
#            
#            '''
#            TO-DO:
#            -For each transport mode, capture the N fastest (time) locations
#            -Return some data structure containing just those locations for that mode
#            
#            Collect all modes & close out fn
#            '''
#            
#            travel_times.append(out)


            
#    return travel_times



times = nearest_feature(iselect_loc, 'supermarket',7,'duration',gmaps)


def nearest_feature(address, feature, num_sm,sm_pref, con):


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
dests = [x[1] for x in nearby]


dmat = gmaps.distance_matrix(origins = [loc_encode[0]['geometry']['location']]
                    , destinations = dests
                    , mode = 'transit')





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