#setwd("banco-mun")


# Variáveis ambientais ----------------------------------------------------
# libs --------------------------------------------------------------------
library(tidyverse)

# import ------------------------------------------------------------------
files <- dir("../dados/desmat", full.names = T)
desmat <- map(files, read_csv, locale = locale(encoding = "Windows-1252"))
bd <- read_csv2("banco_final.csv", locale = locale(encoding = "UTF-8"))

# desmatamento ------------------------------------------------------------
join_by <- c("Nr", "Lat", "Long", "Latgms", "Longms", "Municipio", "CodIbge", "Estado", "AreaKm2")

desmat2 <- reduce(desmat, left_join, by = join_by)

desmat3 <-
  desmat2 %>%
  select(-starts_with("Soma"), -(Nr:Municipio), -Estado) %>%
  rename_with(~paste(., "g5", sep = "_"), .cols = -CodIbge)


# export ------------------------------------------------------------------
l <- list(bd, desmat3)

bd_mod <- reduce(l, left_join, by = c("cod7_2019_g0" = "CodIbge"))

write_csv2(bd_mod, "banco_final.csv")
