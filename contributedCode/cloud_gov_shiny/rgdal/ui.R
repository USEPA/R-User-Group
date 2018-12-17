
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(rgdal)

################################################################################
#Combined UI
################################################################################
ui <- fluidPage(
  # Application title
  titlePanel("Testing rgdal"),

  # Sidebar layout with input and output definitions ----
  flowLayout(
    # Output: text ----
    textOutput(outputId = "rgdal")
  )
)

