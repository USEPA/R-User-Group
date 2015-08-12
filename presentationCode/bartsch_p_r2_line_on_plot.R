# Adding r^2, p value, and the equation of a line to a regression plot
# By: Will Bartsch - EPA-MED, Duluth

# Call up the iris data that is available on R
data(iris) 

#Create a subset that contains only the versicolor species
versicolor <- subset(iris, Species=="versicolor")

#Run a linear regression model
versicolor_lm <- lm(versicolor$Petal.Length ~ versicolor$Petal.Width)

#Create an object of the regression model summary
versicolor_sum <- summary(versicolor_lm)

#Plot the data
plot(versicolor$Petal.Width, versicolor$Petal.Length, main="Irises", ylab="Petal Length", xlab="Petal Width")

#Add the regression line
abline(coef(versicolor_lm), lwd=2)

#Add a legend that contains: r^2, p-value, and the equation of the line 
legend("bottomright", 
	 legend=c(as.expression(bquote(italic(r)^2==.(format(versicolor_sum$r.squared, digits=2)))),
		    as.expression(bquote(italic(p)==.(format(versicolor_sum$coefficients[2,4], digits=2)))),
		    as.expression(bquote(italic(y) == .(format(versicolor_sum$coefficients[2,1], digits=2))*italic(x) 
		    + .(format(versicolor_sum$coefficients[1,1], digits=2))))))

#as.expression attempts to coerce its argument into an expression object. 
#bquote evaluates R code within an expression wrapped in .( ) and substitutes the result into the expression

#Alternatively, place the r^2 value in a different location using the "text" function
#and the x,y coordinates of the desired location
plot(versicolor$Petal.Width, versicolor$Petal.Length, main="Irises", ylab="Petal Length", xlab="Petal Width")
abline(coef(versicolor_lm), lwd=2)
text(1.1, 5.0, bquote(italic(r)^2==.(format(versicolor_sum$r.squared, digits=2))))









