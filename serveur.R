# Définition de la fonction server qui contient la logique pour générer les graphiques et la carte
server <- function(input, output, session) {
  
  # Observer pour réagir aux changements de l'année sélectionnée dans l'input "year"
  observe({
    selected_year <- input$year
  })

  # Génération du graphique en barres pour l'évolution des interventions par année
  output$barchart <- renderPlotly({
    selected_year <- input$year
    
    # Création du graphique initial avec ggplot2, puis ajout des barres pour chaque type d'intervention
    bar_fig1 <- plot_ly(x = years, y = totals, type = 'bar', name = 'Total') %>% 
      layout(title = list(text = "Évolution des interventions par année",
                          x = 0.5, y = 0.95, xanchor = 'center', yanchor = 'top'),
             xaxis = list(title = 'Année'),
             yaxis = list(title = 'Nombre d\'interventions'),
             margin = list(l = 75, r = 75, t = 75, b = 75))
    
    # Boucle pour ajouter des lignes à la figure pour chaque type d'intervention
    for (idx in 1:length(interventions)) {
      intervention <- interventions[idx]
      yearly_totals <- sapply(dfs, function(df) sum(df[[intervention]], na.rm = TRUE))
      
      bar_fig1 <- bar_fig1 %>%
        add_lines(x = years, y = yearly_totals, name = intervention, line = list(color = colors5[idx]))
    }
    
    bar_fig1
  })
  
  # Génération du graphique en secteurs pour la répartition des interventions par type pour l'année sélectionnée
  output$piechart <- renderPlotly({
    selected_year <- input$year
    
    # Calcul de la répartition des interventions pour l'année sélectionnée
    répartition_interventions <- colSums(dfs[[as.character(selected_year)]][, c('Incendies', 'Secours à personne', 'Accidents de circulation', 'Risques technologiques', 'Opérations diverses')], na.rm = TRUE)
    
    # Transformation des données en format approprié pour plotly
    df_pie <- data.frame(
      Category = names(répartition_interventions),
      Values = répartition_interventions
    )
    
    # Création du graphique en secteurs avec plotly
    pie_fig1 <- plot_ly(data = df_pie, labels = ~Category, values = ~Values, type = 'pie', textinfo='label+percent',
                        marker = list(colors = colors5)) %>% 
      layout(
        title = list(
          text = paste("Répartition des interventions par type pour l'année", selected_year),
          x = 0.5,
          y = 0.95,
          xanchor = 'center',
          yanchor = 'top',
          font = list(size = 18)  # Ajustement de la taille du titre
        ),
        margin = list(l = 90, r = 90, t = 90, b = 90),  # Marges autour du graphique en secteurs
        showlegend = TRUE,
        domain = list(
          x = c(0.125, 0.875),  # Ajustement de la taille du graphique sur l'axe X
          y = c(0.125, 0.875)   # Ajustement de la taille du graphique sur l'axe Y
        )
      )
    
    pie_fig1
  })

  # Génération de la carte Leaflet pour l'année sélectionnée
  output$map <- renderLeaflet({
    selected_year <- input$year
    df_carte <- dfs[[as.character(selected_year)]]
    
    # Sélection de la ligne BSPP et création de nouvelles lignes pour chaque département de l'Île-de-France
    bspp_row <- df_carte %>% filter(Numéro == 'BSPP') %>% slice(1)
    bspp_modified <- map(c('75', '92', '93', '94'), ~{
      new_row <- bspp_row
      new_row$Numéro <- .x
      new_row
    }) %>% bind_rows()
    
    # Préparation de la DataFrame en supprimant la ligne BSPP originale et en ajoutant les nouvelles lignes
    df_carte <- df_carte %>% 
      filter(Numéro != 'BSPP') %>%
      bind_rows(bspp_modified)
    
    # Conversion des numéros de département en format avec zéros non significatifs
    df_carte$Numéro <- sprintf("%02d", as.numeric(df_carte$Numéro))
    
    # Fusion des données géographiques des départements avec les données d'interventions
    merged <- departements %>%
      left_join(df_carte, by = c("code" = "Numéro"))
    
    # Exclusion des départements 77, 78, 91 et 95 si nécessaire
    merged <- merged %>%
      filter(!code %in% c('77', '78', '91', '95'))
    
    # Création de la carte Leaflet avec les données fusionnées
    leaflet(data = merged) %>%
      addTiles() %>%
      setView(lng = 3.078600, lat = 46.896242, zoom = 5) %>%
      addPolygons(
        fillColor = ~colorQuantile("GnBu", `Total interventions`, n = 5)(`Total interventions`),
        weight = 2,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        label = ~as.character(`code`)
      )  # Assurez-vous que les noms des colonnes correspondent à votre jeu de données
  })
  
  # Génération du graphique en barres pour le top 5 des départements avec le plus grand nombre d'interventions
  output$top5barchart <- renderPlotly({
    selected_year <- input$year
    df <- dfs[[as.character(selected_year)]]
    top5 <- df %>% 
      arrange(desc(`Total interventions`)) %>%
      head(5)
    
    bar_fig2 <- plot_ly(top5, x = ~Département, y = ~`Total interventions`, type = 'bar', color = ~Département, colors = colors5) %>%
      layout(title = list(text = paste("Top 5 des départements avec le plus grand nombre d'interventions pour", selected_year),
                          x = 0.5, y = 0.95, xanchor = 'center', yanchor = 'top', font = list(size = 14)),
             margin = list(l = 75, r = 75, t = 75, b = 75))
    
    bar_fig2
  })
  
  # Génération de l'histogramme des interventions pour l'année sélectionnée
  output$histogram <- renderPlot({
    selected_year <- input$year
    data_for_year <- dfs[[as.character(selected_year)]]
    
    ggplot(data_for_year, aes(x = `Total interventions`)) + 
      geom_histogram(binwidth = 10000, fill = '#4eb3d3', color = '#7bccc4') +
      labs(x = "Nombre d'interventions", y = "Fréquence", 
           title = paste("Histogramme des interventions pour l'année", selected_year)) +
      theme(plot.title = element_text(size = 18))  # Ajustement de la taille du titre
  })
  
  # Génération de la matrice de corrélation pour les types d'interventions de l'année sélectionnée
  output$correlationMatrix <- renderPlot({
    selected_year <- input$year
    data_for_year <- dfs[[as.character(selected_year)]]
    
    # Sélection uniquement des colonnes correspondant aux types d'interventions pour le calcul de la matrice de corrélation
    interventions_data <- data_for_year[, interventions]
    
    # Calcul de la matrice de corrélation
    correlation_matrix <- cor(interventions_data, use = "complete.obs")
    # Transformation des valeurs de corrélation pour la visualisation
    transformed_correlation_matrix <- atan(correlation_matrix * (pi/2 - 0.1))
    
    # Création de la visualisation de la matrice de corrélation avec corrplot
    corrplot::corrplot(transformed_correlation_matrix, method = "circle",tl.col = "black", tl.cex = 0.6, number.cex = 0.7, col = my_palette(200), is.corr = FALSE)
    mtext("Matrice de Corrélation", side = 3, line = 1, col = "black", cex = 1.5)  # Ajustement de la taille de texte de l'étiquette
  })
}

# Lancement de l'application Shiny avec la définition de l'interface utilisateur et du serveur
shinyApp(ui, server)
