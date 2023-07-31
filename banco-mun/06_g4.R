# Grupo 4 de variáveis socioeconomicas ------------------------------------
# libs --------------------------------------------------------------------
library(tidyverse)
library(readxl)
library(sidrar)
library(janitor)

# import ------------------------------------------------------------------
bd <- read_csv2(
  "banco_final.csv",
  col_types = cols(cod7_2019_g0 = col_double()))

idhm <- read_excel(
  "idhm_outros_atlasbrasil.xlsx",
  .name_repair = "universal")

# municipios de interesse

# 1193 1194 2072 5938 5939 6784
#search_sidra("Produto interno bruto")
#info_sidra(5938, T)

# pib <- get_sidra(
#   x = 5938,
#   variable = 37,
#   period = "all",
#   geo = "City",
#   geo.filter = list("State" = c(11:17,21,51)))
#
# pib %>% write_csv2("pib.csv")

pib <- read_csv2("pib.csv")

muns <- pib %>%
  select(`Município (Código)`, Município) %>%
  unique()

# PIB ---------------------------------------------------------------------
#glimpse(pib)

pib2 <- pib %>%
  as_tibble() %>%
  select(cod7 = "Município (Código)", Ano, Valor) %>%
  mutate(Valor = Valor * 1000) %>%
  pivot_wider(
    id_cols = cod7,
    names_from = "Ano",
    values_from = "Valor",
    names_prefix = "pib_") %>%
  rename_with(~ paste0(., "_g4"), .cols = !c(cod7))

# IDH Municipal -----------------------------------------------------------
#glimpse(idhm)

idhm2 <- idhm %>%
  select(nome = Territorialidades, starts_with("IDHM")) %>%
  clean_names() %>%
  mutate(nome = nome %>% str_remove("[)]") %>% str_replace("[(]", "- ")) %>%
  left_join(muns, c(nome = "Município")) %>%
  select(-nome, cod7 = `Município (Código)`) %>%
  rename_with(~ paste(., "g4", sep = "_"), -cod7)


# Proporção da população ocupada por setores de atividade -----------------
idhm %>%
  select(nome = Territorialidades,
         ..dos.ocupados.no.setor.agropecuário.2000:..dos.ocupados.no.setor.de.serviços.2010) %>%
  names() %>%
  cat(., sep = "\n")

p_setor_ativ <- idhm %>%
  select(nome = Territorialidades, contains("ocupados")) %>%
  mutate(nome = nome %>% str_remove("[)]") %>% str_replace("[(]", "- ")) %>%
  left_join(muns, c(nome = "Município")) %>%
  select(2:15, `Município (Código)`) %>%
  rename(
    cod7                          = `Município (Código)`,
    setorAgro_2000_g4             = ..dos.ocupados.no.setor.agropecuário.2000,
    setorAgro_2010_g4             = ..dos.ocupados.no.setor.agropecuário.2010,
    setorExtrativoMineral_2000_g4 = ..dos.ocupados.no.setor.extrativo.mineral.2000,
    setorExtrativoMineral_2010_g4 = ..dos.ocupados.no.setor.extrativo.mineral.2010,
    setorIndTransform_2000_g4 = ..dos.ocupados.na.indústria.de.transformação.2000,
    setorIndTransform_2010_g4 = ..dos.ocupados.na.indústria.de.transformação.2010,
    setorServIndUtilPub_2000_g4   = ..dos.ocupados.nos.setores.de.serviços.industriais.de.utilidade.pública.2000,
    setorServIndUtilPub_2010_g4   = ..dos.ocupados.nos.setores.de.serviços.industriais.de.utilidade.pública.2010,
    setorConstr_2000_g4           = ..dos.ocupados.no.setor.de.construção.2000,
    setorConstr_2010_g4           = ..dos.ocupados.no.setor.de.construção.2010,
    setorComercio_2000_g4         = ..dos.ocupados.no.setor.comércio.2000,
    setorComercio_2010_g4         = ..dos.ocupados.no.setor.comércio.2010,
    setorServicos_2000_g4         = ..dos.ocupados.no.setor.de.serviços.2000,
    setorServicos_2010_g4         = ..dos.ocupados.no.setor.de.serviços.2010) %>%
  mutate(across(where(is.numeric), ~ .x / 100))

# join com o banco --------------------------------------------------------
l <- list(bd, pib2, idhm2, p_setor_ativ)
bd_mod <- l %>% reduce(left_join, by = c("cod7_2019_g0" = "cod7"))

write_csv2(bd_mod, "banco_final.csv")
