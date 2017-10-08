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


# Round to nearest N-mins
N = 15 #mins
as.POSIXct(floor(as.double(time_stamp)/(N*60))*(N*60),origin='1970-01-01')
floor = 'Previous interval'
round = 'closest interval'



# Activate R kernel for Jupyter
install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))
devtools::install_github('IRkernel/IRkernel')
IRkernel::installspec()


library(RODBC)
cnxn <- odbcDriverConnect('driver={SQL Server};server=CICDBDEV;Uid=<user name>;Pwd=<pw>')
sqlQuery(channel = cnxn, query = "<your sql query>")
