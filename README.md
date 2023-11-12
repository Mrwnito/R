**Tableau de Bord des Interventions**

Ce projet est un tableau de bord interactif en R qui visualise les données d'interventions. Il est structuré en trois fichiers principaux de script R (global.R, ui.R, server.R) et utilise un dossier de données (les interventions des sapeurs pompiers en france de 2008 a 2021) ayant été traité via python pour harmoniser les colonnes, enlever les valeurs manquantes, etc.

**Structure du Projet**

global.R : Contient les bibliothèques nécessaires et la préparation des données.
ui.R : Gère l'interface utilisateur du tableau de bord.
server.R : Contient la logique du serveur pour les réactivités et les visualisations.
Données/ : Dossier contenant les données des interventions.

Prérequis
Pour exécuter ce projet, vous devez avoir R et les bibliothèques suivantes installées :

library(dplyr)
library(ggplot2)
library(leaflet)
library(sf)
library(shiny)
library(shinydashboard)
library(plotly)
library(bslib)
library(purrr)
library(readxl)
library(readr)
library(htmlwidgets)
library(corrplot)


Exécution du Tableau de Bord
Pour lancer le tableau de bord, suivez ces étapes :

Ouvrez RStudio ou un autre environnement de développement R.
Définissez le répertoire de travail à la racine du projet.

'setwd("chemin/vers/le/dossier/du/projet")'

Puis changer base_path avec votre chemin jusqu'au fichier Données

base_path <- r"(cheminvers\R\Données\)"

Exécutez global.R pour charger les bibliothèques et préparer les données.

'source('global.R')'

Lancez l'application Shiny en exécutant ui.R et runApp('server.R.')

'source('ui.R')'
'runApp('server.R.')'

Le tableau de bord devrait maintenant s'ouvrir dans une nouvelle fenêtre de navigateur ou dans l'interface utilisateur de RStudio.
