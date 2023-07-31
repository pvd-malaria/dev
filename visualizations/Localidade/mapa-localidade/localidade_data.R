library(tidyverse)
library(sf)


# get grid data
arquivo = "../dados/sivep/sivep_municipios_georeferenciados_positivos_2007_2020.csv"
cols = cols(
  .default = col_double(),
  DT_NOTIF = col_character(),
  DT_ENVLO = col_character(),
  DT_DIGIT = col_character(),
  SEM_NOTI = col_character(),
  DT_NASCI = col_character(),
  ID_DIMEA = col_character(),
  SEXO = col_character(),
  DT_SINTO = col_character(),
  DT_EXAME = col_character(),
  QTD_PARA = col_character(),
  DT_TRATA = col_character(),
  NOME_MUN = col_character()
)

grid_data = read_csv2(arquivo, col_types = cols)

grid_infe = grid_data %>%
  mutate(id = paste0(MUN_INFE, LOC_INFE)) %>%
  select(id, lat = LATI_INFE, lon = LONG_INFE) %>%
  filter(!is.na(lat), !is.na(lon)) %>%
  count(id, lat, lon) %>%
  print()

sf_grid <- st_as_sf(grid_infe, coords = c("lon", "lat"))

write_sf(sf_grid, "data.gpkg")
