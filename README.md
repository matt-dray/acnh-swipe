
# acnh-swipe

<!-- badges: start -->

[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![](https://img.shields.io/badge/Shiny-shinyapps.io-blue?style=flat&labelColor=white&logo=RStudio&logoColor=blue)](https://mattdray.shinyapps.io/acnh-swipe/)
[![rostrum.blog post](https://img.shields.io/badge/rostrum.blog-post-008900?style=flat&labelColor=black&logo=data:image/gif;base64,R0lGODlhEAAQAPEAAAAAABWCBAAAAAAAACH5BAlkAAIAIf8LTkVUU0NBUEUyLjADAQAAACwAAAAAEAAQAAAC55QkISIiEoQQQgghRBBCiCAIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAAh+QQJZAACACwAAAAAEAAQAAAC55QkIiESIoQQQgghhAhCBCEIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAA7)](https://www.rostrum.blog/2020/06/06/acnh-swipe/)
<!-- badges: end -->

Who's the most popular [Animal Crossing: New Horizons](https://www.animal-crossing.com/new-horizons/) character? [Go to the app and help decide!](https://mattdray.shinyapps.io/acnh-swipe/)

<img src='img/20200606_screenshot-demo.png'>

# Instructions

Swipe right to 'like' and left to 'dislike' a villager who is presented to you at random (think [Tinder](https://en.wikipedia.org/wiki/Tinder_(app))).

Swipe with you finger on mobile and click and drag on desktop.

A table of the top 10 by 'like' count is displayed and updated as you swipe.

You can read more in [this blog post](https://www.rostrum.blog/2020/06/06/acnh-swipe/).

# Technicals

* Made with [R](https://www.r-project.org/) using the packages [{shiny}](https://shiny.rstudio.com/), [{googledrive}](https://googledrive.tidyverse.org/), [{googlesheets4}](https://googlesheets4.tidyverse.org/) and [{tidyverse}](https://www.tidyverse.org/)
* The swiping mechanism is from [Nick Strayer](http://nickstrayer.me/)'s [{shinysense}](http://nickstrayer.me/shinysense/) package
* Data from [Kaggle](https://www.kaggle.com/jessicali9530/animal-crossing-new-horizons-nookplaza-dataset/data) and [TidyTuesday](https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-05-05/readme.md)
* Animal Crossing is owned by Nintendo
* Icons from [Font Awesome](https://www.fontawesome.com/) ([Creative Commons Attribution 4.0 International](https://fontawesome.com/license) license, no changes made) via the [{icon}](https://github.com/ropenscilabs/icon) package

# Note on data

No personal data are stored. The app records the date-time, villager name and swipe direction only. 
