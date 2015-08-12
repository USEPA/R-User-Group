######
# functions for creating report
# created May 2014, M. Beck

######
# processes data for creating output in report
# 'dat_in' is input data as data frame
# output is data frame with converted variables
proc_fun<-function(dat_in){
  
  # convert temp to C
  dat_in$Temperature <- round((dat_in$Temperature - 32) * 5/9)
  
  # long format
  dat_in <- melt(dat_in, measure.vars = c('Restoration', 'Reference'))
  
  return(dat_in)
  
}

######
# creates linear model for data
# 'proc_dat' is processed data returned from 'proc_fun'
# output is linear model object
mod_fun <- function(proc_in) lm(value ~ variable + Year, dat = proc_in)