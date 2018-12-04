# install.packages("shiny")
# install.packages("DT")
# install.packages("httr")
# install.packages("dplyr")
# install.packages("jsonlite")
# install.packages("eeptools")
library(shiny)
library(httr)
library(dplyr)
library(jsonlite)
library(DT)

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


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Fantasy Basketball"),
  fluidRow(
    column(3, radioButtons(
      inputId = "mode",
      label = "mode:",
      choices = list("Totals", "Averages"), 
      inline = TRUE
    )),
    column(2, selectInput(
      inputId = "team", 
      label = "Team:", 
      choices = unique(c("All", data_nba$Team))
    )),
    column(4, checkboxGroupInput(
      inputId = "position", 
      label = "Positions:", 
      choices = unique(c(data_nba$Position)), 
      selected = unique(c(data_nba$Position)),
      inline = TRUE
    )),
    column(1, submitButton(
      text = "Trade", 
      icon("basketball-ball")
    ))
  ),
  
  hr(),
  
  fluidRow(
    column(12, DT::dataTableOutput("stats"))
  ),
  
  hr(),
  
  fluidRow(
    column(12, plotOutput("plot"))
  )
))
