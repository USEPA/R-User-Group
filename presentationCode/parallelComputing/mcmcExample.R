# 
# Tutorial 2-2.R
# Parallel MC Chains in JAGS
#


#--- Libraries ---
library(rjags)
library(parallel)

#--- Create True Model Parameters ---
N      <- 1e3
m.tru  <- 2
b.tru  <- 1
sd.tru <- 1

#--- Create Model Data ---
x      <- seq(0,1,length.out=N)   #independent variable
y.tru  <- m.tru*x + b.tru         #true mean function
y.obs  <- rnorm(N, y.tru, sd.tru) #observed with noise

#--- MCMC Parameters ---
n.iter   <- 10e3
n.chains <- 3
n.thin   <- 10


#--- Model Specification ---
#Simple linear model with normal errors
modeltxt <- "model{
    m~dnorm(0,10)
    b~dnorm(0,10)
    sd~dunif(0,10)
    tau <- pow(sd,-2)

    yhat <- x*m+b

    for(obsj in 1:N){
        y.obs[obsj] ~ dnorm( yhat[obsj], tau)}
}"

#"

#####################################################
######## SIMPLE  RUN OF JAGS   ######################

#get start time
simple.start.time <- proc.time()

#initialize JAGS model
lm.model <- jags.model(textConnection(modeltxt),
                        data=list(x=x,y.obs=y.obs, N=N),
                             n.chains=n.chains,
                             n.adapt=100)

coda.samples(lm.model, c("m", "b", "sd"), n.iter=n.iter, thin=n.thin)

simple.end.time <- proc.time()
simple.dtime <- simple.end.time - simple.start.time
simple.dtime
                                       

#####################################################
######## PARALLEL RUN OF JAGS ######################


#--- Create Initialize Model With JAGS and run MC chain ---
coda.samples.wrapper <- function(j) {

    temp.model <- jags.model(textConnection(modeltxt),
                             data=list(x=x,y.obs=y.obs, N=N),
                             inits=list(.RNG.name="base::Wichmann-Hill",
                                        .RNG.seed=j),
                             n.chains=1,
                             n.adapt=100)
    coda.samples(temp.model, c("m", "b", "sd"), n.iter=n.iter, thin=n.thin)
}

#--- set start time ----
parallel.start.time <- proc.time()


#--- Set Up Parallelization
#no_cores <- detectCores() - 1   #traditionally should use this
no_cores <- n.chains #set number of chains 
                     #as number of cores, in our case 3
cl       <- makeCluster(no_cores)


#--- YOU MUST EXPORT THE NECESSARY R OBJECTS TO ALL CORES ---
clusterExport(cl, list("x", "y.obs", "N", "n.iter", "n.thin", "modeltxt"))

#--- MAKE SURE THE LIBRARY "rjags" IS LOADED IN EACH CLUSTER ---
# Function below evaluates code "library(rjags) on all clusters
clusterEvalQ(cl, library(rjags))

#--- Use clusterApply() to set the random number seed 
#    on each and run "coda.samples.wrapper" to simulate
#    chains on each core. The results are returned as a list
par.samples <- clusterApply(cl, 1:n.chains, coda.samples.wrapper)

#We need to combine all the chains into a single "mcmc.list"
#S3 type of object
for(i in 1:length(par.samples)) { par.samples[[i]] <- par.samples[[i]][[1]] }

#--- Set class so that it is object of type "mcmc.list" so we can use
#generic functions with it (see R object oriented programming types)
class(par.samples) <- "mcmc.list"

parallel.end.time <- proc.time()
parallel.dtime <- parallel.end.time - parallel.start.time
parallel.dtime

##########################################################
###### Compare Simple Versus Parallel Times     ##########

print(simple.dtime)
print(parallel.dtime)
print(simple.dtime/parallel.dtime)
