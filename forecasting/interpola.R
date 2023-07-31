library(fpp3)

malaria <- readRDS("~/CONSULTORIA/2020/PROJETO MALARIA/beluzo-malaria/banco-mun/banco_arima.rds")
malaria <- malaria %>%
  mutate(mes = yearmonth(sem_epi),
         row = row_number()) %>%
  select(-c(nm_mun, nm_uf, sem_epi)) %>%
  as_tsibble(key = c(row, cd_mun, sexo, tp_parasi, g_idade),
             index = mes) %>%
  mutate(uf = cd_mun %/% 1e4) %>%
  group_by(uf) %>%
  summarise(casos = sum(n))

malaria

cresc <- readxl::read_xlsx("projecoes-ibge-populacao-2007-2020.xlsx") %>%
  mutate(across(where(is.character), as.double)) %>%
  filter(ano <= 2019) %>%
  mutate(mes    = paste(ano, "01", sep = "-"),
         mes    = yearmonth(mes)) %>%
  select(mes, uf, populacao)

meses <- seq(yearmonth("2007-01"), yearmonth("2019-12"), by = 1)

cresc2 <- cresc %>%
  expand(mes = meses, uf) %>%
  left_join(cresc) %>%
  arrange(uf) %>%
  print(n = 100)

desmat <- readRDS("desmatamento.rds") %>%
  rename_with(tolower) %>%
  mutate(uf = codibge %/% 1e5) %>%
  relocate(uf, .after = id) %>%
  group_by(uf, ano) %>%
  summarise(across(areakm:hidrografia, sum), .groups = "drop") %>%
  select(uf, ano, areakm, desmatado, incremento, hidrografia) %>%
  mutate(mes = yearmonth(paste(ano, "01", sep = "-")))

desmat2 <- desmat %>%
  expand(mes = meses, uf) %>%
  left_join(desmat %>% select(-ano)) %>%
  arrange(uf) %>%
  fill(areakm, hidrografia)

desmat2 %>% arrange(uf) %>% print(n = 50)

prec <- readRDS("clima_prec.rds") %>%
  select(uf = code_state, mes, prec = mediana) %>%
  mutate(mes = yearmonth(mes)) %>%
  as_tsibble(uf, mes)

prec

tmax <- readRDS("clima_tmax.rds") %>%
  select(mes, uf = code_state, tmax = mediana) %>%
  mutate(mes = yearmonth(mes)) %>%
  as_tsibble(uf, mes)

tmax

tmin <- readRDS("clima_tmin.rds") %>%
  select(mes, uf = code_state, tmin = mediana) %>%
  mutate(mes = yearmonth(mes)) %>%
  as_tsibble(uf, mes)

tmin

malaria2 <- malaria %>%
  left_join(cresc2) %>%
  left_join(desmat2) %>%
  left_join(prec) %>%
  left_join(tmax) %>%
  left_join(tmin) %>%
  filter_index(. ~ "2019-12") %>%
  fill_gaps()


malaria2 %>% print(n = 50)

my_interp <- function(data, vars) {
  f <- formula(paste0(vars, " ~ -1 + pdq(0,1,0) + PDQ(0,0,0)"))
  data %>%
    model(naive = ARIMA(f)) %>%
    interpolate(new_data = data) %>%
    pull(vars)
}

malaria2 %>%
  mutate(populacao = my_interp(malaria2, "populacao"),
         desmatado = my_interp(malaria2, "desmatado"),
         incremento = desmatado - lag(desmatado),
         incremento = if_else(mes == yearmonth("2007-01"), NA_real_, incremento),
         desmatado = NULL,
         areakm = NULL,
         hidrografia = NULL) %>%
  saveRDS("malaria_covars.rds", compress = FALSE)



