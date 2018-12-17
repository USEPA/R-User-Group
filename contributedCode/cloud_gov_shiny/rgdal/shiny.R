library(shiny)
install.packages("praise",repos = "https://cran.r-project.org")
install.packages("rgdal",repos = "https://cran.r-project.org",
                 configure.args=c('--with-proj-include=/home/vcap/deps/0/apt/usr/include',
                                  '--with-proj-lib=/home/vcap/deps/0/apt/usr/lib',
                                  '--with-gdal-config=/home/vcap/deps/0/apt/usr/bin'))
runApp(host="0.0.0.0", port=strtoi(Sys.getenv("PORT")))


