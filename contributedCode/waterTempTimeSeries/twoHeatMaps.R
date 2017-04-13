
# This code uses a modified version of filled.contour called filled.contour3 and
# a separate function for creating legends called filledlegend.
# Both were created by Carey McGilliard, Ian Taylor, and Bridget Ferris.

# Find modified function code and an example Neptune used as a starting point here:
# http://wiki.cbr.washington.edu/qerm/sites/qerm/images/1/16/Filled.contour3.R
# http://wiki.cbr.washington.edu/qerm/sites/qerm/images/2/25/Filled.legend.R
# http://wiki.cbr.washington.edu/qerm/sites/qerm/images/b/bb/Example_4-panel_v1a.R
# The accompanying files include further modfications of the McGilliard et al code
# to adjust spacing and legend details.

# source the code that generates the necessary dataframes
source("contributedCode/neptuneTO76TD3/readUsaceSonde.R")

#Source the modified functions for filled contour and legend
source("contributedCode/neptuneTO76TD3/filledcontour3.R")
source("contributedCode/neptuneTO76TD3/filledlegend.R")

# create new graphic with two contour plots
tiff("contributedCode/neptuneTO76TD3/output/figures/both.tif", res=1200, compression="lzw", 
     width=3, height=6, units='in')

#plot.new() is necessary if using the modified versions of filled.contour
plot.new()

######################################################################

# First plot: set region for plotting
par(new = "TRUE",              
    plt = c(0.18,0.8,0.55,0.95),  # using plt instead of mfcol (compare
                                  # coordinates in other plots)
    las = 1,                      # orientation of axis labels
    cex.axis = .8,                # size of axis annotation
    tck = -0.02,                  # major tick size and direction, < 0 means outside
    mgp = c(3, .4, 0))            # control spacing for title, axes, labels

# Top plot: the filled contour for temp
wtr <- c.usace.dam.wtr
depths <- get.offsets(wtr)
n <- nrow(wtr)
wtr.dates <- wtr$datetime
wtr.mat <- as.matrix(wtr[, -1])
y <- depths
filled.contour3(wtr.dates, y, wtr.mat, 
                ylim = c(max(depths), 0), nlevels = 100, 
                color.palette = colorRampPalette(c("violet", 
                                                   "blue", "cyan", "green3", 
                                                   "yellow", "orange", "red"), 
                                                 bias = 1, space = "rgb"), 
                ylab = "", key.title = title(main = "Celsius", cex.main = .5, line=1),
                plot.title = title(ylab = "Depth (m)", line = 1.4))

######################################################################

# Define region for top legend:
par(new = "TRUE",
    plt = c(0.85,0.9,0.55,0.95),   
    las = 1,
    cex.axis = 0.8,
    cex.main = 0.8,
    mgp = c(3, .7, 0)
    )

# Add top legend
filled.legend(
  x = wtr.dates,
  y = depths,
  z = wtr.mat,
  color.palette = colorRampPalette(c("violet", "blue", "cyan", "green3", 
                                     "yellow", "orange", "red"), 
                                   bias = 1, space = "rgb"),
  xlab = "",
  ylab = "",
  xlim = range(wtr.dates),
  ylim = c(max(depths), 0),
  plot.title = title(main = "Celsius", line = .5)  # line argument adjusts spacing
  )

# Place label A
par(xpd = NA)
text(x=-16, y=31, "A", cex = 1.0) 


######################################################################

# Define region for second plot:
par(new = "TRUE",
    plt = c(0.18,0.80,0.05,0.45),
    las = 1,
    cex.axis = 0.8,
    mgp = c(3, .4, 0)
    )

# Bottom plot: the filled contour for do
wtr <- c.usace.dam.do
depths <- get.offsets(wtr)
n <- nrow(wtr)
wtr.dates <- wtr$datetime
wtr.mat <- as.matrix(wtr[, -1])
y <- depths
filled.contour3(wtr.dates, y, wtr.mat, ylim = c(max(depths), 
                                                0), nlevels = 100, 
                color.palette = colorRampPalette(c("violet", 
                                                   "blue", "cyan", "green3", 
                                                   "yellow", "orange", "red"), 
                                                 bias = 1, space = "rgb"), 
                ylab = "", key.title = title(main = "Celsius", line=1),
                plot.title = title(ylab = "Depth (m)", line = 1.4))

######################################################################

# Define region for second legend
par(new = "TRUE",
    plt = c(0.85,0.9,0.05,0.45),   
    las = 1,
    cex.axis = 0.8,
    cex.main = 0.8,
    mgp = c(3, .7, 0)
    )

# Add second legend
filled.legend(
  x = wtr.dates,
  y = depths,
  z = wtr.mat,
  color.palette = colorRampPalette(c("violet", "blue", "cyan", "green3", 
                                     "yellow", "orange", "red"), 
                                   bias = 1, space = "rgb"),
  xlab = "",
  ylab = "",
  xlim = range(wtr.dates),
  ylim = c(max(depths), 0),
  plot.title = title(main = "mg/L", line = .5)
  )

# Place label B
par(xpd = NA)
text(x=-16, y=16, "B", cex = 1.0) 


dev.off()




