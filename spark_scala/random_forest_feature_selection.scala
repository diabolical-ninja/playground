// Start Spark
// Run as Administrator
bin\spark-shell --packages com.databricks:spark-csv_2.11:1.3.0


// Load Required Libraries
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.ml.regression.RandomForestRegressor
import org.apache.spark.ml.regression.RandomForestRegressionModel
import scala.util.Sorting


// Import Data (CSV)
val quakes = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("C:/Users/yassin.eltahir/quakes.csv")


// Load model_df function
// Create data frame for model input
 val mod_dat = model_df(quakes, "mag")
 
 
 // Setup Random Forest
 val rf = new RandomForestRegressor()
 
 // Fit Model
val rf_mod = rf.fit(mod_dat)

// Score Predictions on Training data
val predictions = rf_mod.transform(mod_dat)

// Select example rows to display.
predictions.select("prediction", "label", "features").show(5)



// Calculate Variable Importance
val var_imp = rf_mod.featureImportances

// Select top N Variables from var_imp
val temp = rf_mod.featureImportances.toArray.zipWithIndex
scala.util.Sorting.stableSort(temp, (_._1 > _._1) : ((Double,Int),(Double,Int)) => Boolean) 


val mapped_col_names = quakes.columns.filter(_ != "mag").zipWithIndex.map(x => (x._2,x._1)).toMap

val mapped_var_imp = temp.map(x => (x._1, mapped_col_names(x._2)))




// Select Top N variables & Indepedent variables