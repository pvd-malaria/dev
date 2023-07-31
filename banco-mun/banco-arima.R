library(tidyverse, warn.conflicts = FALSE, quietly = TRUE)
library(lubridate, warn.conflicts = FALSE)

try(setwd("banco-mun"))

# Input -------------------------------------------------------------------

bd <- read_csv2("banco_id_munic.csv", col_types = cols())
#glimpse(bd)

sivep <- read_rds("../../malaria-git/dados/sivep_datatable.rds")
#glimpse(sivep)


# Tidy --------------------------------------------------------------------

bd <- bd %>%
  select(cd_mun = cod6_2019_g0,
         nm_mun = name_2019_g0,
         nm_uf = ufname_2019_g0)

bd2 <-
  sivep %>%
  filter(id_lvc == "Não LVC") %>%
  mutate(id_pacie_anos = if_else(id_pacie_anos > 120, NA_integer_, id_pacie_anos),
         sem_epi = tsibble::yearweek(dt_notif),
         g_idade = cut(id_pacie_anos, c(0, 5, 60, Inf), right = FALSE),
         tp_parasi = fct_collapse(res_exam,
                                  Falciparum = c("Falciparum", "F+Fg", "Fg"),
                                  Vivax = c("Vivax", "Não Falciparum"),
                                  other_level = "Outro")) %>%
  count(cd_mun = mun_noti, sem_epi, sexo, tp_parasi, g_idade)

bd3 <- bd %>% right_join(bd2)

#sample_n(bd3, 10)

# Export ------------------------------------------------------------------

write_csv2(bd3, "banco_arima.csv")
write_rds(bd3, "banco_arima.rds")
