# install.packages("httr")
# install.packages("dplyr")
# install.packages("jsonlite")
# install.packages("eeptools")
# install.packages("shiny")
library(httr)
library(dplyr)
library(jsonlite)
library(eeptools)
library(shiny)

# returns the stats of a given player
get_stats <- function(player) {
  names <- c(tolower(data_nba$Name))
  if (is.element(tolower(player), names)) {
    player_stats <- filter(data_nba, tolower(Name) == tolower(player))
    return(player_stats)
  } else {
    return("Please input a valid NBA player's name")
  }
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$stats <- DT::renderDataTable({
    data_update <- filter(data_nba, Position %in% input$position)
    if (input$team != "All") {
      data_update <- filter(data_update, Team == input$team)
    }
    if (input$mode == "Averages") {
      for (i in 1:nrow(data_update)) {
        for (j in 10:17) {
          data_update[i, j] <- round(data_update[i, j] / data_update[i, "Games"], 2)
        }
      }
    }
    colnames(data_update) <- c("Name", "Team", "POS", "Rate", "Draft", 
                               "GP", "MIN", "FG%", "FT%", "3PM", "REB", "AST", 
                               "STL", "BLK", "PTS", "TOV", "+/-")
    data_update
  })
  
  output$plot <- renderPlot({
    output$text <- renderText({})
  })
  
})