## Function to Calculate Tax on Salary
# Using tax rates and brackets as of 15/06/2015 for Australia

def tax(income):
    # Assign Tax Rates
    tax_rates =[0,0.19,0.325,0.37,0.45]

    # Calculate Portion in each tax bracket
    bracket = [0]*5
    bracket[0] =max(min(18000, income),0)
    bracket[1] =max(min(37000-18000, income - 18000),0)
    bracket[2] =max(min(80000-37000, income - 37000),0)
    bracket[3] =max(min(180000-80000, income - 80000),0)
    bracket[4] =max(income-180000,0)
    
    taxation=sum([a*b for a,b in zip(tax_rates,bracket)])
    
    print "Tax Amount is $%.2f" % taxation
