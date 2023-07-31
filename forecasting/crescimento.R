library(tidyverse)

# import ------------------------------------------------------------------

estimativas <- "../banco-mun/EstimaPop2006-2020.csv"
projecoes <- "../banco-mun/ProjMunic-2010_2030.xlsx"
contagem <- "../dados/contagem2007.xlsx"

read_lines(contagem, n_max = 10)

colspec <- cols(
  Cód. = col_double(),
  Município = col_character(),
  .default = col_double()
)

estim <- read_csv2(
  estimativas,
  skip = 3,
  n_max = 772,
  col_types = colspec,
  na = "...")

estim2 <- estim %>%
  select(Cód., `2008`:`2009`) %>%
  pivot_longer(`2008`:`2009`,
               names_to = "Ano",
               values_to = "Total",
               names_transform = list(Ano = as.double))

proj <- readxl::read_xlsx(projecoes)
proj2 <- proj %>%
  select(Ano:NomeMunic, Total) %>%
  count(Ano, Cód. = Armenor, wt = Total, name = "Total")

cont <- readxl::read_xlsx(contagem,
                          skip = 4,
                          n_max = 807,
                          col_names = c("Cód.", "Município", "Total"))
cont2 <- cont %>%
  mutate(Ano = 2007, Cód. = as.numeric(Cód.)) %>%
  select(-Município)
cont2

pop <-
  bind_rows(
    Projecao = proj2,
    Estimativa = estim2,
    Contagem = cont2,
    .id = "Origem") %>%
  arrange(Ano)

tx_cresc <- pop %>%
  filter(Ano <= 2030) %>%
  group_by(Cód.) %>%
  mutate(tx_cr = Total / lag(Total) - 1) %>%
  arrange(Cód., Ano)

tx_cresc %>% write_rds("crescimento.rds")

