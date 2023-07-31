xfun::pkg_attach("tmap", "sf", "dplyr")

# importação -------------------------------------------------------------
xls_file <- "dados/lista_de_municipios_da_amazonia_legal_2014.xls"
aml_municipios <- readxl::read_xls(
  xls_file,
  skip = 2,
  col_names = c("UF", "UF_NM", "MUNIC", "MUNIC_NM"),
  col_types = c("numeric", "text", "numeric", "text"))

sf_municipios <- geobr::read_municipality()
sf_estados <- geobr::read_state()

# cozinha ----------------------------------------------------------------
sf_municipios <- st_make_valid(sf_municipios)
sf_estados <- st_make_valid(sf_estados)

str(sf_municipios)
str(sf_estados)
str(aml_municipios)

aml_municipios <-
  aml_municipios %>%
  mutate(in_aml = "Amazônia Legal") %>%
  select(MUNIC, in_aml)

sf_join <-
  inner_join(sf_municipios, aml_municipios, c("code_muni" = "MUNIC"))

sf_estados_aml <- sf_estados %>% filter(code_state %in% c(11:21,51))

tmap_mode("view")

# Map plotter -----------------------------------------------------------
map_basemap <- tm_basemap("GeoportailFrance.orthos")

map_municipios <-
  tm_shape(sf_join) +
  tm_fill(col = "in_aml",
              palette = "Reds",
              alpha = 0.5,
              title = "Municípios",
              group = "Municípios",
              popup.vars = c("name_muni", "abbrev_state"))
map_limites <- tm_shape(sf_join) + tm_borders(group = "Limites",
                                              col = "grey50")
map_estados <-
  tm_shape(sf_estados_aml) + tm_borders(col = "black", group = "Estados")

map_basemap + map_municipios + map_limites + map_estados

# save files for map ----------------------------------------------------------
sf_join
sf_estados_aml
st_write(sf_join, "atlas/01_municipios_aml.shp")
st_write(sf_estados_aml, "atlas/01_estados_aml.shp")
