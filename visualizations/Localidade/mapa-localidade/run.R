source("localidade_data.R")
source("mapbox_localidades.R")

files <- dir(include.dirs = TRUE)

dest <- "~/CONSULTORIA/2020/PROJETO MALARIA/beluzo-malaria/visualizations/Localidade/mapa-localidade"

if(!dir.exists(dest)) dir.create(dest)

file.copy(files, dest, recursive = TRUE)
