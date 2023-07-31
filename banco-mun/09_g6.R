# libs --------------------------------------------------------------------
library(tidyverse, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)

# import ------------------------------------------------------------------
ipa <- read_csv("Dataset_municip_TxIncidencia.csv", col_types = cols(),
                locale = locale(encoding = "UTF-8"))

data <- readRDS("../dados/sivep_datatable.rds")

bd <- read_csv2("banco_final.csv",
                locale = locale(encoding = "UTF-8"),
                col_types = cols())

# munge -------------------------------------------------------------------

# Contagem de casos mensais

casos_mensais <-
  data %>%
  mutate(date_notif = parse_date_time(DT_NOTIF, orders = c("Y-m-d", "d/m/y")),
         month_notif = month(date_notif, label = TRUE, locale = "Portuguese_Brazil"),
         year_notif = year(date_notif),
         cod6_2019_g0 = as.double(MUN_INFE)) %>%
  count(cod6_2019_g0, year_notif, month_notif) %>%
  pivot_wider(cod6_2019_g0,
              names_from = c(month_notif, year_notif),
              names_prefix = "casos_",
              values_from = n,
              values_fill = 0)

# Contagem de casos anuais

casos_anuais <-
  data %>%
  mutate(date_notif = parse_date_time(DT_NOTIF, orders = c("Y-m-d", "d/m/y")),
         month_notif = month(date_notif, label = TRUE, locale = "Portuguese_Brazil"),
         year_notif = year(date_notif),
         cod6_2019_g0 = as.double(MUN_INFE)) %>%
  count(cod6_2019_g0, year_notif) %>%
  pivot_wider(cod6_2019_g0,
              names_from = year_notif,
              names_prefix = "casos_anual_",
              values_from = n,
              values_fill = 0)


# Taxa de incidência (IPA)
ipa2 <- ipa %>%
  select(cod6_2019_g0 = MUN_INFE, year_notif, ipa = txinc) %>%
  pivot_wider(
    id_cols = cod6_2019_g0,
    names_from = year_notif,
    values_from = ipa,
    names_prefix = "ipa_")

# Proporção de falciparum e vivax
prop_falcvivx <- data %>%
  as_tibble() %>%
  mutate(RES_EXAM = as.character(RES_EXAM),
         RES_EXAM = fct_collapse(
           RES_EXAM,
           Falciparum = c("2", "3", "5", "6", "7", "9"),
           Vivax = c("4"),
           other_level = "Outros")) %>%
  count(MUN_INFE, .id, RES_EXAM) %>%
  add_count(MUN_INFE, .id, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(MUN_INFE,
              names_from = c(RES_EXAM, .id),
              values_from = prop,
              names_prefix = "malariaProp") %>%
  rename(cod6_2019_g0 = MUN_INFE) %>%
  rename_with(~ paste(., "g6", sep = "_"), -cod6_2019_g0)


# Joins e writes ----------------------------------------------------------
l <- list(bd, casos_anuais, casos_mensais, ipa2, prop_falcvivx)

reduce(l, left_join) %>% write_csv2("banco_final.csv")
