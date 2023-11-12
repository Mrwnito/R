server <- function(input, output, session) {
  # Serveur logique pour rendre les graphiques et la carte

  observe({
    selected_year <- input$year
  })

  
  # Exemple pour le graphique en barres
  output$barchart <- renderPlotly({
    selected_year <- input$year
    
    bar_fig1 <- plot_ly(x = years, y = totals, type = 'bar', name = 'Total') %>% #marker = list(color = '#83A1A4')
      layout(title = list(text = "Évolution des interventions par année",
                          x = 0.5, y = 0.95, xanchor = 'center', yanchor = 'top'),
             xaxis = list(title = 'Année'),
             yaxis = list(title = 'Nombre d\'interventions'),
             margin = list(l = 75, r = 75, t = 75, b = 75))
    
    for (idx in 1:length(interventions)) {
      intervention <- interventions[idx]
      yearly_totals <- sapply(dfs, function(df) sum(df[[intervention]], na.rm = TRUE))
      
      bar_fig1 <- bar_fig1 %>%
        add_lines(x = years, y = yearly_totals, name = intervention, line = list(color = colors5[idx]))
    }
    
    bar_fig1
  })
  
  # Exemple pour le graphique en secteurs
  output$piechart <- renderPlotly({
    selected_year <- input$year
    
    # Calcul de la répartition des interventions
    répartition_interventions <- colSums(dfs[[as.character(selected_year)]][, c('Incendies', 'Secours à personne', 'Accidents de circulation', 'Risques technologiques', 'Opérations diverses')], na.rm = TRUE)
    
    # Transformer en data frame
    df_pie <- data.frame(
      Category = names(répartition_interventions),
      Values = répartition_interventions
    )
    
    # Créer le diagramme à secteurs avec plot_ly
    pie_fig1 <- plot_ly(data = df_pie, labels = ~Category, values = ~Values, type = 'pie', textinfo='label+percent',
                        marker = list(colors = colors5)) %>% 
      layout(
        title = list(
          text = paste("Répartition des interventions par type pour l'année", selected_year),
          x = 0.5,
          y = 0.95,
          xanchor = 'center',
          yanchor = 'top',
          font = list(size = 18)  # Ajustez la taille ici selon vos besoins
        ),
        # Ajuster la taille du camembert à 75%
        margin = list(l = 90, r = 90, t = 90, b = 90),  # Marges autour du camembert
        showlegend = TRUE,
        domain = list(
          x = c(0.125, 0.875),  # Ajustement pour réduire la taille à 75% sur l'axe X
          y = c(0.125, 0.875)   # Ajustement pour réduire la taille à 75% sur l'axe Y
        )
      )
    
    pie_fig1
  })

  
 
  # Dans la fonction server
  output$map <- renderLeaflet({
    # Obtenez l'année sélectionnée
    selected_year <- input$year
    df_carte <- dfs[[as.character(selected_year)]]
    
    # Sélectionnez la ligne BSPP et créez de nouvelles lignes pour chaque département de l'Île-de-France
    bspp_row <- df_carte %>% filter(Numéro == 'BSPP') %>% slice(1)
    bspp_modified <- map(c('75', '92', '93', '94'), ~{
      new_row <- bspp_row
      new_row$Numéro <- .x
      new_row
    }) %>% bind_rows()
    
    # Préparer la DataFrame en supprimant la ligne BSPP originale et en ajoutant les nouvelles lignes
    df_carte <- df_carte %>% 
      filter(Numéro != 'BSPP') %>%
      bind_rows(bspp_modified)
    
    # Convertir les numéros de département en format avec zéros non significatifs
    df_carte$Numéro <- sprintf("%02d", as.numeric(df_carte$Numéro))
    
    # Fusionner les données géographiques des départements avec vos données
    merged <- departements %>%
      left_join(df_carte, by = c("code" = "Numéro"))
    
    # Exclure les départements 77, 78, 91 et 95 si nécessaire
    merged <- merged %>%
      filter(!code %in% c('77', '78', '91', '95'))
    
    # Créer la carte leaflet
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
  
  # Exemple pour le graphique en barres du top 5
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
  
  output$histogram <- renderPlot({
    selected_year <- input$year
    data_for_year <- dfs[[as.character(selected_year)]]
    
    ggplot(data_for_year, aes(x = `Total interventions`)) + 
      geom_histogram(binwidth = 10000, fill = '#4eb3d3', color = '#7bccc4') +
      labs(x = "Nombre d'interventions", y = "Fréquence", 
           title = paste("Histogramme des interventions pour l'année", selected_year)) +
      theme(plot.title = element_text(size = 18))  # Ajustez la taille ici selon vos besoins
      
  })
  
  # Dans la fonction server
  output$correlationMatrix <- renderPlot({
    selected_year <- input$year
    data_for_year <- dfs[[as.character(selected_year)]]
    
    # Sélectionnez seulement les colonnes correspondant aux types d'interventions
    interventions_data <- data_for_year[, interventions]
    
    # Calcul de la matrice de corrélation
    correlation_matrix <- cor(interventions_data, use = "complete.obs")
    # Transformer les valeurs de corrélation
    transformed_correlation_matrix <- atan(correlation_matrix * (pi/2 - 0.1))
    
    # Utiliser la matrice transformée avec corrplot
    corrplot::corrplot(transformed_correlation_matrix, method = "circle",tl.col = "black", tl.cex = 0.6, number.cex = 0.7, col = my_palette(200), is.corr = FALSE)
    mtext("Matrice de Corrélation", side = 3, line = 1, col = "black", cex = 1.5)  # Ajuster selon vos besoins
  })
}
shinyApp(ui, server)

