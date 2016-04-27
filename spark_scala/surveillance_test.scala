// Surveillance Test
//
// Script Goals/Test:
//		- Benchmark Spark RF performance for ~10k tags.
//		- Feature select to N variables to simulate requirements of surveillance code

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
// Some csv load function from S3
// file = s3://wel-science-working-dev/Data_Science_Work_Space/wide_ads_benchmarking.csv
// columns to drop = s3://wel-science-working-dev/Data_Science_Work_Space/wide_ads_names.csv
// val df = ....



// Remove rows containing nulls
val df_no_null = df.na.drop()

// Dependant Variable
// This name needs to be checked to ensure it matches the dataframe
val dep = "PGP.117PC033.PIDA.OP"

// Transform For Model
val formula = new RFormula()
  .setFormula("PGP.117PC033.PIDA.OP ~ . -time_stamp")
  .setFeaturesCol("features")
  .setLabelCol("label")
  
val df_mod = formula.fit(df_no_null).transform(df_no_null)
val mod_dat = df_mod.select($"features", $"label")


// Setup Random Forest
 val rf = new RandomForestRegressor()
	.numTrees(500)
 
 // Fit Model
val rf_mod = rf.fit(mod_dat)


// Function to extract top N variables based on importance

def top_n_vars (df: DataFrame, target: String, rf:RandomForestRegressionModel, n: Int) : DataFrame = {
	
	// Sort variables by descreasing importance
	val temp = rf.featureImportances.toArray.zipWithIndex
	scala.util.Sorting.stableSort(temp, (_._1 > _._1) : ((Double,Int),(Double,Int)) => Boolean) 

	// Prep DF names to map with importance
	val mapped_col_names = df.columns.filter(_ != target).zipWithIndex.map(x => (x._2,x._1)).toMap

	// Join column names with importance
	val mapped_var_imp = temp.map(x => (x._1, mapped_col_names(x._2)))

	// Select top N variables
	val top_vars = mapped_var_imp.take(2).map(_._2)

	// Subset DF to include top vars
	val assembler = new VectorAssembler()
		.setInputCols(top_vars)
		.setOutputCol("features")
  
	val stage_features = assembler.transform(df)

	// Rename target column
	val stage_label = stage_features.withColumnRenamed(target, "label")
	  
	// Output only features and label
	return stage_label.select("features","label")	

}



// Select top 20 Variables
val top_20_vars = top_n_vars(df, "PGP.117PC033.PIDA.OP", rf_mod, 20)