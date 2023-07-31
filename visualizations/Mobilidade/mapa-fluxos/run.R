source("fluxos_mapdeck.R")

files <- dir(include.dirs = TRUE)
files

dest <- "~/CONSULTORIA/2020/PROJETO MALARIA/beluzo-malaria/visualizations/Mobilidade/mapa-fluxos"

file.copy(files, dest, recursive = TRUE)
