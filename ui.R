ui <- dashboardPage(
  dashboardHeader(title = "Tableau de Bord"),
  
  dashboardSidebar(
    selectInput("year", "Filtre Année", choices = 2008:2021, selected = 2020)
  ),
  dashboardBody(
    div(style = "text-align: center; font-weight: bold;", 
        tags$h3("Insights sur les Interventions d'Urgence")),
    fluidRow(
      box(leafletOutput("map"), width =6 ),
      box(plotlyOutput("barchart"), width =6),
    ),
    fluidRow(
      box(plotlyOutput("top5barchart"), width = 6),
      box(plotlyOutput("piechart"), width = 6),
    ),
    fluidRow(
      box(plotOutput("correlationMatrix"), width = 6),
      box(plotOutput("histogram"), width = 6),
    )
  )
  
)
