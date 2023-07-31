# libs --------------------------------------------------------------------

xfun::pkg_attach('tidyverse')

try(setwd('banco-mun'))

# data --------------------------------------------------------------------

muns <- readxl::read_excel('../../malaria-git/dados/cd10/_Documentacao/Divisao territorial do brasil/Unidades da Federa‡Æo, Mesorregiäes, microrregiäes e munic¡pios 2010.xls', skip = 2, .name_repair = "universal")

m_tbl <- muns %>%
  select(!c(Mesor.região, Nome_Mesorregião, Micror.região, Nome_Microrregião)) %>%
  rename(cod7_2019_g0 = Município,
         name_2019_g0 = Nome_Município,
         coduf_2019_g0 = UF,
         ufname_2019_g0 = Nome_UF) %>%
  add_row(cod7_2019_g0 = "1504752", name_2019_g0 = "Mojuí dos Campos",
          coduf_2019_g0 = "15", ufname_2019_g0 = "Pará") %>%
  filter(coduf_2019_g0 %in% c(11:17, 21, 51)) %>%
  mutate(cod6_2019_g0 = str_sub(cod7_2019_g0, 1L, 6L))
m_tbl

# Municípios por uf
m_tbl %>% count(coduf_2019_g0)

# Mojuí
m_tbl %>% filter(cod7_2019_g0 == 1504752)

# save --------------------------------------------------------------------

write_csv2(m_tbl, 'banco_id_munic.csv')
write_csv2(m_tbl, 'banco_final.csv')
