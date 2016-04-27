## Generate Dummy Woodside Data
#
#  Desc: This is the format data is generally provided to us.
#        Sometimes we have a fourth column called confidence. You can add that if you want.


## Required Packages  ####
pacman::p_load(data.table, 
               foreach,
               doSNOW,
               parallel,
               reshape2)



# Variables  ####
tag_name <- paste("tag_",letters,sep="")
cpu_to_use <- detectCores() - 1



# Create timeseries
ts <- seq(as.POSIXct('2016-01-01 00:00:00'), as.POSIXct('2016-03-01 00:00:00'), by = 'min')


# Build Dummy Table in Parallel  ####
cl <- makeCluster(cpu_to_use, type="SOCK")
registerDoSNOW(cl)

data <- foreach(i=tag_name, .combine='rbind', .packages='data.table') %dopar% {
  
  # Randomly generate lower & upper bounds for randomised data
  bounds <- floor(runif(2,min=-1000, max=1000))
  
  rand_data <- runif(length(ts), min = min(bounds), max(bounds))
  
  cbind(as.POSIXct(ts),i,rand_data)
  
}

stopCluster(cl)

data <- data.table(data)
setnames(data, c('time_stamp', 'tag_name', 'value'))


# Apply correct column formats
# There is a way to have the foreach loop output the correct column formats
# but I can't remember what it is right now.
# * hint hint, might be a good exercise
data[,time_stamp:= as.POSIXct(as.numeric(time_stamp), origin='1970-01-01 00:00:00')]
data[,value:=as.numeric(value)]


# Convert to Wide ####

data_wide <- dcast.data.table(data, time_stamp ~ tag_name, value.var='value')


# Output as CSV
write.table(data_wide,
            file ='woodside_examples/Data/dummy_data_continuous.csv',
            sep=',',
            row.names = F,
            quote = F)

