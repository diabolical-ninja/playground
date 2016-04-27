// Forecasting Test
//
// Script Goals/Test:
//		- Convert input string to timestamp format
//		- Shift dependant variable forward by a given amount for forcasting
//		- Run Desired Model

// Start Spark
// Run as Administrator
bin\spark-shell --packages com.databricks:spark-csv_2.11:1.3.0

// Load Required Libraries
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.ml.regression.RandomForestRegressor
import org.apache.spark.ml.regression.RandomForestRegressionModel
import scala.util.Sorting
import org.apache.spark.ml.feature.RFormula
import org.apache.spark.sql.DataFrameNaFunctions

// Load Data
val dow_jones_index = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/Users/yassineltahir/Google Drive/Data/dow_jones_index.csv")


// Convert timestamp format
val dji = string_to_timestamp(dow_jones_index, "Date", "Timestamp","MM/dd/yyyy")


// Forecast Dependant

// Select dep & timestamp
// Dependant is forecasted 1 day
// "high" is the chosen dependant. As this is just a POC this could be anything.
val temp = dji.select($"high",$"Timestamp" + expr("INTERVAL 1 DAY"))
val temp2 = temp.withColumnRenamed("(Timestamp + interval 1 days)", "Timestamp")
val dep = temp2.withColumnRenamed("high","Dep")

// Join dependant to independant variables
val new_ddf = dji.join(dep, "Timestamp").drop("high")


// Remove rows containing nulls
val df_no_null = dji.na.drop()


// Transform For Model
val formula = new RFormula()
  .setFormula("high ~ . -Timestamp")
  .setFeaturesCol("features")
  .setLabelCol("label")
  
val df_mod = formula.fit(df_no_null).transform(df_no_null)
val mod_dat = df_mod.select($"features", $"label")


// Setup Random Forest
 val rf = new RandomForestRegressor().setNumTrees(100)
 
 // Fit Model
val rf_mod = rf.fit(mod_dat)

// Score Predictions on Training data
val predictions = rf_mod.transform(mod_dat)


