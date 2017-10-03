# Spatial Data Manipulation, Analysis and Visualization in R: The Basics
Marc Weber  
Wednesday, February 18 2015  


## The Roadmap {.smallest .columns-2}
<div class="notes">
- Talk will be a methods talk, not a demonstration of project, will go over a lot of foundation stuff many people may already know or have heard, but will hopefully have some interesting stuff later in talk even for those used to doing spatial work in R

- I've been using R for about a decade, started doing spatial work in R about 5 years ago

- Impetus for doing spatial work in R was documenting workflow in same programming language most folks I work with use - which is R

- Now do about 50% or more of spatial work in R, but even when I don't use R, I typically do use R - will explain in last slides
</div>
- Structure of spatial data in R
- Reading / Writing Spatial Data
- Visualizing Spatial Data
- Analysing Spatial Data

<img src="roadmap.jpg" alt="Roadmap" style="width: 300px;"/>

## Explosion of Spatial Packages in R Recently
<div class="centered">
![](RUserGroupWebinar_files/figure-html/unnamed-chunk-1-1.png) 
</div>

- Spatial package dependencies on sp package in R (July 2011) from Roger Bivand talk
http://geostat-course.org/system/files/monday_slides.pdf 

## Get to know sp
<div class="notes">
- sp package is foundation for spatial objects in R, used by most spatial packages

- Key point is that sp uses S4 new style classes 

- S4 classes have formal definitions for components, or slots, that classes contain 

- These formal constraints are useful for spatial objects (i.e. bounding boxes have to have x and y mins an maxes, spatial things have coordinate reference systems, etc)
</div>
<div class="centered">
![](RUserGroupWebinar_files/figure-html/unnamed-chunk-2-1.png) 
</div>

## sp slots mirror the structure of ESRI shapefiles
Mandatory Components                                       Optional Components
---------------------------------------------------------  -------------
.shp - actual geometry of feature                          .prj - CRS and projection info in WKT format
.shx - shape index - binary file giving position index     .sbn and .sbx- spatial indexing files
.dbf - attribute information, stored in dBase IV format    .xml - metadata file

## Get to know sp objects {.smaller .columns-2}
<div class="notes">
- Here we're loading in a spatial points data frame of norwegian peaks over 2000 meters that comes with the rgdal package (the r implementation of the geospatial data abstraction library), one of workhorse spatial packages in R

- Remember that sp uses new style classes - the class of an object in R determines the method used

- Therefore, we can use plot and summary on sp spatial objects and get appropriate results
</div>

```r
library(rgdal)
data(nor2k)
class(nor2k)
```

```
[1] "SpatialPointsDataFrame"
attr(,"package")
[1] "sp"
```

```r
slotNames(nor2k)
```

```
[1] "data"        "coords.nrs"  "coords"      "bbox"        "proj4string"
```

```r
plot(nor2k, axes=T, 
main='Peaks in Norway over 2000 meters')
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-3-1.png" title="" alt="" width="425px" />

## Get to know sp objects {.smaller}
<div class="notes">
- Summary method with sp akin to summary on data frame, but provides some useful overview information for spatial objects like the class, the bounding box, coordinate reference system, synopsis of attributes in data table
</div>

```r
library(rgdal)
data(nor2k)
summary(nor2k)
```

```
Object of class SpatialPointsDataFrame
Coordinates:
           min     max
East    404700  547250
North  6804200 6910050
Height    2001    2469
Is projected: TRUE 
proj4string :
[+proj=utm +zone=32 +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0]
Number of points: 300
Data attributes:
      Nr.             Navn             Kommune         
 Min.   :  1.00   Length:300         Length:300        
 1st Qu.: 75.75   Class :character   Class :character  
 Median :150.50   Mode  :character   Mode  :character  
 Mean   :150.50                                        
 3rd Qu.:225.25                                        
 Max.   :300.00                                        
```

## Get to know raster {.smallest .columns-2 .build}
<div class="notes">
- A big advantage of the raster package is that it can work with data on disk that's too large to load into memory for R

- raster package creates objects from files that only contain information about the structure of the data, like number of rows and columns, extent, but doesn't try to read all the cell values into memory

- Processes data in chunks when running computations on rasters
</div>
>- sp has grid and pixel classes, but recommend raster package
>- Raster data structure divides region into rectangles / cells 
>- Cells can store one or more values for the cells

```r
library(raster)
r <- raster(ncol=10, nrow=10)
values(r) <- c(1:100)
plot(r, 
main='Raster with 100 cells')
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-5-1.png" title="" alt="" width="450px" />

## Making data spatial {.smaller .build}
<div class="notes">
- Let's say we have a table in an R dataset or a csv that has coordinate information - we can 'promote' to a spatial object in sp
- In this case, we're just looking at a data frame of US cities in the maps package
</div>

```r
library(maps);library(sp);require(knitr)
data(us.cities)
knitr::kable(us.cities[1:5,])
```



name         country.etc       pop     lat      long   capital
-----------  ------------  -------  ------  --------  --------
Abilene TX   TX             113888   32.45    -99.74         0
Akron OH     OH             206634   41.08    -81.52         0
Alameda CA   CA              70069   37.77   -122.26         0
Albany GA    GA              75510   31.58    -84.18         0
Albany NY    NY              93576   42.67    -73.80         2

```r
class(us.cities) # simple data frame
```

[1] "data.frame"

## Making data spatial {.smaller .build}
### Promote a data frame with coordinates to an sp object

```r
library(maps); library(sp); data(us.cities)
coordinates(us.cities) <- c("long", "lat") 
class(us.cities) 
```

[1] "SpatialPointsDataFrame"
attr(,"package")
[1] "sp"

```r
plot(us.cities, pch = 20, col = 'forestgreen', axes=T,
     xlim=c(-125,-70), ylim=c(26,55))
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-7-1.png" title="" alt="" width="200px" style="display: block; margin: auto;" />

## Maps package provides convenient stock maps {.smaller .columns-2}
<div class="notes">
- It's handy to use existing administrative units in R or from online databases when mapping in R
</div>

```r
library(maps)
par(mfrow=c(1,1)); map()
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-8-1.png" title="" alt="" width="275px" />

```r
map.text('county','oregon')
map.axes()
title(main="Oregon State")
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-8-2.png" title="" alt="" width="275px" />

Loading administrative backgrounds from Global Administrative Areas is another good option (http://gadm.org/)

## Coordinate reference systems in R {.smaller .columns-2}
<div class="notes">
- Coordinate reference systems  can sometimes be an area of confusion for those working with spatial data in R who don't come from a GIS background

- You need to put together several different essenatial components defined for coordinate reference systems, such as spheroid, datum projection parameters, beyond scope of this talk to delve into all the details
</div>
- CRS can be geographic (lat/lon), projected, or NA in R
- Data with different CRS MUST be transformed to common CRS in R
- Projections in sp are provided in PROJ4 strings in the proj4string slot of an object
- http://www.spatialreference.org/

- Useful rgdal package functions:
    * projInfo(type='datum')
    * projInfo(type='ellps')
    * projInfo(type='proj')

<img src="CRS.png" alt="CRS" style="width: 550px;"/>


## Coordinate reference systems in R 
<div class="notes">
- Show how we can lookup projection information in RStudio with makeEPSG and ogrInfo
</div>
- For sp classes:
    - To get the CRS:  proj4string(x)
    - To assign the CRS:
          - proj4string(x) <- CRS("init=epsg:4269")
          - proj4string(x) <- CRS("+proj=utm +zone=10 +datum=WGS84")
    - To transform CRS
          - x <- spTransform(x, CRS("+init=epsg:4238"))
          - x <- spTransform(x, CRS(proj4string(y)))
- For rasters:
    - To get the CRS:  projection(x)
    - To transform CRS:  projectRaster(x)

## Reading and writing spatial data {.build}
- Best method for reading and writing shapefiles is to use readOGR() and writeOGR() in rgdal

```r
library(rgdal)
setwd('K:/GitProjects/RUserWebinar')
HUCs <- readOGR('.','OR_HUC08')
writeOGR(HUCs, '.','HUC', driver='ESRI Shapefile')
```
- Best method for reading and writing rasters is raster package

```r
library(raster)
r <- raster('clay.tif')
# crop it
r <- crop(r, extent(-1000000, 2000000, 100000, 3000000) )
writeRaster(r, 'clay_smaller.tif',format='GTiff')
```

## Understanding slot structure { .build}
<div class="notes">
- Knowing how information is stored in slots, we can pull out area in a couple different ways from a spatial polygons data frame 
- Here we'll start looking at some example analyses using a spatial polygons data frame of USGS Hydrologic Units in Oregon
- Using the structure function is a nice way to get to understand slots in S4 spatial objects
</div>

```r
require(sp);require(rgeos);load("K:/GitProjects/RUserWebinar/Data.RData")
# A spatial PolygonsDataFrame has 5 slots:
str(HUCs, 2)
```

```
Formal class 'SpatialPolygonsDataFrame' [package "sp"] with 5 slots
  ..@ data       :'data.frame':	91 obs. of  3 variables:
  ..@ polygons   :List of 91
  ..@ plotOrder  : int [1:91] 78 1 32 87 81 24 26 11 38 3 ...
  ..@ bbox       : num [1:2, 1:2] -2297797 2191569 -1576981 2914667
  .. ..- attr(*, "dimnames")=List of 2
  ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
```

## Understanding slot structure { .build}

```r
require(sp);require(rgeos);load("K:/GitProjects/RUserWebinar/Data.RData")
# Each polygon element has 5 of it's own slots:
str(HUCs@polygons[[1]])[]
```

```
Formal class 'Polygons' [package "sp"] with 5 slots
  ..@ Polygons :List of 1
  .. ..$ :Formal class 'Polygon' [package "sp"] with 5 slots
  .. .. .. ..@ labpt  : num [1:2] -1805054 2272669
  .. .. .. ..@ area   : num 9.13e+09
  .. .. .. ..@ hole   : logi FALSE
  .. .. .. ..@ ringDir: int 1
  .. .. .. ..@ coords : num [1:13339, 1:2] -1782485 -1782433 -1782329 -1782239 -1782084 ...
  ..@ plotOrder: int 1
  ..@ labpt    : num [1:2] -1805054 2272669
  ..@ ID       : chr "0"
  ..@ area     : num 9.13e+09
```

```
NULL
```

## Understanding slot structure {.smaller .build}

```r
require(sp);require(rgeos); load("K:/GitProjects/RUserWebinar/Data.RData")
# Here we get a vector of area for features in HUCs spdf
area(HUCs[1:4,])
```

```
[1] 9128424113 2997942053 6065238017 4861449846
```

```r
# Total Area - gArea function in rgeos gives same result
sum(area(HUCs))
```

```
[1] 312620322426
```

```r
# Area of a particular feature
HUCs@polygons[[1]]@Polygons[[1]]@area
```

```
[1] 9128424113
```

## Getting areas of polygons {.smaller .build}

```r
require(sp);load("K:/GitProjects/RUserWebinar/Data.RData")
plot(HUCs, axes=T, main='HUCs in Oregon')
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-14-1.png" title="" alt="" width="400px" style="display: block; margin: auto;" />

## Getting areas of polygons {.smaller .columns-2 .build}
<div class="notes">
- Here we leverage the area slot of the polgons slot to write a simple function to generate a percent of total area for each HUC in our spatial polygons data frame
- First we use sum and sapply over area slots of polygon slots to derive our total area of all features
- Next, we again use sapply over our area slots of polygon slots but dividing by total area for each feature to get percent area
- Finally, we apply the function to our HUCs by indexing to just plot HUCs larger than a defined percent of area in a different color
</div>
- Highlight larger HUCs using Area function

```r
require(sp)
load("K:/GitProjects/RUserWebinar/Data.RData")
plot(HUCs, axes=T, main='HUCs in Oregon')
# Function to calculate percent of area
AreaPercent <- function(x) {
  tot_area <- sum(sapply(slot(x, "polygons"),
                         slot, "area"))
  sapply(slot(x, "polygons"), slot, 
         "area") / tot_area * 100
}  
# just plot bigger HUCs
plot(HUCs[AreaPercent(HUCs) > 1,], add=T, 
     col='Steel Blue')
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-15-1.png" title="" alt="" width="400px" />

## Spatial Operations on vector data {.build .smaller .columns-2}
<div class="notes">
- Now we'lll step through some examples of spatial operations on vector data
- Here we're looking at a spatial points data frame of stream gages in Oregon
- First step in any spatial analysis should ALWAYS be setting everything to same CRS
- Here we use ggplot from ggplot2 package to plot our gages and color the points by log of flow
</div>

```r
require(ggplot2)
load("K:/GitProjects/RUserWebinar/Data.RData")
# Take a look at some USGS stream gages for PNW
gages@data[1:5,5:8]
```

```
##    LON_SITE LAT_SITE    NearCity     FLOW
## 1 -123.3178 42.43040 Grants Pass 3402.544
## 2 -122.6011 42.42763 Eagle Point   60.201
## 3 -119.9233 42.42488    Altamont   34.272
## 4 -122.6011 42.40819 Eagle Point  104.177
## 5 -122.5373 42.40263 Eagle Point   72.511
```

```r
# Explicitly set CRS for layers
gages <- spTransform(gages, 
                     CRS('+init=epsg:2991'))
# Locations of gages
ggplot(gages@data, aes(LON_SITE, LAT_SITE)) + 
  geom_point(aes(color=log10(FLOW))) + 
  coord_equal()
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-16-1.png" title="" alt="" width="450px" />

## Spatial Operations on vector data {.build .smaller .columns-2}
### Spatial Indexing 
<div class="notes">
- Here we can see we subset our HUCs by those less than a certain longitude using an attribute index of HUCs whose longitude is less than 400,000
- Then we plot all our stream gages over that - our gages extend beyond the bounds of our subset HUCs
</div>
- Select gages within a set of HUCs

```r
load("K:/GitProjects/RUserWebinar/Data.RData")
gages_proj <- spTransform(gages, 
                          CRS('+init=epsg:2991'))
HUCs_proj <- spTransform(HUCs, 
                         CRS('+init=epsg:2991'))
HUCs_proj$LON <- coordinates(HUCs_proj)[,1]
HUCs_west <- HUCs_proj[HUCs_proj$LON < 400000, ]
options(scipen=3)
plot(gages_proj, axes=T, col='blue')
plot(HUCs_west, add=T)
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-17-1.png" title="" alt="" width="400px" style="display: block; margin: auto;" />

## Spatial Operations on vector data {.build .smaller .columns-2}
### Spatial Indexing 
<div class="notes">
- It's as simple as an index operation to subset the gages to just those within our new HUCs
</div>
- Select gages within a set of HUCs


```r
load("K:/GitProjects/RUserWebinar/Data.RData")
gages_west <- gages_proj[HUCs_west,]
plot(HUCs_west, axes=T)
plot(gages_west, add=T, col='blue')
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-18-1.png" title="" alt="" width="400px" style="display: block; margin: auto;" />

## Spatial Operations on vector data {.build .smaller}
### Overlay and Aggregation - What HUCs are gages located in?
<div class="notes">
- Another typical GIS question we might ask of spatial data is what HUCs are our gages located in?
- Here we roll together couple simple steps in a function to update our gages data slot with the ID of the HUC each gage is within
- The first line in our function uses the 'over' from sp to overlay our gages and HUCs - what it returns is a data frame containing the HUC attributes corresponding to each of our 622 stream gages
- We then have to take the additional step of rolling this result back into the data slot of our gages spatial points data frame
</div>

```r
load("K:/GitProjects/RUserWebinar/Data.RData")
OverUpdate <- function(points, polys) {
  pointpoly <- over(points, polys)
  points@data <- data.frame(points@data, pointpoly)
}
gages_proj@data <- OverUpdate(gages_proj, HUCs_proj)
head(gages_proj@data[,c(3,12)])
```

```
                                     STATION_NM    HUC_8
1                ROGUE RIVER AT GRANTS PASS, OR 17100308
2   N F LTL BUTE CR AB INTKE CANL LKECREEK OREG 17100307
3                  HONEY CREEK NEAR PLUSH,OREG. 17120007
4 SOUTH FORK LITTLE BUTTE CR NR LAKECREEK,OREG. 17100307
5      NO FK LITTLE BUTTE CR NR LAKECREEK,OREG. 17100307
6             TWELVEMILE CREEK NEAR PLUSH,OREG. 17120007
```

## Spatial Operations on vector data {.smaller .build}
### Overlay and Aggregation 
<div class="notes">
- Here rather than identifying which HUC each gage goes with, we can summarize some attribue of gages for all the gages within each HUCs
- In our over function here, you can see we specify a field of our gages to use (flow), and then give a function parameter of mean to over as well
</div>
- What is mean streamflow based on gages within each HUC?

```r
load("K:/GitProjects/RUserWebinar/Data.RData")
HUCs_proj$StreamFlow <- over(HUCs_proj,gages_proj[8],fn = mean)
head(HUCs_proj@data[!is.na(HUCs_proj@data$StreamFlow),])
```

```
      HUC_8 SUM_ACRES      LON      FLOW
2  17050103   1498689 716737.1  32.78000
5  17050107    956848 669298.4 930.73000
8  17050110   1264239 631925.6 622.90075
10 17050116   1554027 572126.3 130.40100
11 17050117    607018 633179.4 304.05640
12 17050118    375002 617941.8  31.72333
```

## Attribute joining {.smaller.build}
<div class="notes">
- Often we want to combine spatial data with attributes from another table or a csv file
- Here we'll use a data frame of cities with population information
</div>

```r
load("K:/GitProjects/RUserWebinar/Data.RData")
head(cities[,c(3:4, 7:8)])
```

```
          NAME ST_ABBREV POP_2000 POP2007
1      Astoria        OR     9813    9901
2    Warrenton        OR     4096    4413
3     Gearhart        OR      995    1033
4      Seaside        OR     5900    5982
5   Clatskanie        OR     1528    1664
6 Cannon Beach        OR     1588    1669
```

## Attribute joining {.smaller.build}
<div class="notes">
- Next we'll join to our data slot of gages spatial points data frame in a way that does not scramble the ordering between data and spatial slots
- match or join are good options to use - I typically use match.  Be very careful about using merge - you'll need to make sure your data slot and spatial slot are ordered the same or you'll scramble results
</div>

```r
require(plyr);load("K:/GitProjects/RUserWebinar/Data.RData")
# We can use match or join to connect to our spatial gages 
# gages$POP2007 <- cities$POP2007[match(gages$NearCity, cities$NAME)]
# OR set a common name field and use join from plyr
names(gages)[7] <- "NAME"
gages@data <- join(gages@data, cities)
head(gages@data[,c(3,18)])
```

```
                                     STATION_NM POP2007
1                ROGUE RIVER AT GRANTS PASS, OR   24753
2   N F LTL BUTE CR AB INTKE CANL LKECREEK OREG    6819
3                  HONEY CREEK NEAR PLUSH,OREG.   20493
4 SOUTH FORK LITTLE BUTTE CR NR LAKECREEK,OREG.    6819
5      NO FK LITTLE BUTTE CR NR LAKECREEK,OREG.    6819
6             TWELVEMILE CREEK NEAR PLUSH,OREG.   20493
```

## Spatial operations on vector data {.build .smaller .columns-2}
### Dissolving
<div class="notes">
-  Some of the common tasks we want to do in a GIS like dissolving, buffering, unioning, intersecting we can do in R using the rgeos package
- Here we use the cut function with quanitles to generate four 'longitude' bins
- We then apply those bins as a parameter in the rgeos gUnaryUnion function to dissolve our HUCs on four classes or longitude and generate four larger units out of the HUCs 
</div>
- create four bins of longitude values using coordinate data from HUCs

```r
library(rgeos); library(rgdal)
lps <- coordinates(HUCs)
IDFourBins <- cut(lps[,1], quantile(lps[,1]), 
                  include.lowest=TRUE)
regions = gUnaryUnion(HUCs,IDFourBins)
regions = SpatialPolygonsDataFrame(regions,
          data.frame(regions = c('Coastal',
          'Mountains','High Desert','Eastern')),
          match.ID = FALSE)
plot(regions, axes=T)
text(coordinates(regions), 
     label = regions$regions, cex=.8)
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-23-1.png" title="" alt="" width="350px" style="display: block; margin: auto;" />

## Working with rasters {.build .smaller .columns-2}
<div class="notes">
- We've been focusing on vector data, so let's loook a bit at raster data
- Here we'll read in a raster of USGS STATSGO clay for the US
- raster package handles spatial data differently 
- As I mentioned earlier, a big advantage of the raster package is that it can work with data on disk that's too large to load into memory for R, and here we use the helper inMemory fuction to verify that our raster is not in memory in R
- Here we use cellStats function in raster to get our overall min and max cell values, projection to get our rasters' projeciton info, and plot to plot our raster
</div>

```r
require(raster)
load("K:/GitProjects/RUserWebinar/Data.RData")
clay <- raster('clay.tif')
inMemory(clay)
```

```
[1] FALSE
```

```r
cellStats(clay, min); cellStats(clay, max)
```

```
[1] 0
```

```
[1] 73.6665
```

```r
projection(clay)
```

```
[1] "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"
```

```r
plot(clay)
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-24-1.png" title="" alt="" width="375px" />

## Working with rasters {.build .smaller}
<div class="notes">
-  We can crop a raster by passing it some extent coordinates as well as by using another raster or spatial object from which extent can be extracted 
</div>

```r
require(raster)
clay <- raster('clay.tif')
clay_OR <- crop(clay, extent(-2261000, -1594944, 2348115, 2850963))
plot(clay_OR)
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-25-1.png" title="" alt="" width="300px" style="display: block; margin: auto;" />

## Working with rasters {.build .smaller}
<div class="notes">
-  We can use the extract function in the raster package much like over in sp, to derive clay content at our gage stations
</div>

```r
require(raster)
clay <- raster('clay.tif')
gages <- spTransform(gages, CRS(projection(clay)))
gages$clay = extract(clay,gages)
head(gages@data[,c(3,12)])
```

```
                                     STATION_NM    clay
1                ROGUE RIVER AT GRANTS PASS, OR 24.0840
2   N F LTL BUTE CR AB INTKE CANL LKECREEK OREG 37.8365
3                  HONEY CREEK NEAR PLUSH,OREG. 28.0060
4 SOUTH FORK LITTLE BUTTE CR NR LAKECREEK,OREG. 37.8365
5      NO FK LITTLE BUTTE CR NR LAKECREEK,OREG. 37.8365
6             TWELVEMILE CREEK NEAR PLUSH,OREG. 40.8730
```

## Visualizing data {.build .smaller .columns-2}
### RasterVis
<div class="notes">
- Now we'll step through some visualization examples, starting with the rasterVis package since we just looked at raster data
- rasterVis builds off the raster package and provides methods for enhanced visualization and interaction with raster data in R
- See great examples at http://oscarperpinan.github.io/rastervis/
- Here we use the handy 'getData' function in raster package to grab altitude data at 2.5 are-minute resolution from the global climage data center and global administrative areas I mentioned on earlier slide
- We then subset our admin areas to the state of Oregon, crop our altitude raster to Oregon, and use levelplot function in rasterVis to make a nice levelplot visualization
</div>

```r
library(rasterVis)
alt <- getData('worldclim', var='alt', res=2.5)
usa1 <- getData('GADM', country='USA', level=1)
oregon <- usa1[usa1$NAME_1 == 'Oregon',]
alt <- crop(alt, extent(oregon) + 0.5)
alt <- mask(alt, oregon)
levelplot(alt, par.settings=GrTheme)
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-27-1.png" title="" alt="" width="500px" />
- http://oscarperpinan.github.io/rastervis/

## Visualizing data
### PlotGoogleMaps
<div class="notes">
- This package was new to me until last week and was pointed out by Mike Papenfus here at our lab
- Allows you to map your points, lines and polygons straight onto Google Maps, and further, allows you to do interactive pop-ups of your spatial data overlaid on Google Maps
</div>

```r
require(plotGoogleMaps)
HUCs <- spTransform(HUCs, CRS('+init=epsg:28992'))
map <- plotGoogleMaps(HUCs, filename='RGoogleMapsExample.htm')
```
<div class="centered">
<img src="PlotGoogleMapsExample.png" alt="Roadmap" style="width: 400px;"/>
</div>

## Visualizing data using ggmap
<div class="notes">
- Handy package is ggmap - basically allows you to visualize spatial data on top of Google Maps, OpenStreetMaps, Stamen  Maps or Cloud Made maps using ggplot2
- Unfortunately using stamen maps from ggmap is broken at the moment so can't use
- Fix involves editing function in package
</div>

```r
library(ggmap)
mymap <- get_map(location = "Corvallis, OR", source="google", maptype="terrain",zoom = 12)
ggmap(mymap, extent="device")
```

<img src="RUserGroupWebinar_files/figure-html/unnamed-chunk-29-1.png" title="" alt="" width="400px" style="display: block; margin: auto;" />

## Visualizing data
### Taking it a step further with ggmap
<div class="notes">
- You can plot points, lines and polygons on ggmap for nice visualizations
- Here I just have an example of arranging several plots based on gpx coordinates from my watch from a weekend run using ggplot and ggmap
- Just an example of the kind of melding of data and maps you can do in R with ggplot2 and ggmap
- I don't show code here, but I have all the code posted up on my GitHub page
</div>

<div class="centered">
<img src="SundayRun.png" alt="Roadmap" style="width: 500px;"/>
</div>

## Exploratory Spatial Data Analysis with micromaps
<div class="notes">
- I'd be remiss not to point out our micromap package that's up on CRAN, article on package in latest issue of JSS
- The micromap package provides a means to read in shapefiles of existing geographic units such as states and then summarize both a statistical and geographic distrubution by linking statistical summaries to a series of small maps
- In this case we're looking at summaries of both pverty and education by US states
</div>

<div class="centered">
<img src="Micromap.jpeg" alt="Micromap" style="width: 350px;"/>
</div>
## Some things still better in python { .smaller}
### R Markdown + knitr package
<div class="notes">
- There are times when certain tasks with certain data are better done using python or another programming language
- R Markdown is a format that allows easy creation of dynamic documents, presentations, and reports from R. 
- Combines markdown syntax with embedded R code chunks that are run so their output can be included in the final document. 
- R Markdown documents are fully reproducible (they can be automatically regenerated whenever underlying R code or data changes).
- knitr package, used with RStudio, basically extends and makes easy creating dynamic documents using R markdown
- Great thing with knitr is that you can actually fold in programming languages other than R into your R markdown
- here I've got a code that will run a python chunk of code, and then run an R chunk of code
- I combine all my R and python work into one R document this way, that I can then generate an html, Word, or pdf document or slide show and make work reproducible
</div>
<div class="centered">
<img src="KnitrRPython.png" alt="Roadmap" style="width: 600px;"/>
</div>

## Combining R and Python { .smaller}
### R Markdown + knitr package
<div class="notes">
- Here we can see output generated in my Markdown document when I 'knit' the R Markdown in the previous document.  
- Show in RStudio
</div>
<div class="centered">
<img src="levelplotElev.png" alt="Roadmap" style="width: 650px;"/>
</div>
## Resources
- https://github.com/Robinlovelace/Creating-maps-in-R
- https://github.com/Pakillo/R-GIS-tutorial/blob/master/R-GIS_tutorial.md
- http://www.maths.lancs.ac.uk/~rowlings/Teaching/Sheffield2013/spatialops.html
- http://www.maths.lancs.ac.uk/~rowlings/Teaching/UseR2012/cheatsheet.html
- https://science.nature.nps.gov/im/datamgmt/statistics/r/advanced/spatial.cfm
- http://www.asdar-book.org/ 
- http://pakillo.github.io/R-GIS-tutorial/
