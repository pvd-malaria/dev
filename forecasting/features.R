library(fpp3)

# input -------------------------------------------------------------------

# should probably extract first 2 sections into another script later

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

pop <- sidrar::get_sidra(7358,
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

# extracting features -----------------------------------------------------

# basic features
malaria2 %>% features(api_1000, list(mean = mean))
malaria_sem %>% features(api_1000, list(mean = mean))

malaria2 %>% features(api_1000, quantile)
malaria_sem %>% features(api_1000, quantile)

# acf derived
malaria2 %>% features(api_1000, feat_acf)
malaria_sem %>% features(api_1000, feat_acf)

# stl derived
malaria2 %>% features(api_1000, feat_stl)
malaria_sem %>% features(api_1000, feat_stl)

malaria2 %>% features(api_1000, feat_stl) %>%
  ggplot(aes(x = trend_strength, y = seasonal_strength_year,
             color = nm_uf,
             label = nm_uf)) +
  geom_text(vjust = 1.1) +
  geom_point() +
  guides(color = "none", label = "none") +
  labs(title = "Trend by seasonal strengths",
       subtitle = "Mensal")


malaria_sem %>% features(api_1000, feat_stl) %>%
  ggplot(aes(x = trend_strength, y = seasonal_strength_year,
             color = nm_uf,
             label = nm_uf)) +
  geom_text(vjust = 1.1) +
  geom_point() +
  guides(color = "none", label = "none") +
  labs(title = "Trend by seasonal strengths",
       subtitle = "Semanal")


# most seasonal = Amapá

malaria2 %>% filter(nm_uf == "Amapá") %>% autoplot()

malaria_sem %>% filter(nm_uf == "Amapá") %>% autoplot()

# most trended = Rondônia

malaria2 %>% filter(nm_uf == "Rondônia") %>% autoplot()

malaria_sem %>% filter(nm_uf == "Rondônia") %>% autoplot()

# This approach actually allows me to work with the municipal level time series
# but I will leave it for later because I need the municipal projection data


# other features ----------------------------------------------------------

# coef_hurst, long memory time series
malaria2 %>% features(api_1000, coef_hurst)

malaria_sem %>% features(api_1000, coef_hurst)

# feat_spectral, easeness of forecasting
malaria2 %>% features(api_1000, feat_spectral)

malaria_sem %>% features(api_1000, feat_spectral)

# interesting, it seems that it will be difficult to forecast malaria in some ufs

# box_pierce, is the series white noise?

malaria2    %>% features(api_1000, box_pierce)
malaria_sem %>% features(api_1000, box_pierce)

# definitely not white noise

# ljung_box, same idea as box_pierce

malaria2    %>% features(api_1000, ljung_box)
malaria_sem %>% features(api_1000, ljung_box)

# shift_level_max, for finding largest mean shifts between consecutive sliding windows

malaria2    %>% features(api_1000, shift_level_max)
malaria_sem %>% features(api_1000, shift_level_max)

# guerrero, for finding the optimal lambda value for Box-Cox Trans

malaria2    %>% features(api_1000, guerrero)
malaria_sem %>% features(api_1000, guerrero)


# there are many others...
