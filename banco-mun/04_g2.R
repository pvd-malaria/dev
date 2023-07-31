
# libs --------------------------------------------------------------------
xfun::pkg_attach("tidyverse")

# import ------------------------------------------------------------------
#cd00 <- read_rds('censo_2000.rds')
#cd10 <- read_rds('censo_2010.rds')
bd <- read_csv2('banco_final.csv')

cd00_ <-
  cd00 %>%
  as_tibble() %>%
  filter(mun %in% bd$cod7_2019_g0) %>%
  mutate(mun = as.numeric(mun))

cd10_ <-
  cd10 %>%
  as_tibble() %>%
  unite(mun, uf, mun, sep = "") %>%
  mutate(mun = as.numeric(mun)) %>%
  filter(mun %in% bd$cod7_2019_g0)

# sexo --------------------------------------------------------------------
sexo00 <- cd00_ %>%
  mutate(sexo = factor(sexo, 1:2, c("Masc", "Fem"))) %>%
  count(mun, sexo, wt = peso) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(mun, names_from = sexo, values_from = prop, names_prefix = 'sexo') %>%
  rename_with(~ paste(., "2000", "g2", sep = "_"), starts_with('sexo'))

sexo10 <- cd10_ %>%
  mutate(sexo = factor(sexo, 1:2, c("m", "f"))) %>%
  count(mun, sexo, wt = peso) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(mun, names_from = sexo, values_from = prop, names_prefix = 'sexo') %>%
  rename_with(~ paste(., "2010", "g2", sep = "_"), starts_with('sexo'))

# idade -------------------------------------------------------------------
#cd00 %>% count(idade) %>% print(n = Inf)
#cd10 %>% count(idade) %>% print(n = Inf)

idade00 <- cd00_ %>%
  mutate(idade = factor(idade, 0:130)) %>%
  count(mun, idade, wt = peso, .drop = FALSE) %>%
  arrange(mun, idade) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(
    mun,
    names_from = idade,
    values_from = prop,
    names_prefix = 'idade_') %>%
  rename_with(~ paste(., "2000", "g2", sep = "_"), starts_with('idade'))

idade10 <- cd10_ %>%
  mutate(idade = factor(idade, 0:135)) %>%
  count(mun, idade, wt = peso, .drop = FALSE) %>%
  arrange(mun, idade) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(
    mun,
    names_from = idade,
    values_from = prop,
    names_prefix = 'idade_') %>%
  rename_with(~ paste(., "2010", "g2", sep = "_"), starts_with('idade'))

# nível de instrução ------------------------------------------------------

level <- c("00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","20","30")
label <- c("Sem instrução ou menos de 1 ano",
           "1 ano",
           "2 anos",
           "3 anos",
           "4 anos",
           "5 anos",
           "6 anos",
           "7 anos",
           "8 anos",
           "9 anos",
           "10 anos",
           "11 anos",
           "12 anos",
           "13 anos",
           "14 anos",
           "15 anos",
           "16 anos",
           "17 anos ou mais",
           "Não determinado",
           "Alfabetização de adultos")

nvins00 <-
  cd00_ %>%
  mutate(
    an_est = factor(an_est, level, label),
    nv_ins = fct_collapse(
      an_est,
      SemInstrFundIncomp = c("Sem instrução ou menos de 1 ano", "1 ano",
                                "2 anos", "3 anos", "4 anos", "5 anos",
                                "6 anos", "7 anos", "8 anos",
                                "Alfabetização de adultos"),
      FundCompMedIncomp = c("9 anos", "10 anos", "11 anos"),
      MedCompSupIncomp = c("12 anos", "13 anos", "14 anos", "15 anos"),
      SupComp = c("16 anos", "17 anos ou mais"),
      NDeterm = c("Não determinado"))) %>%
  count(mun, nv_ins, wt = peso, .drop = FALSE) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(
    mun,
    names_from = nv_ins,
    names_prefix = 'nvins',
    values_from = prop,
    values_fill = list(n = NA_real_)) %>%
  rename_with(~ paste(., "2000", "g2", sep = "_"), starts_with("nvins"))

level <- 1:5
label <- c("SemInstrFundIncomp",
           "FundCompMedIncomp",
           "MedCompSupIncomp",
           "SupComp",
           "NDeterm")

nvins10 <- cd10_ %>% mutate(nv_ins = factor(nv_ins, level, label)) %>%
  count(mun, nv_ins, wt = peso, .drop = FALSE) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(
    mun,
    names_from = nv_ins,
    names_prefix = 'nvins',
    values_from = prop) %>%
  rename_with(~ paste(., "2010", "g2", sep = "_"), starts_with("nvins"))

# raça/cor ----------------------------------------------------------------
level = c(1:5, 9)
label = c("Branca", "Preta", "Amarela", "Parda", "Indigena", "Ignorado")

raca00 <- cd00_ %>%
  mutate(raca = factor(raca, level, label)) %>%
  count(mun, raca, wt = peso, .drop = FALSE) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(
    mun,
    names_from = raca,
    names_prefix = 'raca',
    values_from = prop) %>%
  rename_with(~ paste(., "2000", "g2", sep = "_"), starts_with("raca"))

raca10 <- cd10_ %>%
  mutate(raca = factor(raca, level, label)) %>%
  count(mun, raca, wt = peso, .drop = FALSE) %>%
  add_count(mun, wt = n, name = "total") %>%
  mutate(prop = n/total) %>%
  pivot_wider(
    mun,
    names_from = raca,
    names_prefix = 'raca',
    values_from = prop) %>%
  rename_with(~ paste(., "2010", "g2", sep = "_"), starts_with("raca"))

# rendimento mediano em reais de 2020 -------------------------------------------
rend00 <- cd00_ %>%
  group_by(mun, ctrl) %>%
  summarise(rend_to = sum(rend_to, na.rm = T),
            n_mora = n(),
            .groups = "drop") %>%
  mutate(def_2000 = 1628.9,
         def_2020 = 5493.48,
         rend_pc = rend_to/n_mora,
         rend_pc_def = rend_pc * (def_2020 / def_2000)) %>%
  group_by(mun) %>%
  summarise(rendpc_median_2000_g2 = median(rend_pc_def))

rend10 <- cd10_ %>%
  group_by(mun, ctrl) %>%
  summarise(rend_pc = max(rend_pc), .groups = "drop") %>%
  mutate(def_2010 = 3200.06,
         def_2020 = 5493.48,
         rend_pc_def = rend_pc * def_2020 / def_2010) %>%
  group_by(mun) %>%
  summarise(rendpc_median_2010_g2 = median(rend_pc_def, na.rm = T))


# join to database --------------------------------------------------------
l = list(bd, sexo00, sexo10, raca00, raca10, rend00, rend10, nvins00, nvins10,
         idade00, idade10)

bd_mod <- l %>% reduce(left_join, c(cod7_2019_g0 = "mun")) %>% print()

write_csv2(bd_mod, 'banco_final.csv')

rm(list=setdiff(ls(), c("cd00", "cd10")))
