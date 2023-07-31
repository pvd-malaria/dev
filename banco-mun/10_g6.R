# functions ---------------------------------------------------------------
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

# libs --------------------------------------------------------------------
library(tidyverse, warn.conflicts = FALSE)
library(janitor)
library(withr)

# import ------------------------------------------------------------------
med <-
  read_csv2("../dados/cnes/medicos.csv", skip = 5, n_max = 772,
            locale = locale(encoding = "Windows-1252"), col_types = cols()) %>%
  clean_names() %>%
  mutate(municipio = parse_number(municipio))

sivep <- readRDS("../dados/sivep_datatable.rds")
sivep <- as_tibble(sivep)

# numero de medicos -------------------------------------------------------
med2 <-
  med %>% pivot_longer(
    -municipio,
    names_to = c("ano", "mes"),
    names_prefix = "x",
    names_sep = "_",
    values_to = "n") %>%
  group_by(municipio, ano) %>%
  summarise(mode = getmode(n)) %>%
  pivot_wider(names_from = ano,
              values_from = mode,
              names_prefix = "med_",
              values_fn = as.numeric)

# médicos por habitante
bd <- read_csv2("banco_final.csv")
med3 <-
  bd %>% select(cod6_2019_g0, pop_total_2010_g1) %>%
  left_join(med2, by = c(cod6_2019_g0 = "municipio")) %>%
  mutate(across(starts_with("med_"), ~ .x / pop_total_2010_g1 * 1000)) %>%
  rename_with(~ str_replace(.x, "_", "1kHab_"), starts_with("med_")) %>%
  select(-pop_total_2010_g1)

# proporcao de deteccao ativa ---------------------------------------------
prop_da <-
  sivep %>%
  count(ano = .id, MUN_INFE, TIPO_LAM) %>%
  add_count(ano, MUN_INFE, wt = n, name = "casos_total") %>%
  mutate(p = n/casos_total) %>%
  filter(TIPO_LAM == 2) %>%
  pivot_wider(
    c(ano, MUN_INFE),
    names_from = "ano",
    values_from = "p",
    names_prefix = "propDetAtiva_") %>%
  rename(cod6_2019_g0 = MUN_INFE) %>%
  rename_with(~ paste0(.x, "_g6"), -cod6_2019_g0)

# Junções ao banco -------------------------------------------------------
bd <- read_csv2("banco_final.csv", locale = locale(encoding = "UTF-8"))
l <- list(bd, med3, prop_da)
reduce(l, left_join) %>% write_csv2("banco_final.csv")
