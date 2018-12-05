# install.packages("shiny")
# install.packages("httr")
# install.packages("dplyr")
# install.packages("jsonlite")
# install.packages("DT")
# install.packages("ggplot2")
library(shiny)
library(httr)
library(dplyr)
library(jsonlite)
library(DT)
library(ggplot2)

# reads in data
url <- paste0("https://api.fantasydata.net/v3/nba/stats/JSON/PlayerSeasonStats/2019")
response <- GET(url, add_headers("Host" = "api.fantasydata.net",
                                 "Ocp-Apim-Subscription-Key" = "ddc32a9a9ec54d5a87e5d0d44a36fd20"))
body <- content(response, "text")
data <- fromJSON(body)
categories <- c("Name", "Team", "Position", "FantasyPoints", "Games", "Minutes", 
                "FieldGoalsPercentage", "FreeThrowsPercentage", "ThreePointersMade", 
                "Rebounds", "Assists", "Steals", "BlockedShots", "Points", 
                "Turnovers", "PlusMinus")
data_nba <- select(data, categories)
for (i in 1:nrow(data_nba)) {
  data_nba[i, "FieldGoalsPercentage"] <- ifelse(data_nba[i, "FieldGoalsPercentage"] > 100, 
                                                100, data_nba[i, "FieldGoalsPercentage"])
  data_nba[i, "FreeThrowsPercentage"] <- ifelse(data_nba[i, "FreeThrowsPercentage"] > 100, 
                                                100, data_nba[i, "FreeThrowsPercentage"])
}

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

calculate_trade <- function(players) {
  colnames(players) <- c("Name", "Team", "POS", "Rating", "GP", "MIN", 
                           "FG%", "FT%", "3PM", "REB", "AST", 
                           "STL", "BLK", "PTS", "TOV", "+/-")
  col_names <- data.frame(names = colnames(players[, 6:16]))
  sums <- data.frame(sums = colSums(players[, 6:16]))
  print(col_names)
  print(sums)
  p_sums <- cbind(data.frame(names = col_names), sums)
  colnames(p_sums)
  return(p_sums)
}

get_averages <- function(players) {
  for (i in nrow(players)) {
    if (players[i, "Games"] == 0) {
      players[i, "Games"] <- 1
    }
  }
  players[, 6:16] <- players[, 6:16] / players$Games
  return(players)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  selected1 <- reactiveValues(data = NULL)
  
  output$stats <- DT::renderDataTable({
    data_update <- filter(data_nba, Position %in% input$d_position)
    if (input$d_team != "All") {
      data_update <- filter(data_update, Team == input$d_team)
    }
    if (input$d_mode == "Averages") {
      for (i in 1:nrow(data_update)) {
        for (j in 9:ncol(data_update)) {
          data_update[i, j] <- round(data_update[i, j] / data_update[i, "Games"], 2)
        }
      }
    }
    colnames(data_update) <- c("Name", "Team", "POS", "Rating", "GP", "MIN", 
                               "FG%", "FT%", "3PM", "REB", "AST", 
                               "STL", "BLK", "PTS", "TOV", "+/-")
    DT::datatable(data_update, options = list(lengthMenu = c(25, 50, 75, 100), 
                                              pageLength = 25))
  })
  
  output$stats1 <- DT::renderDataTable({
    data_update <- filter(data_nba, Position %in% input$t_position)
    if (input$t_team != "All") {
      data_update <- filter(data_update, Team == input$t_team)
    }
    if (input$t_mode == "Averages") {
      for (i in 1:nrow(data_update)) {
        for (j in 9:ncol(data_update)) {
          data_update[i, j] <- round(data_update[i, j] / data_update[i, "Games"], 2)
        }
      }
    }
    colnames(data_update) <- c("Name", "Team", "POS", "Rating", "GP", "MIN", 
                               "FG%", "FT%", "3PM", "REB", "AST", 
                               "STL", "BLK", "PTS", "TOV", "+/-")
    data_update <- data_update %>% select(Name, Team, POS, Rating)
    DT::datatable(data_update, options = list(lengthMenu = c(25, 50, 75, 100), 
                                              pageLength = 25))
  })
  
  output$stats2 <- DT::renderDataTable({
    data_update <- filter(data_nba, Position %in% input$t_position)
    if (input$t_team != "All") {
      data_update <- filter(data_update, Team == input$t_team)
    }
    if (input$t_mode == "Averages") {
      for (i in 1:nrow(data_update)) {
        for (j in 9:ncol(data_update)) {
          data_update[i, j] <- round(data_update[i, j] / data_update[i, "Games"], 2)
        }
      }
    }
    colnames(data_update) <- c("Name", "Team", "POS", "Rating", "GP", "MIN", 
                               "FG%", "FT%", "3PM", "REB", "AST", 
                               "STL", "BLK", "PTS", "TOV", "+/-")
    data_update <- data_update %>% select(Name, Team, POS, Rating)
    DT::datatable(data_update, options = list(lengthMenu = c(25, 50, 75, 100), 
                                              pageLength = 25))
  })
  
  stats1 <- dataTableProxy("stats1")
  stats2 <- dataTableProxy("stats2")
  
  output$team1 <- renderPrint({
    players <- input$stats1_rows_selected
    data_update <- filter(data_nba, Position %in% input$t_position)
    if (input$t_team != "All") {
      data_update <- filter(data_update, Team == input$t_team)
    }
    selected <- data_update[players, "Name"]
    if (length(selected) > 0) {
      cat('Team 1\n\nis trading these players to Team 2:\n\n')
      cat(selected, sep = '\n')
    }
  })
  
  output$team2 <- renderPrint({
    players <- input$stats2_rows_selected
    data_update <- filter(data_nba, Position %in% input$t_position)
    if (input$t_team != "All") {
      data_update <- filter(data_update, Team == input$t_team)
    }
    selected <- data_update[players, "Name"]
    if (length(selected) > 0) {
      cat('Team 2\n\nis trading these players to Team 1:\n\n')
      cat(selected, sep = '\n')
    }
  })
  
  output$trade_plot <- renderPlot({
    players <- input$stats1_rows_selected
    data_update <- filter(data_nba, Position %in% input$t_position)
    if (input$t_team != "All") {
      data_update <- filter(data_update, Team == input$t_team)
    }
    
    selected1 <- data_update[input$stats1_rows_selected,]
    selected2 <- data_update[input$stats2_rows_selected,]
    
    if (nrow(selected1) == 0 | nrow(selected2) == 0) {
      return()
    }
    
    averages1 <- get_averages(selected1)
    averages2 <- get_averages(selected2)
    
    trade1 <- calculate_trade(averages1)
    trade2 <- calculate_trade(averages2)
    trade <- trade1
    trade$sums = trade1$sums - trade2$sums
    View(trade1)
    
    g <- ggplot(data = trade, aes(x = names, weight = sums)) + geom_bar() + coord_flip()
    print(g)
  })
  
  observeEvent(input$t_reset, {
    stats1 %>% selectRows(NULL)
    stats2 %>% selectRows(NULL)
  })
  
})