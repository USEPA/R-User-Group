#************************************************************************
#          		3D Spatial Scatter Plots
#************************************************************************
#
#  Brief description:
#  This script creates a 'lollipop' 3D plot of sample point data overlaid on top of a shapefile.
#  
#
#
#  Packages required:
#  rgdal, ggplot2, scatterplot3d
#  
# 
#
#  Keywords (less than 10):
#  3D lollipop plot, spatial data, scatterplot
#
#
#
#  EPA Contact Information
#  Name: Jake Beaulieu
#  Phone Number: 513-569-7842
#  E-mail Address: Beaulieu.jake@epa.gov
#  
#		
#
#  Is data available upon request? Yes/No
#  
#
#
#  Date script was written: June 2015
#  Modified by J. Beaulieu: August 2015
#
#
#
##-------------------------------------------------------------------------

# load required libraries
require(rgdal) # -- to load spatial data files
require(ggplot2) # -- to easily convert polygon to list of coordinates using 'fortify' function
require(scatterplot3d) # -- not actually required here, but this is useful to be able to look at params in help ('?scatterplot3d')
require(RColorBrewer) # -- helpful for grabbing color palettes

# load external script (this is the scatterplot3d function, but changed a bit with to add more user control over style)
source("contributedCode/scatterplot3dMap/scatterplot3d_edit.R")

# load spatial data - polygon
lake <- readOGR("contributedCode/scatterplot3dMap","HarshaLake_Boundary_Alb")

# load measurement data from pointfile
data <- readOGR("contributedCode/scatterplot3dMap","cleanedSamplePointsAllMeasurements06.05.15")

# grab coordinates from polygon (in order to plot as a line on the xy plane of 3D plot)
coords = fortify(lake)
coords <- subset(coords, !hole)

# create vector for point color (for categorical variable)   -- note: this could be adapted for point sizes based on a categorical variable 
nclr <- length(unique(data$stratum))                    # determine the number of colors based on the number of categories - in this case, 'stratum'
pointclr <- brewer.pal(nclr,"Dark2")                    # get the actual colors from the selected palette ... type display.brewer.all() to see all palette options
# OR, one could create their own color palette, such as:
#pointclr <- c("#1DABB8","#BADA55","#C82647","#282830","#E7E7E7")
colornum <- cut(rank(data$stratum), nclr, labels=FALSE) # creates index list the length of data$stratum used to split and assign colors to each data point
colcode <- pointclr[colornum]                           # creates the actual color vector used when plotting


##########################################################################
### Create plot
tiff("contributedCode/scatterplot3dMap/plot.tif",  # write to .tiff file
     res=1200, compression="lzw", # specify resolution and compression
     width=6, height=3.5, units='in', # specify dimensions
     pointsize=7) # size of points

with(data@data, {
  tp_plot <- scatterplot3d_edit(x=coords$long, y=coords$lat, z=rep(0,length(coords$long)),   # x y and z data, respectively
                                   color="#282830",                               # color of lake outline
                                   lwd=0.8,                                       # line width of lake outline
                                   fill = "white",
                                   type="l",                                      # plot type - "l" = line, "h" = the lollipop style with a line  connecting to the horizontal plane 
                                   angle=80,                                     # angle aspect of plot (-35)
                                   scale.y=0.6,                                  # scale y axis (increase by 175%)
                                   #main="Nitrate at Harsha Lake",                # main plot title
                                   xlab="Easting (m)",                                       # x-axis label (left blank here to reposition later)
                                   ylab="",                           # y-axis label
                                   zlab=expression(Total~Phosphorus~(mu*g~P~L^{-1})),                      # z-axis label
                                   zlim=range(0,500),                             # range of z data shown - I grabbed the max from previously plotting the methane data here. Set so when I add the points, the z-axis fits that data. 
                                   lty.axis=1,                                    # the line type of the axes
                                   axis=TRUE,                                     # wheather to include axes
                                   grid=c('xy','xz','yz'),                        # which grids to show - added to edited version of scatterplot3d fx
                                   lty.grid.xy = 1,                               # grid line type  
                                   lty.grid.xz = 3,
                                   lty.grid.yz = 3,
                                   lwd.grid.xy = 0.5,                             # line width of grid 
                                   lwd.grid.xz = 0.5,
                                   lwd.grid.yz = 0.5,
                                   box=FALSE                                      # get rid of the box around the plot
  )
  
  # reposition & add y-axis label
  dims <- par("usr")                        # format of 'dims' is vector of: [xmin,xmax,ymin,ymax]
  x <- dims[2] - 0.03*diff(dims[1:2])       # define x position of label
  y <- dims[3] + 0.18*diff(dims[3:4])       # define y position of label
  text(x,y,"Northing (m)", srt=73)          # add label.  srt sets angle
  
  # add the legend
  legend("topright", inset=0.1,     # location and inset
         bty="n",                    # suppress legend box, 
         cex=0.8,                    # adjust legend size
         title="Location in Lake",
         c("Open Water","Tributary"), fill=c(pointclr[1],pointclr[2])
  )
  
  # add the lollipop points
  tp_plot$points3d(x=xcoord, y=ycoord, z=TP, # x y and z data
                      col="#282830",               # color of lines connecting points to lake outline
                      lwd=0.4,                     # line width of lines connecting points to lake outline
                      pch=21,                      # type of point to plot
                      bg=colcode,                  # fill color of points
                      type="h",                    # plot type = lines to the horizontal plane
                      cex=(TP)/100            # scaling of point sizes - this will need to be adjusted for each variable
  )
})
dev.off()



## Examples for other sorts of 3D plots in R:
#  - packages 'rgl', 'plot3D'
#  - http://spatial.ly/2013/05/3d-mapping-r/
#  - https://learnr.wordpress.com/2009/07/20/ggplot2-version-of-figures-in-lattice-multivariate-data-visualization-with-r-part-6/

## create vector for point color (for continuous variable)    
#pointclr <- brewer.pal(9,"YlOrRd") 
#nclr <- colorRampPalette(pointclr, space="rgb")(length(data$ch4TR))
#colornum <- cut(rank(data$ch4TR), length(nclr), labels=FALSE) 
#colcode <- nclr[colornum]                           
