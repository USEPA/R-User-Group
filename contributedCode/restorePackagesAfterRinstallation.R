###############################################################################
# Installed_Packages.R
#
# Author:    Lucas Neas
# Purpose:   Reinstall directories for new version of R
#
# Revision:  May 13, 2016
# R Version: 3.2.2
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
