#**************************************************************************#
# Title: industrialised_variable_forecasting
#
# Desc: Builds a Random Forest Predictive Model for a given set of variables.
#       For each variable a user defined number of forecast models are generated.
#
# Author:  2016-03-12  Yassin Eltahir
#
# Steps:  1 - Load Packages
#         2 - Setup Global Variables & Connections
#         3 - Source Data
#         4 - Model Each Variable
#         5 - Feature Select
#         6 - Variable Importance
#         7 - Score Results of Feature Selection
#         8 - Train Final Model
#         9 - Final Results
#        10 - Output Results Tables
#
#**************************************************************************#


# 1 - Load Packages & Functions Script  ####

pacman::p_load(data.table,
               h2o,
               foreach,
               doSNOW,
               parallel,
               ggplot2,
               randomForest)

source('woodside_examples/Code/common_functions.R')



# 2 - Setup Variables & Connections  ####

# Connect to H2O
h2o_con <- h2o.init(nthreads = -1, max_mem_size = "16G")


# Directories
home_dir <- '/Users/yassineltahir/woodside_examples'
dir.create(sprintf('%s/output',home_dir))  # Create output location


# Available System Cores for Parallelisation
cpu_to_use <- detectCores()

# Define Forecasts
forecast_size <- c(0,2,6,12,24)
forecast_units <- 'hours'


# Dependant Variables
all_dep_vars <- c('tag_a',
                  'tag_b',
                  'tag_c')


# Define holdout (testing) period
holdout_date <- as.POSIXct('2016-02-15 00:00:00', "%Y-%m-%d %H:%M:%S")

# Number of variable to keep in the final model
top_n_vars <- 10

# Number of trees
fs_trees <- 200  # Number of trees for feature selection
final_trees <- 500  # Number of trees for final model


# Results Tables
importances <- NULL
accuracy_table <- NULL




# 3 - Source Data  ####

# Read in Data
ads <- fread(sprintf("%s/Data/dummy_data_continuous.csv",home_dir))


# Concert timestamp format
ads[,time_stamp:=as.POSIXct(time_stamp,"%Y-%m-%d %H:%M:%S")]




# 4 - Model Each Variable  ####
for(dep_var in all_dep_vars){
  
  # Create Results Directory for Variable
  dir.create(sprintf('%s/output/%s',home_dir,dep_var))
  
  # Model for each forecast
  for(forecast in forecast_size){
    
    # Create forecast results directory
    dir.create(sprintf('%s/output/%s/fc_%s_%s',home_dir,dep_var,forecast,forecast_units))
    
    
    # Lag Dependant Variable by forecast size
    dep_ads <- ads[,c('time_stamp',dep_var),with=F]
    dep_ads[,time_stamp:=time_stamp - as.difftime(forecast, units=forecast_units)]
    
    
    # Join with Independant Variables
    model_ads <- merge(dep_ads, ads[,!c(dep_var),with=F], by='time_stamp')
    
    
    
    # 5 - Feature Select using RandomForest  ####
    
    # Convert Data to H2O format
    train_hex <- as.h2o(object = model_ads[time_stamp < holdout_date,!'time_stamp',with=F], 
                        conn=h2o.getConnection())
    
    
    # Model Using Random Forest
    rf <- h2o.randomForest(x = names(model_ads)[!names(model_ads) %in% c('time_stamp',dep_var)],
                           y = dep_var, 
                           training_frame = train_hex, 
                           ntrees = fs_trees,
                           model_id = sprintf('%s_fc_%s_%s',dep_var,forecast,forecast_units))
    
    # Save Model
    h2o.saveModel(rf, path = sprintf('%s/output/%s/fc_%s_%s',home_dir,dep_var,forecast,forecast_units))
    
    
    
    
    # 6 - Variable Importance  ####
    
    # Extract Importance & Order
    var_imp <- rf@model$variable_importances
    var_imp_ordered <- transform(var_imp, variable = reorder(variable, scaled_importance))
    
    
    # Append top N to Global Importance Table
    tmp <- cbind(dep_var, forecast, forecast_units, var_imp[1:top_n_vars,])
    importances <- rbind(importances, tmp)
    
    
    vi_plot <- ggplot(var_imp_ordered[1:top_n_vars,], aes(x=variable, fill = scaled_importance))+
      geom_bar() +
      coord_flip() +
      labs(title = sprintf('%s %s %s Forecast - Top %s Important Variables \n',
                           dep_var, forecast, forecast_units, top_n_vars),
           x = 'Variable',
           y = ' Scaled Importance') + 
      theme(axis.title = element_text(size = 12),
            title = element_text(size=15, face = 'bold')) 
    
    # Save Results
    filename <- sprintf('%s_fc_%s_%s_variable_importance_plot',dep_var,forecast,forecast_units)
    ggsave(plot = vi_plot, 
           filename = sprintf('%s/output/%s/fc_%s_%s/%s.jpg',home_dir,dep_var,forecast,forecast_units, filename),
           dpi = 300)
    
    
    
    
    # 7 - Results of Feature Selection  ####
    
    
    # Set partitions
    partitions <- c('Train','Test')
    
    for(i in partitions){
      
      # Score Prediction
      if(i=='Train'){
        
        # Score Model on Training Data
        pred <- as.data.frame(h2o.predict(rf, train_hex))
        plot_dt <- cbind(model_ads[time_stamp < holdout_date,c('time_stamp',dep_var),with=F],pred)
        
      } else{
        
        # Convert Test data to h2o.frame
        test_hex <- as.h2o(object = model_ads[time_stamp >= holdout_date,!'time_stamp',with=F], 
                           conn=h2o.getConnection())
        
        # Score Model on Testing Data
        pred <- as.data.frame(h2o.predict(rf, test_hex))
        plot_dt <- cbind(model_ads[time_stamp >= holdout_date,c('time_stamp',dep_var),with=F],pred)
        
      }
      
      setnames(plot_dt, c('time_stamp', 'actual','predicted'))
      
      
      # Calculate Model Accuracy
      r2_val <- r2(plot_dt$actual, plot_dt$predicted)
      rmse_val <- rmse(plot_dt$actual, plot_dt$predicted)
      mape_val <- mape(plot_dt$actual, plot_dt$predicted)
      
      # Store accuracy
      hold <- cbind(c('r2','rmse','mape'), c(r2_val,rmse_val,mape_val))
      hold <- cbind(dep_var, forecast, forecast_units,i, hold)
      accuracy_table <- rbind(accuracy_table, hold)
      
      
      # Plot timeseries of prediction
      ts_plot <- ggplot(plot_dt, aes(x=time_stamp, frame=time_stamp)) +
        geom_point(aes(y=actual, col='Actual')) +
        geom_point(aes(y=predicted, col='Predicted')) +
        labs(title = sprintf('%s %s %s Forecast - Actual vs Predicted - %s Data \n R2 = %f%%, RMSE = %f, MAPE = %f%%',
                             dep_var, forecast, forecast_units, i, r2_val*100, rmse_val, mape_val*100),
             x = 'Timestamp',
             y = 'Value') + 
        theme(axis.title = element_text(size = 12),
              title = element_text(size=12, face = 'bold')) 
      
      filename <- sprintf('%s_%s_fc_%s_%s_actual_vs_predicted_timeseries_plot',i,dep_var,forecast,forecast_units)
      ggsave(plot = ts_plot, 
             filename = sprintf('%s/output/%s/fc_%s_%s/%s.jpg',home_dir,dep_var,forecast,forecast_units, filename),
             dpi = 300)
    }
    
    
    
    # 8 - Train Final Model ####
    
    
    # Subset data to top N important variables previously identified
    final_var_names <- c('time_stamp',dep_var,
                         as.character(var_imp_ordered$variable[1:10]))
    
    final_ads <- model_ads[,final_var_names,with=F]
    
    
    # Setup parallel cluster
    cl <- makeCluster(cpu_to_use)
    registerDoSNOW(cl)
    
    # Run Random Forest
    rf_final <- foreach(ntree=final_trees, .combine=combine, .packages = c('data.table','randomForest')) %dopar%
      randomForest(as.formula(sprintf('%s ~ . -time_stamp',dep_var)), 
                   data = final_ads, 
                   ntree = ntree)
    
    stopCluster(cl)
    
    # Save Model
    filename <- sprintf('%s_fc_%s_%s_final_rf.RData',dep_var,forecast,forecast_units)
    save(rf_final, file = sprintf('%s/output/%s/fc_%s_%s/%s',home_dir,dep_var,forecast,forecast_units, filename))
    
    
    # 9 - Final Results  ####
    
    i <- 'Final'
    
    # Score Model on Final Data
    pred <- predict(rf_final, final_ads)
    plot_dt <- cbind(final_ads[,c('time_stamp',dep_var),with=F],pred)
    setnames(plot_dt, c('time_stamp', 'actual','predicted'))
    
    
    # Calculate Model Accuracy
    r2_val <- r2(plot_dt$actual, plot_dt$predicted)
    rmse_val <- rmse(plot_dt$actual, plot_dt$predicted)
    mape_val <- mape(plot_dt$actual, plot_dt$predicted)
    
    # Store accuracy
    hold <- cbind(c('r2','rmse','mape'), c(r2_val,rmse_val,mape_val))
    hold <- cbind(dep_var, forecast, forecast_units,i, hold)
    accuracy_table <- rbind(accuracy_table, hold)
    
    
    # Plot timeseries of prediction
    ts_plot <- ggplot(plot_dt, aes(x=time_stamp, frame=time_stamp)) +
      geom_point(aes(y=actual, col='Actual')) +
      geom_point(aes(y=predicted, col='Predicted')) +
      labs(title = sprintf('%s %s %s Forecast - Actual vs Predicted - %s Data \n R2 = %f%%, RMSE = %f, MAPE = %f%%',
                           dep_var, forecast, forecast_units, i, r2_val*100, rmse_val, mape_val*100),
           x = 'Timestamp',
           y = 'Value') + 
      theme(axis.title = element_text(size = 12),
            title = element_text(size=12, face = 'bold')) 
    
    filename <- sprintf('%s_%s_fc_%s_%s_actual_vs_predicted_timeseries_plot',i,dep_var,forecast,forecast_units)
    ggsave(plot = ts_plot, 
           filename = sprintf('%s/output/%s/fc_%s_%s/%s.jpg',home_dir,dep_var,forecast,forecast_units, filename),
           dpi = 300)
  
    }
  
}



# 10 - Output Results Tables  ####


# Neaten Names
importances <- data.table(importances)
setnames(importances, c('variable_name',
                        'forecast_size',
                        'forecast_units',
                        'importance_variables',
                        'relative_importance',
                        'scaled_importance',
                        'percentage'))


accuracy_table <- data.table(accuracy_table)
setnames(accuracy_table, c('variable_name',
                           'forecast_size',
                           'forecast_units',
                           'data_set',
                           'accuracy_metric',
                           'accuracy_value'))


# Output Tables
write.table(importances, 
            file = sprintf('%s/output/importances.csv',home_dir),
            sep = ',',
            quote = F,
            row.names = F)

# Save Importances Table
write.table(accuracy_table, 
            file = sprintf('%s/output/accuracy_table.csv',home_dir),
            sep = ',',
            quote = F,
            row.names = F)
