# VARIOUS ATTEMPTS TO PLOT HARSHA BATHYMETRY

# LIBRARY------------
library(marmap)  # Used for working with bathymetry data
library(rgdal)  # Use for reading shapefile

# GET DATA----------
# ODNR bathymteric survey of Harsha Lake 
depths.odnr <- readOGR(dsn = "contributedCode/bathymetry/inputData/ODNRdata",  # ODNR data has better coverage than USGS
                  layer = "EastFork_depths")

# USGS data.  Coverage is poor relative to ODNR data.  Data not pushed to repository
# depths.usgs <- read.table(file="inputData/USGSdata/Harsha_Bathymetry.txt", 
#                       sep = ",", header = TRUE)


# Inspect data
plot(depths.odnr)  # looks good
str(depths.odnr@data)
depths.df <- (cbind(depths.odnr@data[1], depths.odnr@data[2], depths.odnr@data[3]))  # convert to dataframe
head(depths.df)  # inspect
sum(duplicated(depths.df[,1:2]))  # Have some duplicate depth measurements.  Aggregate them away
depths.df <- aggregate(Depth_ft ~ UTM_East + UTM_North, data=depths.df, mean)  # aggregate
sum(duplicated(depths.df[,1:2]))  # All better!
depths.df$Depth_ft



# LATTICE WIREFRAME PLOT-------
library(lattice)
with(depths.df, wireframe(Depth_ft ~ UTM_East*UTM_North))  # Reached total allocation of 8097Mb
with(depths.df, cloud(Depth_ft ~ UTM_East*UTM_North))  # cloudplot is ok , but takes a while
# Extract a subset of measurements
# http://stackoverflow.com/questions/5237557/extracting-every-nth-element-of-a-vector
depths.df.sub <- depths.df[1:(1+100)==(1+100),] # extract every 100th value
# Cloudplot
with(depths.df.sub, # looks good
     cloud(Depth_ft ~ UTM_East + UTM_North, 
               shade = TRUE, colorkey=TRUE,
               scales=list(draw=F,arrows=FALSE))) 

# try wireframe again
with(depths.df.sub, # draws axis, but no surface. Wont work because x and y don't form a grid
     wireframe(Depth_ft ~ UTM_East + UTM_North, shade = T, data = depths.df.sub)) 

# create grid, http://stackoverflow.com/questions/15340658/using-wireframe-graphs-in-r
library("akima")
depths.df.sub.s <- with(depths.df.sub, interp(UTM_East, UTM_North, Depth_ft, )) #  This interpolates data to grid, I think.
with(depths.df.sub.s, # still doesnt work.  Seems to choke on NA.  Replace these with zeroes?
     wireframe(z ~ x + y, shade = T)) 

depths.df.sub.s[[3]][is.na(depths.df.sub.s[[3]])] = 0  # replace z == NA with zeroes.
with(depths.df.sub.s,
     wireframe(z ~ x + y, shade = T)) # Still doesn't work.  Still chokeing on NA?


# 3d PERSPECTIVE PLOT FROM rgl------------
library(rgl)
# scatterplot
with(depths.df, plot3d(UTM_East, UTM_North, Depth_ft, type="p"))  # this is pretty cool.
# surface plot. doesn't work
with(depths.df.sub, surface3d(UTM_East, UTM_North, Depth_ft))  # probably needs grid

# Another attempty at creating a grid
# http://r-sig-geo.2731867.n2.nabble.com/convert-x-y-z-data-into-a-grid-td2764850.html
library(ecespa)
depths.pp <- haz.ppp(depths.df.sub)  # makes ppp object
depths.s <- Smooth(depths.pp) # Smoothes ppp object.  generates warnings message, but seems to work
surface3d(depths.s)  # still doesn't work
# Use perspective plot from spatstat package
depths.p <- persp.im(depths.s) # Generates plot and object.  Plot looks weird.
persp3d(depths.p) # perspective plot from rgl.  This works, but interpolation seems weird

# marmap APPROACH------------
library(marmap)
# First, need to convert data to a 'bathy' object.
# My machine reports "Error: cannot allocate vector of size 7.8 Gb." when I use full data set.
# Below uses subset.
depths.marmap <- as.bathy(depths.df.sub)  # convert to bathy object.
summary(depths.marmap)
plot(depths.marmap)  # empty map because data are not on regular grid.  Sounds familiar!
# use marmap tools to creat grid.
reg.depths <- griddify(depths.df, # use interpolation tools to create reg grid using full dataset
                       nlon=100, nlat =100)  # these parameters are important
class(reg.depths)  # creates raster object
reg.depths.marmap <- as.bathy(reg.depths)  # convert to bathy object
class(reg.depths.marmap)  # back to bathy object.
plot(reg.depths.marmap, image = TRUE, lwd = 0.1)  # this is a decent contour plot

wireframe(unclass(reg.depths.marmap))  # now we can use wireframe from lattice because we have a good grid.

wireframe(unclass(reg.depths.marmap), shade=T, aspect=c(0.5, 0.1),  # code from marmap PLOSOne paper.  Kinda cool
          screen = list(z = 0, x = -45),
          par.settings = list(axis.line = list(col = "transparent")),
          par.box = c(col = rgb(0,0,0,0.1)))
# Above shows poor interploation along margin.  Might improve by using full dataset and/or merging bathymetry file 
# with shapefile of lake perimeter.


surface3d(unclass(reg.depths.marmap))  # surface3d from rgl still doesn't work.



