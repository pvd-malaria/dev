library(tidyverse)

# Variáveis ambientais ----------------------------------------------------
# libs --------------------------------------------------------------------

# import ------------------------------------------------------------------
files <- dir("../dados/desmat", full.names = T)
desmat <- map(files, read_csv, locale = locale(encoding = "Windows-1252"))

# desmatamento ------------------------------------------------------------
names(desmat) <- 2007:2019
desmat2 <- desmat %>%
  imap(~ mutate(.x, Ano = as.numeric(.y))) %>%
  map(~ rename_with(.x, str_remove, pattern = "\\d+$")) %>%
  bind_rows() %>%
  select(Id = Nr, Ano, CodIbge, AreaKm:last_col())
desmat2

# export ------------------------------------------------------------------
write_rds(desmat2, "desmatamento.rds")
