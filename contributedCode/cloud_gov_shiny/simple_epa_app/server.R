library(praise)

server <- function(input, output) {
  
  praise_text <- eventReactive(input$praise, {praise()})
  output$bigpraise <- renderText({praise_text()})
  
}