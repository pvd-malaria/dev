
# libs --------------------------------------------------------------------

xfun::pkg_attach('tidyverse')

# import ------------------------------------------------------------------

#cd00 <- read_rds('censo_2000.rds')
#cd10 <- read_rds('censo_2010.rds')
bd <- read_csv2('banco_final.csv', col_types = cols())

estima <- read_csv2('EstimaPop2006-2020.csv', skip = 3, col_names = TRUE,
                    na = c("", "NA", "..."), n_max = 772,
                    col_types = cols(
                      Cód. = col_double(),
                      Município = col_character(),
                      `2006` = col_double(),
                      `2008` = col_double(),
                      `2009` = col_double(),
                      `2011` = col_double(),
                      `2012` = col_double(),
                      `2013` = col_double(),
                      `2014` = col_double(),
                      `2015` = col_double(),
                      `2016` = col_double(),
                      `2017` = col_double(),
                      `2018` = col_double(),
                      `2019` = col_double(),
                      `2020` = col_double()))

p2007 <- read_csv2('popContagem2007.csv', skip = 3, n_max = 771,
                   col_types = cols(
                     Cód. = col_double(),
                     Município = col_character(),
                     `2007` = col_double()))

projFlavio <- readxl::read_xlsx("ProjMunic-2010_2030.xlsx")

# munge -------------------------------------------------------------------
cd_adj <- cd10 %>%
  as_tibble() %>%
  unite('cod7', uf, mun, sep = "") %>%
  mutate(sitru = factor(sitru, c(1, 2), c('urbana', 'rural')),
         cod7 = as.numeric(cod7)) %>%
  filter(cod7 %in% bd$cod7_2019_g0)

cd_adj2 <- cd00 %>%
  as_tibble() %>%
  mutate(sitru = factor(sitru, c(1, 2), c('urbana', 'rural')),
         cod7 = as.numeric(mun)) %>%
  filter(cod7 %in% bd$cod7_2019_g0)

# tabulate ----------------------------------------------------------------

  # 2010
  pop_total <- cd_adj %>% count(
    cod7,
    wt = peso,
    .drop = FALSE,
    name = 'pop_total_2010_g1'
  )

  pop_ru <- cd_adj %>%
    count(cod7, sitru, wt = peso, .drop = FALSE) %>%
    add_count(cod7, wt = n, name = "popTotal") %>%
    mutate(prop = n/popTotal) %>%
    pivot_wider(cod7, names_from = sitru, values_from = prop) %>%
    rename(popUrbana_2010_g1 = urbana, popRural_2010_g1 = rural)

  # 2000
  pop_total2 <- cd_adj2 %>% count(
    cod7,
    wt = peso,
    .drop = FALSE,
    name = 'pop_total_2000_g1'
  )

  pop_ru2 <- cd_adj2 %>%
    count(cod7, sitru, wt = peso, .drop = FALSE) %>%
    add_count(cod7, wt = n, name = "popTotal") %>%
    mutate(prop = n/popTotal) %>%
    pivot_wider(cod7, names_from = sitru, values_from = prop) %>%
    rename(popUrbana_2000_g1 = urbana, popRural_2000_g1 = rural)

# consistency tests -------------------------------------------------------

  # 2010
  nrow(pop_total) == nrow(bd) - 1 # Mojuí dos Campos

  pop_total %>% count(wt = pop_total_2010_g1) > 24*10^6 # População total 24 milhões

  # urbana + rural = total?
  pop_ru %>% mutate(test = popUrbana_2010_g1 + popRural_2010_g1) %>%
    pull(test) %>% all()

  # 2000
  nrow(pop_total2) == nrow(bd) - 1 # Mojuí dos Campos

  pop_total2 %>% count(wt = pop_total_2000_g1) # População total

  # urbana + rural = total?
  pop_ru2 %>% mutate(test = popUrbana_2000_g1 + popRural_2000_g1) %>%
    pull(test) %>% all()


# população projetada -----------------------------------------------------
p2007 <- p2007 %>% select(-Município)
estima <- estima %>% select(-Município)

names(p2007)
names(estima)

pop_estimada <- left_join(estima, p2007, c("Cód.")) %>%
  select(cod7 = Cód., `2007`, everything(), -`2006`) %>%
  rename_with(~ paste0("popEstimada_", .), -cod7)


# projeção flávio ---------------------------------------------------------

pop_projetada <-
  projFlavio %>%
  group_by(Ano, Armenor) %>%
  janitor::clean_names() %>%
  summarise(popProjetada = sum(total)) %>%
  pivot_wider(armenor,
              names_from = ano,
              values_from = popProjetada,
              names_prefix = "popProjetada_") %>%
  rename(cod7 = armenor)

# add to database ---------------------------------------------------------

l = list(
  bd,
  pop_total,
  pop_ru,
  pop_total2,
  pop_ru2,
  pop_estimada,
  pop_projetada
)

bd_mod <- l %>%
  reduce(left_join, by = c(cod7_2019_g0 = 'cod7')) %>%
  select(-starts_with('sitru')) %>%
  # taxas de crescimento
  mutate(txcresc_2010_g1 = (pop_total_2010_g1/pop_total_2000_g1)^(1/10) - 1)

# save to database --------------------------------------------------------
file = 'banco_final.csv'
write_csv2(bd_mod, file)
