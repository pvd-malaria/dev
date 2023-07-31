library(fpp3)

# tidy workflow ---------------------------------------------------------------

malaria <- readRDS("~/CONSULTORIA/2020/PROJETO MALARIA/beluzo-malaria/banco-mun/banco_arima.rds")

malaria <- malaria %>%
  arrange(-n) %>%
  as_tsibble(key = c(cd_mun, sexo, tp_parasi, g_idade, n),
             index = sem_epi)

malaria2 <- malaria %>%
  index_by(mes = yearmonth(sem_epi)) %>%
  group_by(nm_uf) %>%
  summarise(n = sum(n))

pop <- sidrar::get_sidra(
  7358,
  variable = 606,
  geo = "State",
  geo.filter = list(c(11:17, 21, 51)),
  classific = "c1933",
  category = list(
    c(116329, 116327, 119270, 4336, 12037, 13242, 49029,
      49030, 49031, 49032, 49033, 49034, 49035, 49036)),
  format = 2)

names(pop) <- make.unique(names(pop))

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
  select(-n, -Pop) %>%
  filter(year(mes) < 2020)

malaria2 %>% saveRDS("malaria2.rds", compress = FALSE)


# visualize

malaria2 %>%
  filter(nm_uf %in% c("Acre", "Roraima")) %>%
  autoplot(api_1000) +
  labs(title = "Notificações de malária")

# fit model

fit <- malaria2 %>%
  model(trend_model = TSLM(api_1000 ~ trend()))

# diagnostics and evaluation will come later

fit %>% forecast(h = "1 year")

fit %>% forecast(h = "1 year") %>%
  filter(nm_uf %in% c("Acre", "Roraima")) %>%
  autoplot(malaria2) +
  labs(title = "Predição de 1 ano")

# simple forecasting tools ------------------------------------------------

# mean, naïve, seasonal naïve and drift models
malaria_train <- malaria2 %>%
  filter(nm_uf != "Tocantins", year(mes) < 2019)

malaria_fit <- malaria_train %>%
  model(
    mean         = MEAN(api_1000),
    naive        = NAIVE(api_1000),
    season_naive = SNAIVE(api_1000 ~ lag("year")),
    drift        = NAIVE(api_1000 ~ drift())
  )

malaria_test <- malaria2 %>%
  filter(nm_uf != "Tocantins", year(mes) == 2019)

malaria_fc <- malaria_fit %>% forecast(new_data = malaria_test)

malaria_fc %>%
  autoplot(malaria_train, level = NULL) +
  autolayer(malaria_test, api_1000, color = "black") +
  labs(title = "Benchmark models to test predictions against",
       y     = "Notificações",
       color = "Forecasts")

# Eu provavelmente abandonaria a ideia de modelos mean e naive,
# porque eles fazem predições fixas. Pelo menos o seasonal naive ajusta um pouco
# a variação ao longo do ano e o drift permite acompanhar a tendência de queda


# residual analysis -------------------------------------------------------

f <- function(uf) {
  malaria_fit %>%
    augment() %>%
    filter(nm_uf == uf) %>%
    autoplot(.innov) +
    facet_wrap(~nm_uf, scales = "free_y")
}

# simple innovation residuals

Map(f, unique(malaria_fit$nm_uf))

# multiplot of innov, acf and hist of residuals

f <- function(uf, model) {
  malaria_fit %>%
    select(nm_uf, !!model) %>%
    filter(nm_uf == uf) %>%
    gg_tsresiduals() +
    labs(title = uf,
         subtitle = model)
}

f("Acre", "mean")
f("Acre", "naive")
f("Acre", "season_naive")
f("Acre", "drift")

f("Amapá", "mean")
f("Amapá", "naive")
f("Amapá", "season_naive")
f("Amapá", "drift")

f("Amazonas", "mean")
f("Amazonas", "naive")
f("Amazonas", "season_naive")
f("Amazonas", "drift")

f("Roraima", "mean")
f("Roraima", "naive")
f("Roraima", "season_naive")
f("Roraima", "drift")

dev.off()

# box_pierce and ljung_box tests

malaria_fit %>%
  select(nm_uf, mean) %>%
  augment() %>%
  features(.innov, ljung_box, lag = 24, dof = 0)

f <- function(model) {
  malaria_fit %>%
    select(nm_uf, !!model) %>%
    augment() %>%
    features(.innov, ljung_box, lag = 24, dof = 0)
}

Map(f, names(malaria_fit)[-1])

# distributional forecasts and predictions --------------------------------

# hilo function

malaria_fit %>%
  forecast(h = 12) %>%
  hilo()

malaria_fit %>%
  forecast(h = 12) %>%
  autoplot() +
  facet_grid(nm_uf~.model) +
  labs(title = "Notificações de malária")

# You can manually generate bootstrapped samples to construct the prediction
# intervals, but I've decided to skip that and go straight to the option in
# forecast()

# takes a while
malaria_fc <- malaria_fit %>% forecast(h = 12, bootstrap = TRUE, times = 1000)
malaria_fc

malaria_fc %>% autoplot(malaria_train) +
  labs(title = "Notificações de malária", subtitle = "Bootstrap 1000 times")


# Forecasting using transformations ---------------------------------------

# I am skipping this section because I haven't applied any transformations
# to the malaria data, but I may return to it in the future.
# For reference, the suggestion is to consider the effect of bias adjustment
# of the mean when the fable package backtransforms your data automatically
# since it may be more sensible to use the median instead.


# Forecasting using decomposition -----------------------------------------

malaria_dcmp <- malaria_train %>%
  model(stlf = decomposition_model(
    STL(api_1000 ~ trend(window = 21), robust = TRUE),
    NAIVE(season_adjust)
  ))

malaria_dcmp %>%
  forecast(h = 12) %>%
  autoplot(malaria_train) +
  autolayer(malaria_test, api_1000, color = "black") +
  labs(title    = "Previsão de casos de malária",
       subtitle = "Modelo STL + NAIVE(SAdjust)",
       y        = "Índice parasitário anual")

ggsave("modelo-STL.png")

malaria_dcmp %>% slice(1) %>% gg_tsresiduals() + ggtitle("Acre")
malaria_dcmp %>% slice(2) %>% gg_tsresiduals() + ggtitle("Amapá")
malaria_dcmp %>% slice(3) %>% gg_tsresiduals() + ggtitle("Amazonas")
malaria_dcmp %>% slice(4) %>% gg_tsresiduals() + ggtitle("Maranhão")
malaria_dcmp %>% slice(5) %>% gg_tsresiduals() + ggtitle("Mato Grosso")
malaria_dcmp %>% slice(6) %>% gg_tsresiduals() + ggtitle("Pará")
malaria_dcmp %>% slice(7) %>% gg_tsresiduals() + ggtitle("Rondônia")
malaria_dcmp %>% slice(8) %>% gg_tsresiduals() + ggtitle("Roraima")

# These residuals don't look very hot, because we're using a naive model for
# season_adjust component


# Evaluating point forecast accuracy --------------------------------------

malaria_fit

malaria_fc

malaria_fc %>%
  autoplot(bind_rows(malaria_train, malaria_test), level = NULL)

malaria_full <- malaria2 %>%
  filter(nm_uf != "Tocantins", mes < yearmonth("2020 Jan"))

accuracy(malaria_fc, malaria_full) %>% arrange(nm_uf, MAPE)


# Evaluating forecast distributional accuracy -----------------------------

# quantile score
accuracy(malaria_fc, malaria_full, list(qs = quantile_score), probs = .1) %>%
  arrange(nm_uf, qs) %>%
  print(n=Inf)

# winkler score
accuracy(malaria_fc, malaria_full, list(ws = winkler_score), level = 80) %>%
  arrange(nm_uf, ws) %>%
  print(n=Inf)

# continuous ranked probability score
accuracy(malaria_fc, malaria_full, list(crps = CRPS)) %>%
  arrange(nm_uf, crps) %>%
  print(n=Inf)

# skill score for CRPS
accuracy(malaria_fc, malaria_full, list(skill = skill_score(CRPS))) %>%
  arrange(nm_uf, -skill) %>%
  print(n=Inf)


# Time series cross validation --------------------------------------------

malaria_cvtr <- malaria_train %>%
  stretch_tsibble(.step = 1, .init = 60)

malaria_fc %>% accuracy(malaria_full) %>% arrange(nm_uf, RMSE)

malaria_cvtr %>%
  model(
    Mean = MEAN(api_1000),
    Naive = NAIVE(api_1000),
    SNaive = SNAIVE(api_1000),
    Drift = RW(api_1000 ~ drift())
  ) %>%
  forecast(h = 12) %>%
  accuracy(malaria_full) %>%
  arrange(nm_uf, RMSE)

malaria_cv_models <- malaria_cvtr %>%
  model(Mean = MEAN(api_1000),
        Naive = NAIVE(api_1000),
        SNaive = SNAIVE(api_1000),
        Drift = RW(api_1000 ~ drift()))

malaria_cvfc <- malaria_cv_models %>%
  forecast(h = 12) %>%
  group_by(.id, nm_uf, .model) %>%
  mutate(h = row_number()) %>%
  ungroup()

# RMSE evaluation for point forecast

malaria_cvfc %>%
  accuracy(malaria_full, by = c("h", ".model", "nm_uf")) %>%
  ggplot(aes(x = h, y = RMSE, color = .model)) +
  facet_wrap(~nm_uf, scales = "free_y") +
  geom_point() +
  labs(title = "Medidas de confiança das estimativas pontuais",
       subtitle = "RMSE")

ggsave("modelo-rmse.png")

# CRPS evaluation for distribution

malaria_cvfc %>%
  accuracy(malaria_full,
           by = c("h", ".model", "nm_uf"),
           list(CRPS = CRPS)) %>%
  ggplot(aes(x = h, y = CRPS, color = .model)) +
  facet_wrap(~nm_uf, scales = "free_y") +
  geom_point() +
  labs(title = "Medidas de confiança da distribuição de probabilidade",
       subtitle = "CRPS")

ggsave("modelo-cprs.png")

