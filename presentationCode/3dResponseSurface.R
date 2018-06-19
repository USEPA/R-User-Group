# Simulate data following:---------------------------

# z=α+β1A+β2B+β3AB+ϵ

# where z is the dependant variable, α the intercept, βn your coefficients for 
# your n predictors, in this case, A, B, and A∗B (the interaction), and ϵ the
# normally distributed noise, or error.


# Set coefficients
alpha = 10
beta1 = .3
beta2 = .5
beta3 = 0.1

# Generate 200 trials
# A = c(rep(c(0), 100), rep(c(1), 100)) # '0' 100 times, '1' 100 times
A <- rnorm(200, 100, sd=30) #18
noisyA <- jitter (A, amount = 10)
# B = rep(c(rep(c(0), 50), rep(c(1), 50)), 2) # '0'x50, '1'x50, '0'x50, '1'x50
B <- rnorm(200, 250, sd=85)
noisyB <- jitter(B, amount = 15)
e <- rnorm(200, 0, sd=1) # Random noise, with standard deviation of 1

# Generate your data using the regression equation
z <- alpha + beta1*A + beta2*B + beta3*A*B + e

# Join the variables in a data frame
data <- data.frame(cbind(A, B, z))

# Fit a lm
model <- lm(z ~ A*B, data=data)
summary(model)

# Bivariate plots
with(data, plot(z ~ A))
with(data, plot(z ~ B))

# 3D RESPONSE SURFACE PLOTS: persp from base R----------------------------------------
# Create A and B values to predict over
new.A <- seq(from = min(A), to = max(A), length.out = 50)
new.B <- seq(from = min(B), to = max(B),  length.out = 50)

# Predict z over this range of A and B.  persp requires a matrix of matched
# y, A, and B data
pred.z <- outer(new.A, new.B, function(new.A, new.B) { # must be same names in these arguments
  predict(model, data.frame(A = new.A, B = new.B))
}
)
# pred.z is a matrix of 50 rows and 50 columns
class(pred.z);str(pred.z)

p <- persp(new.A, new.B, pred.z, 
           ticktype = "detailed", # produce detailed axis
           shade = 0.5, # add shade to surface
           col = "lightblue",
           theta = 40, # rotate plot
           xlab = "A",
           ylab = "B",
           zlab = "z")

# Can suppress default tick labels and supply custom ones
# http://entrenchant.blogspot.com/2014/03/custom-tick-labels-in-r-perspective.html
# Parameters to set custom tick marks and labels


# Add points and line segment connecting surface to points
obs <- trans3d(noisyA,
               noisyB,
               data$z,
               p)
pred  <- trans3d(noisyA,
                 noisyB,
                 fitted(model), p);
points(obs, col = "red", pch=16) # add observations to plot
segments(obs$x, obs$y, pred$x, pred$y)

# Add custom color ramp
# https://stackoverflow.com/questions/39117827/colorful-plot-using-persp
# Color palette (100 colors)
col.pal<-colorRampPalette(c("blue", "red"))
colors<-col.pal(100)
# height of facets
z.facet.center <- (pred.z[-1, -1] + pred.z[-1, -ncol(pred.z)] + pred.z[-nrow(pred.z), -1] + pred.z[-nrow(pred.z), -ncol(pred.z)])/4
# Range of the facet center on a 100-scale (number of colors)
z.facet.range<-cut(z.facet.center, 100)

persp(new.A, new.B, pred.z, 
      ticktype = "detailed", # produce detailed axis
      col = colors[z.facet.range],
      theta = 40, # rotate plot
      xlab = "A",
      ylab = "B",
      zlab = "z")

# 3D RESPONSE SURFACE PLOTS: interactive plot from persp3d---------------------
library(rgl)
persp3d(new.A, new.B, pred.z, 
      ticktype = "detailed", # produce detailed axis
      col = "red",
      theta = 40, # rotate plot
      xlab = "A",
      ylab = "B",
      zlab = "z")

points3d(noisyA,
         noisyB,
         data$z,
         size = 10)

# 3D RESPONSE SURFACE PLOTS: wireframe from lattice----------------------------------------
# In previous scripts we used persp and persp3d to generate 3d plots.
# Unfortunately, these functions wont' accomodate expressions for axis label,
# which means no superscripts, subscripts, etc.  After a bunch of investigating,
# I settled on the wireframe function from the lattice package.  This function
# gets complicated real quick, but does allow for nearly limitless tweaking.

library(lattice)
# Prediction grid.  Dataframe.
foo.fit = expand.grid(list(A = new.A, B = new.B))
#Prediction across grid
foo.predict <- predict(model, newdata = foo.fit) 
# Add predicted values to prediction grid
foo.fit$z <- as.numeric(foo.predict)

# Plot
wireframe(z ~ A * B, 
          data = foo.fit,
          xlab = list(label = expression(Surface~Area~(km^{2})),
                      cex = 1.5, rot = -30), # add rot to list to control rotation
          ylab = list(label = expression(TP~(mu*g~L^{-1})),
                      cex = 1.5), # add rot to list to control rotation
          zlab = list(expression(CO[2]~flux~+43~(mg~CO[2]-C~m^{-2}~d^{-1})),
                      cex = 1.5, rot = 90),
          #shade = TRUE,
          drape = TRUE,
          screen = list(z = -50, x = -80),)
