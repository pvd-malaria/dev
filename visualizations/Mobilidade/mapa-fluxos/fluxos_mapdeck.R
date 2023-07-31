library(tidyverse)
library(sf)
library(mapdeck)
library(stringi)
library(colourvalues)

# data ------------------------------------------------------------
fluxo <- read_csv2("fluxo_data.csv.xz")
limites <- st_read("limites_data.gpkg")

fluxo <- fluxo %>%
  mutate(
    info = stri_trans_general(info, "Latin-ASCII"),
    colors = colour_values(fluxos, "cividis")
  )

limites <- limites %>% mutate(name = stri_trans_general(name, "Latin-ASCII"))

# mapdeck ------------------------------------------------------------
key = "pk.eyJ1IjoiemxrcnZzbSIsImEiOiJja2QwcnFhNG0wMzJwMzBwOHkwYnF5MHI3In0.G30lGCNBQQ_aGPtzt-8gCQ"

map <-
  mapdeck(
    token = key,
    style = mapdeck_style("light"),
    height = 600,
    width = 800,
  ) %>%
  add_animated_arc(
    fluxo,
    origin = c("lon.origem", "lat.origem"),
    destination = c("lon.destino", "lat.destino"),
    stroke_from = "colors",
    stroke_from_opacity = 100,
    stroke_to = "colors",
    stroke_to_opacity = 100,
    stroke_width = "stroke",
    tooltip = "info",
    auto_highlight = TRUE,
    highlight_colour = rgb(139, 26, 26, 200, maxColorValue = 255),
    trail_length = 10,
    animation_speed = 1,
    legend = F) %>%
  add_polygon(
    data = limites,
    stroke_colour = "#E0E0E0",
    stroke_width = 2000,
    fill_opacity = 0,
    tooltip = "name",
    auto_highlight = TRUE,
    highlight_colour = rgb(255, 228, 181, 200, maxColorValue = 255)) %>%
  mapdeck_view(
    pitch = 45,
    location = c(-59, -5),
    zoom = 3.3)

map

htmlwidgets::saveWidget(map, "fluxos_infeccao_residencia.html",
                        selfcontained = FALSE)
