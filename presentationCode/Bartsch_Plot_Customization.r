#Customizing Plots
#By: Will Bartsch  -  EPA-MED, Duluth
#Date: 5/1/13
##################################################################
set
#Load the necessary libraries.
library(ggplot2)
library(plotrix)

#Create a data frame to use for the plots.
location <- c("urban","urban","urban","urban","rural","rural","urban",
	"urban","urban","urban","rural","rural","rural","rural","urban",
	"urban","urban","rural","rural","rural")
nh4 <- c(14.01,17.12,17.51,12.32,5.68,12.02,19.16,16.22,19.59,16.82,
	7.78,11.89,8.6,12.74,13.96,19.44,13.83,9.93,7.76,8.49)
stress <- c(0.82,0.78,0.84,0.89,0.21,0.45,0.88,0.74,0.98,0.65,0.35,
	0.39,0.38,0.45,0.59,0.8,0.56,0.42,0.31,0.32)
	
wq <- data.frame(location, nh4, stress)

#Create some subsets to be used later.
wq_rural <- subset(wq, location=="rural")
wq_urban <- subset(wq, location=="urban")


#Create a default plot.
plot(wq$stress, wq$nh4)

#Set the range of the x and y axes and add labels and a title.
plot(wq$stress, wq$nh4, xlim=c(0,1), ylim=c(0,20), 
	xlab="Relative Stress", 	
	ylab=expression(paste("NH"[4]^" +  ",mu,"g/L")), 
	main="Ammonium Levels in Lakes", pch=16, col="red")  

#Part of the y label is cut off; resize the margins.
#This will adjust margins on your future plots, not the current one.
par(mar=c(5, 5,4,2) )  
     
#The default is (5,4,4,2). The order is (bottom, left, top, right). 

#Use different symbols for the urban and rural locations. 
#There are many ways to code this. For a couple of alternatives see 
#the bonus material at the end of this document. We will use 
#the subsets we created.
 
#pch selects the symbol. Run the code to see the 25 basic symbols:
plot(1:25, pch=c(1:25))
text(1:25, pos=3, offset=0.4)

#Make the plot using the solid triangle(17) and the solid circle(16).
#We will start with a blank plot that has the correct x and y limits,
#and the correct labels. Then we will add our data with the "points"
#command
plot(NULL,NULL, xlim=c(0,1), ylim=c(0,20), 
	xlab=expression(paste(bold("Relative Stress"))), 
	ylab=expression(paste("NH"[4]^" +  	",mu,"g/L")), 
	main="Ammonium Levels in Lakes")
points(wq_urban$stress, wq_urban$nh4, pch=16, col="red")
points(wq_rural$stress, wq_rural$nh4 , pch=17, col="black")


#Add trend lines for each group. Start by doing a linear regression 
#on both the urban and rural data. Then make an object of the 
#summaries so they can be called on later.
nh4_urban_lm <- lm(wq_urban$nh4  ~ wq_urban$stress)
nh4_urban_lm_sum <- summary(nh4_urban_lm)

nh4_rural_lm <- lm(wq_rural$nh4  ~ wq_rural$stress)
nh4_rural_lm_sum <- summary(nh4_rural_lm)

#Display the summary.
nh4_rural_lm_sum

#Check the names of the summary components
names(nh4_rural_lm_sum)

#Call up the r squared
nh4_rural_lm_sum$r.squared

#Notice that under the coefficients section there is a table of 
#values. We can call them out later using the table name and the 
#number's position within that table.

#Use the "ablineclip" function from the plotrix package to add the 
#trend lines. We will pull the necessary information from the 
#linear model summaries we just created. x1 and x2 are cutoff values.
#We can eyeball the cutoff values or use the range function

range(wq_rural$stress)
range(wq_urban$stress)

ablineclip(nh4_rural_lm_sum$coefficients[1,1], 
	nh4_rural_lm_sum$coefficients[2,1], lwd=2, x1=0.21, 	x2=0.45)
ablineclip(nh4_urban_lm_sum$coefficients[1,1], 
	nh4_urban_lm_sum$coefficients[2,1], col="red", 	lwd=2, 
	x1=0.56, x2=0.98)

#Customize the x axis and add a legend. If we want a custom axis we
#have to remove the default axis.

plot(NULL,NULL, xlim=c(0,1), ylim=c(0,20), xaxt="n",	
	xlab=expression(paste(bold("Relative Stress"))), 
	ylab=expression(paste("NH"[4]^" +  	",mu,"g/L")), 
	main="Ammonium Levels in Lakes")      

#xaxt="n"  removes the x axis. We can add it back in and customize 
#it using the "axis" function. The axis is still set to the 0 to 1 
#scale, so we can select positions on the scale to place our labels.
axis(1, at=c(0.2, 0.5, 0.8), labels=c("Low", "Medium", "High"), 
	cex.axis=0.8)  

#cex.axis changes the size of the labels. We just set them to 0.8 
#of there standard size. Want the new axis labels to be 
#perpendicular to the axis? Include "las=2" in the axis code. 

#Add in the data.
points(wq_urban$stress, wq_urban$nh4, pch=16, col="red")
points(wq_rural$stress, wq_rural$nh4 , pch=17, col="black")
ablineclip(nh4_rural_lm_sum$coefficients[1,1], 
	nh4_rural_lm_sum$coefficients[2,1], lwd=2, x1=0.21, 	x2=0.45)
ablineclip(nh4_urban_lm_sum$coefficients[1,1], 
	nh4_urban_lm_sum$coefficients[2,1], col="red", 	lwd=2, 
	x1=0.56, x2=0.98)
legend("bottomright", legend=c("Urban", "Rural"), pch=c(16,17), 
	col=c("red","black"))

#Don't want a box around the legend? Add bty="n" to the legend code.
#If you want to add the r^2, p-value or equation of the line to a 
#plot review the "Tips and Tricks" section from the April 2013 
#meeting. It is available on the group site.



#Save the plot as a pdf
pdf("nh4.pdf")
par(mar=c(5,5,4,2))


plot(NULL,NULL, xlim=c(0,1), ylim=c(0,20), 
	xlab=expression(paste(bold("Relative Stress"))), 
	ylab=expression(paste("NH"[4]^" +  	",mu,"g/L")), 
	main="Ammonium Levels in Lakes", xaxt="n")
points(wq_urban$stress, wq_urban$nh4, pch=16, col="red")
points(wq_rural$stress, wq_rural$nh4 , pch=17, col="black")
ablineclip(nh4_rural_lm_sum$coefficients[1,1], 
	nh4_rural_lm_sum$coefficients[2,1], lwd=2, x1=0.21, 	x2=0.45)
ablineclip(nh4_urban_lm_sum$coefficients[1,1], 
	nh4_urban_lm_sum$coefficients[2,1], col="red", 	lwd=2, 
	x1=0.56, x2=0.98)
axis(1, at=c(0.2, 0.5, 0.8), labels=c("Low", "Medium", "High"), 
	cex.axis=0.8)   
legend("bottomright", legend=c("Urban", "Rural"), pch=c(16,17), 
	col=c("red","black"))

dev.off()   

#"dev.off()" stops the "pdf" function and sends the plot to the file 
#that you have your directory set to.



################ ggplot2 ###################

#Now we will do a very similar graph in ggplot2

#Basic plot
nh4_a <-ggplot(data=wq, aes(x=stress, y=nh4))
nh4_a + geom_point()

#Customized plot using ggplot2 
nh4_b <- ggplot(data=wq, aes(x=stress, y=nh4, color=location, 
	shape=location))
nh4_b + geom_point() + scale_x_continuous(limits=c(0,1), 
	breaks=c(0.2,0.5,0.8), labels=c("Low","Medium", "High")) + 
	ylim(0,20) + ggtitle("Ammonium Levels in Lakes") + 
	scale_colour_manual("Location", 
	labels=c("Urban", "Rural"), breaks=c("urban", "rural"), 
	limits=c("urban", "rural"), values=c("red", "black"))  + 
	scale_shape_manual("Location", labels=c("Urban", "Rural"), 
	breaks=c("urban", "rural"), limits=c("urban", "rural"), 
	values=c(16,17)) + 
	xlab(expression(paste(bold("Relative Stress")))) + 
	ylab(expression(paste("NH"[4]^" +  ",mu,"g/L"))) + 
	geom_smooth(method=lm, fill=NA)

	


######## Examples of code for common scientific expressions#######

#A blank plot is used as the canvas 

plot(NULL,NULL, xlim=c(0,10),ylim=c(0,10), 
	xlab=expression(paste
	('excess ', N[2], '-N (', mu, 'mol ', L^-1, 	')')), 
	ylab=expression(paste(N[2], 'O saturation')))
text( 2,10, expression(paste(alpha, mu, beta)))
text(2,9, expression(paste(italic("E. coli")," ", "levels")))  
text(2,8, "angled", srt=45) 
  #the "srt" command can only be used with the "text" function, 
  #it can't be used to label axes
text(2,7, "less angled", srt=30)
text(2,6, expression(paste('TOC (mmol', L^-1, ')')))
text(2,5, expression(paste(bold("Relative Stress"))))
text(2,4, expression(paste(underline("Relative Stress"))))


############ Bonus Material ###############

#Alternative ways to call just the urban or just the rural data.

#Alternative #1

#Use the original data frame and set the criteria when listing the 
#items to be plotted

plot(NULL,NULL, xlim=c(0,1), ylim=c(0,20), 
	xlab=expression(paste(bold("Relative Stress"))), 
	ylab=expression(paste("NH"[4]^" +  	",mu,"g/L")), 
	main="Ammonium Levels in Lakes")
points(wq$stress[wq$location=="urban"], 
	wq$nh4[wq$location=="urban"], pch=16, col="red")
points(wq$stress[wq$location=="rural"], 
	wq $nh4[wq$location=="rural"] , pch=17, col="black")

#Alternative #2

#Subset the data in the command line using the "with" function
plot(NULL,NULL, xlim=c(0,1), ylim=c(0,20), 
	xlab=expression(paste(bold("Relative Stress"))), 	
	ylab=expression(paste("NH"[4]^" +  	",mu,"g/L")), 
	main="Ammonium Levels in Lakes")
with(subset(wq, location=="urban"), points(stress, nh4,  
	pch=16, col="red"))
with(subset(wq, location=="rural"), points(stress, nh4 , 
	pch=17, col="black"))



#Create a legend with both symbols and lines

legend("bottomright", 
	legend=c("Urban", "Rural", "Urban Trend", "Rural Trend"), 
	bty="n", lty=c(0,0,1,1), lwd=c(0,0,2,2), pch=c(16,17,1,1), 
	pt.cex=c(1,1,0,0), col=c("red","black","red","black"))
