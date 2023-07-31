# Variáveis climáticas ----------------------------------------------------
#setwd("banco-mun")

# libs --------------------------------------------------------------------

library(tidyverse)

options(readr.default_locale = locale(encoding = "Windows-1252"))
# Import ------------------------------------------------------------------

# read location data
station_metadata <- function(file, input_dir) {
  withr::with_dir(input_dir,{
    y <- suppressMessages({
      read_csv2(file, n_max = 8, col_names = c("var", "value"))
    })
    y <- pivot_wider(y, names_from = var, values_from = value)
    y <- janitor::clean_names(y, ascii = FALSE)
    y
  })
}

files <- list.files("../dados/inmet", recursive = TRUE)
dir <- "../dados/inmet"

station_metadata(files[3], dir)

x <- map_dfr(files, station_metadata, input_dir = dir)
x
