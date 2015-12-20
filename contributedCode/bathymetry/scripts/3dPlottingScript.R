# VARIOUS ATTEMPTS TO PLOT HARSHA BATHYMETRY

# LIBRARY------------
library(marmap)
library(rgdal)

# GET DATA----------
# ODNR data
depths.odnr <- readOGR(dsn = "inputData/ODNRdata",  # ODNR data has better coverage than USGS
                  layer = "EastFork_depths")

depths.usgs <- read.table(file="inputData/USGSdata/Harsha_Bathymetry.txt", 
                      sep = ",", header = TRUE)


# Inspect data
plot(depths.dnr)  # looks good
str(depths@data)
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

# wireframe, no good
with(depths.df.sub, # draws axis, but no surface. Wont work because x and y don't form a grid
     wireframe(Depth_ft ~ UTM_East + UTM_North, shade = T, data = depths.df.sub)) 

# create grid, http://stackoverflow.com/questions/15340658/using-wireframe-graphs-in-r
library("akima")
depths.df.sub.s <- with(depths.df.sub, interp(UTM_East, UTM_North, Depth_ft)) # depth not interpolated correctly
with(depths.df.sub.s, # still doesnt work
     wireframe(Depth_ft_pos ~ UTM_East + UTM_North, shade = T, data = depths.df.sub)) 


# 3d PERSPECTIVE PLOT FROM rgl------------
library(rgl)
# scatterplot
with(depths.df.sub, plot3d(UTM_East, UTM_North, Depth_ft, type="p"))
# surface plot. doesn't work
with(depths.df.sub, surface3d(UTM_East, UTM_North, Depth_ft))  # probably needs grid

library(ecespa)
# http://r-sig-geo.2731867.n2.nabble.com/convert-x-y-z-data-into-a-grid-td2764850.html
depths.pp <- haz.ppp(depths.df.sub)  # makes ppp object

# My machine chokes on this command
depths.s <- smooth.ppp(depths.pp) #spatial smoothing of numeric values observed
depths.p <- persp.im(depths.s) # 3D transformation matrix returned by persp.default 
persp3d(depths.p) # perspective plot.  This works, but interpolation seems weird

# marmap APPROACH------------
library(marmap)
depths.marmap <- as.bathy(depths.df.sub)
summary(depths.marmap)
plot(depths.marmap)  # empty map because data are not on regular grid
# use marmap tools to creat grid.
reg.depths <- griddify(depths.df, # use interpolation tools to create reg grid using full dataset
                       nlon=100, nlat =100)  # these parameters are important
class(reg.depths)
reg.depths.marmap <- as.bathy(reg.depths)  # convert to bathy object
class(reg.depths.marmap)
plot(reg.depths.marmap, image = TRUE, lwd = 0.1)  # this is a decent contour plot

wireframe(unclass(reg.depths.marmap))  # now we can use wireframe because we have a good grid.

wireframe(unclass(reg.depths.marmap), shade=T, aspect=c(0.5, 0.1),  # code from marmap PLOSOne paper
          screen = list(z = 0, x = -45),
          par.settings = list(axis.line = list(col = "transparent")),
          par.box = c(col = rgb(0,0,0,0.1)))
surface3d(unclass(reg.depths.marmap))  # still doesn't work here though



