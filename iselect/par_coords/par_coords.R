#**************************************************************************#
# Title: iselect_parallel_coordinates_plot
#
# Desc:  Plot parallel coordinates using the R wrapper for D3 which 
#        provides interactivity. 
#
# ACK:   Much of this was guided by:
#           - http://stackoverflow.com/questions/23553397/parallel-coordinates-plot-in-rcharts-how-can-i-reproduce-this-chart
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
               rCharts,
               downloader)

# If rCharts aren't already installed, they will be required
# devtools::install_github('ramnathv/rCharts')


# Source par-coords files into a temporary directory
tf <- tempfile(fileext = ".zip")
download(
  url = "https://github.com/rcharts/parcoords/archive/gh-pages.zip",
  tf
)

# unzip to tempdir and set as working directory
td <- tempdir()
unzip(tf, exdir = td)
setwd(file.path(td, "parcoords-gh-pages"))



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



# 3 - Build Plot  ####

# initialize chart and set path to parcoords library
p1 <- rCharts$new()
p1$setLib("libraries/widgets/parcoords")

# add more details to the plot
p1$set(padding = list(top = 50, bottom = 50,
                      left = 50, right = 50),
       width = 1080, height = 600)

# Create output
p1$set(
  data = toJSONArray(dt, json = F), 
  colorby = 'result_rank', 
  range = range(dt$result_rank),
  colors = c('black', 'red')
)
p1



# 4 - Save as HTML  ####

p1$save("/Users/yassineltahir/Repos/playground/iselect/par_coords/par_coords.html")
write.table(dt,"/Users/yassineltahir/Repos/playground/iselect/par_coords/dt.csv", quote = F, row.names = F)