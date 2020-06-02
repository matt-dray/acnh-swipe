# acnh-swipe: Tinder, but like, for Animal Crossing
# Matt Dray (@mattdray, www.rostrum.blog)
# June 2020


# Attach packages ---------------------------------------------------------

library(shinysense)  # remotes::insatll.github("nstrayer/shinysense")
library(shiny)
library(dplyr)
library(readr)

# UI ----------------------------------------------------------------------


ui <- fixedPage(
  h1("Animal Crossing Tinder"),
  p("Swipe right to approve a villager. Left to discard."),
  hr(),
  shinyswipr_UI( "quote_swiper",
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
  villagers_k <- read_csv("data/villagers-kaggle.csv")
  villagers_tt <- read_csv("data/villagers-tuesday.csv")
  villagers <- left_join(villagers_k, villagers_tt, by = c("Name" = "name")) %>% 
    mutate(url = paste0("<img src='", url, "'>"))
  
  card_swipe <- callModule(shinyswipr, "quote_swiper")
  
  villager <- sample_n(villagers, 1)
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
    #Record our last swipe results.
    appVals$swipes <- rbind(
      data.frame(
        name  = appVals$villager$Name,
        species  = appVals$villager$Species,
        url  = appVals$villager$url,
        swipe  = card_swipe()
      ),
      appVals$swipes
    )
    #send results to the output.
    output$resultsTable <- renderTable({ appVals$swipes })
    
    #update the quote
    appVals$villager <- sample_n(villagers, 1)
    
    #send update to the ui
    output$name <- renderText({ appVals$villager$Name })
    output$species <- renderText({ appVals$villager$Species })
    output$url <- renderText({ appVals$villager$url })
  }) #close event observe.
}

# Run ---------------------------------------------------------------------


# wrap it all together.
shinyApp(ui, server)