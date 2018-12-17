
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(praise)

shinyServer(function(input, output) {

  output$rgdal <- renderText({
    if(any(installed.packages() %in% "rgdal")){
      "It Worked"
    } else {
      "NOPE!"
    }
  })
})

