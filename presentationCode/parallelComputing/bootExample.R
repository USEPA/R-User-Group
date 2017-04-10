

library(parallel)
library(data.table)

#Subset Iris dataset
x <- iris[which(iris[, 5] != "setosa"), c(1, 5)]

#Bootstrap Function
bootery<-function(...) {
  ind <- sample(100, 100, replace = TRUE)
  result1 <- glm(x[ind, 2] ~ x[ind, 1], family = binomial(logit))
  coefficients(result1)
}

#start sampling in parallel
start.time<-proc.time()

  #Create Cluster
  cl<-makeCluster(3)
  
  #Send dataset to workers
  clusterExport(cl,"x")
  
  #perform bootstrap sampling
  samps.par<-clusterApply(cl,1:10000,bootery)
  
  #shut down cluster
  stopCluster(cl)
end.time<-proc.time()
end.time-start.time

system.time(samps.seq<-lapply(1:10000,bootery))
