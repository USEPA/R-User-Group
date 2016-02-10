# LIBRARY
library(ggplot2)

# LOAD DATA
load("contributedCode/neptuneFigure/methaneFigure.RData")  # object is loaded as 'poo'
emis.final <- poo  # 'poo' is silly, give new name

# LETS FABRICATE AN ERROR ESTIMATE.  WILL CALCULATE TRUE ERROR ESTIMATE LATER.
emis.final$error  <- emis.final$ch4RateBest * 0.05  # Assume 5% error

# Best data: mg ch4/m2/day
ggplot(emis.final,
  aes(date.time.deployment + ((date.time.logger.end - date.time.deployment)/2), # center of observation period
      ch4RateBest)) +  # methane emission rate
  facet_wrap(~fsite, scales = c("free_y")) +  # wrap by ordered factor
  geom_rect(  # rectangle to highlight period of special interest.
    xmin=as.numeric(as.POSIXct("2015-09-14 09:00", tz = "UTC")),  # note tz specification
    xmax=as.numeric(as.POSIXct("2015-09-15 09:00", tz = "UTC")),  # note tz specification
    ymin = 0,
    ymax=10000,  # fill entire y-axis range
    fill = "black",
    alpha = 1/50) +  # semi transparent.
  geom_point() +
  geom_errorbar(aes(ymax = ch4RateBest + error,  # add error bars
                ymin = ch4RateBest - error)) +
  geom_segment(aes(x = date.time.deployment, # segment denotes observation period
                   xend = date.time.logger.end,
                   y = ch4RateBest,
                   yend = ch4RateBest)) + 
  ylab(expression(Methane~Ebullition~(mg~ CH[4]~ m^{-2}~ day^{-1}))) +
  theme_bw() + 
  theme(axis.title.x = element_blank(),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank())

ggsave(filename="contributedCode/neptuneFigure/bestCh4EbullitionRate.tiff",
       width=10, height=7, units="in",
       dpi=1200,compression="lzw")
