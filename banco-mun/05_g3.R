# libs --------------------------------------------------------------------
#setwd('banco-mun')

xfun::pkg_attach("tidyverse")

# import ------------------------------------------------------------------
#cd00 <- read_rds('censo_2000.rds')
#cd10 <- read_rds('censo_2010.rds')
bd <- read_csv2('banco_final.csv', col_types = cols())

# munge migração ----------------------------------------------------------
cd10_ <- cd10 %>%
  mutate(data_fixa = as.integer(data_fixa),
         mun = as.integer(paste0(uf, mun)))

cd00_ <- cd00 %>%
  mutate(data_fixa = as.integer(data_fixa),
         mun = as.integer(mun))

# taxas de migração -------------------------------------------------------
cd00_ %>% as_tibble()
cd10_ %>% as_tibble()

cd00_ %>% count(data_fixa, sort = TRUE)
cd10_ %>% count(data_fixa, sort = TRUE)

x <- cd00_ %>%
  as_tibble() %>%
  filter(!is.na(data_fixa)) %>%
  count(mun, wt = peso, name = "imig_2000_g3")
x

y <- cd00_ %>%
  as_tibble() %>%
  filter(!is.na(data_fixa)) %>%
  count(data_fixa, wt = peso, name = "emig_2000_g3")
y

z <-
  inner_join(x, y, by = c("mun" = "data_fixa")) %>%
  filter(mun %in% bd$cod7_2019_g0) %>%
  mutate(migbruta_2000_g3 = imig_2000_g3 + emig_2000_g3,
         saldomig_2000_g3 =  imig_2000_g3 - emig_2000_g3,
         iem_2000_g3 = saldomig_2000_g3/migbruta_2000_g3)
z

x2 <- cd10_ %>%
  as_tibble() %>%
  filter(!is.na(data_fixa)) %>%
  count(mun, wt = peso, name = "imig_2010_g3")
x2

y2 <- cd10_ %>%
  as_tibble() %>%
  filter(!is.na(data_fixa)) %>%
  count(data_fixa, wt = peso, name = "emig_2010_g3")
y2

z2 <-
  inner_join(x2, y2, by = c("mun" = "data_fixa")) %>%
  filter(mun %in% bd$cod7_2019_g0) %>%
  mutate(migbruta_2010_g3 = imig_2010_g3 + emig_2010_g3,
         saldomig_2010_g3 =  imig_2010_g3 - emig_2010_g3,
         iem_2010_g3 = saldomig_2010_g3/migbruta_2010_g3)
z2

bd_mod <- bd %>%
  left_join(z , by = c("cod7_2019_g0" = "mun")) %>%
  left_join(z2, by = c("cod7_2019_g0" = "mun")) %>%
  mutate(txmigbruta_2000_g3 = migbruta_2000_g3 / pop_total_2000_g1,
         txmigliqui_2000_g3 = saldomig_2000_g3 / pop_total_2000_g1,
         txmigbruta_2010_g3 = migbruta_2010_g3 / pop_total_2010_g1,
         txmigliqui_2010_g3 = saldomig_2010_g3 / pop_total_2010_g1)

bd_mod %>% write_csv2("banco_final.csv")
