# pkgs ---------------------------------------------------------------
library(sf)
library(tidyverse)
library(geobr)
library(scales)
library(tmap)

# import -------------------------------------------------------------
data <- read_csv2("atlas/03_indicadores_migração.csv.xz")
data

states <-
  if (!file.exists("atlas/brasil-uf.gpkg")) {
    x = read_state(showProgress = FALSE)
    st_write(x, "atlas/brasil-uf.gpkg", append = FALSE)
    x
  } else {
    st_read("atlas/brasil-uf.gpkg")
  }

states

# cozinha ------------------------------------------------------------
# prepare data
prep_data <- data %>%
  filter(uf %in% c(11:21,51)) %>%
  mutate(
    ufb = factor(ufb, levels = c(
      "RONDÔNIA", "ACRE", "AMAZONAS", "RORAIMA", "PARÁ", "AMAPÁ",
      "TOCANTINS", "MARANHÃO", "MATO GROSSO")),
    tx_bruta = tx_bruta*1000,
    tx_liqui = tx_liqui*1000
  ) %>%
  select(-ufb)

prep_data


# merge with spatial features
state_data <-
  inner_join(states, prep_data, by = c("code_state" = "uf"))
state_data

# viz ----------------------------------------------------------------
tmap_options(basemaps = "OpenStreetMap.Mapnik",
             limits = c(facets.view = 6))

tmap_mode("view")

map_populacao <-
    tm_shape(state_data) +
    tm_polygons(
      col = "populacao",
      style = "fisher",
      n = 4,
      midpoint = NA,
      palette = "Oranges",
      title = "Habitantes",
      popup.vars = c("populacao", "name_state"),
      legend.format =
        list(
          fun = number_format(accuracy = 1,
                              big.mark = ".",
                              decimal.mark = ","),
          text.separator = "a"
        )
    ) +
    tm_view(view.legend.position = c("left", "bottom")) +
    tm_layout(title = "População total", panel.show = TRUE)

map_migbruta <-
    tm_shape(state_data) +
    tm_polygons(
      col = "mig_bruta",
      style = "fisher",
      n = 4,
      midpoint = NA,
      palette = "Oranges",
      title = "Migrantes",
      popup.vars = c("mig_bruta", "name_state"),
      legend.format =
        list(
          fun = number_format(accuracy = 1,
                              big.mark = ".",
                              decimal.mark = ","),
          text.separator = "a"
        )
    ) +
    tm_view(view.legend.position = c("left", "bottom")) +
    tm_layout(title = "Migração bruta", panel.show = TRUE)

map_migsaldo <-
    tm_shape(state_data) +
    tm_polygons(
      col = "mig_saldo",
      style = "fisher",
      n = 4,
      midpoint = NA,
      palette = "-PuOr",
      title = "Migrantes",
      popup.vars = c("mig_saldo", "name_state"),
      legend.format =
        list(
          fun = number_format(accuracy = 1,
                              big.mark = ".",
                              decimal.mark = ","),
          text.separator = "a"
        )
    ) +
    tm_view(view.legend.position = c("left", "bottom")) +
    tm_layout(title = "Saldo migratório", panel.show = TRUE)

map_txbruta <-
    tm_shape(state_data) +
    tm_polygons(
      col = "tx_bruta",
      style = "fisher",
      n = 4,
      midpoint = 0,
      palette = "Oranges",
      title = "Taxa (por 1000 hab.)",
      popup.vars = c("tx_bruta", "name_state"),
      legend.format =
        list(
          fun = number_format(accuracy = 1,
                              big.mark = ".",
                              decimal.mark = ","),
          text.separator = "a"
        )
    ) +
    tm_view(view.legend.position = c("left", "bottom")) +
    tm_layout(title = "Taxa de migração bruta", panel.show = TRUE)

map_txliqui <-
    tm_shape(state_data) +
    tm_polygons(
      col = "tx_liqui",
      style = "fisher",
      n = 4,
      midpoint = 0,
      palette = "-PuOr",
      title = "Taxa (por 1000 hab.)",
      popup.vars = c("tx_liqui", "name_state"),
      legend.format =
        list(
          fun = number_format(accuracy = 0.1,
                              big.mark = ".",
                              decimal.mark = ","),
          text.separator = "a"
        )
    ) +
    tm_view(view.legend.position = c("left", "bottom")) +
    tm_layout(title = "Taxa de migração líquida", panel.show = TRUE)

map_indiceef <-
    tm_shape(state_data) +
    tm_polygons(
      col = "indice_ef",
      style = "fisher",
      n = 4,
      midpoint = NA,
      palette = "-PuOr",
      title = "Índice",
      popup.vars = c("indice_ef", "name_state"),
      legend.format =
        list(
          fun = number_format(accuracy = 0.1,
                              big.mark = ".",
                              decimal.mark = ","),
          text.separator = "a"
        )
    ) +
    tm_view(view.legend.position = c("left", "bottom")) +
    tm_layout(title = "Índice de eficácia migratória", panel.show = TRUE)

# export ---------------------------------------------------------------------
l <- list(map_populacao,
          map_migbruta,
          map_migsaldo,
          map_txbruta,
          map_txliqui,
          map_indiceef)

file <-
  paste(
    c(
      "map_populacao",
      "map_migbruta",
      "map_migsaldo",
      "map_txbruta",
      "map_txliqui",
      "map_indiceef"
    ),
    ".html",
    sep = ""
  )

purrr::walk2(l, file, ~tmap_save(.x, .y, height = 3, width = 4.5))
