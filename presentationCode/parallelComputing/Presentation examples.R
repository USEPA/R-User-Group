###
###  
###  Title:  Parallel Processing in R Presentation Examples
###  Author: Chris Grieves
###
###  Description: These are the examples that I included in my slides
###  I put them in here to make it more convenient for others to run
###


###################################################################
#####
##### Example 1: Setting up and Running a Parallel Process
#####
###################################################################

library(parallel)

#Get Number of Cores
no_cores<-detectCores()-1

#make cluster uses SOCK by default but we 
#explicitly pass it as an argument 
cl<-makeCluster(no_cores, type="PSOCK")

#parallel version of lapply, note the 
#extra argument of the cluster
results<-parLapply(cl,1:100,fun=sqrt)
class(results)
print(results[[3]])


#finally clean up
stopCluster(cl)

###################################################################
#####
##### Example 2: Running X-13 on time series in parallel
#####
###################################################################


library(parallel)        #parallel package
library(microbenchmark) #package for timing how long code takes
library(seasonal)   #"seasonal" package for running Census' X-13 in R

#Number of time series to simulate
N<-15

#Simulate Time Series
ts<-replicate(N,arima.sim(list(order = c(1,1,0), ar = 0.7), n = 200))
ts.list<-lapply(split(ts,rep(1:ncol(ts), each = nrow(ts))),
                function(x) ts(x,frequency=12,start=c(2005,1)))

#Run in Sequence
microbenchmark(result.seq<-lapply(ts.list,seas),times=1)

#Run in Parallel
cl<-makeCluster(3)
microbenchmark(result.par<-parLapply(cl,ts.list,seas),times=1)

#Stop Cluster
stopCluster(cl)

###################################################################
#####
##### Example 4: mclapply
#####
##### !!!DOES NOT WORK ON WINDOWS!!!
#####
###################################################################


library(parallel)
library(seasonal)

#Number of time series to simulate
N<-15

#Simulate Time Series
ts<-replicate(N,arima.sim(list(order = c(1,1,0), ar = 0.7), n = 200))
ts.list<-lapply(split(ts,rep(1:ncol(ts), each = nrow(ts))),
                function(x) ts(x,frequency=12,start=c(2005,1)))



#Run in Parallel
result<-mclapply(ts.list,seas,mc.cores = 15)

###################################################################
#####
##### Example 5: Inefficient Parallel Processing Example
#####
#####
###################################################################

#Create Vector of Numbers we want to apply function to
x<-1:100

#Get number of cores minus 1
no_cores<-detectCores()-1

#Set up your "Workers" to send tasks to
cl<-makeCluster(no_cores)
#cl<-makeCluster(2)

#We run the process in parallel and in sequence to compare the results 
microbenchmark(sqrt.par<-parLapply(cl,x,sqrt),times=100)

stopCluster(cl)

#Run sequentially
microbenchmark(sqrt.seq<-lapply(x,sqrt),times=100)

###################################################################
#####
##### Example 6: clusterEvalQ example
#####
###################################################################

library(parallel)

#make socket cluster
cl<-makeCluster(3,type="PSOCK")

#load MASS library on every worker
clusterEvalQ(cl,library(MASS))

#stop cluster
stopCluster(cl)

###################################################################
#####
##### Example 7: clusterExport example
#####
###################################################################

#make socket cluster of size 3
cl<-makeCluster(3)

#create vector of 10 numbers
x<-1:10

#export vector "x" to every worker in the cluster
clusterExport(cl,c("x"))

#as an example, sum the vector x on all of the workers
clusterEvalQ(cl,sum(x))

#stop cluster
stopCluster(cl)


###################################################################
#####
##### Example 7: clusterSetRNGStream example
#####
##### This function allows you to make your parallel results
##### reproducible when using random numbers. Also may be required
##### when forking since you do not have a unique seed
#####
##### Example is meant for Linux but can be run on windows by changing
##### "FORK" to "PSOCK"
#####
###################################################################

library(parallel)

cl<-makeCluster(3,type="FORK")

#Generate 1 normal random number on each cluster with same seed
clusterEvalQ(cl,rnorm(1))

#set random seed on each worker
clusterSetRNGStream(cl,iseed = 1000)

#Generate 1 normal random number on each cluster with unique
clusterEvalQ(cl,rnorm(1))

#stop cluster
stopCluster(cl)


###################################################################
#####
##### Example 8: Load Balancing
#####
##### Typically, the parallel package assigns jobs ahead of time.
##### It may happen that some of your workers finish their jobs,
##### but one still is working on several. It may be beneficial 
##### to dynamically assign jobs in this
##### 
###################################################################

#Lets create a contrived example where Load Balancing matters. 
#We simply make the system sleep for a fixed amount of time.
#In our example we use 3 workers and assign them wait times
#of c(1,..,1,10,1,...,1)
wait.times<-rep(1,10*3)
wait.times[21]<-10
print(wait.times)

#make cluster
cl<-makeCluster(3,type="PSOCK")

#In this case since jobs are preassigned, one cluster will take 
#19 seconds to finish (10+9*1). No other cores help after
#they finish theres which take 10 seconds
system.time(results.par<-clusterApply(cl,wait.times,Sys.sleep))


#In this case, we dynamically assign the wait times thus once the 
#workers with an easy assignment are finished, 
#they help to finish the remaining jobs.
system.time(results.par<-clusterApplyLB(cl,wait.times,Sys.sleep))

###################################################################
#####
##### Example 8: Copy-on-Modify with Forking
#####
##### "pryr" is a package that allows us to "look under the hood" in R
##### We use it in this example to see what memory address something is 
##### pointing to. With forking, if i create a variable, I fork and inspect
##### the address in the worker units, they will be the same until I 
##### modify them.
##### 
###################################################################

library(parallel)
library(pryr)

## create x
x<-1

#original address of variable x
address(x)

#make cluster of size 2
cl<-makeCluster(2,type="FORK")

#address of x on cluster processes
clusterEvalQ(cl,c(as.character(x),address(x)))

#modify x and check addresses
clusterApply(cl,2:3,function(y){c(as.character(x<<-y),address(x))})
