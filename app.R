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

# Google Sheet unique ID
ss <- "1kMbmav6XvYqnTO202deyZQh37JeWtTK4ThIXdxGmEbs"

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
  p("Swipe on mobile • Click and drag on desktop"),
  HTML(
    "<a href='https://www.twitter.com/mattdray'>@mattdray</a> • <a href='https://www.github.com/matt-dray/acnh-swipe'>Source</a> • <a href='https://www.rostrum.blog'>Blog</a>"
  ), 
  hr(), br(),
  
  shinyswipr_UI(

    "acnh_swipe",
    
    p(
      icon("arrow-left"),
      HTML("Discard • Approve"),
      icon("arrow-right"),
    ),
    
    
    fixedRow(
      column(4, htmlOutput("url")),
      column(
        4,
        h4("Name"), textOutput("name"),
        h4("Species"), textOutput("species"),
      ),
      column(
        4,
        h4("Personality"), textOutput("personality"),
        h4("Hobby"), textOutput("hobby"),
      ),
    )

    
  ),

  br(), hr(),
  
  
  h4("Top 10"),
  p("This table updates after you swipe"),
  column(12, align = "center", tableOutput("table"))
  
)

# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  card_swipe <- callModule(shinyswipr, "acnh_swipe")
  
  # Data from Tidy Tuesday and Kaggle
  # https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-05-05/readme.md
  # https://www.kaggle.com/jessicali9530/animal-crossing-new-horizons-nookplaza-dataset/data
  villagers_k <- suppressMessages(read_csv("data/villagers-kaggle.csv"))
  villagers_tt <- suppressMessages(read_csv("data/villagers-tuesday.csv"))
  villagers <- left_join(villagers_k, villagers_tt, by = c("Name" = "name")) %>% 
    mutate(url = paste0("<img src='", url, "'>"))
  
  # Sample one villager
  villager <- sample_n(villagers, 1)
  
  # Render the villlager variables
  output$url <-         renderText({ villager$url })
  output$name <-        renderText({ villager$Name })
  output$species <-     renderText({ villager$Species })
  output$personality <- renderText({ villager$Personality })
  output$hobby <-       renderText({ villager$Hobby })
  
  # Render the table of swipes
  output$resultsTable <- renderDataTable({ appVals$swipes })
  
  # Set up reactive values object
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
    
    # Record the last swipe result
    latest_result <- data.frame(
      name = appVals$villager$Name,
      swipe = card_swipe()
    )
    
    # Send to Google Sheets
    date_col <- data.frame(date = Sys.time())  # capture datetime
    sheet_append(  # add a row to the sheet
      ss,  # the Google Sheet unique ID
      cbind(date_col, latest_result)
    )  
    
    # Add to table of all swipe results
    appVals$swipes <- rbind(latest_result, appVals$swipes)
    
    # Send results to the output
    #output$resultsTable <- renderTable({ appVals$swipes })
    
    # Update the villager
    appVals$villager <- sample_n(villagers, 1)
    
    # Send update to ui
    output$url <-         renderText({ appVals$villager$url })
    output$name <-        renderText({ appVals$villager$Name })
    output$species <-     renderText({ appVals$villager$Species })
    output$personality <- renderText({ appVals$villager$Personality })
    output$hobby <-       renderText({ appVals$villager$Hobby })
    
  }) # Close event observe.
  
  # Read latest data from the Google Sheet
  the_data <- eventReactive(
    { card_swipe() },
    read_sheet(ss) %>%
      count(name, swipe) %>%
      pivot_wider(names_from = swipe, values_from = n) %>% 
      arrange(`right`) %>% 
      mutate(Rank = row_number()) %>% 
      select(
        Rank, Name = name, `Approved` = right, `Declined` = left
      ) %>% 
      slice(1:10),
    ignoreNULL = FALSE
  )
  
  # Render the latest results as a table
  output$table <- renderTable(the_data())
  
}

# Run ---------------------------------------------------------------------

shinyApp(ui, server)