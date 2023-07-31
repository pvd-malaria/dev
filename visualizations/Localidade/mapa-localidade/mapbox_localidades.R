library(mapdeck)
library(tidyverse)
library(sf)

# get grid data
sf_grid <- st_read("data.gpkg")

# get token
key = "pk.eyJ1IjoiemxrcnZzbSIsImEiOiJja2QwcnFhNG0wMzJwMzBwOHkwYnF5MHI3In0.G30lGCNBQQ_aGPtzt-8gCQ"

# make map --------------------------------------------------------------------
color_range <- viridisLite::plasma(6)

map <-
  mapdeck(
    token = key,
    style = mapdeck_style(style = "satellite-streets"),
    pitch = 45,
    location = c(-59.13, -4.27)
  ) %>%
  add_grid(
    data = sf_grid,
    layer_id = "loc_infe",
    colour = "n",
    colour_range = color_range,
    elevation = "n",
    cell_size = 10000,
    elevation_scale = 1000,
    auto_highlight = T,
    legend = T,
    legend_options = list(title = "Casos")
  ) %>%
  mapdeck_view(
    location = c(-60, -3),
    zoom = 3.13
  )

print(map)

htmlwidgets::saveWidget(map, "map_infeccoes_localidades.html",
                        selfcontained = FALSE)
