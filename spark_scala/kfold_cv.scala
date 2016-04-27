// Required Libraries
import org.apache.spark.ml.evaluation.RegressionEvaluator



// Partition data into n equal parts

val n_splits = 4



// Create Partitions
def partitions (partitions: Int, df:org.apache.spark.sql.DataFrame) : Array[org.apache.spark.sql.DataFrame] ={

	// Calculate Partition Size
	val tmp = (df.count()/partitions.toDouble)/df.count()
	val size = Math.floor(tmp*10)/10
	
	// Generate Array of Splits
	val split_arry = Array.fill(partitions)(size)

	// Output array of DFs of nrow = n
	df.randomSplit(split_arry)
	
}


// Apply Function
val n_splits = 4
val partitions_test = partitions(n_splits,mod_dat)


// Initialise R2 Output Array
val rmse = new Array[Double](n_splits)

// RMSE Evalutator
val evaluator = new RegressionEvaluator()
  .setLabelCol("label")
  .setPredictionCol("prediction")
  .setMetricName("rmse")

// Calculate & Assess linear model for each fold
for(i <- 0 to (n_splits - 1)){

	// Extract data where k != n
	val fold_dat = sql("""
			select a.*
			from mod_dat a
			join partitions_test($i) b
			where a.* != b.* """)
			
	// Fit Model
	val mod = lr.fit(fold_dat)
	
	// Score on holdout data
	val predictions = mod.transform(partitions_test(i))
	
	// Calculate RMSE
	rmse(i) = evaluator.evaluate(predictions)

	
	
	
}

