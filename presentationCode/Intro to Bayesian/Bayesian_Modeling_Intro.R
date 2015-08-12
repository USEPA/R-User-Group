#### Will Barnett, Neptune and Company, July 2015
#### This script demonstrates a couple of basic Bayesian models in R


library(rjags)
# OR
# library(R2WinBUGS))


#### Set working directory - change as necessary
# setwd("~/Documents/Neptune/Projects/EPA RUG/Intro to Bayesian/")


#### Example 1
#### Using R and JAGS to model moth mortality.
#### Example data set taken from the Royle and Dorazio (2006) book

## Mortality counts
mothData <- data.frame(y = c(1,4,9,13,18,20, 0,2,6,10,12,16),
                       sex = c(rep('male',6), rep('female',6)),
                       ldose = log(rep(c(1,2,4,8,16,32), 2)))
## Sample size for the data above
nSamp = 20
dataList <- list(n = nrow(mothData), nSamp = nSamp, y = mothData$y, x = mothData$ldose, 
                z = mothData$sex)
params <- list('beta0','beta1','beta2')
inits <- list(beta0 = rnorm(1), beta1 = rnorm(1), beta2 = rnorm(1))


#### JAGS model
#### This is a text file saved with .jag extension (for JAGS), OR .txt / .bug (for WinBUGS)
#### This part doesn't need to be done in R necessarily, but it's nice to be able to edit 
#### the model file without opening another text editor.
modelFilename <- 'model.jag'
# OR
# modelFilename = 'model.bug'
cat('
    model {
    
    beta0 ~ dnorm(0, 0.001)
    beta1 ~ dnorm(0, 0.001)
    beta2 ~ dnorm(0, 0.001)

    for (i in 1:n) {
    y[i] ~ dbin(p[i], nSamp)
    logit(p[i]) <- beta0 + beta1 * x[i] + beta2 * z[i]
    }
    }
    ', fill=TRUE, file=modelFilename)


#### Fit the model. This is slightly diferent syntax in JAGS and WinBUGS.
#### The 'samps' object is where WinBUGS or JAGS is actually opened in the background
#### and used for computation.
#### For JAGS:
params <- c("beta0","beta1","beta2","p")
jags.mod <- jags.model(file = "model.jag", data = dataList, inits = inits,
                       n.chains = 3)
jags.samps <- coda.samples(model = jags.mod, variable.names = params, n.iter = 5000, 
                      thin = 10, n.burnin = 1000)
summary(jags.samps)
#### For WinBUGS:
# bugs.samps = bugs(data, inits, params, model.file=modelFilename,
#           n.chains=1, n.iter=50000, n.burnin=10000, n.thin=5)
# summary(bugs.samps)

## Plot of a single coefficient - in this case beta2 (the dose coefficient)
plot(jags.samps[,2], main = "Beta1")
# plot(jags.samps[,1], main = "Beta0")


#### Example 2 
#### Using MCMCpack to estimate the same model
library(MCMCpack)
## The data needs to be in a slightly different form: 1's and 0's instead of successes/failure
mothData2 <- matrix(-999,nrow=1, ncol = ncol(mothData))
for(i in 1:nrow(mothData)){ # i = 6
  if(! (mothData[i,"y"] %in% c(0,20)) ){
    rowsSuccess <- matrix(unlist(rep(mothData[i,],times = mothData[i,"y"])),
                          nrow = mothData[i,"y"], ncol = ncol(mothData),
                          byrow = TRUE)
    rowsSuccess[,1] <- 1
    rowsFailure <- matrix(unlist(rep(mothData[i,],times = 20 - mothData[i,"y"])),
                          nrow = 20 - mothData[i,"y"],
                          ncol = ncol(mothData), byrow=TRUE)
    rowsFailure[,1] <- 0
    mothData2 <- rbind(mothData2, rbind(rowsSuccess,rowsFailure))
  }else if( mothData[i,"y"] == 20 ){
    rowsSuccess <- matrix(unlist(rep(mothData[i,],times = mothData[i,"y"])),
                          nrow = mothData[i,"y"], ncol = ncol(mothData),
                          byrow = TRUE)
    rowsSuccess[,1] <- 1
    mothData2 <- rbind(mothData2, rowsSuccess)
  }else {
    rowsFailure <- matrix(unlist(rep(mothData[i,],times = 20 - mothData[i,"y"])),
                          nrow = 20 - mothData[i,"y"],
                          ncol = ncol(mothData), byrow=TRUE)
    rowsFailure[,1] <- 0
    mothData2 <- rbind(mothData2, rowsFailure)
  }
}
mothDataAdj <- data.frame(mothData2[-1,])
names(mothDataAdj) <- names(mothData)
mothDataAdj$sex <- ifelse(mothDataAdj$sex == 2, "male", "female")
mcmcpack.samps <- MCMClogit(y ~ ldose + sex, data = mothDataAdj,
                            burnin = 1000, mcmc = 5000, thin = 10,
                            b0=0, B0=.001)
summary(mcmcpack.samps)



#### GLM fit with the data
mothData$total <- 20
glm.fit <- glm(y / total ~ ldose + sex, data = mothData, family = "quasibinomial")
## An overdispersed binomial actually fits this better than the typical binomial.
summary(glm.fit)
## Notice that the coefficient estimates are fairly close using glm() and MCMCpack here.
## The intercept coefficient and SD are a bit different for the JAGS/BUGS model.
## The trace plot for beta0 shows some correlation -- perhaps the Gibbs sampler didn't converge.





