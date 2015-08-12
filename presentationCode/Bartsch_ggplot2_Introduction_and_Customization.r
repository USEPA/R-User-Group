#############################################################################
#File: ggplot2_Introduction_&_Customization.r
#Purpose: Demonstrate how to produce and customize plots using the ggplot 
# function in the ggplot2 package. We will create and customize a scatter
# plot, a bar plot, a stacked histogram, and a categorical boxplot. 
# We will also plot multiple plots on one panel.
#By: Will Bartsch  -  EPA-MED, Duluth
#Date: 7/16/14
#############################################################################

#Load the necessary packages.
library(ggplot2)
library(plyr)
library(grid)

#Create a data frame to use for the plots.
dat <- data.frame(condition = rep(c("A", "B", "C"), each=30),
			response=rep(c("Yes", "No"), each=15, times=3),
			xvar = 50:139 + rnorm(90,sd=15),
			yvar = 50:139 + rnorm(90,sd=15))
			
head(dat)
dim(dat)


########################## A scatter plot #############################			

# Basic plot using base R
plot(dat$xvar, dat$yvar)

# Basic plot using the 'qplot' function in ggplot2
qplot(dat$xvar, dat$yvar)

# Basic plot using the 'ggplot' function in ggplot2
ggplot(dat, aes(y=yvar, x=xvar)) + geom_point()

# Change the symbols to a solid triangle and color code according to 
#	"condition"

# A plot of all the symbols	to find the triangle  
plot(1:25, pch=c(1:25))
text(1:25, pos=3, offset=0.4)

# A colorblind friendly palette (create it for later use)
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", 
	"#0072B2", "#D55E00", "#CC79A7")

# Create the plot
sp <- ggplot(dat, aes(y=yvar, x=xvar, color=condition)) 
sp + geom_point(shape=17)


# Add a title and axis lables
sp + geom_point(shape=17)+
	ggtitle("Data Presentation") + xlab("X") + ylab("Y")
	
# Same plot with a black and white theme
sp + geom_point(shape=17)+
	ggtitle("Data Presentation") + xlab("X") + ylab("Y") + theme_bw()
	
	
# Format the legend 
	sp + geom_point(shape=17, size=3)+
	ggtitle("Data Presentation") + xlab("X") + ylab("Y") +
	scale_colour_manual("Group", breaks=c("A", "B", "C"), 
	labels=c("Apple", "Banana", "Cherry"), values=cbbPalette) +	# Change the labels and title, change the color palette
	theme(legend.background=element_rect(color="black", fill="gray"), # Make the legend background gray with a black border
		legend.text=element_text(size=16),	#Change label text size
		legend.title=element_text(size=16, face="bold"), #Change title text
		legend.key.size=unit(1, "cm"),	#Change Size of symbol box
		legend.position = c(0.89,0.135))		#Set position
	
	
# Format Axis, Labels and Title (Maintain previous formating) and add
# trend lines
	sp + geom_point(shape=17, size=3)+
	ggtitle("Data Presentation") + xlab("X") + ylab("Y") +
	scale_colour_manual("Group", breaks=c("A", "B", "C"), 
	labels=c("Apple", "Banana", "Cherry"), values=cbbPalette)+		
	theme(legend.background=element_rect(color="black", fill="gray"),
		legend.text=element_text(size=16),	
		legend.title=element_text(size=16, face="bold"), 
		legend.key.size=unit(1, "cm"),	
		legend.position = c(0.895,0.135))+
	theme(axis.title=element_text(size=16),		#Change axis title size
		axis.text=element_text(size=12),		#Change axis label size
		plot.title=element_text(size=20, face="italic"))+	#Change plot title size and make it italic
		xlim(0,175) + ylim(0, 175) +	#Reset the axis ranges
		#scale_y_continuous(limits = c(0,175), expand = c(0,0))+ #Reset the axis ranges and force it to start at 0
		#scale_x_continuous(limits = c(0,175), expand = c(0,0))+ #Reset the axis ranges and force it to start at 0
	geom_smooth(method=lm, fill=NA, size=1)		#Add the linear regression trend lines
	

		
	
############## A bar plot of means with standard error bars #################

# Summarize the data by mean and standard deviation using ddply from 
# the plyr package
dat_mean <- ddply(dat, .(condition), summarize, avg=mean(yvar), 
	stdev=sd(yvar))
	
dat_mean$std_error <- dat_mean$stdev/sqrt(30)

# Make a basic plot
bp <- ggplot(dat_mean, aes(y=avg, x=condition)) 
bp + geom_bar(stat="identity", color="black", fill="black")+ 
	geom_errorbar(aes(ymin=avg-std_error, 
	ymax=avg+std_error), color='red', width=0.5)
	

# Customize the plot with white background and no grid lines
bp + geom_bar(stat="identity")+ geom_errorbar(aes(ymin=avg-std_error, 
	ymax=avg+std_error), color='red', width=0.5, size=1.5) + 
	ggtitle("Example\nBar Plot") +				  
	xlab(expression(paste(italic("Condition")))) + 
	ylab(expression(paste("NH"[4]^" +  ",mu,"g/L")))+ 	
	theme(panel.background=element_rect(fill="white"),
		panel.grid=element_blank(),
		panel.border=element_rect(color="black", fill=NA))
		


		
		
##################### A faceted histogram plot ###########################
hp <- ggplot(dat, aes(x=xvar, fill=condition))
hp + geom_histogram(color="black", binwidth=15) +
	facet_grid(condition ~ .) + ggtitle("Results") +
	xlab("X") + ylab("Count") +
	scale_y_continuous(breaks=seq(0, 12, 3))+
	scale_fill_hue("Variable", l=20) #Darken the color scheme and label legend

# If you don't want a legend, use the following line in your script:
	theme(legend.position="none")
	
	
	

#################### Categorical Box Plot ###################	
boxp <- ggplot(dat, aes(y=yvar, x=condition, fill=response))
boxp + geom_boxplot() + ggtitle("Was There\nA\nResponse")+
	xlab("Condition") + ylab("Y Variable")
	
	
#################### Plotting Multiple Plots on One Panel ###################

# Multiple plot function (from www.cookbook-r.com)
#
# ggplot objects can be passed in ..., or to plotlist 
#	(as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
	
	
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}	
	
	
#Make multiple plots and save them as an object
p1 <- 	ggplot(dat, aes(y=yvar, x=xvar, color=condition)) +
	geom_point(shape=17)

p2 <- ggplot(dat, aes(y=yvar, x=xvar, color=condition)) +
	geom_smooth(method=lm)
	
p3 <- ggplot(dat_mean, aes(y=avg, x=condition)) +
	geom_bar(stat="identity", color="black", fill="black")+ 
	geom_errorbar(aes(ymin=avg-1.96*stdev, 
	ymax=avg+1.96*stdev), color='red', width=0.5)
	
p4 <- ggplot(dat, aes(y=yvar, x=condition)) +
	geom_boxplot()

# Plot them
multiplot(p1,p2,p3,p4, cols=2)
multiplot(p1,p2, cols=2)
multiplot(p1,p2, cols=1)
multiplot(p1,p2,p3, layout=matrix(c(1,2,3,3), nrow=2, byrow=TRUE))	
multiplot(p1,p2,p3, layout=matrix(c(1,2,1,3), ncol=2, byrow=TRUE))		
	
	
	
############################# Resources ################################
#
# Cookbook for R
# Available online and a great resource. Go to the Graphs section:
# www.cookbook-r.com
#
#
# Use R! ggplot2 	-    Springer 
#				  
########################################################################

				  
				  
				  
				  
				  
				  
				  
				  








