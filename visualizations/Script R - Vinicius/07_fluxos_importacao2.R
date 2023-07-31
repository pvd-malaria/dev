# section_header ------------------------------------------------------------
library(tidyverse)
library(geobr)
library(sf)
library(mapdeck)

# import ------------------------------------------------------------
data <- read_rds("dados/sivep_datatable.rds")

municipios <- if (file.exists("sivep/municipios_centro.gpkg")) {
  st_read("sivep/municipios_centro.gpkg")
} else {
  read_municipal_seat()
}

limites <- if (file.exists("sivep/municipios_limite.gpkg")) {
  st_read("sivep/municipios_limite.gpkg")
} else {
  read_municipality()
}

# munge ------------------------------------------------------------
full <-
  data %>%
  as.tbl() %>%
  select(MUN_NOTI, MUN_RESI, MUN_INFE) %>%
  filter(MUN_RESI != MUN_INFE) %>%
  count(MUN_INFE, MUN_RESI, name = "fluxos") %>%
  arrange(-fluxos) %>%
  add_count(wt = fluxos, name = "Total")

reduced <-
  data %>%
  as.tbl() %>%
  select(MUN_NOTI, MUN_RESI, MUN_INFE) %>%
  filter(MUN_RESI != MUN_INFE) %>%
  count(MUN_INFE, MUN_RESI, name = "fluxos") %>%
  filter(fluxos > 9.0) %>%
  arrange(-fluxos) %>%
  add_count(wt = fluxos, name = "Total")

full
reduced

quantile(pull(full, fluxos), seq(0, 1, 0.01))
pull(reduced, Total)[1] / pull(full, Total)[1]

municipios_select <- municipios %>%
  mutate(code_muni2 = as.integer(substr(code_muni, 1, 6))) %>%
  select(code_muni = code_muni2, name_muni) %>%
  st_make_valid() %>%
  st_transform(crs = 4326) %>%
  mutate(lon = st_coordinates(.)[,"X"],
         lat = st_coordinates(.)[,"Y"])

st_geometry(municipios_select) <- NULL

fluxo <-
  left_join(reduced, municipios_select, by = c("MUN_INFE" = "code_muni")) %>%
  left_join(
    municipios_select,
    by = c("MUN_RESI" = "code_muni"),
    suffix = c(".origem", ".destino")
  ) %>%
  mutate(stroke = fluxos/300,
         info = enc2native(paste0(name_muni.origem, "->",
                       name_muni.destino, ": ",
                       fluxos)))

limites2 <- limites %>%
  st_make_valid() %>%
  st_transform(crs = 4326) %>%
  st_cast("POLYGON") %>%
  mutate(code_muni = as.integer(substr(code_muni, 1, 6))) %>%
  select(code_muni, name_muni) %>%
  filter(code_muni %in% c(fluxo$MUN_INFE, fluxo$MUN_RESI))

limites2$name_muni <- enc2native(as.character(limites2$name_muni))

# mapdeck ------------------------------------------------------------
key = "pk.eyJ1IjoiemxrcnZzbSIsImEiOiJja2QwcnFhNG0wMzJwMzBwOHkwYnF5MHI3In0.G30lGCNBQQ_aGPtzt-8gCQ"

map <-
  mapdeck(
    token = key,
    style = mapdeck_style("light"),
    height = 600,
    width = 800) %>%
  add_animated_arc(
    fluxo,
    origin = c("lon.origem", "lat.origem"),
    destination = c("lon.destino", "lat.destino"),
    stroke_from = "name_muni.origem",
    stroke_from_opacity = 100,
    stroke_to = "name_muni.destino",
    stroke_to_opacity = 100,
    stroke_width = "stroke",
    tooltip = "info",
    auto_highlight = TRUE,
    highlight_colour = rgb(139, 26, 26, 200, maxColorValue = 255),
    palette = "inferno",
    trail_length = 10,
    animation_speed = 1,
    legend = T,
    legend_options = list(stroke_from = list(title = "Destino"),
                          stroke_to = list(title = "Origem"),
                          css = "max-height: 100px;")) %>%
  add_polygon(
    data = limites2,
    stroke_colour = "#E0E0E0",
    stroke_width = 2000,
    fill_opacity = 0,
    tooltip = "name_muni",
    auto_highlight = TRUE,
    highlight_colour = rgb(255, 228, 181, 200, maxColorValue = 255)) %>%
  mapdeck_view(
    pitch = 45,
    location = c(-59, -5),
    zoom = 4.5)

map

withr::with_dir(
  "img/",
  htmlwidgets::saveWidget(map, "fluxos_infectados_.9.html")
)
