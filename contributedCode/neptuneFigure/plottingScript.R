# LIBRARY
library(ggplot2)

# LOAD DATA
#ch4RateBest and ch4RateBestError is the methane ebullion rate and ebullition rate error, respectively
#ch4Diff and ch4Diff95CI is the methane diffusion rate and diffusion rate error, respectively
load("contributedCode/neptuneFigure/methaneFigure.RData")  # object is loaded as 'methaneFigure'.  Contains emission rate data.
emis.final <- methaneFigure  # give new name


load("contributedCode/neptuneFigure/poolElevationFigure.RData") # object loaded as 'poo'.  Contains pool elevation data.
all.levels <- poo  # 'poo' is silly, give new name.



# PLOT
# This code produces the faceted plot without the secondary y-axis.  Use as a guide.
# Best data: mg ch4/m2/day
ggplot(emis.final,
  aes(date.time.deployment + ((date.time.logger.end - date.time.deployment)/2), # center of observation period
      ch4RateBest)) +  # methane ebullition rate
  geom_point() +
  geom_errorbar(aes(ymax = ch4RateBest + ch4RateBestError,  # add ebullition error bars
                    ymin = ch4RateBest - ch4RateBestError)) +
  geom_point(aes(date.time.deployment + ((date.time.logger.end - date.time.deployment)/2), ch4Diff), # methane diffusion
             color = "red") +
  geom_errorbar(aes(ymax = ch4Diff + ch4Diff95CI, ymin = ch4Diff - ch4Diff95CI), color = "red") + # diffusion error bars
  geom_segment(aes(x = date.time.deployment, # segment denotes observation period
                   xend = date.time.logger.end,
                   y = ch4RateBest,
                   yend = ch4RateBest)) +  
  geom_rect(  # rectangle to highlight period of special interest.
    xmin=as.numeric(as.POSIXct("2015-09-14 09:00", tz = "UTC")),  # note tz specification
    xmax=as.numeric(as.POSIXct("2015-09-15 09:00", tz = "UTC")),  # note tz specification
    ymin = 0,
    ymax=10000,  # fill entire y-axis range
    fill = "black",
    alpha = 1/50) +  # semi transparent.
  ylab(expression(Methane~Ebullition~(mg~ CH[4]~ m^{-2}~ day^{-1}))) +
  facet_wrap(~fsite, scales = c("free_y")) +  # wrap by ordered factor
  theme_bw() + 
  theme(axis.title.x = element_blank(),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank())

ggsave(filename="contributedCode/neptuneFigure/bestCh4EbullitionRate.tiff",
       width=10, height=7, units="in",
       dpi=1200,compression="lzw")

# I wonder if the diffusive and ebullitive emission rates should be in the same column,
# with a new column added for 'emission.type'.  Then we could call 
# geom_point(aes(color = emission.type)).  I think this approach would also give us
# a legend.



# Plot of pool elevations
ggplot(all.levels, aes(RDateTime, Elevation)) + 
  geom_line()



