###########################################################################
# Title: equipment_failure_ADS
#
# Desc: Build ADS for each piece of equipment to model
#       Independent variables are passed through the following transforms:
#         - Rolling Averages
#         - Differences (where applicable)
#         - Normalisation
#
# Author:  2016-03-15  Yassin Eltahir
#
# Functions:  1 - Load Required Packages & Global Variables
#             2 - Source Data
#             3 - Normalise Data
#             4 - Calculate Rolling Averages
#             5 - Calculate Pairwise Differences
#             6 - Create Final ADS & Output
#
###########################################################################


# 1 - Load Required Packages & Global Variables  ####

pacman::p_load(data.table,
               foreach,
               doSNOW,
               parallel,
               RcppRoll)

# Number of Processors to Use
cpu_to_use <- detectCores() - 1

# Possible sensor types
sensors <- c('temp','pressure','vibration','flow')




# 2 - Source Data  ####

# Read in ADS
ads <- fread('woodside_examples/Data/equipment_failure_data.csv')
ads$time_stamp <- as.POSIXct(ads$time_stamp,"%Y-%m-%d %H:%M:%S")


# Read in mapping
mapping <- fread('woodside_examples/Data/equipment_failure_mapping.csv')



# 3 - Normalise Data  ####

# Select data to become basis of normalised ads - don't want to normalise the dependant variables
norm_ads <- ads[,!c('time_stamp',unique(mapping$equipment_id)),with=F]

# Normalise
norm_ads <- norm_ads[,lapply(.SD, function(x){x/median(x,na.rm = T)})]

# Adjust names
setnames(norm_ads, paste(names(norm_ads),"norm",sep="_"))



# 4 - Calculate Rolling Averages  ####

# Select data to become basis of roll-avg ads - don't want the dependant variables
roll_ads <- ads[,!c('time_stamp',unique(mapping$equipment_id)),with=F]

# Define rolling average windows (units=days)
roll_window <- c(1,2,7,14)
roll_window <- roll_window * 1440 # Convert to minutes


# Setup Parallel Cluster
cl <- makeCluster(cpu_to_use, type="SOCK")
registerDoSNOW(cl)

# Calculate rolling averages
roll_ads_tmp <- foreach(i=roll_window, .combine = 'cbind',.packages = c('data.table','RcppRoll')) %dopar% {
  
  # for window size i
  tmp <- roll_ads[,lapply(.SD, function(x){
    roll_mean(x,i, fill = F, align = 'right', na.rm = T)}
  )]
  
  # Adjust names
  setnames(tmp, paste(names(tmp),i,"day_roll_avg",sep="_"))
  
}

stopCluster(cl)




# 5 - Calculate Pairwise Differences  ####

# Setup Progress bar
pb <- txtProgressBar(min = 0, max = length(unique(mapping$equipment_id)), style = 3)
n <- 1

# Initialise difference ads
diff_ads <- data.table(rows=1:nrow(ads))

# If an equipment has multiple sensors of the same type, calculate the difference of them
for(i in unique(mapping$equipment_id)){
  
  # For each sensor type
  for(j in sensors){
    
    # If multiples of sensor type exist
    if(sum(mapping[equipment_id==i]$variables %like% j) > 1){
      
      # Select corresponding sensor readings
      sub_ads <- ads[,c(mapping[equipment_id==i]$variables[mapping[equipment_id==i]$variables %like% j]),with=F]
      
      # Calculate difference between each pairwise column combination
      tmp_diff_ads <- data.table(data.frame(apply(combn(ncol(sub_ads), 2), 2, function(x) sub_ads[,x[1],with=F] - sub_ads[,x[2],with=F])))
      setnames(tmp_diff_ads, 
               apply(combn(ncol(sub_ads), 2), 2, function(x) paste(names(sub_ads)[x], collapse='_')))
      
      
      # Attach to the equipment difference ads
      diff_ads <- cbind(diff_ads, tmp_diff_ads)
      
    }
    
  }
  
  # Update progress bar
  setTxtProgressBar(pb, n)
  n <- n + 1
}

close(pb)

# Remove intialising column
diff_ads[,rows:=NULL]



# 6 - Create Final ADS & Output  ####

final_ads <- cbind(ads, norm_ads, roll_ads, diff_ads)
  

# Partition into train & test
train_ads <- final_ads[time_stamp < '2016-03-01 00:00:00']
test_ads <- final_ads[time_stamp >= '2016-03-01 00:00:00']
  

# Output ADS's to CSV
write.table(train_ads,
            file ='woodside_examples/Data/equipment_failure_train_ads.csv',
            sep=',',
            row.names = F,
            quote = F)

write.table(test_ads,
            file ='woodside_examples/Data/equipment_failure_test_ads.csv',
            sep=',',
            row.names = F,
            quote = F)
