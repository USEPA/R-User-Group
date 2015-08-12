# R snippets of code
#1. read & write .dbf file
#2. write csv file
#3. remove all objects
#4. subsetting observations & selecting all variables
#5. creating a list
#6. using substring function
#7. exluding observations based on variable value using negation ! operator
#8. creating table with a logical T/F indicator object, not understand syntax
#9. creating table with sum of margins
#10. paste: Concatenate vectors after converting to character
#11. another example of negation ! operator
#12. create a new variable with as many entries (rows) as an existing variable
#13. check to see if have sites with more than one data record (multiple visits)
#14. add column to existing dataframe & make text in that column all uppercase
#15. create a variable and recoding it values using a list
#16. side-by-side histograms & recoding numerical variable to categorical
#17. merging two dataframes that have different variable names so use by.x and by.y
#18. recoding variables example to create new variable taken from QuickR
#19. get session information sessionInfo()
#20. Combining character with numeric modes therefore dataframe is needed
#21. Two ways, a global and local, to round
#22.  Order (sort) data
#23.  Aggregate to get summary stats
#24.  Compare two empirical cumulative distribution functions
#25.  Generate summary stats using library reshape
#26.  Grouping data in plots
#27.  Two ways to put Greek mu into axis title
#28.  Setting font size in ggplot2
#29.  How to subscript in axis label requires brackets
#30.  Obtain five number summary as data frame that shows n
#31.  Recode an existing value of a variable
#32.  Head/summary function indexed by brackets
#33.  Use of brackets to identify or act on elements in a dataframe or matrix
#34.  change order of data frame columns based on their class

#1. read .dbf file
library(foreign)
hu12land_ds1<-read.dbf(file="wbdhu12_LRSS_LANDUSE_clip.dbf")
write.dbf(gis0206conduct.ts.yr, file='L:/Lab/GISData/GIS-User/GIS-User-ma-zz/mmcmanus/LinkedMicromaps_mgm/gis0206conduct.ts.yr')

#2. write csv file
write.table(land_tbl1,file='WMD_x_LANDUSE_CO.csv', sep=',', col.names=NA)

#3. remove all objects
rm(list=ls(all=TRUE))

#4. subsetting observations & selecting all variables
huc5050006<-subset(results, huc4==5050006, select=site_id:ymarinus)

#5. creating a list
# Create Random_Watershed variable based on Watershed for use in estimates later
SiteData$Random_Watershed <- SiteData$WATERSHED
levels(SiteData$Random_Watershed) <- list(
    "South Branch Potomac"="South Branch Potomac",
    "North Branch Potomac"="North Branch Potomac",
    "Cacapon/Shenandoah Hardy"=c("Cacapon", "Shenandoah Hardy"),
    "Potomac Direct Drains/Shenandoah Jefferson"=c("Potomac Direct Drains",
    "Shenandoah Jefferson"), "Upper New/James"=c("Upper New", "James"),
    "Tygart Valley"="Tygart Valley", "West Fork"="West Fork",
    "Monongahela/Dunkard"=c("Monongahela", "Dunkard"),
    "Cheat/Youghiogheny"=c("Cheat","Youghiogheny"),
    "Upper Ohio North/Upper Ohio South"=c("Upper Ohio North", "Upper Ohio South"),
    "Middle Ohio North"="Middle Ohio North",
    "Middle Ohio South"="Middle Ohio South",
    "Little Kanawha"="Little Kanawha", "Greenbrier"="Greenbrier",
    "Lower New"="Lower New", "Gauley"="Gauley", "Upper Kanawha"="Upper Kanawha",
    "Elk"="Elk", "Lower Kanawha"="Lower Kanawha", "Coal"="Coal",
    "Upper Guyandotte"="Upper Guyandotte", "Lower Guyandotte"="Lower Guyandotte",
    "Tug Fork"="Tug Fork", "Big Sandy/Lower Ohio"=c("Big Sandy", "Lower Ohio"),
    "Twelvepole"="Twelvepole")

#6. using substring function
SiteData$Stratum <- factor(substr(as.character(SiteData$EPA_ID),1,2) )
levels(SiteData$Stratum)
addmargins( table(SiteData$WATERSHED,SiteData$Stratum) )

#7. exluding observations based on variable value using negation ! operator
evaluse <- !SiteData$FINAL=='NN'

#8. creating table with a logical T/F indicator object, not understand syntax
table(SiteData$WATERSHED[evaluse])

#9. creating table with sum of margins
addmargins(table(SiteData$STATUSCODES, SiteData$FINAL))

#10. paste: Concatenate vectors after converting to character.
SiteData$Watershed_SO <- factor(paste(as.character(SiteData$WATERSHED),
           as.character(SiteData$STREAMORDER), sep=" SO_"))
levels(SiteData$Watershed_SO)

#11. another example of negation ! operator
SiteData$Use_9701 <- SiteData$SAMPLINGCYCLE == 1 &     # use only cycle 1 sites
                SiteData$FINAL != 'NN' &    # exclude Not needed sites
                SiteData$FINAL != 'IF' &    # exclude Ohio River sites, IF=Incorrect Frame
                SiteData$FINAL != 'WW' &    # exclude Upper Kanawha 1997 sites, WW=Wrong Watershed
                SiteData$FINAL != 'RD'      # exclude randomly deselected sites
                
#12. create a new variable with as many entries (rows) as an existing variable
SiteData$Wgt_9701 <- adjwgt(SiteData$Use_9701,rep(1,nrow(SiteData)),
         SiteData$Watershed_SO,framesum_9701)
         
#13. check to see if have sites with more than one data record (multiple visits)
table(duplicated(SiteData$EPA_ID))   # No duplicates

#14. add column to existing dataframe & make text in that column all uppercase
ion_ds1$WS_CLASS<-toupper(ion_ds1$ws_class) #makes uppercase so use that in strip.text.x of pcp

#15. creating a new variable and recoding its values
# Create a Target/Non-target variable
results$TNT <- results$Status
levels(results$TNT) <- list(Target=c("Sampled", "Inaccessible", "Flooded"),
                            NonTarget=c("Intermittent", "NoStream",
                               "Pond", "Tidal", "NonWadeable"))

#16. creating side-by-side histograms & recoding a numerical variable to nominal variable
#side-by-side histograms from:http://sas-and-r.blogspot.com/
ds = read.csv("http://www.math.smith.edu/r/data/help.csv")
head(ds)
dim(ds)
ds$gender = ifelse(ds$female==1, "female", "male")
head(ds)
library(lattice)
histogram(~ cesd | gender, data=ds)

#17. merging two dataframes that have different variable names so use by.x and by.y
permityr_ws_ds1<-merge(ws_n95_ds1, mean_permit_yr_ds1, by.x="siteid_dnr", by.y="SITEID_DNR")

#18. recoding variables example taken from QuickR
# create 2 age categories
mydata$agecat <- ifelse(mydata$age > 70,
c("older"), c("younger"))

# another example: create 3 age categories
attach(mydata)
mydata$agecat[age > 75] <- "Elder"
mydata$agecat[age > 45 & age <= 75] <- "Middle Aged"
mydata$agecat[age <= 45] <- "Young"
detach(mydata)

#19. get session information:
sessionInfo()

#20. combining character with numeric modes therefore dataframe is needed
site_resids<-data.frame(siteid_ds3,rstudent.modely2)

#21.  Two ways, a global and local, to round
options(digits=2) #does globally
round_any(135, 10) #does locally using reshape library

#22.  Order (sort) data ex. from UCLA site
sort1.hsb2 <- hsb2[order(read) , ] #N.B. need that comma

#23.  Aggregate to get summary stats + QuickR example
cond_fivenum<-aggregate(results_ts_yr$CONDUCT, by = list(results_ts_yr$huc8), FUN = fivenum)
cond_summary<-aggregate(results_ts_yr$CONDUCT, by = list(results_ts_yr$huc8), FUN = summary)
attach(mtcars)
aggdata <-aggregate(mtcars, by=list(cyl,vs), 
  FUN=mean, na.rm=TRUE)
print(aggdata)
detach(mtcars)

#24.  Compare two empirical cumulative distribution functions
#from:  http://sas-and-r.blogspot.com/2009/08/example-78-plot-two-empirical.html
ds <- read.csv("http://www.math.smith.edu/sasr/datasets/helpmiss.csv")
attach(ds)
names(ds)
summary(pcs)
plot(ecdf(pcs[female==1]), verticals=TRUE, pch=46)
lines(ecdf(pcs[female==0]), verticals=TRUE, pch=46)
legend(20, 0.8, legend=c("Women", "Men"), lwd=1:3)
detach(ds)

#from:  http://stackoverflow.com/questions/6839956/how-do-i-plot-multiple-ecdfs-using-ggplot
library(plyr)
library(ggplot2)
d.f <- data.frame(   grp = as.factor( rep( c("A","B"), each=40 ) ) ,   val = c( sample(c(2:4,6:8,12),40,replace=TRUE), sample(1:4,40,replace=TRUE) )   )
d.f <- arrange(d.f,grp,val)
d.f.ecdf <- ddply(d.f, .(grp), transform, ecdf=ecdf(val)(val) )
p <- ggplot( d.f.ecdf, aes(val, ecdf, colour = grp) )
p + geom_step() 

d.f <- data.frame(   grp = as.factor( rep( c("A","B"), each=120 ) ) ,   grp2 = as.factor( rep( c("cat","dog","elephant"), 40 ) ) ,   val = c( sample(c(2:4,6:8,12),120,replace=TRUE), sample(1:4,120,replace=TRUE) )   )
d.f <- arrange(d.f,grp,grp2,val)
d.f.ecdf <- ddply(d.f, .(grp,grp2), transform, ecdf=ecdf(val)(val) )
p <- ggplot( d.f.ecdf, aes(val, ecdf, colour = grp) )
p + geom_step() + facet_wrap( ~grp2 ) 


#25.  Generate summary stats using library reshape
#from:  http://statmethods.wordpress.com/
options(digits = 3)
library(reshape)
# define and name the statistics of interest
stats <- function(x)(c(N = length(x), Mean = mean(x), SD = sd(x)))
# label the levels of the classification variables (optional)
mtcars$am   <- factor(mtcars$am, levels = c(0, 1), labels = c("Automatic", "Manual"))
mtcars$gear <- factor(mtcars$gear, levels = c(3, 4, 5),
                      labels = c("3-Cyl", "4-Cyl", "5-Cyl"))
# melt the dataset
dfm   <- melt(mtcars,
              # outcome variables
              measure.vars = c("mpg", "hp", "wt"),
              # classification variables
              id.vars = c("am", "gear"))

# statistics for the entire sample
cast(dfm, variable ~ ., stats)
# statistics for cells defined by transmission type
cast(dfm, am + variable ~ ., stats)
# statistics for cells defined by number of gears
cast(dfm, gear + variable ~ ., stats)
# statistics for cells defined by each am x gear combination
cast(dfm, am + gear + variable ~ ., stats)

#26.  Grouping data in plots
#http://www.ling.upenn.edu/~joseff/rstudy/summer2010_ggplot2_intro.html
#Groups of data can be defined in two ways: as combinations of aesthetic settings, or explicitly with the argument group.
ggplot(mpg, aes(displ, hwy, colour=factor(cyl))) + geom_point() + stat_smooth(method="lm")


#27.  Two ways to put Greek mu into axis title
spcond_plot1_bw + xlab("Watershed Type") + ylab(expression(paste("ln(Specific Conductance, ",mu,"S/cm)")))
z2=z1 + labs(x="Ln (Sulfate Concentration, (mg/L))", y="Ln (Specific Conductivity ("* mu ~"S/cm))", colour="Watershed Type")

#28.  Setting font size in ggplot2
pcp1.a<-pcp1 + facet_grid(. ~ WS_CLASS) + labs(colour = "Watershed Type")
#the facet_grid option crosses ws_type1 factor with ws_class factor to make small multiples of pcp
pcp1.a + labs(y="Re-scaled Values") +opts(legend.position = "top", legend.title.align = "center", legend.direction = "vertical", #legend.title = theme_blank(), removes title
                                          axis.text.x = theme_text(size = 18, face = "bold"),
                                          strip.text.x = theme_text(size = 21, face = "bold"),
                                          axis.title.x = theme_text(size = 21, face = "bold"), axis.text.y = theme_text(size = 18, face = "bold",),
                                          axis.title.y = theme_text(size = 21, face = "bold", angle = 90), legend.text = theme_text(size = 18, face = "bold"),
                                          legend.title = theme_text(size = 21, face = "bold"))
#size 18 and 21 worked, but size 21 and 24, respectively, produced crowded x-axis

#29.  How to subscript in axis label requires brackets
so4_plot1 + ylab(expression(bold(paste("ln(So"[4], ",mg/L)")))) + xlab("Watershed Type")


#30.  Obtain five number summary as data frame that shows n
library(ggplot2)
#tip from QuickR blog  http://statmethods.wordpress.com/
# define and name the statistics of interest  
stats <- function(x)(c(N = length(x), Mean = mean(x)))  

statsq <-function(x)(c(N = length(x), Min = min(x), Q1 = quantile(x,c(.25)),
                       Median = quantile(x,c(.5)), Q3 = quantile(x,c(.75)),
                       Max = max(x)))

# melt the dataset  
eco_ds1.dfm   <- melt(eco_ds1,  
                      #outcome variables  
                      measure.vars = c("COND"),  
                      # classification variables  
                      id.vars = c("ecoregl3", "dataset"))

# statistics for cells defined by each manufacturer x model combination  
cast(eco_ds1.dfm, ecoregl3 + dataset + variable ~ ., stats) 
cast(eco_ds1.dfm, ecoregl3 + variable ~ ., stats)

cast(eco_ds1.dfm, ecoregl3 + dataset + variable ~ ., statsq)

#31.  Recode an existing value of a variable
# Combine 66 with 67 since it has only one site
#Note formate of code:  give the dataframe and variable, state the
#condition of that dataframe and variable, and then assign new value
results$LEVEL_III_ECOREGION[results$LEVEL_III_ECOREGION == 66] <- 67

#32.  head/summary function indexed by brackets
summary(results[,69:71])

#33.  Use of brackets to identify or act on elements in a dataframe or matrix
wsa_npl<-subset(wsa_r1, wsa_r1$ECOWSA9=="NPL")
str(wsa_npl)
npl.lonlatdd<-cbind(wsa_npl$LON_DD,wsa_npl$LAT_DD)
head(npl.lonlatdd)
npl.dis<-rdist.earth(npl.lonlatdd, miles = FALSE, R = NULL)
#npl.dis is a 84 x 84 distance matrix
head(npl.dis) #returns first 6 rows & 84 columns of matrix
#N.B. that where row i = col i is sometimes 0 & other times very, very small number
upper.npl.dis<-col(npl.dis) > row(npl.dis)
#believe that comparison of col to row indices creates a logical matrix
#of the upper triangle 
head(upper.npl.dis)
#returns bottom half of matrix as false and upper half as true

# histogram of all pairwise distances. 
hist( npl.dis[upper.npl.dis])
#creates histogram of element in npl.dis that are true
summary(as.vector(npl.dis[upper.npl.dis])) #add code to select npl.dis > 0

#example code for distances came from:
#http://www.r-bloggers.com/great-circle-distance-calculations-in-r/

#34.  change order of data frame columns based on their class
clss <- sapply( data, class )
ord <- order( clss )
ordereddata <- clss[ , ord ]

