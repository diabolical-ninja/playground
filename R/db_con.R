# Connect to database

# Load Required Packages
install.packages('RMySQL')
library(RMySQL)


# Setup connection
drv <- dbDriver("MySQL")
con <- dbConnect(drv, user = 'root', password = '', host = 'localhost', dbname='data')


# Simple test query
dt <- data.table(dbGetQuery(con, "select * from data.idm_admission_source"))

names(dt)
