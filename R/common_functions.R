###########################################################################
# Title: common_functions
#
# Desc: List of commonly used functions
#
# Author:  2016-03-12  Yassin Eltahir
#
# Functions:  1 - R2
#             2 - RMSE
#             3 - MAPE
#             4 - 
#             5 - 
#
###########################################################################


# 1 - R2 ####

# Calculates R2 using the Pearson Correlation Coefficient Squared

r2 <- function(actual, predicted){
  
  # Ensure Variable inputs are of the same size
  try(if(length(actual) != length(predicted)) stop("Actual & Predicted have differing length."))
  
  # Calculate R2
  tmp <- data.frame(actual = actual, predicted = predicted)
  tmp <- tmp[complete.cases(tmp),]
  return(cor(tmp$actual, tmp$predicted)^2)
  
}


# 2 - RMSE ####

# Calculates the Root Mean Sqaured Error

rmse <- function(actual, predicted){
  
  # Ensure Variable inputs are of the same size
  try(if(length(actual) != length(predicted)) stop("Actual & Predicted have differing length."))

  # Calculate RMSE
  resid <- actual - predicted
  stage <- mean(resid^2, na.rm = T)
  return(sqrt(stage))
  
}


# 3 - MAPE  ####

# Calculates Mean Absolute Percentage Error

mape <- function(actual, predicted){
  
  # Ensure Variable inputs are of the same size
  try(if(length(actual) != length(predicted)) stop("Actual & Predicted have differing length."))
  
  # Calculate MAPE
  stage <- (actual - predicted)/actual
  stage <- abs(stage)
  stage <- mean(stage, na.rm=T)
  
  # Ensure output is not infinity (caused by zero or near-zero actual values)
  return(ifelse(stage==Inf, NA, stage))
  
}