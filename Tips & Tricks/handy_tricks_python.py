# Column wise binarising (useful for large data sets)

import pandas as pd

def column_binariser(df, columns):
    catlist = []

    for i in columns:
        catlist.append(pd.get_dummies(data=df[i], prefix=str(i)))

    dfbin = pd.concat(catlist, axis=1)
    
    dfrem = df.drop(columns, axis=1)

    dfcon = pd.concat([dfbin, dfrem], axis=1)        
    
    return dfcon

	
	
	
# ODBC Connection & Query
cnxn = pyodbc.connect("DRIVER={SQL SERVER};SERVER=<server name>")
df = pd.read_sql(con = cnxn, sql = "<SQL Query>")