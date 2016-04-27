###########################################################################
# Title: equipment_failure_data_generation
#
# Desc: Randomly generate data to simulate equipment operation
#
# Author:  2016-03-15  Yassin Eltahir
#
# Functions:  1 - Load Required Packages & Global Variables
#             2 - Define "dependant" variables
#             3 - Build Dependant Variables
#             4 - Build Final Data & Output
#
###########################################################################


# 1 - Load Required Packages & Global Variables  ####

pacman::p_load(data.table,
               foreach,
               doSNOW,
               parallel)


# Number of Processors to Use
cpu_to_use <- detectCores() - 1

# Data Dates
start <- '2015-01-01 00:00:00'
end <- '2016-06-01 00:00:00'



# 2- Define "dependant" variables  ####


# Equipment_names
equip <- paste0("equip_",letters[1:10])

# Generate timeseries
ts <- seq(as.POSIXct(start), as.POSIXct(end), by = 'min')

# Empty data.table to be populated with failures
dep_ads <- data.table(time_stamp = ts)


# Create binary variable foreach "equipment"
for(i in equip){
  
  # Generate N [1,10] failures of length [2,8] days
  num_failures <- floor(runif(1,1,10))
  failure_length <- round(runif(num_failures,3,10))
  
  # Select random failure times
  failure_times <- round(runif(num_failures,1,length(ts)))
  
  # Initialise equipment with 0's for non-failures
  dep_ads[,c(i):=0]
  
  n <- 1
  # Build failure variable
  for(j in failure_times){
    
    dep_ads[time_stamp %between% c(ts[j],ts[j] + as.difftime(failure_length[n],units='days')),c(i):=1]
    
    n <- n + 1  
  }
  
}



# 3 - Build Dependant Variables  ####


# Assume each equipment can have any or all of the following sensors associated with it
sensors <- c('temp','pressure','vibration','flow')

# Setup table to store "independent" sensor data & equipment to sensor map
ind_ads <- data.table(rows = 1:length(ts))
equip_sensor_map <- NULL


# Setup Parallel Cluster
cl <- makeCluster(cpu_to_use, type="SOCK")
registerDoSNOW(cl)

# Setup Progress bar
pb <- txtProgressBar(min = 0, max = length(equip), style = 3)
n <- 1

# For each piece of equipment generate data for the selected sensors
for(i in equip){
  
  # Select which sensor types to include
  sensor_select <- unique(round(runif(4,1,4)))
  sensor_select <- sensors[sensor_select]
  
  # Have between 1 & 3 of each sensor type
  num_per_type <- round(runif(length(sensor_select),1,3))
  
  sensor_names <- NULL
  
  # Build sensor names
  for(j in 1:length(sensor_select)){
    
    sensor_names <- c(sensor_names,paste(i,sensor_select[j],seq(1,num_per_type[j]),sep="_"))
    
  }
  
  
  # Generate Dummy Data
  data <- foreach(i=sensor_names, .combine='cbind', .packages='data.table') %dopar% {
    
    # Randomly generate lower & upper bounds for randomised data
    bounds <- floor(runif(2,min=-100, max=200))
    
    # Generate Data
    rand_data <- runif(length(ts), min = min(bounds), max(bounds))
    
    return(rand_data)
    
  }
  
  # Format Output
  data <- data.table(data)
  setnames(data, c(sensor_names))
  
  # Append data output
  ind_ads <- cbind(ind_ads, data)
  
  # Map Tags to Equipment
  equip_sensor_map <- rbind(equip_sensor_map,cbind(i,sensor_names))
    
  # Update progress bar
  setTxtProgressBar(pb, n)
  n <- n + 1
  
}

# Remove initialising data
ind_ads[,rows:=NULL]


# Close Parallel Cluster & progress bar
stopCluster(cl)
close(pb)


# Format mapping data
equip_sensor_map <- data.table(equip_sensor_map) 
setnames(equip_sensor_map,c('equipment_id','variables'))



# 4 - Build Final Data & Output  ####

# Join dependent and independent datasets
final_ads <- cbind(dep_ads, ind_ads)


# Output ADS to CSV
write.table(final_ads,
            file ='woodside_examples/Data/equipment_failure_data.csv',
            sep=',',
            row.names = F,
            quote = F)


# Output Mapping to CSV
write.table(equip_sensor_map,
            file ='woodside_examples/Data/equipment_failure_mapping.csv',
            sep=',',
            row.names = F,
            quote = F)
