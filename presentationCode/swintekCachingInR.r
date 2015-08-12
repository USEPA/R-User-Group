#Caching 
#Joe Swintek June 13,2013
#######################################################################################
#										On Lists				     				  #
#######################################################################################
rm(list = ls()) #Clears the workspace
Cache<-list()   #Declare list
Cache

Cache[[1]] #out of bounds error

Cache$A #Will give a null

is.null(Cache$A) #Will give a TRUE

Cache$A<-c(10,13) #Give Cache A some Values
Cache$A
Cache[[1]]  #Usefull oddity 

Cache$Z<-'This is Cache Z' #Give Cache Z a string value
Cache$B<-list('Empty'={}) #Give Cache B a value of an empty list
Cache
#Will associate indexes with the order at which it was assigned
Cache[[2]]  #Same as Cache Z
Cache[[3]]  #Same as Cache B

length(Cache) #Number of top most elements ,i.e. 3

Cache[[4]]  #Gives an out of bounds error



#Treating a list as a Hash Table
Cache[['A']] #Same as Cache$A
Cache[['Z']] #Same as Cache$Z
Cache[['B']] #Same as Cache$B


Key<-'Z'

Cache[[Key]] #will print Cache Z
Cache[['B']][['Empty']]<-'The label is a misnomer'
Cache
Cache[['B']]

#######################################################################################
#									Recursive Fibonacci				     			  #
#######################################################################################

RecursiveFibonacci<-function(n){ #Slow
	#This gives the Fibonacci number after n steps 
    if (n<=2) return(1)
return (RecursiveFibonacci(n-1)+RecursiveFibonacci(n-2))
}

RecursiveFibonacci(1)   #Should be 1
RecursiveFibonacci(2)   #Should be 1
RecursiveFibonacci(7)   #Should be 13
RecursiveFibonacci(20)  #Should be 6765
RecursiveFibonacci(30)  #takes some time


system.time(RecursiveFibonacci(30)) #Time it takes
system.time(RecursiveFibonacci(32)) 
#######################################################################################
#						Aliasing functions (Well... kind of)					   	  #
#######################################################################################

PrintFunction<-function(Function,Args){
	#This will run a function with arguments Args
	print(Function(Args))
return()
}

PrintFunction(RecursiveFibonacci,10) #prints 55
Function<-RecursiveFibonacci
Function(10) #prints 55

#######################################################################################
#									On Caching Itself				     			  #
#######################################################################################

CacheFunction<-function(Cache,FunctionAsString,Args){
#This function will draw a function result from Cache or run the function and Cache the result
#This will return the updated Cache and print the result
#FunctionAsString must be string
#Cache is the Cache being used 
#Args is a vector of arguments for the function 

	
	Key<-FunctionAsString  #Gets the Cache Key
	Function<-get(FunctionAsString)  #Turn a sting into code of its name 
									 #You can use get to write a function that writes a function
	
	#Check to see if that Function is Cached with the args
	InCache<-!is.null(Cache[[Key]][[toString(Args)]]) #is.null checks for a null argument 
													  #toString will convert a vector to a string of its elements
													  #The ! means not in R
													  											  
	#If the function/Args is not in the Cache run it and Cache the function
	if (InCache==FALSE){
		#if (!is.null(Cache[[Key]])==FALSE){Cache[[Key]]$CasheSetUp<-TRUE} #Fixes index problem 
		Cache[[Key]][[toString(Args)]]<-Function(Args)
	}
	
	#Print the Result
	print(Cache[[Key]][[toString(Args)]])

return (Cache) #Return the Cache
}

Cache<-list()  #Reset Cache
system.time(Cache<-CacheFunction(Cache,'RecursiveFibonacci',30)) #Run the function and store the Cache
system.time(Cache<-CacheFunction(Cache,'RecursiveFibonacci',30)) #Rerun and it works!

#Test
system.time(Cache<-CacheFunction(Cache,'RecursiveFibonacci',32)) #Fails to Run...
print(Cache)

#Retry
Cache<-list()  #Reset Cache
system.time(Cache<-CacheFunction(Cache,'RecursiveFibonacci',30)) #Run the function and store the Cache
system.time(Cache<-CacheFunction(Cache,'RecursiveFibonacci',32)) #Works this time

print(Cache)


#######################################################################################
#										Global Caching 						   		  #
####################################################################################### 
CacheFunction<-function(FunctionAsString,Args){
#This function will draw a function result from Cache or run the function and Cache the result
#This will return the updated Cache and print the result
#FunctionAsString must be string
#Cache is the Cache being used And is a global
#Args is a vector of arguments for the function 

	
	Key<-FunctionAsString  #Gets the Cache Key
	Function<-get(FunctionAsString)  #Turn a sting into code of its name 
									 #You can use get to write a function that writes a function
	
	#Check to see if that Function is Cached with the args
	InCache<-!is.null(Cache[[Key]][[toString(Args)]]) #is.null checks for a null argument 
													  #toString will convert a vector to a string of its elements
													  #The ! means not in R
	#If the function/Args is not in the Cache run it and Cache the function
	if (InCache==FALSE){
		if (!is.null(Cache[[Key]])==FALSE){Cache[[Key]]$CasheSetUp<<-TRUE} #Fixes index problem 
		Cache[[Key]][[toString(Args)]]<<-Function(Args) #<<-Assigns the variable to the upper most workspace
	}
	
	#Print the Result
return(Cache[[Key]][[toString(Args)]])
}

Cache<-list()  #Reset Cache
system.time(Number<-CacheFunction('RecursiveFibonacci',30)) #Run the function and store the Cache
print(Number)

system.time(Number<-CacheFunction('RecursiveFibonacci',30)) #Rerun and it works!
print(Number)

print(Cache)

system.time(Number<-CacheFunction('RecursiveFibonacci',33)) #Try it with 33
print(Number)

system.time(Number<-CacheFunction('RecursiveFibonacci',33)) #Rerun and it works!
print(Number)

print(Cache)

#######################################################################################
#								Save and load the Cache						   		  #
#######################################################################################


save('Cache',file="MyCache.RData") #Saves Cache to file 
ls()						#look at workspace
rm('Cache')					#Delete the Cache
ls()						
load("MyCache.RData")  		#loads the Cashe into the workspace
					        #This will overide any variables that have the same name as ones in the loaded file
ls()  					    #look at workspace to see what loaded

CacheSize<-object.size(Cache) #lists the size of the data object
print(CacheSize,units='auto') #Prints the Cache size in different units 


#######################################################################################
#								Final Demonstration 								  #
#######################################################################################


Cache<-list()  #Reset Cache
RecursiveFibonacci<-function(n){ #Slow, but now cached for speed
	#This gives the Fibonacci number after n steps 
    if (n<=2) return(1)
return (CacheFunction('RecursiveFibonacci',(n-1))+CacheFunction('RecursiveFibonacci',(n-2)))
}


system.time(print(RecursiveFibonacci(30))) #Time it takes
system.time(print(RecursiveFibonacci(33))) 
system.time(print(RecursiveFibonacci(100))) 
system.time(print(RecursiveFibonacci(200))) 

length(Cache)   

CacheSize<-object.size(Cache) #lists the size of the data object
print(CacheSize,units='auto') #Prints the Cache size in different units 
























