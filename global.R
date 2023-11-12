# Chargement des bibliothèques nécessaires pour le traitement des données et la visualisation
library(dplyr) # Utilisé pour les manipulations de données, équivalent à pandas en Python
library(ggplot2) # Utilisé pour créer des graphiques complexes, équivalent à matplotlib et seaborn en Python
library(leaflet) # Utilisé pour les cartes interactives, équivalent de folium en Python
library(sf) # Utilisé pour la manipulation de données géospatiales, équivalent de geopandas en Python
library(shiny) # Utilisé pour créer des applications web interactives, équivalent de dash en Python
library(shinydashboard) # Fournit un cadre de tableau de bord pour Shiny
library(plotly) # Intègre Plotly avec Shiny pour des graphiques interactifs
library(bslib) # Permet l'utilisation de composants Bootstrap dans Shiny pour personnaliser l'apparence
library(purrr) # Utilisé pour la programmation fonctionnelle
library(readxl) # Utilisé pour lire des fichiers Excel
library(readr) # Utilisé pour lire et écrire des données
library(htmlwidgets) # Permet d'intégrer des widgets HTML avec R
library(corrplot) # Utilisé pour visualiser des matrices de corrélations

# Chemin de base vers le dossier contenant les données
base_path <- 'cheminverslerepertoire/R/Données'
# Création d'une séquence d'années
years <- 2008:2021
# Génération des noms de fichiers pour chaque année
file_names <- paste0("interventions", years, "V3.xlsx")
# Création des chemins complets vers les fichiers
full_paths <- paste0(base_path, file_names)
# URL vers le GeoJSON des départements français simplifiés
url <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements-version-simplifiee.geojson"
# Lecture des données géospatiales des départements
departements <- st_read(url)

# Création d'une liste de DataFrames pour chaque année en utilisant une combinaison des fonctions set_names et map
dfs <- set_names(years) %>% 
  map(~ read_excel(paste0(base_path, "interventions", .x, "V3.xlsx")))

# Exemple d'utilisation de dfs pour accéder aux DataFrames : dfs[[2008]] pour l'année 2008

# Calcul des totaux d'interventions pour chaque année
totals <- sapply(dfs, function(df) sum(df$`Total interventions`, na.rm = TRUE))
# Définition d'une palette de couleurs pour les graphiques
colors5 <- c('#ccebc5', '#a8ddb5', '#7bccc4', '#4eb3d3', '#2b8cbe')
# Création d'une fonction de palette de couleurs basée sur la palette définie
my_palette <- colorRampPalette(colors5)
# Liste des types d'interventions à visualiser
interventions <- c('Incendies', 'Secours à personne', 'Accidents de circulation', 'Risques technologiques', 'Opérations diverses')
