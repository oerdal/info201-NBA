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
  col_names <- data.frame(categories = colnames(players[, 6:16]))
  sums <- data.frame(sums = colSums(players[, 6:16]))
  print(col_names)
  print(sums)
  p_sums <- cbind(data.frame(categories = col_names), sums)
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

empty_list <- function(players) {
  empty <- data.frame("categories" = c("MIN", 
                       "FG%", "FT%", "3PM", "REB", "AST", 
                       "STL", "BLK", "PTS", "TOV", "+/-"),
                     "sums" = (rep(0, 11)))
  rownames(empty) <- c("MIN", 
                       "FG%", "FT%", "3PM", "REB", "AST", 
                       "STL", "BLK", "PTS", "TOV", "+/-")
  return(empty)
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
    cat('Team 1\n\n')
    if (length(selected) > 0) {
      cat('is trading these players to Team 2:\n\n')
      cat(selected, sep = '\n')
    } else {
      cat('Please select players\nfrom below to\ntrade to Team 2')
    }
  })
  
  output$team2 <- renderPrint({
    players <- input$stats2_rows_selected
    data_update <- filter(data_nba, Position %in% input$t_position)
    if (input$t_team != "All") {
      data_update <- filter(data_update, Team == input$t_team)
    }
    selected <- data_update[players, "Name"]
    cat('Team 2\n\n')
    if (length(selected) > 0) {
      cat('is trading these players to Team 1:\n\n')
      cat(selected, sep = '\n')
    } else {
      cat('Please select players\nfrom below to\ntrade to Team 1')
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
    
    if (nrow(selected1) == 0) {
      trade1 <- empty_list()
    } else {
      averages1 <- get_averages(selected1)
      trade1 <- calculate_trade(averages1)
    }
    if (nrow(selected2) == 0) {
      trade2 <- empty_list()
    } else {
      averages2 <- get_averages(selected2)
      trade2 <- calculate_trade(averages2)
    }
    
    trade1$sums = trade1$sums - trade2$sums
    
    trade <- rbind(trade1["PTS",],
                   trade1["BLK",],
                   trade1["STL",],
                   trade1["AST",],
                   trade1["REB",],
                   trade1["3PM",],
                   trade1["FG%",],
                   trade1["FT%",],
                   trade1["MIN",])
    g <- ggplot(data = trade, aes(x = categories, weight = sums)) + geom_bar() + coord_flip() +
           scale_x_discrete(limits=trade$categories)
    print(g)
  })
  
  output$message <- renderText({
    paste0("Each team is benefiting in the categories shown above after the current trade")
  })
  
  observeEvent(input$t_reset, {
    stats1 %>% selectRows(NULL)
    stats2 %>% selectRows(NULL)
  })
  
})