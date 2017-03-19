#*************************************************************************************
# Title:  Database Connections 
# Desc:   Simple script demonstrating how to connect to a variety of databases
# Author: Yass
# Date:   2017-03-19
#*************************************************************************************



# Generic  ####
# install.packages('RODBC')
library(RODBC)


# Setup connection
odbc_con <- odbcDriverConnect('driver={<DB Driver>};
                              Server=192.168.1.8;
                              Port=5432;
                              Database=house;
                              Uid=<user name>;
                              Pwd=<pw>')

# Simple test query
sqlQuery(odbc_con,'select * from leads' )




# MySQL  ####

# Load Required Packages
install.packages('RMySQL')
library(RMySQL)


# Setup connection
drv <- dbDriver("MySQL")
con <- dbConnect(drv,
                 user = 'root',
                 password = '', 
                 host = 'localhost',
                 dbname='data')


# Simple test query
dbGetQuery(con, "select * from data.idm_admission_source")

names(dt)






# PostgreSQL  ####

# install.packages('RPostgreSQL')
library(RPostgreSQL)


# Setup connection
drv <- dbDriver("PostgreSQL")
pg_con <- dbConnect(drv,
                        host = '192.168.1.8',
                        port = 5432,
                        dbname = 'house',
                        user = '<user name>',
                        password='<pass word>')

# Simple test query
dbGetQuery(pg_con, statement = 'select * from pg_con.leads')


