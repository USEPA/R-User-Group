##########################################################
#
# Cross-Validation Example / K-Group Jack-knife
#
# We use perform "Leave one group out" prediction, this 
# is jack-knife prediction variance and can be used 
# for tuning parameters of a model
#
##########################################################

#packages
library(microbenchmark)
library(parallel)


######### CREATE DATA ###################

#data matrix parameters
#we will create data by simulation
num.vars<-100
num.rows<-80000

#Linear Model Noise (Normal noise with mean 0)
sigma<-50

#Create Variable Names
vars<-paste0("X",(1:num.vars))

#create coeficients randomly
coef<-sample(10:500,num.vars,replace=FALSE)

#create data matrix
DF <-as.data.frame(matrix(runif(num.rows*num.vars,-10,10),
                          nrow=num.rows,
                          ncol = num.vars,
                          dimnames=list(NULL,vars)))

#create response variable and add noise
DF$y <- (as.matrix(DF) %*% coef) + rnorm(n = num.rows,0,sigma)


####################################################################
# Global Variables
####################################################################

#create formula for model creation
form<-as.formula(paste0("y~", paste0(vars,collapse ="+" ),sep=""))

#Cross Validation Parameter
#How many cross validation folds do you want?
K<-5

#################################################################
# cross.val.one(i)
#
# Evaluates the mean square error of prediction in the i-th of K
# cross validation folds and returns the mean square error
# for that fold.
#################################################################
cross.val.one<-function(i) {
  #logical vector with data to leave out
  leave.out<- as.logical(1:nrow(DF) %% K == (i-1))
  
  #True values left out set
  y<-DF[leave.out,]$y
  
  mdl<-lm( formula = form, data=DF[!leave.out,])
  
  #Predict on left out set
  y.hat<-predict(mdl,DF[leave.out,])
  
  return(mean( (y.hat-y)^2))
}


#Benchmark results done sequentially without parallel processing
microbenchmark(results.seq<-sapply(1:K,cross.val.one),times=3,unit="s")


#Fucntion to run parallel with Socket Cluster
go_sock<-function() {  
  #Start Cluster
  cl<-makeCluster(3,type="PSOCK")
  
  #Send data, number of folds, and the formula
  clusterExport(cl,c("DF","K","form"))
  
  #Perform Cross Validation on each fold
  results.par.sock<-parSapply(cl,1:K,cross.val.one) 
  
  #Stop cluster
  stopCluster(cl)  
  return(results.par.sock)
}
#Benchmark results
microbenchmark(go_sock(),times=3,unit="s")

#Function to run FORK Cross Validation
go_fork<-function() {  
  #Start Cluster
  cl<-makeCluster(10,type="FORK")
  
  #Not needed for Forking
  #clusterExport(cl,c("DF","K","form"))
  
  #Perform Cross Validation on each fold
  results.par.fork<-parSapply(cl,1:K,cross.val.one) 
  
  #Stop cluster
  stopCluster(cl)  
  return(results.par.fork)
}
#Benchmark results
microbenchmark(go_fork(),times=5,unit="s")