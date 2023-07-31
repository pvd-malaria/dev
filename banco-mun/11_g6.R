# libs --------------------------------------------------------------------
library(tidyverse, warn.conflicts = FALSE, quiet = T)
library(data.table, warn.conflicts = FALSE)
library(janitor, warn.conflicts = FALSE)
library(withr)

# import ------------------------------------------------------------------
read_lines("../dados/cnes/AtendAmbulat2017.csv", skip = 30, n_max = 10)
read_lines("../dados/cnes/AtendFarmaciaOutros2007.csv", n_max = 10)
read_lines("../dados/cnes/AtendIntern2007.csv", n_max = 10)
read_lines("../dados/cnes/AtendSadt2019.csv", n_max = 10)
read_lines("../dados/cnes/AtendUrgen2008.csv", n_max = 10)
read_lines("../dados/cnes/ESAgo2007.csv", n_max = 10)
read_lines("../dados/cnes/Habilit2007.csv", n_max = 10)
read_lines("../dados/cnes/NivAtAgo2020.csv", n_max = 7)

getPaths <- function(x) {
  paths <- dir("../dados/cnes", x)
  names(paths) <- c(2007:2020)
  paths
}

read_CNES <- function(x, dir) {
  paths <- getPaths(x)
  withr::with_dir(dir, {
    result <- purrr::map(paths, ~data.table::fread(.x, skip = 4, na.strings = c("-"))) %>%
      rbindlist(idcol = "ano", fill = TRUE) %>%
      as_tibble() %>%
      janitor::clean_names() %>%
      mutate(ano = as.integer(ano),
             codigo = parse_number(municipio),
             municipio = NULL,
             .after = 1) %>%
      filter(!is.na(codigo))
    result
  })
}

dataDir <- "../dados/cnes/"

ambulat <- read_CNES("Ambulat", dataDir)
internacoes <- read_CNES("Intern", dataDir)
farmacia <- read_CNES("Farmacia", dataDir)
sadt <- read_CNES("Sadt", dataDir)
urgencia <- read_CNES("Urgen", dataDir)
estabSaude <- read_CNES("ESAgo", dataDir)
nivAtencao <- read_CNES("NivAtAgo", dataDir)

# munge -------------------------------------------------------------------
pivot_cnes <- function(x, nome) {
  pivot_wider(
    data = x,
    names_from = c(ano),
    values_from = c(sus, particular, plano_de_saude_publico, plano_de_saude_privado),
    names_glue = paste0("es", nome, "_{.value}_{ano}_g6"),
    id_cols = codigo)
}

ambulat2 <- pivot_cnes(ambulat, "Ambulat")
internacoes2 <- pivot_cnes(internacoes, "Intern")
farmacia2 <- pivot_cnes(farmacia, "FarmaciaOutros")
sadt2 <- pivot_cnes(sadt, "Sadt")
urgencia2 <- pivot_cnes(urgencia, "Urgen")

estabSaude2 <- estabSaude %>% pivot_wider(
  id_cols = codigo,
  names_from = ano,
  values_from = c(-ano, -codigo),
  names_glue = "esTipo_{.value}_{ano}_g6")

nivAtencao2 <- nivAtencao %>% pivot_wider(
  id_cols = codigo,
  names_from = ano,
  values_from = c(-ano, -codigo),
  names_glue = "esNivAtencao_{.value}_{ano}_g6")

# joins and save ----------------------------------------------------------
bd <- read_csv2("banco_final.csv", col_types = cols())
l <- list(bd, ambulat2, internacoes2, farmacia2, sadt2, urgencia2, nivAtencao2)

l %>%
  reduce(left_join, by = c(cod6_2019_g0 = "codigo")) %>%
  write_csv2("banco_final.csv")
