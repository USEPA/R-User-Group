library(shiny)
install.packages("praise",repos = "https://cran.r-project.org")
#this doesn't appear to be working yet...
#install.packages("rgdal", type = "source",
#                 repos = "https://cran.r-project.org",
#                 configure.args=c('--with-proj-include=/home/vcap/deps/0/apt/usr/include',
#                                  '--with-proj-lib=/home/vcap/deps/0/apt/usr/lib',
#                                  '--with-gdal-config=/home/vcap/deps/0/apt/usr/bin'))
# maybe some info here: https://github.com/cloudfoundry/python-buildpack/issues/25
runApp(host="0.0.0.0", port=strtoi(Sys.getenv("PORT")))


