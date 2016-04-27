###########################################################################
# Title: equipment_failure_model
#
# Desc: Predict likelihood of equipment failure.
#         - Cluster behaviour
#         - Sample dependant to reduce possible class bias
#         - Predict likelihood of failure
#
# Author:  2016-03-16  Yassin Eltahir
#
# Functions:  1 - Load Required Packages & Global Variables
#             2 - Source Data
#             3 - Model Each Piece of Equipment
#             4 - Sample Dependent Variable
#             5 - Cluster Behaviour
#             6 - Build Cluster Variables
#             7 - Build Failure Model
#             8 - Variable Importance
#             9 - Plot Likelihood
#            10 - Calculate AUC & ROC
#            11 - Output Variable Importances
#
###########################################################################


# 1 - Load Required Packages & Global Variables  ####

pacman::p_load(data.table,
               parallel,
               RcppRoll,
               ggplot2,
               h2o,
               ROCR)


# Connect to H2O
h2o_con <- h2o.init(nthreads = -1, max_mem_size = "16G")


# Number of clusters
num_clust <- 10
roll_clust_size <- 7
roll_clust_units <- 'days'

# Percentage time spent as "failure"
fail_perc <- 0.05

# If insufficient failures then define failure window
failure_lead <- 21
failure_lag <- 5
lead_lag_units <- 'days'


# Timeseries interval size (used for calculating rolling average)
ts_step_size <- 'mins'


# Directories
home_dir <- '/Users/yassineltahir/woodside_examples'
dir.create(sprintf('%s/equipment_output',home_dir))  # Create output location


# Empty Table to Store Importances
importances <- NULL




# 2 - Source Data  ####

# Read in ADS
ads <- fread('/Users/yassineltahir/woodside_examples/Data/equipment_failure_train_ads.csv')
ads$time_stamp <- as.POSIXct(ads$time_stamp,"%Y-%m-%d %H:%M:%S")


# Read in mapping
mapping <- fread('/Users/yassineltahir/woodside_examples/Data/equipment_failure_mapping.csv')




# 3 - Model Each Piece of Equipment  ####

# Setup Progress bar
pb <- txtProgressBar(min = 0, max = length(unique(mapping$equipment_id)), style = 3)
n <- 1

for(equipment in unique(mapping$equipment_id)[2:3]){
  
  # Create Results Directory for Variable
  dir.create(sprintf('%s/equipment_output/%s',home_dir,equipment))
  
  
  # Subset data to include only data related to specific piece of equipment
  specific_vars <- names(ads)[names(ads) %like% equipment]
  equip_ads <- ads[,c('time_stamp',specific_vars),with=F]
  
  
  
  # 4 - Sample Dependent Variable  ####
  
  # Want failures to account for n% of observations
  required_obs <- fail_perc*nrow(equip_ads) - sum(equip_ads[,equipment,with=F])
  
  
  # Due to a class imbalance (more 0's/non-failures than 1's/failures), sampling
  # increases the number of failures until they account for at least n% of observations
  if(required_obs > 0){
    
    # Imposing a normal distribution onto the samples for given failure lead & lag window
    probs <- unlist(kernel("daniell", rep(failure_lead*1440/4, 4)))
    probs <- probs[-length(probs)]
    
    # Lead Probabilities
    lead_probs <- probs[order(probs, decreasing = F)]
    
    # Lag Probabilities
    lag_probs <- probs[order(probs, decreasing = T)][1:(failure_lag*1440)]
    probs <- c(lead_probs, lag_probs)
    
    # Get number of failures
    tmp <- unlist(equip_ads[,equipment,with=F])
    tmp <- diff(tmp)
    num_failures <- sum(tmp==1)
    
    # Create sampling distribution for each failure.
    probs <- rep(probs, num_failures)
    
    if(length(equip_ads[get(equipment)==1]$time_stamp) != length(probs)){
      
      probs <- probs[(length(probs)-nrow(equip_ads[get(equipment)==1])+1):length(probs)]
      
    }
    
    # Randomly selects observations to include into samples
    extra_rows <- sample(equip_ads[get(equipment)==1]$time_stamp, required_obs, replace = T, prob = probs)
    
    # Select sampled rows
    equip_ads <- rbind(equip_ads, equip_ads[time_stamp %in% extra_rows])
    
  }
  
  
  
  
  # 5 - Cluster Behaviour  ####
  
  
  # Cluster using k-means
  assign(paste(equipment,"kmeans",sep="_"),
         kmeans(equip_ads[,!c('time_stamp',equipment),with=F], centers = num_clust))
  
  # Extract cluster result timeseries
  clust_ads <- data.table(time_stamp = equip_ads$time_stamp,
                          cluster = get(paste(equipment,"kmeans",sep="_"))$cluster)
  
  
  # Save Cluster Model
  filename <- paste(equipment,"kmeans",sep="_")
  save(list=filename,
       file = sprintf('%s/equipment_output/%s/%s.RData',home_dir,equipment,filename))
  
  
  
  
  # 6 - Build Cluster Variables  ####
  
  
  # Build binary variable for each cluster
  for(i in 1:num_clust){
    
    clust_ads[,c(paste("cluster",i,sep="_")):=ifelse(cluster == i, 1, 0)]
    
  }
  
  # Original cluster list no longer required
  clust_ads[,cluster:=NULL]
  
  
  # Calculate rolling cluster average
  # This generates a proportion of total time spent in cluster N in last X days
  roll_window <- as.numeric(as.difftime(roll_clust_size,units=roll_clust_units), units=ts_step_size)
  clust_names <- names(clust_ads)[names(clust_ads) %like% 'cluster']
  clust_ads[,c(clust_names):=lapply(.SD, function(x){
    roll_mean(x,roll_window, fill = F, align = 'right', na.rm = T)}),
    .SDcols = -'time_stamp']
  
  
  # Create Final ADS ready for modelling
  model_ads <- cbind(equip_ads[,c('time_stamp',equipment),with=F], clust_ads[,!'time_stamp',with=F])
  
  # Convert dependant to factor
  model_ads[,c(equipment):=as.factor(get(equipment))]
  
  
  
  
  # 7 - Build Failure Model  ####
  
  # Convert Data to H2O format
  train_hex <- as.h2o(object = model_ads[,!'time_stamp',with=F], 
                      conn=h2o.getConnection())
  
  #   # Model Using Random Forest
  #   rf <- h2o.randomForest(x = names(model_ads)[!names(model_ads) %in% c('time_stamp',equipment)],
  #                          y = equipment, 
  #                          training_frame = train_hex, 
  #                          ntrees = 500,
  #                          model_id = sprintf('%s_fc_%s_%s',dep_var,forecast,forecast_units))
  #   
  # Model Using a Deep Neural Network
  dnn <- h2o.deeplearning(x = names(model_ads)[!names(model_ads) %in% c('time_stamp',equipment)],
                          y = equipment,
                          training_frame = train_hex,
                          model_id = sprintf("%s_dnn",equipment), 
                          variable_importances = T)
  
  # Save Model
  h2o.saveModel(dnn, path = sprintf('%s/equipment_output/%s/',home_dir,equipment))
  
  
  
  
  # 8 - Variable Importance  ####
  
  # Extract Importance & Order
  var_imp <- dnn@model$variable_importances
  var_imp_ordered <- transform(var_imp, variable = reorder(variable, scaled_importance))
  
  
  # Append top N to Global Importance Table
  tmp <- cbind(equipment, var_imp)
  importances <- rbind(importances, tmp)
  
  
  vi_plot <- ggplot(var_imp_ordered, aes(x=variable, fill = scaled_importance))+
    geom_bar() +
    coord_flip() +
    labs(title = sprintf('%s - Variable Importances \n', equipment),
         x = 'Variable',
         y = ' Scaled Importance') + 
    theme(axis.title = element_text(size = 12),
          title = element_text(size=15, face = 'bold')) 
  
  # Save Results
  filename <- sprintf("%s_variable_importance_plot",equipment)
  ggsave(plot = vi_plot, 
         filename = sprintf('%s/equipment_output/%s/%s.jpg',home_dir,equipment,filename),
         dpi = 300)
  
  
  
  # 9 - Plot Likelihood  ####
  
  
  # Build dataset with Actual and predicted probability of failure
  pred <- as.data.frame(h2o.predict(dnn,train_hex)[,3])
  plot_dt <- data.table(equip_ads[,c('time_stamp',equipment),with=F],
                        pred = pred)
  setnames(plot_dt, c('time_stamp','y','pred'))
  
  
  # Get Start of each failure
  tmp <- unlist(equip_ads[,equipment,with=F])
  tmp <- diff(tmp)
  failure_dates <- equip_ads[which(tmp==1)]$time_stamp
  
  
  # Likelihood plot
  likelihood_plot <- ggplot(plot_dt, aes(x=time_stamp, y=Value)) +
    geom_line(aes(y=y,colour='Failure Window')) +
    geom_line(aes(y=pred,colour='Failure Likelihood')) +
    geom_vline(xintercept=as.numeric(failure_dates), linetype=4, colour='black') +
    labs(title=sprintf('%s Failure Likelihood',equipment),
         x='Timestamp',
         y='Failure Probability') +
    theme(plot.title = element_text(lineheight=1, face="bold", color="black", size=16),
          axis.title.y = element_text(lineheight=1, color="black", size=14),
          axis.title.x = element_text(lineheight=1, color="black", size=14))
  
  
  # Save likelihood Plot
  filename <- sprintf("%s_failure_likelihood_plot",equipment)
  ggsave(plot = likelihood_plot, 
         filename = sprintf('%s/equipment_output/%s/%s.jpg',home_dir,equipment,filename),
         dpi = 300)
  
  
  
  
  # 10 - Calculate AUC & ROC  ####
  
  if(length(unique(plot_dt$y))>1){
    
    # Create prediction object
    predictions=prediction(plot_dt$pred, plot_dt$y, label.ordering = NULL)
    
    # Create the ROC curve
    perf=performance(predictions,"tpr", "fpr")
    
    # Create Dataset for plotting ROC Curves
    roc_dt <- data.table(fpr=data.frame(perf@x.values), tpr=data.frame(perf@y.values))
    setnames(roc_dt,c('fpr','tpr'))
    auc <- performance(predictions, measure="auc")@y.values[[1]]
    
    
    # Plot ROC
    roc_plot <- ggplot(roc_dt, aes(x=fpr, y=tpr)) +
      geom_line(size=1) +
      labs(title=sprintf('%s ROC Curve \nAUC=%0.6s',equipment,auc),
           x='False Positive Rate',
           y='True Positive Rate') +
      geom_abline(intercept=0, slope=1, colour='red', linetype='dashed') +
      theme(plot.title = element_text(lineheight=1, face="bold", color="black", size=16),
            axis.title.y = element_text(lineheight=1, color="black", size=14),
            axis.title.x = element_text(lineheight=1, color="black", size=14))
    
    # Upload ROC Plot
    filename <- sprintf("%s_roc_curve",equipment)
    ggsave(plot = roc_plot, 
           filename = sprintf('%s/equipment_output/%s/%s.jpg',home_dir,equipment,filename),
           dpi = 300)
    
  }
  
  
  # Update progress bar
  setTxtProgressBar(pb, n)
  n <- n + 1
}

close(pb)



# 11 - Output Variable Importances  ####


# Save Variable Importances
importances <- data.table(importances)
write.table(importances,
            file = sprintf('%s/equipment_output/equipment_failure_models_variable_importances.csv',home_dir),
            sep=',',
            row.names = F,
            quote = F)





