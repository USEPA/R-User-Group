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

# Generate 200 observations
A <- rnorm(200, 100, sd=30)
noisyA <- jitter (A, amount = 10) # Add noise for more interesting points()
B <- rnorm(200, 250, sd=85)
noisyB <- jitter(B, amount = 15) # Add noise for more interesting points()
e <- rnorm(200, 0, sd=1) # Random noise, with standard deviation of 1

# Generate z using the regression equation
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
           #ticktype = "detailed", # produce detailed axis
           #shade = 0.5, # add shade to surface
           #col = "lightblue",
           #theta = 40, # rotate plot
           xlab = "A",
           ylab = "B",
           zlab = "z")

# Can suppress default tick labels and supply custom ones
# http://entrenchant.blogspot.com/2014/03/custom-tick-labels-in-r-perspective.html
# Parameters to set custom tick marks and labels

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


# Add points and line segment connecting surface to points
obs <- trans3d(noisyA,
               noisyB,
               data$z,
               p)

points(obs, col = "red", pch=16) # add observations to plot

# # This bit not working at moment
# pred  <- trans3d(noisyA,
#                  noisyB,
#                  fitted(model), p);
# segments(obs$x, obs$y, pred$x, pred$y)



# 3D RESPONSE SURFACE PLOTS: interactive plot from persp3d---------------------
library(rgl)
persp3d(new.A, new.B, pred.z, 
      ticktype = "detailed", # produce detailed axis
      col = "red",
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
          screen = list(z = -50, x = -80),
          xlab = list(label = expression(Surface~Area~(km^{2})),
                      cex = 1.5, rot = -30), # add rot to list to control rotation
          ylab = list(label = expression(TP~(mu*g~L^{-1})),
                      cex = 1.5), # add rot to list to control rotation
          zlab = list(expression(CO[2]~flux~+43~(mg~CO[2]-C~m^{-2}~d^{-1})),
                      cex = 1.5, rot = 90),
          drape = TRUE,
          col.regions = colorRampPalette(c("blue", "cyan", "green", "yellow", "red"))(n = 299),  # manual color pallete
          # Color key values below don't make sense for this plot, but
          # illustrate how to customize color key.
          colorkey = list(labels = list(cex = 0.3, # size of key text
                                        at = c(-0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1), # label location
                                        labels = c(0.199, 0.251, 0.316, 0.398, 0.501, 0.631, 0.794)), #labels
                          height = 0.5, # key height
                          width = 0.5) #key width
)

