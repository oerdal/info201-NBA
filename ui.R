# install.packages("shiny")
# install.packages("httr")
# install.packages("dplyr")
# install.packages("jsonlite")
# install.packages("DT")
library(shiny)
library(httr)
library(dplyr)
library(jsonlite)
library(DT)
library(eeptools)

# reads in data
url <- paste0("https://api.fantasydata.net/v3/nba/stats/JSON/PlayerSeasonStats/2019")
response <- GET(url, add_headers("Host" = "api.fantasydata.net",
                                 "Ocp-Apim-Subscription-Key" = "ddc32a9a9ec54d5a87e5d0d44a36fd20"))
body <- content(response, "text")
data <- fromJSON(body)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  tags$head(
    tags$style(
      ".title {text-align: center}"
    )
  ),
  tags$div(class = "title", titlePanel("Fantasy Basketball Trading Comparison Tool")),
  hr(),
  
  fluidRow(
    column(3, radioButtons(
      inputId = "mode",
      label = "Mode:",
      choices = list("Totals", "Averages"), 
      inline = TRUE
    )),
    column(2, selectInput(
      inputId = "team", 
      label = "Team:", 
      choices = unique(c("All", data$Team))
    )),
    column(4, checkboxGroupInput(
      inputId = "position", 
      label = "Positions:", 
      choices = unique(c(data$Position)), 
      selected = unique(c(data$Position)),
      inline = TRUE
    )),
    column(1, actionButton(
      inputId = "trade",
      label = "Trade", 
      icon("basketball-ball")
    )),
    column(1, actionButton(
      inputId = "reset",
      label = "Reset"
    ))
  ),
  
  hr(),
  # shows players user clicked for trading comparison
  fluidRow(
    column(6, verbatimTextOutput("team1")),
    column(6, verbatimTextOutput("team2"))
  ),
  
  hr(),
  # plot for trading comparison
  fluidRow(
    column(12, DT::dataTableOutput("stats"))
  )
  
))
