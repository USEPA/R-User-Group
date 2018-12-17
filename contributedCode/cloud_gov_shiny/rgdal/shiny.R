library(shiny)
runApp(host="0.0.0.0", port=strtoi(Sys.getenv("PORT")))
