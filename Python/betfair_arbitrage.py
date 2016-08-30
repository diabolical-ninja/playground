##--------------------------------------------------------------------------------------------------
# Title: betfair_arbitrage.py
#
# Info: Applies arbitrage rules to betfair data from 2014, calculating profit for identified instances
#         - Date source: http://www.nielda.co.uk/betfair/data/
#         - Sport ID's: http://data.betfair.com/sportids.htm
#
# Author:  Yassin Eltahir 2016-08-30
#
# Notes:  - Should really apply rules in parallel, providing sufficient RAM
#         - Some of the event selections are a bit odd. These haven't been scrutinised yet
#         - Looks at best event odds regardless of offer time. This needs to be taken into account
#         - Probably some other stuf that's worth considering
#
##--------------------------------------------------------------------------------------------------

# 1. Environment Setup

# Required Packages
import pandas as pd
import numpy as np
from tqdm import tqdm
import os

# Global Variables
wd = '/Users/yassineltahir/Downloads/other_2014'


# Read in All csv's & join
files = os.listdir(wd)

# Read in Sports IDS
sports_ids = pd.read_csv('/Users/yassineltahir/Downloads/sports_ids.csv')

# Sports to ignore
test_id = sports_ids[sports_ids.SportName=='American Football'].SportID


# 2. Arbitrage Function

# Define function to calculate arbitrage potential
def arb(odds_1, odds_2, bet):
    
    """
    Function to determine if arbitrage opportunity exists.
    If so, place an according bet
    """
    
    pct_1 = (1/float(odds_1))
    pct_2 = (1/float(odds_2))
    
    # If Arbitrage Opportunity then bet
    if pct_1 + pct_2 < 1:
        bet_1 = (pct_1 * bet)/(pct_1 + pct_2)
        bet_2 = (pct_2 * bet)/(pct_1 + pct_2)
        profit = bet/(pct_1 + pct_2) - bet
        
        # Output
        out = [bet_1, bet_2, profit]
    else:
        out = [0,0,0]
    
    return(out)

#arb(3.9, 1.43, 100)



# 3. Calculate Return for 2014 sports

# Initialise Profit
profit = 0

# For each data file, identify 2 outcome events then apply arbitrage rules
for f in tqdm(files):
    
    # Read in File
    df = pd.read_csv((wd+'/%s'%f))
    
    # Identify event_id's where only 2 outcomes are listed
    event_ids = []
    for i in np.unique(df.EVENT_ID):
        
        # Identify number of outcomes
        outcomes = len(np.unique(df[df.EVENT_ID==i].SELECTION_ID))
    
        # If 2 outcomes, then capture event_ID
        if outcomes == 2:
            event_ids.append(i)
   
    # Calculate Arb opportunity for each 2 outcome event
    for event in event_ids:
        
        # Get best odds for each outcome
        event_ods = df[df.EVENT_ID==event].groupby(['SELECTION_ID'])['ODDS'].max()
    
        # Arb & Capture Return
        action = arb(event_ods.values[0], event_ods.values[1], 10)
        profit = profit + action[2]     
        


