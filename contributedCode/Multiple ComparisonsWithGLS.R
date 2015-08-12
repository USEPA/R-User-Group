#************************************************************************
#          		MultipleComparisonsWithGLS.R
#************************************************************************
#
#  Brief description: This script explores multiple comparisons using a
#  generalized least squares regression model with a multi-level factor
#  variable. 
#  
#
#
#  Packages required:
#  nlme, multcomp, MASS
#  
# 
#
#  Keywords (less than 10):
#  Multiple comparisons, gls, regression, factor, multcomp, generalized least squares
#
#
#
#  EPA Contact Information
#  Name: 
#  Phone Number: 
#  E-mail Address: 
#  
#		
#
#  Is data available upon request? Yes/No
#  
#
#
#  Date script was written: Feb. 13, 2014
#
#
#
##-------------------------------------------------------------------------

#### Clean up workspace
rm(list=ls())

#### Include packages.
library(nlme); library(multcomp); library(MASS)


#### Setup some fake data.
set.seed(1111)
site <- rep(c("A","B","C","D","E","F"),each = 20) # Specify site levels
siteMns <- c("A"=10,"B"=20,"C"=35,"D"=20,"E"=15,"F"=20) # Declare true site means.
resp <- as.vector(mvrnorm(20,mu = siteMns, Sigma = diag(c(2,4,6,4,2,4)))) # Grab random values by site.
error <- rnorm(length(site),0,0.5) # Introduce some more error
dat <- data.frame("y"=resp + error, "site" = as.factor(site)) # Make a data frame
aggregate(y~site, dat, summary)

# This script works the same with an unbalanced design:
if(FALSE){
  dat <- dat[-c(1,40),]
}

#### Use gls() to setup a model using the 6-level factor as a predictor.
glsModel1 <- gls(y ~ site, data = dat)
anova(glsModel1) # There is clearly evidence that means by site differ in some capacity.
summary(glsModel1) # The p-values are all 'significant', but that is misleading. See below.

# The estimates for each listed coefficient are from t-tests (really Wald tests)
# with the null hypothesis that the difference between the reference level mean (Intercept)
# and the other factor level mean is zero. Since site 'A' has a true mean of 10 and
# no other site has a true mean of 10, we expect these p-values to be 'significant'.
# But that does not mean that all the levels of the factor have different means. To check this,
# we need a multiple comparisons test that will test the pairwise differences. Doing this be re-ordering
# the factor level several times and re-running the gls() model will not inflate the standard errors, 
# and this will bring the familywise confidence level down. 

#### Note that if we re-order the factor levels, the p-values change. But the standard errors don't account
#### for the fact that we're potentially running several tests. Post-hoc analysis like this can be dangerous.
dat$site <- relevel(dat$site, ref = "B")
glsModel2 <- gls(y ~ site, data = dat)
anova(glsModel2) # This is identical to the anova above with 'A' as the reference.
summary(glsModel2) # The coefficient for site 'D' is not significantly different from the Intercept


#### Multiple comparisons procedures
glht(glsModel1, linfct = mcp(site = "Tukey")) # Doesn't work, as you know.
## Run the following lines. These introduce methods for 'gls' objects.
model.matrix.gls <- function(object, ...){
  model.matrix(terms(object), data = getData(object), ...)  
}
model.frame.gls <- function(object, ...){
  model.frame(formula(object), data = getData(object), ...)  
}
terms.gls <- function(object, ...){
  terms(model.frame(object),...)  
}
# The line below gives pairwise comparisons now.
# Note that the above performs t-tests for all pairwise differences.
multCompTukey <- glht(glsModel1, linfct = mcp(site = "Tukey")) 
