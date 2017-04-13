# SCRIPT TO READ AND PLOT DISSOLVED OXYGEN AND TEMPERATURE DATA
# COLLECTED BY THE US ARMY CORPS OF ENGINEERS AT WILLIAM H HARSHA
# (STATION 20001) IN 2015.

# LIBRARIES
library(rLakeAnalyzer)  # This package provided a wrapper for filled.contour()
library(readxl)  # for reading excel file
library(dplyr)  # data manipulation
library(reshape2) # melt and dcast
library(ggplot2)


# Read and format raw data from USACE
usace <- read_excel(path = "contributedCode/neptuneTO76TD3/Jake B-EFR 2015 profile data.xlsx", skip = 14)
colnames(usace)  <- c("station", "date.time", "depth.ft", "wtr", "doobs")
usace <- mutate(usace, depth.ft = as.numeric(depth.ft))

# Format date for quick ggplot figures.
usace <- mutate(usace, rDate = as.Date(substr(date.time, 1, 8), format = "%Y%m%d")) %>%
  arrange(station, rDate, depth.ft)

# Format datetime column for rLakeAnalyzer package
usace <- mutate(usace, 
                datetime = paste(
                  substr(date.time, 1, 4), # extract year
                  "-", # add dash between year and month
                  substr(date.time, 5, 6), # extract month
                  "-", # add dash between month and day
                  substr(date.time, 7, 8), # extract day
                  " ", # add space between day and hour
                  substr(date.time, 11, 12), # extract hour
                  ":", # add colon between hour and minute
                  substr(date.time, 13, 14), # extract minute
                  sep = "")
)

# Subset site (dam site, 20001) and data of interest
usace.dam <- filter(usace, station == "2EFR20001") %>%
  select(depth.ft, wtr, doobs, rDate, datetime)


# Plot water temperature and Dissolved oxygen profiles for general inspection
ggplot(usace.dam, aes(depth.ft, wtr)) + #temp, looks good
  geom_line() +
  scale_x_reverse() +
  coord_flip() +
  facet_wrap(~rDate)

ggplot(usace.dam, aes(depth.ft, doobs)) + #Dissolved Oxygen, looks good
  geom_line() +
  scale_x_reverse() +
  coord_flip() +
  facet_wrap(~rDate)

# Format for heat map with rLakeAnalyzer
m.usace.dam <- select(usace.dam, -rDate) %>%  # remove rDate
  filter(depth.ft %in% seq(0,90,5)) %>% # only use data from 5 ft depth incriments.  Other depths are spotty.
  mutate(datetime = as.POSIXct(datetime), # POSIXct time format required
         depth.m = (depth.ft/3.28)) %>%  # convert depth to meters
  select(-depth.ft) %>%  # exclude depth in ft
  melt(id.vars = c("depth.m", "datetime")) # melt

c.usace.dam <- dcast(m.usace.dam, datetime ~ variable + depth.m) # cast

# Create separate dataframes for temperature and DO data
c.usace.dam.wtr <- select(c.usace.dam, datetime, # create dataframe with wtr
                          grep(pattern = "wtr", colnames(c.usace.dam))) # extract wtr

c.usace.dam.do <- select(c.usace.dam, datetime, # create dataframe with wtr
                          grep(pattern = "doobs", colnames(c.usace.dam))) # extract DO

#Plot default figures
tiff("contributedCode/neptuneTO76TD3/output/figures/tempProfile.tif", res=1200, compression="lzw", 
     width=6, height=6, units='in')
wtr.heat.map(c.usace.dam.wtr, 
             key.title = title(main = "Celsius", cex.main = 1, line=1),
             plot.title = title(ylab = "Depth (m)"))
dev.off()


tiff("contributedCode/neptuneTO76TD3/output/figures/doProfile.tif", res=1200, compression="lzw", 
     width=6, height=6, units='in')
wtr.heat.map(c.usace.dam.do, key.title = title(main = "mg/L", cex.main = 1, line=1),
             plot.title = title(ylab = "Depth (m)"))
dev.off()

