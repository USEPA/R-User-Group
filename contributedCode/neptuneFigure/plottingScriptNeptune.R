#************************************************************************
#          		Faceted GGPlot with Secondary Axis
#************************************************************************
#
#  Brief description:
#  This script utilizes a function to combine two ggplots into a faceted plot with a secondary axis.
#  
#
#
#  Packages required:
#  ggplot2, grid, gtable
#  
# 
#
#  Keywords (less than 10):
#  ggplot, facets, secondary axis
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
#  Date script was written: February 2016
#
#
#
##-------------------------------------------------------------------------

# LOAD REQUIRED LIBRARIES
library(ggplot2) # version 2.0.0 or above!
library(grid)
library(gtable)

# SET THE WORKING DIRECTORY
#setwd("~/Repositories/EPA-ORD_EP-C-13-022/trunk/2015/TO 60/Task B/TD 4/")

# LOAD DATA
load("contributedCode/neptuneFigure/methaneFigure.RData")  # object is loaded as 'poo'.  Contains emission rate data.
#load("data/methaneFigure.RData")
load("contributedCode/neptuneFigure/poolElevationFigure.RData") # object also loaded as 'poo'.  Contains pool elevation data.
#load("data/poolElevationFigure.RData")

# FORMAT METHANE DATA
emis.final <- methaneFigure  # 'poo' is silly, give new name

  ## Place the diffusive and ebullitive emission rates in the same column
  df.emis <- emis.final[,-c(6,7)]
  names(df.emis)[c(4,5)] <- c("ch4Rates","ch4RatesError")
  df.emis$ch4RateType <- "Ebullition"
  df.diff <- emis.final[,-c(4,5)]
  names(df.diff)[c(4,5)] <- c("ch4Rates","ch4RatesError")
  df.diff$ch4RateType <- "Diffusion"
  emis.final <- rbind(df.emis,df.diff)
  
  ## Make the type of methane emission an ordered factor (for colouring the different points in the plot)
  emis.final$ch4RateType <- factor(emis.final$ch4RateType, ordered = T, levels = c("Ebullition","Diffusion"))

# FORMAT ELEVATION DATA
all.levels <- poo  # 'poo' is silly, give new name.

# GRAB THE METHANE MIN AND MAX DATES - will use to limit the graph of the elevation data so it will have the same x-range as the methane data when initially plotted
min.date <- min(emis.final$date.time.deployment)  # note: all.levels actually has more extreme min and max dates
max.date <- max(emis.final$date.time.logger.end)

# DEFINE THE FUNCTION TO PRODUCE FACETED GGPLOT WITH SECONDARY AXES
ggplotSecondaryAxis <- function(plot1,plot2){  # 'plot2' gets repeatedly plotted onto 'plot1's space
  
  ## extract gtables from both plots
  g1 <- ggplot_gtable(ggplot_build(plot1))
  g2 <- ggplot_gtable(ggplot_build(plot2))
  
  ## add elevation plot's panel to each of the methan facets
  tops <- lefts <- c()
  grobs <- list()
  for(p in 1:length(unique(emis.final$fsite))) {  
    
    pp <- c(subset(g1$layout, name==paste0("panel-",p), se=t:r)) # grab each methane facet's panel 
    tops <- c(tops, pp$t) # record the row that each panel is contained in
    lefts <- c(lefts, pp$l) # record the column that each panel is contained in
    
    grobs[[p]] <- g2$grobs[[which(g2$layout$name=="panel")]] # create a list that is just the panel grob of plot2 repeated for each panel that exists in plot1
  }
  g1 <- gtable_add_grob(g1, grobs, tops, lefts, tops, lefts, -Inf) # note that -Inf tells the grid to plot the added grobs below the existing grobs in the methane plot. It is therefore important to set the plot background to transparent in the methane plot so that the elevation plot will show up when put behind it.
  
  # get elevation plot's y-axis title & ready it to be on the right side instead of the left
  g2.ytitle <- g2$grobs[[which(g2$layout$name=="ylab")]]
  g2.ytitle$children[[1]]$hjust <- 1 - g2.ytitle$children[[1]]$hjust # revert hjust
  g2.ytitle$children[[1]]$x <- grid::unit(1, "npc") - g2$grob[[7]]$children[[1]]$x
  
  # get elevation plot's y-axis (ticks & tick labels) & reposition them for the right side
  tick.length <- plot2$theme$axis.ticks.length 
  g2.lax <- g2$grobs[[which(g2$layout$name == "axis-l")]]$children[[2]] # grab the actual y-axis grob from the plot2
  g2.lax$widths <- rev(g2.lax$widths)
  g2.lax$grobs <- rev(g2.lax$grobs) 
  # ticks
  g2.lax$grobs[[1]]$x <- g2.lax$grobs[[1]]$x - unit(1, "npc") 
  g2.lax$grobs[[2]]$children[[1]]$hjust <- 1 - g2.lax$grobs[[2]]$children[[1]]$hjust 
  # tick labels
  g2.lax$grobs[[2]]$children[[1]]$x <- unit(1, "npc") - g2.lax$grobs[[2]]$children[[1]]$x 
  
  # add columns and fill with y-axis grobs on farthest side of entire plot
  g1 <- gtable_add_cols(g1, g1$widths[g1$layout[which(g1$layout$name=="axis_l-1"),]$l], length(g1$widths)-2) # space for ylab2's
  g1 <- gtable_add_grob(g1, list(g2.lax,g2.lax,g2.lax), c(4,8,12), rep(length(g1$widths)-2,3), name="axis_r-3") #add right axes (the secondary axis) to the three left most panels
  g1 <- gtable_add_cols(g1, g1$widths[g1$layout[which(g1$layout$name=="ylab"),]$l], length(g1$widths)-2) # space for ylab2 label
  g1 <- gtable_add_grob(g1, g2.ytitle, g1$layout[which(g1$layout$name=="ylab"),]$t, length(g1$widths)-2, g1$layout[which(g1$layout$name=="ylab"),]$b, name="ylab2")
  
  # create grob of just the tick marks of the secondary y-axis
  g2.ticks <- g2.lax
  g2.ticks$grobs[[1]]$x <- g2.ticks$grobs[[1]]$x + tick.length + tick.length + tick.length + unit(2,"pt") # ticks
  g2.ticks$grobs[[2]]$children[[1]]$label <- rep("",length(g2.ticks$grobs[[2]]$children[[1]]$label)) # tick labels
  g2.ticks$grobs[[2]]$children[[1]]$x <- rep(unit(0,"cm"),length(g2.ticks$grobs[[2]]$children[[1]]$x)) # tick labels no width
  
  # add columns and fill with secondary y-axis tick marks to the other panels
  g1 <- gtable_add_cols(g1, unit(6,"pt"), 7) # space for ticks after second column of panels
  g1 <- gtable_add_grob(g1, list(g2.ticks,g2.ticks,g2.ticks), c(4,8,12), rep(8,3), name="axis_r-2") #add ticks
  g2.ticks$grobs[[1]]$x <- g2.ticks$grobs[[1]]$x - tick.length - tick.length
  g1 <- gtable_add_cols(g1, unit(6,"pt"), 5) # space for ticks after first column of panels
  g1 <- gtable_add_grob(g1, list(g2.ticks,g2.ticks,g2.ticks), c(4,8,12), rep(6,3), name="axis_r-1") #add ticks
  
  return(g1)
}

# IF you only want ebullition data, 
# 1) subset the df and,
# 2) add the following to the end of the plotting function: + guides(colour = FALSE), and 
# 3) change the title to 'Ebullition' instead of 'Emission'
#emis.final <- subset(emis.final, ch4RateType=='Ebullition')

# FACETED METHANE PLOT
methanePlot <- ggplot(emis.final,
                aes(date.time.deployment + ((date.time.logger.end - date.time.deployment)/2), # center of observation period
                    ch4Rates)) +  # methane emission rates
  geom_point(aes(colour=ch4RateType), size=1.5) + 
  scale_colour_manual(values=c("black","red"), name="") + 
  geom_errorbar(aes(ymax = ch4Rates + ch4RatesError,  # add error bars
                    ymin = ch4Rates - ch4RatesError, colour=ch4RateType)) +
  geom_segment(aes(x = date.time.deployment, # segment denotes observation period
                   xend = date.time.logger.end,
                   y = ch4Rates,
                   yend = ch4Rates, colour=ch4RateType)) +  
  scale_fill_manual(values=c("black","red"), name="") + 
  geom_rect(  # rectangle to highlight period of special interest.
    xmin=as.numeric(as.POSIXct("2015-09-14 09:00", tz = "UTC")),  # note tz specification
    xmax=as.numeric(as.POSIXct("2015-09-15 09:00", tz = "UTC")),  # note tz specification
    ymin = 0,
    ymax=10000,  # fill entire y-axis range
    fill = "black",
    alpha = 1/50) +  # semi transparent.
  ylab(expression(Methane~Emission~(mg~ CH[4]~ m^{-2}~ day^{-1}))) +
  facet_wrap(~fsite, scales = c("free_y")) +  # wrap by ordered factor
  theme_bw() + 
  theme(axis.title.x = element_blank(),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(),
        panel.background=element_rect(fill = "transparent",colour = NA),
        plot.background=element_rect(fill = "transparent",colour = NA),
        legend.position="bottom",
        legend.key = element_blank()) + guides(colour = guide_legend(override.aes = list(size=2,linetype=0))) #+ guides(colour = FALSE) 

# ELEVATION PLOT
elevationPlot <- ggplot(all.levels, aes(RDateTime, Elevation, colour="gray")) + 
  scale_colour_manual(values=c('#d3d3d3'), guide=FALSE) + 
  geom_line() + theme_bw() + xlim(min.date, max.date) + 
  theme(axis.title.x = element_blank(),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(),
        plot.background=element_rect(fill = "transparent",colour = NA))

# CREATE NEW PLOT THAT COMBINES METHANE AND ELEVATION PLOTS
plots <- ggplotSecondaryAxis(methanePlot,elevationPlot)

# SAVE PLOT TO FILE
plot.new()
tiff(filename="documents/Neptune documents/Ch4EmissionRates.tiff",
       width=10, height=7, units="in",
       res=1200,compression="lzw")
grid.draw(plots)
dev.off()
