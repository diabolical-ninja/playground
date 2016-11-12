#***************************************************************
# Title: Bulk Auction Results Processing
# Desc:  Take all historical results & extract relevant data
#        Includes: City, Date, Price, Basic property info, address
# Author: Yassin Eltahir
# Date: 2016-11-10
#***************************************************************


import os
from functools import partial
import pandas as pd
from PyPDF2 import PdfFileReader
from tabula import read_pdf_table




#pdf_dir = '/Users/yassineltahir/Google Drive/Data Science/Real Estate Analysis'
pdf_dir = 'C:/Users/Yassin/Google Drive/Data Science/Real Estate Analysis'
historical_results = os.listdir(pdf_dir)
all_files = ['{0}/{1}'.format(pdf_dir, x) for x in historical_results[0:2]]
test_file = '{0}/{1}'.format(pdf_dir, historical_results[0])

out_dir = 'C:/Users/Yassin'


#a.append(a.columns.tolist(), ignore_index=True)
#
#
#df = pd.DataFrame([a.columns.tolist()], columns = a.columns.tolist())



# parse 1st page

# Define coordinates for the 1st page
y1 = 225 # 197
x1 = 11
y2 = 770
x2 = 580
coords = [y1, x1, y2, x2]


# Determine city & auction date
def city_date(filename):
    
    """
    Takes PDF name of known structure & returns the city & auction date
    """
    
    name_parts = filename.split('/')[-1].split('_')
    return name_parts[1], name_parts[0]







def pdf_parse(pdf,coordinates):
    
    try:
        
        # Due to different formatting between page 1 & 2-n they need to be treated differently
        # Additionally when excluding pages from tabula it needs the exact page numbers.
        # To do that we first need to know the number of pages present
        with open(pdf,'rb') as f:
            reader = PdfFileReader(f,'rb')
            num_pages = reader.getNumPages() 
        
        # Extract from pages 2-(N-1)
        pages = range(2,num_pages+1)
        p2n = read_pdf_table(pdf, pages = pages)
        
        # TO-DO: Add check incase documents format changes
        # Find coordinates where number of columns = 6
        p1 = read_pdf_table(pdf, pages = 1, area=coordinates)
        
        # Currently ignoring the 1st row & reading the 2nd row as the header
        tmp = pd.DataFrame([p1.columns.tolist()], columns = p1.columns.tolist())
        p1 = p1.append(tmp)
        
        # Update columns names to match p2n to enable a clean join
        p1.columns = p2n.columns
        
        # Add location & Auction date
        location, date = city_date(pdf)
        
        out = p1.append(p2n).reset_index()
        out['city'] = location
        out['date'] = date
           
        print 'Parsed {0}'.format(pdf)
        # Join all pages
        return out
    
    except:
        print 'Failed {0}'.format(pdf)
        pass
        
    
    
out = pdf_parse(test_file, coords)    




# parse all files
func = partial(pdf_parse, coordinates = coords)
out_all = map(func, all_files)

# Join all dataframes
df = pd.concat(out_all)

# Write output
df.to_csv("{}/test.csv".format(out_dir), sep='|',
          index=False, 
          header = True)
