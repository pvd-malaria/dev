library(fpp3)
library(sidrar)

# input -------------------------------------------------------------------

malaria <- readRDS("~/CONSULTORIA/2020/PROJETO MALARIA/beluzo-malaria/banco-mun/banco_arima.rds")

malaria <- malaria %>%
  arrange(-n) %>%
  as_tsibble(key = c(cd_mun, sexo, tp_parasi, g_idade, n),
             index = sem_epi)

malaria2 <- malaria %>%
  index_by(mes = yearmonth(sem_epi)) %>%
  group_by(nm_uf) %>%
  summarise(n = sum(n))

malaria2

malaria_sem <- malaria %>%
  group_by(nm_uf) %>%
  summarise(n = sum(n))

malaria_sem

# transform malaria into per capita ---------------------------------------

info_sidra(7358)

pop <- get_sidra(7358,
          variable = 606,
          geo = "State",
          geo.filter = list(c(11:17, 21, 51)),
          classific = "c1933",
          category = list(c(116329, 116327, 119270, 4336, 12037, 13242, 49029,
                          49030, 49031, 49032, 49033, 49034, 49035, 49036)),
          format = 2)

names(pop) <- make.unique(names(pop))

# Weekly data

pop_sem <- pop %>%
  select(nm_uf = `Unidade da Federação`, Ano = Ano.1, Pop = Valor) %>%
  mutate(Ano = as.numeric(Ano))

pop_sem <- malaria_sem %>%
  mutate(Ano = year(sem_epi)) %>%
  left_join(pop_sem) %>%
  select(-Ano, -n) %>%
  mutate(Pop = if_else(sem_epi %>% epiweek() == 1, Pop, NA_real_)) %>%
  as_tsibble(nm_uf, sem_epi)

malaria_sem <- pop_sem %>%
  filter(nm_uf != "Tocantins") %>%
  model(ARIMA(Pop ~ -1 + pdq(0,1,0) + PDQ(0,0,0))) %>%
  interpolate(pop_sem) %>%
  left_join(malaria_sem, .) %>%
  mutate(api_1000 = n / Pop * 1000, n = NULL, Pop = NULL)

# Need to find a solution for Tocantins later,
# maybe try again with a modified grid expansion

# Monthly data

pop2 <- pop %>%
  select(nm_uf = `Unidade da Federação`, Ano = Ano.1, Pop = Valor) %>%
  mutate(Ano = as.numeric(Ano)) %>%
  expand_grid(mes = 1:12) %>%
  mutate(Pop = if_else(mes == 1, Pop, NA_real_),
         mes = yearmonth(paste(Ano, mes, sep = "-")),
         Ano = NULL) %>%
  as_tsibble(key = nm_uf, index = mes)

malaria2 <- pop2 %>%
  model(ARIMA(Pop ~ -1 + pdq(0,1,0) + PDQ(0,0,0))) %>%
  interpolate(pop2) %>%
  left_join(malaria2, .) %>%
  mutate(api_1000 = n / Pop * 1000) %>%
  select(-n, -Pop)

malaria2

# components -------------------------------------------------------------

dcmp <- malaria2 %>%
  filter(nm_uf != "Tocantins") %>%
  model(stl = STL(api_1000))

components(dcmp) %>%
  as_tsibble() %>%
  autoplot() +
  facet_wrap(~nm_uf)

components(dcmp) %>%
  filter(nm_uf == "Acre") %>%
  autoplot() +
  ggtitle("STL Decomposition for Acre")

components(dcmp) %>%
  filter(nm_uf == "Rondônia") %>%
  autoplot() +
  ggtitle("STL Decomposition for Rondônia")

components(dcmp) %>%
  filter(nm_uf == "Amazonas") %>%
  autoplot() +
  ggtitle("STL Decomposition for Amazonas")

components(dcmp) %>%
  filter(nm_uf == "Roraima") %>%
  autoplot() +
  ggtitle("STL Decomposition for Roraima")


# classical decomp - moving averages --------------------------------------

malaria_ma <- malaria2 %>%
  mutate(`12-MA` = slider::slide_dbl(api_1000, mean,
                                    .before = 5, .after = 6,
                                    complete = TRUE),
         `2x12-MA` = slider::slide_dbl(api_1000, mean,
                                       .before = 1, .after = 0,
                                       complete = TRUE)
  )

malaria_ma %>%
  filter(nm_uf == "Acre") %>%
  autoplot(api_1000) +
  geom_line(aes(y = `2x12-MA`), color = "orange")

malaria_ma %>%
  filter(nm_uf == "Amazonas") %>%
  autoplot(api_1000) +
  geom_line(aes(y = `2x12-MA`), color = "orange")

malaria2 %>%
  filter(nm_uf == "Acre") %>%
  model(classical_decomposition(api_1000, type = "additive")) %>%
  components() %>%
  autoplot()

malaria2 %>%
  filter(nm_uf == "Amazonas") %>%
  model(classical_decomposition(api_1000, type = "additive")) %>%
  components() %>%
  autoplot()

malaria2 %>%
  filter(nm_uf == "Roraima") %>%
  model(classical_decomposition(api_1000, type = "additive")) %>%
  components() %>%
  autoplot()

malaria2 %>%
  filter(nm_uf == "Acre") %>%
  model(classical_decomposition(api_1000, type = "multiplicative")) %>%
  components() %>%
  autoplot()

malaria2 %>%
  filter(nm_uf == "Amazonas") %>%
  model(classical_decomposition(api_1000, type = "multiplicative")) %>%
  components() %>%
  autoplot()

malaria2 %>%
  filter(nm_uf == "Roraima") %>%
  model(classical_decomposition(api_1000, type = "multiplicative")) %>%
  components() %>%
  autoplot()


# official statistics methods ---------------------------------------------

# x11

# Acre
x11_dcmp <- malaria2 %>%
  filter(nm_uf == "Acre") %>%
  model(x11 = X_13ARIMA_SEATS(api_1000 ~ x11())) %>%
  components()

x11_dcmp %>% autoplot()

x11_dcmp %>% gg_subseries(seasonal)

# Amazonas

x11_dcmp <- malaria2 %>%
  filter(nm_uf == "Amazonas") %>%
  model(x11 = X_13ARIMA_SEATS(api_1000 ~ x11())) %>%
  components()

x11_dcmp %>% autoplot()

x11_dcmp %>% gg_subseries(seasonal)

# Roraima

x11_dcmp <- malaria2 %>%
  filter(nm_uf == "Roraima") %>%
  model(x11 = X_13ARIMA_SEATS(api_1000 ~ x11())) %>%
  components()

x11_dcmp %>% autoplot()

x11_dcmp %>% gg_subseries(seasonal)

# SEATS

seats_dcmp <- malaria2 %>%
  filter(nm_uf != "Tocantins") %>%
  model(seats = X_13ARIMA_SEATS(api_1000 ~ seats())) %>%
  components()

# Acre

seats_dcmp %>%
  filter(nm_uf == "Acre") %>%
  autoplot()

# Amazonas

seats_dcmp %>%
  filter(nm_uf == "Amazonas") %>%
  autoplot()


# Roraima

seats_dcmp %>%
  filter(nm_uf == "Roraima") %>%
  autoplot()

# Neither x11 nor SEATS captured much of a seasonal pattern, like the STL model
# I think this might mean that any seasonal variation is not present in the way
# we would associate with, say, labor markets. It's much more of a cycle/trend.


# STL ---------------------------------------------------------------------

# Monthly data

stl_dcmp_mes <- malaria2 %>%
  filter(nm_uf != "Tocantins") %>%
  model(STL(api_1000 ~ trend(window = 21) + season(window = 5))) %>%
  components()

# Acre

stl_dcmp_mes %>%
  filter(nm_uf == "Acre") %>%
  autoplot()

# Amazonas

stl_dcmp_mes %>%
  filter(nm_uf == "Amazonas") %>%
  autoplot()

# Roraima

stl_dcmp_mes %>%
  filter(nm_uf == "Roraima") %>%
  autoplot()

# Weekly data

stl_dcmp_sem <- malaria_sem %>%
  filter(nm_uf != "Tocantins") %>%
  model(STL(api_1000 ~ trend(window = 101), robust = TRUE)) %>%
  components()

# Acre

state = "Acre"

stl_dcmp_sem %>%
  filter(nm_uf == state) %>%
  autoplot() +
  labs(subtitle = state)

# Amazonas

state = "Amazonas"

stl_dcmp_sem %>%
  filter(nm_uf == state) %>%
  autoplot() +
  labs(subtitle = state)

# Roraima

state = "Roraima"

stl_dcmp_sem %>%
  filter(nm_uf == state) %>%
  autoplot() +
  labs(subtitle = state)

# Pará

state = "Pará"

stl_dcmp_sem %>%
  filter(nm_uf == state) %>%
  autoplot() +
  labs(subtitle = state)


