library(fpp3)

# input -------------------------------------------------------------------

malaria <- readRDS("~/CONSULTORIA/2020/PROJETO MALARIA/beluzo-malaria/banco-mun/banco_arima.rds")

malaria <- malaria %>%
  arrange(-n) %>%
  as_tsibble(key = c(cd_mun, sexo, tp_parasi, g_idade, n),
             index = sem_epi)

# time plots --------------------------------------------------------------

amazonia <- malaria %>%
  summarise(n = sum(n))

autoplot(amazonia, n) +
  scale_x_yearweek(date_breaks = "104.36 weeks") +
  labs(title = "Notificações de malária",
       subtitle = "Amazônia Legal",
       x = "Semana epidemiológica",
       y = "Notificações")

amazonia_byuf <- malaria %>%
  group_by(nm_uf) %>%
  summarise(n = sum(n))

autoplot(amazonia_byuf, n) +
  facet_wrap(~nm_uf, scales = "free_y", ncol = 1) +
  scale_x_yearweek(date_breaks = "104.36 weeks") +
  labs(title = "Notificações de malária",
       subtitle = "UFs da Amazônia Legal",
       x = "Semana epidemiológica",
       y = "Notificações",
       color = "UF") +
  guides(color = 'none')

ggsave("time-plots.png", width = 20, height = 60, units = "cm")

if (interactive()) file.show("time-plots.png")


# seasonal plots ----------------------------------------------------------

amazonia %>%
  gg_season(n, labels = "both") +
  labs(title = "Sazonalidade da malária",
       subtitle = "Amazônia Legal",
       x = "Semana epidemiológica",
       y = "Notificações")

amazonia_byuf %>%
  fill_gaps() %>%
  gg_season(n, labels = "both") +
  labs(title = "Sazonalidade da malária",
       subtitle = "UFs da Amazônia Legal",
       x = "Semana epidemiológica",
       y = "Notificações")

ggsave("season-plots.png", width = 20, height = 60, units = "cm")

if (interactive()) file.show("season-plots.png")


# seasonal subseries plot -------------------------------------------------

amazonia_mes <- malaria %>%
  index_by(mes = yearmonth(sem_epi)) %>%
  summarise(n = sum(n))

amazonia_mes %>%
  gg_subseries(n) +
  labs(title = "Sazonalidade da Malária por mês",
       subtitle = "Amazônia Legal",
       y = "Notificações")

amazonia_uf_mes <- malaria %>%
  group_by(nm_uf) %>%
  index_by(mes = yearmonth(sem_epi)) %>%
  summarise(n = sum(n))

amazonia_uf_mes %>%
  fill_gaps() %>%
  gg_subseries(n) +
  labs(title = "Sazonalidade da Malária por mês",
       subtitle = "UFs da Amazônia Legal",
       y = "Notificações")

ggsave("subseries-plots.png", width = 40, height = 40, units = "cm")

if (interactive()) file.show("subseries-plots.png")


# scatterplots ------------------------------------------------------------

by_sex <- malaria %>%
  group_by(sexo) %>%
  summarise(n = sum(n)) %>%
  drop_na(sexo) %>%
  pivot_wider(names_from = sexo, values_from = n) %>%
  mutate(Total = Masculino + Feminino,
         `NA` = NULL)

by_sex %>%
  ggplot(aes(x = Masculino, y = Total)) +
  geom_point()

by_sex %>%
  ggplot(aes(x = Feminino, y = Total)) +
  geom_point()

by_uf <- malaria %>%
  group_by(nm_uf) %>%
  summarise(n = sum(n))

by_uf %>%
  pivot_wider(names_from = nm_uf, values_from = n, names_repair = "universal") %>%
  GGally::ggpairs(columns = 2:10)

ggsave("pair-plots.png", width = 40, height = 40, units = "cm")


# lag plots ---------------------------------------------------------------

by_uf %>%
  filter(nm_uf == "Acre") %>%
  gg_lag(n, geom = "point", lags = 1:12) +
  ggtitle("Lag plot Acre")

ggsave("lagplot-acre.png")

by_uf %>%
  filter(nm_uf == "Roraima") %>%
  gg_lag(n, geom = "point", lags = 1:12) +
  ggtitle("Lag plot Roraima")

ggsave("lagplot-rora.png")

by_uf %>%
  filter(nm_uf == "Amazonas") %>%
  gg_lag(n, geom = "point", lags = 1:12) +
  ggtitle("Lag plot Amazonas")

ggsave("lagplot-amaz.png")

# autocorrelation, ACF and PACF -------------------------------------------

by_uf %>%
  fill_gaps() %>%
  filter(year(sem_epi) >= 2017) %>%
  ACF(n, lag_max = 52*4) %>%
  autoplot() +
  ggtitle("Malária por uf - semanal", "A partir de 2017")

amazonia_uf_mes %>%
  fill_gaps() %>%
  filter(year(mes) >= 2017) %>%
  ACF(n, lag_max = 36) %>%
  autoplot() +
  ggtitle("Malária por uf - mensal", "A partir de 2017")

by_uf %>%
  fill_gaps() %>%
  filter(year(sem_epi) == 2019) %>%
  ACF(n, lag_max = 53) %>%
  autoplot() +
  ggtitle("Malária por uf - semanal", "2019")

amazonia_uf_mes %>%
  fill_gaps() %>%
  filter(year(mes) == 2019) %>%
  ACF(n, lag_max = 36) %>%
  autoplot() +
  ggtitle("Malária por uf - mensal", "2019")



# Concur with Luciana, no seasonality, but a downward trend.
