################################################################################################################################
## 17 April 2013                                                                                                              ##
## Drs. Jake Beaulieu, US EPA and Dan Sobota, ORISE                                                                                               ##
## EPA/ORD Users Group presentation.                                                                                          ##
## Merging data in R                                                                                                         ##
################################################################################################################################


###CONCATENATE
  ?c
  data1 <- c(1,2,3,4)
  data1
  str(data1)

  #also works for characters
  data2 <- c('A','B','C','D')
  data2
  str(data2)
  
  #and vectors
  str(c(data1, data2))               #result of concatenate can be of only 1 class.  numeric promoted to character, the class
                                     #that can hold both types.
  str(as.factor(c(data1, data2)))    #but can designate as a factor.

###CBIND to merge objects by rows
  ?cbind
  #Merge two vectors
  cbind(data1, data2)
  #cbind on vectors will create an array, which can only hold one type of data.  Here the
  #numeric values were promoted to character values since that type can hold all values.
  str(cbind(data1,data2))
  
  #Be cautious applying cbind to vectors of different lengths.  The shorter vector is recycled!
  print(cbind(c('A','B','C'), c(1,2,3,4)))
  
###RBIND to merge objects by columns
  ?rbind
  #Merge two vectors
  rbind(data1, data2)
  
  #Be cautious applying rbind to vectors of different lengths.  The shorter vector is recycled!
  print(rbind(c('A','B','C'), c(1,2,3,4)))

  
###DATAFRAME
  ?data.frame
  #Similar to matrix, but can hold different object types.
  #Very commonly used.  Required for many operations, including the popular ggplot package.
  df1 <- data.frame(data1=data1, data2=data2)
  df1                     #compare to cbind(data1, data2) above.
  str(df1)
  
  #cbind produces data frames when applied to data frames
  df2 <- data.frame(data3=c('E','F','G','H'), data4=c(5,6,7,8))
  str(cbind(df1,df2))  #Note that characters are automatically converted to factors; be cautious if that is not what you intend.
  
  #a good way of pulling together separate data sets from same study
  #for example, different labs measure different aspects of the same subject
    data(iris)                                                                  #Load built-in data set
    head(iris)
    iris$subject <- rep(1:50, 3)                                                #Add another identifier
    head(iris)
    iris1 <- iris[, c('subject','Sepal.Length', 'Sepal.Width', 'Species')]      #Subset data for demonstration below
    iris2 <- iris[, c('subject', 'Petal.Length', 'Petal.Width', 'Species')]     #Subset data for demonstration below
    head(iris1)
    head(iris2)
  #make sure they have the same numbers of rows
    dim(iris1);dim(iris2)
  #cbind at look at first 6 rows.
    head(cbind(iris1, iris2))                                                   #some duplication of information, but OK.
  #what if data frames have different number of observations?
    iris3 <- iris1[iris1$Species != 'setosa', ]                       #exlcude species = setosa
    dim(iris2);dim(iris3)
    cbind(iris2, iris3)                                               #get an error.
  #What if the # of observations in the larger data frame were an even multiple of the # of observations in the smaller?
    iris4 <- iris1[iris1$Species == 'setosa', ]                       #pull out setosa, exclude all other species
    dim(iris2);dim(iris4)
    iris5<-cbind(iris2, iris4)                                        #now the shorter vector recycles!  Be carful.
    iris5
  #What if the observations were not sorted identically?
    #some coding to reverse sorting.  Pay no mind.
      iris2$Species <- factor(iris2$Species, levels=c('virginica', 'versicolor', 'setosa'))
      iris2 <- iris2[order(iris2$Species),]
    iris2                                                             #species order now reversed
    cbind(iris2, iris1)                                               #Same number of rows, but observations are matched
                                                                      #incorrectly.  Need to inspect data carefully before
                                                                      #binding.
  #cbind is fast and easy to understand, but can cause unexpected errors if not used correctly
    
  
###MATCH
  ?match
  #A way to match data using a common column of names.
  worms<-read.table("http://www.bio.ic.ac.uk/research/mjcraw/therbook/data/worms.txt",header=TRUE)  ##Worms data set from Crawley's The R Book.
  herbicides<-read.table("http://www.bio.ic.ac.uk/research/mjcraw/therbook/data/herbicides.txt",header=TRUE)  ##Herbicides data set.
  
  unique(worms$Vegetation)  #Vegetation types in the worms data set.
  
  herbicides  #Herbicide applied to vegetation type.
  
  herbicides$Herbicide[match(worms$Vegetation,herbicides$Type)]  #Matches the relevant herbicides to the vegetation types in the worms data set.
  
  worms$hb<-herbicides$Herbicide[match(worms$Vegetation,herbicides$Type)]  ##Can add column to the worms data set.
  
  head(worms)
  
  worms<-read.table("http://www.bio.ic.ac.uk/research/mjcraw/therbook/data/worms.txt",header=TRUE)  #(Resets worms to the original data set.)
  
  recs<-data.frame(worms,hb=herbicides$Herbicide[match(worms$Vegetation,herbicides$Type)])  ##Or you can create a new data frame.
  
  head(recs)
  
  
###MERGE
  ?merge
  #A less risky, and cleaner, method to merge data frames
  #Default behavior is to join data frames based on values of all variables (columns) that the data frames have in common.
    str(iris1);str(iris2)                                               #'subject' and 'Species' are common to both
    iris.merge <- merge(iris1, iris2)
    head(iris.merge)                                                    #observations are matched properly.
                                                                        #No duplicated columns.  Sorting perhaps not as expected.
  #resort to original order
    iris.merge[with(iris.merge,(order(Species, subject))),]             #now sorted by species and subject.

  #What if unique idenitifiers (subject, Species) are called different things in the two data frames?  Common when
  #different labs are producing independent data files.  For examples streams, sites, stations might all refer to same thing.
    #rename 'subject' to 'individual' in iris2.  Pay no attention.
      names(iris2)[1] = 'individual'
    str(iris1);str(iris2)                                            #only 'species' is common to both
    merge(iris1,iris2)                                               #7500 observations!  Made all possible combinations of
                                                                     #variables matched by species
  #need to specify merging variables using 'by.x' and 'by.y' arguments
    iris.merge <- merge(iris1, iris2, by.x=c('subject','Species'), by.y=c('individual', 'Species'))
    iris.merge                                                       #observations are matched properly.
  #by.x and by.y are sensitive to order.
    merge(iris1, iris2, by.x=c('Species','subject'), by.y=c('individual', 'Species'))
    #this fails because it is trying to match 'Species' with 'individual'  and 'subject' with 'Species'


  #CAUTIONARY NOTES WITH MERGE
    #Be certain both data sets use identical naming conventions
    #What is one analyst uses uppercase letters and another uses lowercase
      iris2$Species <- factor(iris2$Species, levels=c('setosa', 'versicolor', 'virginica'),
                              labels = toupper(c('setosa', 'versicolor', 'virginica')))                  #code to convert lowercase to upper case species names
      str(iris2);str(iris1)                                                                              #Note upper vs lower
      merge(iris1, iris2, by.x=c('subject', 'Species'), by.y=c('individual', 'Species'))                 #Returns no matches!
    #full names vs abbreviations can cause similar issues.  Many useful character manipulation
    #tools are available to help resolve these issues: grep, substring, strsplit
    
    #Merge and missing values
      x = data.frame(id=c('A','B','D','E','F'), x=c(9,12,14,21,8))
      y = data.frame(id=c('A','B','C','E'), y=c(8,14,19,2))
      #these data frames are of different lengths.  y contains a subset of the 'id' levels in x.
      merge(x,y)                                                            #only 3 observations returned!  Only observations
                                                                            #with observation in which values for 'id' in
                                                                            #both data frames were returned.  This could be bad!
      #retain missing values
      merge(x,y, all=TRUE)                                                        #Retain all observations
      merge(x,y, all.x=TRUE)                                                      #Retain all x observations
      merge(x,y, all.y=TRUE)                                                      #Retain all y observations
    
###MULTIPLE SIMULTANEOUS MERGES
  #Merge can only handle 2 data frames at at time.  Sequential merging is required to merge multiple data frames.
  #Create 3 data frames
      x = data.frame(id=c('A','B','D','E','F'), x=c(9,12,14,21,8))
      y = data.frame(id=c('A','B','C','E'), y=c(8,14,19,2))
      z = data.frame(id=c('A','B','C','D'), z=c(10,13,52,1))
  #2 merges required to combine x, y, and z
    newdata <- merge(x,y, all=T)                                    #first merge
    newdata.final <- merge(newdata, z, all=T)                       #second merge
    newdata.final                                                   #final combined data set
  #Not too tedious with only 3 data frames, but a pain with many data frames.  Imagine 15 different investigators all mesuring
  #different charactistics of the same sample.  14 merges required to pull all data together.

  #EXECUTE SIMULTANEOUSLY WITH LOOP
    list.of.data.frames <- list(x,y,z)                             #put data frames in loop
    merged.data <- x                                               #data frame to hold results
    for (i in list.of.data.frames) {                               #for each element of the list
      merged.data <-merge(merged.data, i, all=T)                   #merge the data frames
     }
    merged.data                                                    #everything is merged
    #Can get complicated if different by.x and by.y arguments are needed.  Best to clean up data frames prior to merging.

  #EXECUTE SIMULTANEOUSLY WITH Reduce FUNCTION
    ?Reduce
    #Reduce applies a function of two arguments cumulatively to items of a list, from left to right,
    #so as to produce on object.
      #Reduce(function, x) where x is a list
        merged.data.frame <- Reduce(function(...) merge(..., all=T), list.of.data.frames)
        merged.data.frame

  #EXECUTE SIMULTANEOUSLY WITH merge_recurse FUNCTION
    install.packages("reshape")
    library(reshape)
    ?merge_recurse
    merge_recurse(list.of.data.frames)
  
