import os
import pyPdf
from tabula import read_pdf_table


pdf_dir = '/Users/yassineltahir/Google Drive/Data Science/Real Estate Analysis'
historical_results = os.listdir(pdf_dir)
test_file = '{0}/{1}'.format(pdf_dir, historical_results[1])



# Due to different formatting between page 1 & 2-n they need to be treated differently
# Additionally when excluding pages from tabula it needs the exact page numbers.
# To do that we first need to know the number of pages present

reader = pyPdf.PdfFileReader(open(test_file))
num_pages = reader.getNumPages() 

# parse 1st page
a = read_pdf_table(test_file, pages = 1, guess=True)
a.shape


left = 11.18
top = 197.14
width = 569.39
height = 573.22

y1 = 225 # 197
x1 = 11
y2 = 770
x2 = 580

coords = [y1, x1, y2, x2]
# top,left,bottom,right)

a = read_pdf_table(test_file, pages = 1, area=coords)
a.shape
a.head(5)




y1 = top
x1 = 11 # left
y2 = top + height
x2 = left + width


b = a[3:a.shape[0]]



df = pd.DataFrame(df.row.str.split(' ',1).tolist(),
                                   columns = ['flips','row'])





# Extract from pages 2-N
pages = range(2,num_pages)
df = read_pdf_table(test_file, pages = pages)








