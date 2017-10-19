###############################################################################
# Installed_Packages.R
#
# Author:    Lucas Neas
# Purpose:   Reinstall directories for new version of R
#
# Revision:  September 15, 2017
# R Version: 3.4.0
###############################################################################

# RUN BOTH: Set up a new directory "R_packages" in your root directory
mainDir <- getwd()
subDir  <- "R_packages"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)
setwd(file.path(mainDir, subDir))
fileName <- paste(file.path(mainDir, subDir), "R_package_list", sep="/")

# RUN BEFORE: Save list of installed R packages (excluding base packages)
basePkgs <- sessionInfo()$basePkgs
RpackageList <- unname(installed.packages()[,1])
RpackageList <- RpackageList[!RpackageList %in% basePkgs]
RpackageList <- RpackageList[!RpackageList %in% "tools"]
save(RpackageList, file=fileName)

# RUN AFTER: Install saved list of R packages
load(file=fileName)
install.packages(RpackageList)

# WHOOPS I FORGOT: Grab package list from prior R installation
R.path <- "C:\\Program Files\\R\\"
all.R  <- list.dirs(path = R.path, full.names = FALSE, recursive = FALSE)
last.R <- all.R[length(all.R)-1]
current.R <- all.R[length(all.R)]
oldlist <- list.dirs(path = paste(R.path, last.R, "\\library\\", sep=""),
                  full.names = FALSE, recursive = FALSE)
currentlist <- list.dirs(path = paste(R.path, last.R, "\\library\\", sep=""),
                         full.names = FALSE, recursive = FALSE)
RpackageList <- oldlist[which(!oldlist%in%currentlist)]
if (length(RpackageList) > 0) {
  install.packages(RpackageList, quiet=TRUE, verbose=FALSE)
}
