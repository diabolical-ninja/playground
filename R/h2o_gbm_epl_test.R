# Load Packages
library(h2o)
library(data.table)
library(ggplot2)

# Initiate H2O Connection
local_h2o <- h2o.init(nthreads = 4, max_mem_size = '8g')

# Source Data
dt <- fread('/Users/yassineltahir/Downloads/E0.csv')
dt[,Div:=NULL]

# Drop date column
dt[,Date:=NULL]

# Convert non numeric columns to factors
dt <- dt[,lapply(.SD, function(x){if(class(x)=='character'){ as.factor(x)} else x})]


# Convert data into h2o format
dt.hex <- as.h2o(object = dt, conn=h2o.getConnection())

# Run GBM on data
# Target variable will be FTR
gbm_epl <- h2o.gbm(x=names(dt)[names(dt) != 'FTR'],
                   y='FTR',
                   training_frame = dt.hex,
                   ntrees=100)

gbm_epl@model$params


# Predict Results
pred <- as.data.table(as.data.frame(h2o.predict(gbm_epl, newdata=dt.hex)))


var_imp <- as.data.table(as.data.frame(h2o.varimp(gbm_epl)))
