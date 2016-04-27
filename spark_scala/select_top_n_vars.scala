// Select top N variables from RandomForest variable importance
// To be used as input to another pass of modelling
// 
// Inputs: Dataframe  - Original "wide" dataframe
//		   Target Variable - Dependant Variable
//		   rf - Random Forest Regression Model
//		   n - Number of independant variables to use
//
// Outputs: Dataframe of [feature, label] to be used in another model


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


// Example Usage
// val output_df = top_n_vars(quakes, "mag", rf_mod, 2)
