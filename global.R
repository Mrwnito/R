library(dplyr) # équivalent de pandas
library(ggplot2) # équivalent de matplotlib et seaborn
library(leaflet) # équivalent de folium
library(sf) # équivalent de geopandas
library(shiny) # équivalent de dash
library(shinydashboard)
library(plotly) # pour utiliser Plotly avec Shiny
library(bslib) # pour utiliser des composants bootstrap avec Shiny
library(purrr)
library(readxl)
library(readr)
library(htmlwidgets)
library(corrplot)

base_path <- 'cheminverslerepertoire/R/Données'
years <- 2008:2021
file_names <- paste0("interventions", years, "V3.xlsx")
full_paths <- paste0(base_path, file_names)
url <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements-version-simplifiee.geojson"
departements <- st_read(url)

dfs <- set_names(years) %>% 
  map(~ read_excel(paste0(base_path, "interventions", .x, "V3.xlsx")))

# Utiliser dfs[[année]] pour accéder aux DataFrames, par exemple dfs[[2008]]


totals <- sapply(dfs, function(df) sum(df$`Total interventions`, na.rm = TRUE))
colors5 <- c('#ccebc5', '#a8ddb5', '#7bccc4', '#4eb3d3', '#2b8cbe')
my_palette <- colorRampPalette(colors5)
interventions <- c('Incendies', 'Secours à personne', 'Accidents de circulation', 'Risques technologiques', 'Opérations diverses')
