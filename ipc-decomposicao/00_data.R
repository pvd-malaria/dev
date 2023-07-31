library(tidyverse)
library(sidrar)

#setwd("ipc-decomposicao")

# Make two databases containing:

# Database - By age
# 1. Unidade da Federação
# 2. Age group
# 3. Sex!!!
# 4. Year (2007 and 2019)
# 5. Number of cases
# 6. Population

# Age ---------------------------------------------------------------------

pnad_07 <- get_sidra(261,
                     variable = c(93),
                     period = '2007',
                     geo = 'State',
                     classific = c('c58', 'c2'),
                     category = 'all')

pnad_19 <- get_sidra(6706,
                     variable = c(606),
                     period = '2019',
                     geo = 'State',
                     classific = c('c58', 'c2'),
                     category = 'all')

pnad_df <-
  pnad_07 %>% as_tibble() %>%
  select(uf = `Unidade da Federação`,
         uf_code = `Unidade da Federação (Código)`,
         ano = Ano,
         age_code = `Grupo de idade (Código)`,
         age_group = `Grupo de idade`,
         sexo = Sexo,
         valor = Valor) %>%
  filter(!age_code %in% c(0, 3242, 3243, 2792, 2793, 3245),
         uf_code %in% c(11:17, 21, 51),
         sexo != "Total") %>%
  mutate(valor = valor * 1000,
         uf = NULL, age_code = NULL)

pnad_df %>% print(n=Inf)

pnad_df2 <-
  pnad_19 %>% as_tibble() %>%
  select(uf = `Unidade da Federação`,
         uf_code = `Unidade da Federação (Código)`,
         ano = Ano,
         age_code = `Grupo de idade (Código)`,
         age_group = `Grupo de idade`,
         sexo = Sexo,
         valor = Valor) %>%
  filter(uf_code %in% c(11:17, 21, 51),
         sexo != "Total") %>%
  mutate(valor = valor * 1000,
         age_group = fct_collapse(
           age_group, '70 anos ou mais' = c('70 a 74 anos',
                                            '75 a 79 anos',
                                            "80 anos ou mais"))) %>%
  count(uf_code, ano, age_group, sexo, wt=valor, name = 'valor') %>%
  mutate(age_group = fct_relevel(age_group, '5 a 9 anos', after = 1)) %>%
  arrange(uf_code, age_group)

pnad_df2 %>% print(n=Inf)

uf_names <- c('11' = "RO", '12' = "AC", '13' = "AM", '14' = "RR",
              '15' = "PA", '16' = "AP", '17' = "TO", '21' = "MA",
              '51' = "MT")

pnad_pop <-
  bind_rows(pnad_df, pnad_df2) %>%
  mutate(pop = valor, valor = NULL) %>%
  group_by(uf_code, ano) %>%
  mutate(pop, pop_percent = pop/sum(pop),
         sexo = fct_collapse(sexo,
                             Homens = c("Homem", "Homens"),
                             Mulheres = c("Mulher", "Mulheres")),
         sexo = fct_recode(sexo, 'Men' = "Homens", "Women" = "Mulheres"),
         age_group = fct_recode(age_group, "70+" = "70 anos ou mais"),
         age_group = fct_relabel(age_group, ~ str_remove(.x, " anos")),
         age_group = fct_relabel(age_group, ~ str_replace(.x, " a ", "-")),
         uf_code = recode_factor(uf_code, !!!uf_names))

pnad_pop %>% print(n=Inf)

rm(pnad_07, pnad_19, pnad_df, pnad_df2)

sivep <- read_rds("~/CONSULTORIA/2020/PROJETO MALARIA/malaria-git/dados/sivep_datatable.rds")

cases <-
  sivep %>%
  filter(ano %in% c(2007, 2019), id_lvc == "Não LVC") %>%
  mutate(uf_notif = as.character(uf_notif),
         idade = id_pacie_anos,
         sexo = fct_recode(sexo, 'Men' = 'Masculino', 'Women' = 'Feminino'),
         age_group = cut(idade,
                         c(seq(0, 70, 5), Inf),
                         unique(pnad_pop$age_group))) %>%
  count(uf_code = uf_notif, ano, age_group, sexo, name = 'cases')

cases

left_join(pnad_pop, cases) %>% write_csv2("data.csv")
