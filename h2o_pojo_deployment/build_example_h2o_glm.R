#********************************************************************************
# Title:   H2O Model Build
# Desc:    Builds and saves an H2O model to test POJO deployment options
# Author:  Yassin Eltahir
# Date:    2016-10-11
#********************************************************************************

# Load Required Packages
pacman::p_load('h2o')


# Startup h2o cluster
h2o_con <- h2o.init(nthreads = 2, max_mem_size = '2G')


# Define work directory
wrk_dir <- 'C:/Users/Yassin Eltahir/Documents/Repositories/playground/h2o_pojo_deployment/'


# Source data & prep for modelling
df <- iris
df_h2o <- as.h2o(df)


# Train Model
mod <- h2o.glm(x = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width" ),
               y = "Species", 
               training_frame = df_h2o, 
               family = "multinomial", 
               model_id = 'test_glm')


# Output model 
h2o.download_pojo(model = mod, path = sprintf('%s/',wrk_dir))

# Output some test data
write.table(df[1,], 
            file = sprintf('%s/test_data.csv',wrk_dir), 
            sep = ',', 
            quote = F, 
            row.names = F)