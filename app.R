# acnh-swipe: Tinder, but like, for Animal Crossing
# Matt Dray (@mattdray, www.rostrum.blog)
# June 2020


# Setup -------------------------------------------------------------------

# Attach packages
library(shinysense)  # remotes::install.github("nstrayer/shinysense")
library(shiny)
library(dplyr)
library(readr)
library(googledrive)
library(googlesheets4)

# Communicate with Google Sheets
options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = "mattdrayshiny@gmail.com")
gs4_auth(token = drive_token())

# UI ----------------------------------------------------------------------

ui <- fixedPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),

  class = "text-center",
  
  title = "Animal Crossing Tinder",
  
  h1("[WIP] Animal Crossing Tinder"),
  p("Best viewed on mobile"),
  hr(), br(),
  
  shinyswipr_UI(
    
    "acnh_swipe",
    
    p(
      icon("arrow-alt-circle-left"), 
      "Discard | Approve",
      icon("arrow-alt-circle-right"), 
    ),
    hr(),
    
    fluidRow(
      column(
        4,
        h4("Name:"), textOutput("name"),
        h4("Species:"), textOutput("species"),
        br()
      ),
      column(4, htmlOutput("url")),
      column(
        4,
        h4("Personality:"), textOutput("personality"),
        h4("Hobby:"), textOutput("hobby"),
        br()
      ),
    )
    
  ),
  
  br(), hr(),
  
  h4("Swipe history"),
  column(12, align = "center", tableOutput("resultsTable"))

)

# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # Data from Tidy Tuesday and Kaggle
  # https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-05-05/readme.md
  # https://www.kaggle.com/jessicali9530/animal-crossing-new-horizons-nookplaza-dataset/data
  villagers_k <- suppressMessages(read_csv("data/villagers-kaggle.csv"))
  villagers_tt <- suppressMessages(read_csv("data/villagers-tuesday.csv"))
  villagers <- left_join(villagers_k, villagers_tt, by = c("Name" = "name")) %>% 
    mutate(url = paste0("<img src='", url, "'>"))
  
  card_swipe <- callModule(shinyswipr, "acnh_swipe")
  
  villager <- sample_n(villagers, 1)  # sample one villager
  output$url <- renderText({ villager$url })
  output$name <- renderText({ villager$Name })
  output$species <- renderText({ villager$Species })
  output$personality <- renderText({ villager$Personality })
  output$hobby <- renderText({ villager$Hobby })
  
  output$resultsTable <- renderDataTable({ appVals$swipes })
  
  appVals <- reactiveValues(
    villager  = villager,
    swipes = data.frame(
      url = character(),
      name = character(),
      species = character(),
      personality = character(),
      hobby = character(),
      swipe = character()
    )
  )
  
  observeEvent(card_swipe(), {
    
    # Record our last swipe results
    latest_result <- data.frame(
      name = appVals$villager$Name,
      species = appVals$villager$Species,
      personality = appVals$villager$Personality,
      hobby = appVals$villager$Hobby,
      swipe = card_swipe()
    )
    
    # Send to Google Sheets
    date_col <- data.frame(date = Sys.time())  # capture date
    sheet_append(
      "1kMbmav6XvYqnTO202deyZQh37JeWtTK4ThIXdxGmEbs",
      cbind(date_col, latest_result)
    )  # add a row to the sheet
    
    # Add to table of all swipe results
    appVals$swipes <- rbind(latest_result, appVals$swipes)
    
    # Send results to the output
    output$resultsTable <- renderTable({ appVals$swipes })
    
    # Update the villager
    appVals$villager <- sample_n(villagers, 1)
    
    # Send update to ui
    output$url <- renderText({ appVals$villager$url })
    output$name <- renderText({ appVals$villager$Name })
    output$species <- renderText({ appVals$villager$Species })
    output$personality <- renderText({ appVals$villager$Personality })
    output$hobby <- renderText({ appVals$villager$Hobby })
    
  }) # Close event observe.
  
}

# Run ---------------------------------------------------------------------

shinyApp(ui, server)