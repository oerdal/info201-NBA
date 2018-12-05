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

  navbarPage("ACBois5",
             
    tabPanel("Player Roster",
       tags$head(
         tags$style(
           ".title {text-align: center}"
         )
       ),
       tags$div(class = "title", titlePanel("Fantasy Basketball Trading Comparison Tool")),
       hr(),
       
       fluidRow(
         column(3, radioButtons(
           inputId = "d_mode",
           label = "Mode:",
           choices = list("Totals", "Averages"), 
           inline = TRUE
         )),
         column(3, selectInput(
           inputId = "d_team", 
           label = "Team:", 
           choices = unique(c("All", data$Team))
         ), offset = 1),
         column(3, checkboxGroupInput(
           inputId = "d_position", 
           label = "Positions:", 
           choices = unique(c(data$Position)), 
           selected = unique(c(data$Position)),
           inline = TRUE
         ), offset = 1)
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
      tags$div(class = "title", titlePanel("Fantasy Basketball Trading Comparison Tool")),
      hr(),
      
      fluidRow(
       column(3, radioButtons(
         inputId = "t_mode",
         label = "Mode:",
         choices = list("Totals", "Averages"), 
         inline = TRUE
       )),
       column(3, selectInput(
         inputId = "t_team", 
         label = "Team:", 
         choices = unique(c("All", data$Team))
       )),
       column(3, checkboxGroupInput(
         inputId = "t_position", 
         label = "Positions:", 
         choices = unique(c(data$Position)), 
         selected = unique(c(data$Position)),
         inline = TRUE
       )),
       column(2, actionButton(
         inputId = "t_reset",
         label = "Reset"
       ), offset = 1)
      ),
      
      hr(),
      # shows players user clicked for trading comparison
      fluidRow(
       column(3, verbatimTextOutput("team1")),
       column(6, plotOutput("trade_plot")),
       column(3, verbatimTextOutput("team2"))
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
