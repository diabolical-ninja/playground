#**************************************************************************#
# Title: iselect_presentation_plots
#
# Desc:  Build and save plots used in presentation 
#
# Author:  2016-05-22  Yassin Eltahir
#
# Steps:  1 - Load Packages & Functions
#         2 - Source & Clean Data
#         3 - Build Plot
#         4 - Save as HTML
#
#**************************************************************************#


# 1 - Load Packages & Functions  ####

pacman::p_load(data.table,
               ggplot2,
               gridExtra)




# 2 - Source and Clean Data  ####

# Source Data
dt <- fread('/Users/yassineltahir/Downloads/analysisProblemForInterview.csv', 
            colClasses=list(character=1:7))

# Clean & format data
dt$Customer_ID <- as.factor(dt$Customer_ID)
dt$result_rank <- as.numeric(dt$result_rank)
dt$provider_Nm <- as.factor(dt$provider_Nm)
dt$product_name <- as.factor(dt$product_name)
dt$dummy_quote_value <- as.numeric(ifelse(dt$dummy_quote_value == 'MISSING', NA, dt$dummy_quote_value))
dt$Sale_made <- as.factor(dt$Sale_made)
dt$Sale_source <- as.factor(dt$Sale_source)
dt[Sale_source==""]$Sale_source <- "No Sale"



# 3 - Result Rank plots  ####


rr_s_ns <- ggplot(dt, aes(x=result_rank)) + 
  geom_density(aes(fill=Sale_made)) + 
  labs(x='Result Rank',
       y='Density',
       title='Sale vs No Sale')

rr_sale_type <- ggplot(dt[Sale_made=='1'], aes(x=result_rank)) + 
  geom_density(aes(fill=Sale_source)) +
  labs(x='Result Rank',
       y='Density',
       title='Comparing sale types')

rr_plots <- list(rr_s_ns, rr_sale_type)

do.call(grid.arrange,c(rr_plots, ncol=2))
