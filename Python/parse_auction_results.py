#***************************************************************
# Title: Bulk Auction Results Processing
# Desc:  Take all historical results & extract relevant data
#        Includes: City, Date, Price, Basic property info, address
# Author: Yassin Eltahir
# Date: 2016-11-10
#***************************************************************


import os
import pandas as pd
from PyPDF2 import PdfFileReader
from tabula import read_pdf_table




#pdf_dir = '/Users/yassineltahir/Google Drive/Data Science/Real Estate Analysis'
pdf_dir = 'C:/Users/Yassin/Google Drive/Data Science/Real Estate Analysis'
all_files = ['{0}/{1}'.format(pdf_dir, x) for x in os.listdir(pdf_dir)]
test_file = all_files[12]
out_dir = 'C:/Users/Yassin'


# Coordinates for first page table
y1 = 224.4
x1 = 11
y2 = 770
x2 = 580
coords = [y1, x1, y2, x2] 



def main(pdf):

    try:
        # Determine City & Auction Date
        city, date = city_date(pdf)
    
        # Process pages 2-N
        p2n = process_p2n(pdf)
    
        # Process page 1
        p1 = process_p1(pdf, coords, p2n.columns)
        
        # Combine P1 & P2N and add city & date info
        out = p1.append(p2n).reset_index()
        out['city'] = city
        out['date'] = date
    
        print "Processed {}".format(pdf)
        
        return out
        
    except:
        print "Failed {}".format(pdf)
        pass
    
    

# Determine city & auction date
def city_date(filename):
    
    """
    Takes PDF name of known structure & returns the city & auction date
    """
    
    name_parts = filename.split('/')[-1].split('_')
    return name_parts[1], name_parts[0]


# Process Pages 2 - N
def process_p2n(pdf):
    
    # Determine number of pages
    with open(pdf,'rb') as f:
        reader = PdfFileReader(f,'rb')
        num_pages = reader.getNumPages() 
       
    # Extract from pages 2-(N-1)
    return read_pdf_table(pdf, pages = range(2,num_pages+1))

    
    
# Process Page 1, checking that no more than the 1st row is missed
def process_p1(pdf, coordinates, columns):

    p1 = read_pdf_table(pdf, pages = 1, area = coordinates)
    ncol = p1.shape[1]

    # Check that y1 is not too high
    # If it is then move down 1 point
    while ncol != 6:

        coordinates[0] = coordinates[0] + 1
        p1 = read_pdf_table(pdf, pages = 1, area = coordinates)
        ncol = p1.shape[1]


    # Check that y1 is not too low
    # If it is then move up in small steps
    while ncol == 6:
        
        coordinates[0] = coordinates[0] - 0.1
        p1 = read_pdf_table(pdf, pages = 1, area = coordinates)
        ncol = p1.shape[1]

        # Indicates we've gone past the top of the table
        if ncol != 6:
            coordinates[0] = coordinates[0] + 0.1
            p1 = read_pdf_table(pdf, pages = 1, area = coordinates)
        
        
    # TO-DO: read first row of table. Currently skipping
    # The 2nd row is incorrectly read as the header. Make it a row
    tmp = pd.DataFrame([p1.columns.tolist()], columns = p1.columns.tolist())
    p1 = p1.append(tmp)
    p1.columns = columns
    
    return p1
 


if __name__ == "__main__":
    out_all = map(main, all_files)

    
# Create single DF out of all files    
out_all = [x for x in out_all if isinstance(x,pd.DataFrame)]
df = pd.concat(out_all)

# Write output
df.to_csv("{}/historical_auction_results.csv".format(out_dir), sep='|',
          index=False, 
          header = True)
