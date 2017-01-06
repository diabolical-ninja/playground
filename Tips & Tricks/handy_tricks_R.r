# Add progress bar to loop  ####
pb <- txtProgressBar(min = 0, max = loop_end, style = 3)
for(i in 1:10){
	
	print i
	
	# Update progress bar
	setTxtProgressBar(pb, i)

}

close(pb)



# Grid Arrange Plotting  ####
p1 <- ggplot(....)
p2 <- ggplot(....)

plots <- list(p1,p2)

# If wanting to loop through plots then:
plots <- lapply(loop_over, function(x){
	
	p <- ggplot(...)
	return(p)
	
}

do.call('grid.arrange',c(plots, ncol=2))


# GGPlot Label Themeing  ####

ggplot(...) +
  theme(plot.title = element_text(lineheight=1, face="bold", color="black", size=16),
        axis.title.y = element_text(lineheight=1, color="black", size=14),
        axis.title.x = element_text(lineheight=1, color="black", size=14))  



# Adjusting Jupyter Display sizing with the R kernal
options(
  repr.vector.quote = TRUE,
  repr.matrix.max.rows = 100,
  repr.matrix.max.cols = 30,
  repr.matrix.latex.colspec = list(row_head = 'r|', col = 'l', end = ''),
  repr.function.highlight = FALSE)



# Setup Parallel Clusters  ####

library(doSNOW)
library(ggplot2)
library(parallel)

# Setup Cluster
cl <- makeCluster(detectCores(), type="SOCK")
registerDoSNOW(cl)

...

stopCluster(cl)