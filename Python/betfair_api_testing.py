# Required Libraries
import requests
import json

# Probably shouldn't have this information in the code!!!!
app_key = 'DyYNTcA5fgF5P5mS'
session_token = '/GyHEucIQGINqREWKiJJf4ipkgNzjaPLlY4DSRWyeEw='


# Function to execute Betfair API Operations
def bfGet(api_req, json_req, app_key, session_token, display=False):
    
    """
    Simple function to query the betfair API
    
    Inputs:
        api_req: The API function to call, eg 'listCompetitions' or 'listMarketCatalogue'
        json_req: The requisite function inputs such as filters etc
        app_key: Your unique used app key
        session_token: Your session token, noting that it's not static
        
    Outputs:
        List of request results, with each element a JSON string containing the request result
        
    """
    
    # Build URLs & make API call
    header = { 'X-Application' : app_key, 'X-Authentication' : session_token ,'content-type' : 'application/json' }
    url = "https://api.betfair.com/exchange/betting/rest/v1.0/" + api_req + "/"
    get = requests.post(url, data=json_req, headers=header)
    
    # Format results into list of JSON strings for output
    out = json.loads(get.text)
    
    # If requested, display the query output
    if display == True:
        print json.dumps(out, indent=3)
    
    return out



## GENERAL JSON REQ FORMAT:
"""
{"<Parameter Name 1>":{ "<Type Name 1>":[<entries>], "<Type Name 1>":[<entries>]},
    "<Parameter Name 2>":{ "<Type Name 1>":[<entries>], "<Type Name 2>":[<entries>]}}
""""


# Get Market Count for Events. Can filter on stuff
api_req = "listEventTypes"
json_req='{"filter":{ "eventTypeIds":["2"]}}'
bfGet(api_req, json_req, app_key, session_token)


# Retrieve All Tennis Competitions
json_req = '{"filter":{"eventTypeIds":[2]}}'
api_req = 'listCompetitions'
bfGet(api_req, json_req, app_key, session_token)

"""
US OPEN INFORMATION
 {u'competition': {u'id': u'7743236', u'name': u'US Open 2016'},
  u'competitionRegion': u'USA',
  u'marketCount': 3356}
"""

# List Events for Tennis
# Goal: try to filter events by those related to US Open
# - Should be able to use competition_id
# GOAL ACHIEVED!!!
json_req = '{"filter":{"competitionIds":[7743236]}}'
api_req = 'listEvents'
bfGet(api_req, json_req, app_key, session_token)


# Get Market Information for an Event (using eventIDs from previous call)
# Event ID corresponds to A Zverev v D Evans
json_req = """{"filter":{"eventIds":["27909795"]}, "maxResults":"100", "marketProjection": [
                "COMPETITION",
                "EVENT",
                "EVENT_TYPE",
                "MARKET_START_TIME"
            ]}"""
api_req = 'listMarketCatalogue'
dat = bfGet(api_req, json_req, app_key, session_token)

# Get all marketID's from previous call
market_ids = [str(x['marketId']) for x in dat]

# Format market ID's for json_req
for_insert = '"' + '","'.join(market_ids) + '"'


# Get Market Prices (using marketID from previous call)
api_req = 'listMarketBook'
# json_req = '{"marketIds" : ["1.126548939"], "priceProjection" : ["EX_ALL_OFFERS"]}'
json_req = '{"marketIds":[' + for_insert + '],"priceProjection":{"priceData":["EX_BEST_OFFERS"]}}}'
market_book = bfGet(api_req, json_req, app_key, session_token)


"""
TO-DO:
    - For market odds returned:
        - Identify best odds for each player (both Back & Lay)
        - Pass odds through arbitrage function
    - Sense check odds returned with those manually found through the website
    - Figure out what all the information returned means!!
    - If an arbitrage opportunity is identified & odds match website, place a bet??
    
"""