// Convert regular dataframe to required format for models
// 
// Inputs: Dataframe 
//		   Target Variable
//
// Outputs: Dataframe of type features: vector & label: double


  def model_df (df:org.apache.spark.sql.DataFrame, target:String) : org.apache.spark.sql.DataFrame = {
   
   // Select all feature names
	val feature_names = df.columns.filter(_ != target)

	// Assemble features into vector
	val assembler = new VectorAssembler()
		.setInputCols(feature_names)
		.setOutputCol("features")
  
	val stage_features = assembler.transform(df)
	 
	// Rename target column
	val stage_label = stage_features.withColumnRenamed(target, "label")
	  
	// Output only features and label
	return stage_label.select("features","label")
   
}

// Example Usage
// val output_df = model_df(original_df, "my_target_column")