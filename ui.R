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

  navbarPage("Fantasy Basketball",
             
    tabPanel("Player Roster",
       tags$head(
         tags$style(
           ".title {text-align: center}"
         )
       ),
       tags$div(class = "title", titlePanel("Fantasy Basketball Roster")),
       hr(),
       
       fluidRow(
         column(4, radioButtons(
           inputId = "d_mode",
           label = "Mode:",
           choices = list("Totals", "Averages"),
           selected = "Averages", 
           inline = TRUE
         ), align = "center"),
         column(4, selectInput(
           inputId = "d_team", 
           label = "Team:", 
           choices = unique(c("All", data$Team))
         ), align = "center"),
         column(4, checkboxGroupInput(
           inputId = "d_position", 
           label = "Positions:", 
           choices = unique(c(data$Position)), 
           selected = unique(c(data$Position)),
           inline = TRUE
         ), align = "center")
       ),
       
       hr(),
       # plot for trading comparison
       fluidRow(
         column(12, DT::dataTableOutput("stats"))
       )
    ),
    
    tabPanel("Trade Comparison",
      tags$head(
       tags$style(
         ".title {text-align: center}"
       )
      ),
      tags$div(class = "title", titlePanel("Trading Comparison Tool")),
      
      hr(),
      # shows players user clicked for trading comparison
      fluidRow(
       column(3, verbatimTextOutput("team1")),
       column(6, plotOutput("trade_plot")),
       column(3, verbatimTextOutput("team2"))
      ),
      
      hr(),
      fluidRow(
        column(6, textOutput("message"), align = "center"),
        column(6, actionButton(
          inputId = "t_reset",
          label = "Reset",
          icon("redo")
        ), align = "center")
      ),
      
      hr(),
      
      # plot for trading comparison             
      fluidRow(
       column(6, DT::dataTableOutput("stats1")),
       column(6, DT::dataTableOutput("stats2"))
      )
    )
  )
))
