"""
Title:  Get Poliniex Data
Desc:   Basic mucking around to get Poloniex historical & live data
Author: Yassin Eltahir
Date:   2017-07-07
"""

import requests
import time
import datetime
import pandas as pd



def returnChartData(currency_pair, start_date, end_date, period, full = False):
    
    """
    Simple function to return historical chart data from Poloniex
    Poloniex Docs: https://poloniex.com/support/api/
    
    Inputs Are:
    currency_pair: From/To currencies, eg USD/BTC USDT_BTC
    start:         Date as string. Format of YYYY-MM-DD
    end:           Date as string. Format of YYYY-MM-DD
    period:        Candlestick period in seconds (INT)
    full:          Flag indicating if full payload should be returned or not.
                   By default this is off
    """   
    
    # The entry point to Poloniex's public API
    base_url = "https://poloniex.com/public"
        
    
    # Convert dates to unix time
    start_unix = time.mktime(datetime.datetime.strptime(start_date , "%Y-%m-%d").timetuple())
    end_unix = time.mktime(datetime.datetime.strptime(end_date , "%Y-%m-%d").timetuple())
    
    
    # Check if the period provided is valid
    # Valid period values
    valid_periods = [300, 900, 1800, 7200, 14400,86400]
    if period not in valid_periods:
        raise ValueError('Invalid period provided. Ensure it is in {}'.format(valid_periods))
          
    
    # Build Full URL
    full_url = "{}?command=returnChartData&currencyPair={}&start={}&end={}&period={}".format(base_url,currency_pair,start_unix, end_unix,period)
    
    # Send request
    response = requests.request("GET", full_url)

    # By default only return the json response. If desired, return the full object
    if full == True:
        return response
    else:
        return response.json()




# Flatten JSON into dataframe
usd_eth_hist = returnChartData('USDT_ETH','2009-01-01','2017-08-01',14400)
usd_eth_hist = pd.DataFrame(usd_eth_hist)


# Convert UNIX time to human-readable time
usd_eth_hist['date'] = pd.to_datetime(usd_eth_hist['date'],unit='s')






