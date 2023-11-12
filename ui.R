# Définition de l'interface utilisateur en utilisant le package shinydashboard pour une meilleure mise en page
ui <- dashboardPage(
  # En-tête du tableau de bord contenant le titre
  dashboardHeader(title = "Tableau de Bord"),
  
  # Barre latérale contenant des éléments d'entrée pour interagir avec le tableau de bord
  dashboardSidebar(
    # Menu déroulant pour sélectionner l'année afin de filtrer les données
    selectInput("year", "Filtre Année", choices = 2008:2021, selected = 2020)
  ),
  
  # Corps principal du tableau de bord contenant les éléments de sortie
  dashboardBody(
    # Titre du tableau de bord, centré et en gras
    div(style = "text-align: center; font-weight: bold;", 
        tags$h3("Insights sur les Interventions d'Urgence")),
    
    # Première ligne de visualisations : carte et graphique en barres
    fluidRow(
      # Boîte contenant une sortie de carte Leaflet
      box(leafletOutput("map"), width = 6 ),
      # Boîte contenant une sortie de graphique en barres de Plotly
      box(plotlyOutput("barchart"), width = 6),
    ),
    
    # Deuxième ligne de visualisations : graphique en barres du top 5 et graphique à secteurs
    fluidRow(
      # Boîte contenant un graphique en barres des 5 meilleures valeurs (à spécifier)
      box(plotlyOutput("top5barchart"), width = 6),
      # Boîte contenant une sortie de graphique à secteurs de Plotly
      box(plotlyOutput("piechart"), width = 6),
    ),
    
    # Troisième ligne de visualisations : matrice de corrélation et histogramme
    fluidRow(
      # Boîte contenant un tracé de la matrice de corrélation
      box(plotOutput("correlationMatrix"), width = 6),
      # Boîte contenant un tracé d'histogramme
      box(plotOutput("histogram"), width = 6),
    )
  )
)
