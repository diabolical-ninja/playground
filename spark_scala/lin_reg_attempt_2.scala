// Start Spark
// Run as Administrator
bin\spark-shell --packages com.databricks:spark-csv_2.11:1.3.0


// Load Required Libraries
import org.apache.spark.ml.regression.LinearRegression
import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.mllib.linalg.Vectors



// Import Data (CSV)
val quakes = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("C:/Users/yassin.eltahir/quakes.csv")



// Create Features & Labels
// From what I can tell this format is required by most spark ML functions
val assembler = new VectorAssembler()
  .setInputCols(Array("lat", "long", "depth","stations"))
  .setOutputCol("features")

val stage1 = assembler.transform(quakes)
val stage2 = stage1.withColumnRenamed("mag","label")
val mod_dat = stage2.select("features","label")


// Build Model
val lr = new LinearRegression()
  .setMaxIter(100)
  

// Fit Model
val lrModel = lr.fit(mod_dat)


// Print the coefficients and intercept for linear regression
println(s"Coefficients: ${lrModel.coefficients} Intercept: ${lrModel.intercept}")

// Summarize the model over the training set and print out some metrics
val trainingSummary = lrModel.summary
println(s"numIterations: ${trainingSummary.totalIterations}")
println(s"objectiveHistory: ${trainingSummary.objectiveHistory.toList}")
trainingSummary.residuals.show()
println(s"RMSE: ${trainingSummary.rootMeanSquaredError}")
println(s"r2: ${trainingSummary.r2}")






