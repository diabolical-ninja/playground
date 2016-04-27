// Convert String to Timestamp
//
// Desc: Takes a dateframe column and adds returns a new dataframe with an additional 
//       column of type timestamp
//
// Inputs: df = dataframe
//		   input_col = input timestamp name
//		   output_col = output timestamp name
//		   ts_format = input timestamp format

// Load Libraries 
import java.sql.Timestamp
import java.text.SimpleDateFormat

// Create String to Timestamp Function
def string_to_timestamp (df: org.apache.spark.sql.DataFrame, input_col: String, output_col: String, ts_format: String) : org.apache.spark.sql.DataFrame = {

	// Define input time format
	val sdf = new SimpleDateFormat(ts_format)
	
	// Create function to convert timestamp
	val dater: (String => Timestamp) = (arg: String) => {new Timestamp(sdf.parse(arg).getTime)}
	val ts_conv = udf(dater) 
	
	// Add column with converted timestamp format
	val df_conv = df.withColumn(output_col, ts_conv(col(input_col)))
	
	// Drop original timestamp column and return dataframe
	df_conv.drop(input_col)
 }

// Example Useage
// string_to_timestamp(dow_jones_index, "Date", "Timestamp","mm/dd/yyyy")