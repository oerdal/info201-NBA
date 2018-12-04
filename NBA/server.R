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

url <- paste0("https://api.fantasydata.net/v3/nba/stats/JSON/PlayerSeasonStats/2019")
response <- GET(url, add_headers("Host" = "api.fantasydata.net",
                                 "Ocp-Apim-Subscription-Key" = "ddc32a9a9ec54d5a87e5d0d44a36fd20"))
body <- content(response, "text")
data <- fromJSON(body)
categories <- c("Name", "Team", "Position", "FantasyPoints", "FantasyPointsFantasyDraft", 
                "Games", "Minutes", "FieldGoalsPercentage", "FreeThrowsPercentage", 
                "ThreePointersMade", "Rebounds", "Assists", "Steals", "BlockedShots", "Points", 
                "Turnovers", "PlusMinus")
data_nba <- select(data, categories)



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
    if (input$team != "ALL") {
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
  
})
