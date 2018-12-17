library(praise)

server <- function(input, output) {
  
  output$bigpraise <- renderText({praise()})
  
}