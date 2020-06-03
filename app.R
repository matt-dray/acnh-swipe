# acnh-swipe: Tinder, but like, for Animal Crossing
# Matt Dray (@mattdray, www.rostrum.blog)
# June 2020

# Packages ----------------------------------------------------------------


library(shinysense)  # remotes::install.github("nstrayer/shinysense")
library(shiny)
library(dplyr)
library(readr)
library(googlesheets4)


# UI ----------------------------------------------------------------------


ui <- fixedPage(
  h1("[WIP] Animal Crossing Tinder"),
  p("Swipe right to approve a villager. Left to discard."),
  hr(),
  shinyswipr_UI( "acnh_swipe",
                 h4("Swipe Me!"),
                 hr(),
                 htmlOutput("url"),
                 h4("Name:"), textOutput("name"),
                 h4("Species:"), textOutput("species")
  ),
  hr(),
  h4("Swipe history"),
  tableOutput("resultsTable")
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
  villager <- sample_n(villagers, 1)  # sample one villager
  
  card_swipe <- callModule(shinyswipr, "acnh_swipe")
  
  output$name <- renderText({ villager$Name })
  output$species <- renderText({ villager$Species })
  output$url <- renderImage({ villager$url })
  output$resultsTable <- renderDataTable({ appVals$swipes })
  
  appVals <- reactiveValues(
    villager  = villager,
    swipes = data.frame(
      name = character(),
      species = character(),
      url = character(),
      swipe = character()
    )
  )
  
  observeEvent( card_swipe(),{
    
    # Record our last swipe results
    latest_result <- data.frame(
      name  = appVals$villager$Name,
      species  = appVals$villager$Species,
      swipe  = card_swipe()
    )
    
    # # Send to Google Sheets
    # date_col <- data.frame(date = Sys.time())  # capture date
    # sheet_append(
    #   "1kMbmav6XvYqnTO202deyZQh37JeWtTK4ThIXdxGmEbs",
    #   cbind(date_col, latest_result)
    # )  # add a row to the sheet
    
    # Add to table of all swipe results
    appVals$swipes <- rbind(latest_result, appVals$swipes)
    
    # Send results to the output
    output$resultsTable <- renderTable({ appVals$swipes })
    
    # Update the villager
    appVals$villager <- sample_n(villagers, 1)
    
    # Send update to ui
    output$name <- renderText({ appVals$villager$Name })
    output$species <- renderText({ appVals$villager$Species })
    output$url <- renderText({ appVals$villager$url })
    
  }) # Close event observe.
  
}

# Run ---------------------------------------------------------------------

shinyApp(ui, server)