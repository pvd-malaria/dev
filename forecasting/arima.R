# packages and data -------------------------------------------------------

library(fpp3)

malaria <- readRDS("malaria2.rds") %>% filter(nm_uf != "Tocantins")
malaria

# stationarity and differencing -------------------------------------------

malaria %>% autoplot() + facet_grid(nm_uf~., scales = "free_y")

# I think I will apply a boxcox transformation instead of a log

lambda <- malaria %>%
  features(api_1000, guerrero)

malaria <- malaria %>%
  left_join(lambda) %>%
  group_by(nm_uf) %>%
  mutate(boxcox_api = box_cox(api_1000, lambda_guerrero))

malaria

# ARIMA models in fable ---------------------------------------------------

# Step 1: Plot the data and identify unusual observations

# Step 2: (maybe) Transform the data (using a Box-Cox Trans) to stabilise the
#         the variance

# Step 3: If the data are non-stationary, take first differences until it is

# Step 4: Examine the (P)ACF: Is an ARIMA(p,d,0) or ARIMA(0,d,q) appropriate?

# Step 5: Try your chosen model(s) and use the AICc to search for a better model

# Step 6: Check the residuals from your chosen model by plotting their ACF and
#         doing a portmanteau test. If they don't look like white noise, try
#         a different model.

# Step 7: once the residuals look like white noise, calculate forecasts.

# hand crafted model per state --------------------------------------------


# Acre --------------------------------------------------------------------

mal_ac <- malaria %>% filter(nm_uf == "Acre", year(mes) < 2020)

mal_ac %>% autoplot(boxcox_api)

mal_ac_difs <- mal_ac %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_ac_difs %>%
  features_at(vars(boxcox_api:dif_sdif),
              list(unitroot_ndiffs,
                   unitroot_nsdiffs,
                   unitroot_kpss)) %>%
  pivot_longer(!nm_uf)

mal_ac_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial", lag_max = 36)
mal_ac_difs %>% gg_tsdisplay(sdif,       plot_type = "partial", lag_max = 36)
mal_ac_difs %>% gg_tsdisplay(dif,        plot_type = "partial", lag_max = 36)
mal_ac_difs %>% gg_tsdisplay(dif_sdif,   plot_type = "partial", lag_max = 36)

# Statistics and visuals say simple difference, but I've decided to include
# a doubly differenced for comparison

# Splits

mal_ac_tr <- mal_ac %>% filter_index(. ~ "2018-12")
mal_ac_ts <- mal_ac %>% filter_index("2019-01" ~ .)

# Candidates

# Hand selected = hs

# 210 110
# 210 210
# 014 001

# Automatic search with trace

mal_ac_tr %>% model(ARIMA(boxcox_api, trace = TRUE))

# 0 1 1 1 0 0 0
# 0 1 1 0 0 1 0
# 0 1 1 0 0 1 1

# Candidate tests

fit <- mal_ac_tr %>%
  model(
    # 210 110
    hs1 = ARIMA(boxcox_api ~ pdq(2,1,0) + PDQ(1,1,0)),
    # 210 210
    hs2 = ARIMA(boxcox_api ~ pdq(2,1,0) + PDQ(2,1,0)),
    # 014 001
    hs3 = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(0,0,1)),
    # 0 1 1 1 0 0 0
    at1 = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(1,0,0) + 0),
    # 0 1 1 0 0 1 0
    at2 = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,1) + 0),
    # 0 1 1 0 0 1 1
    at3 = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,1) + 1)
  )

fit %>% pivot_longer(!nm_uf) %>% print(n = Inf)

fit %>% glance() %>%
  arrange(AICc) %>%
  select(.model:BIC) %>%
  print(n = Inf)

# check residuals,

fit %>% select(hs3) %>% gg_tsresiduals()
fit %>% select(hs2) %>% gg_tsresiduals()

# residuals look pretty good, the doubly differenced look too kurt

fit %>% select(at1) %>% gg_tsresiduals()

# these look good also

# Ljung-Box test results
fit %>% select(hs3) %>%  augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 5)
fit %>% select(at1) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 2)

# Both passed quite well, although I am still confused about the lag value

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_ac_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ac_ts, level = NULL)

# The double differenced models actually beat the other ones in predictive
# power, but I don't think they're very well calibrated, and they could be
# over fitting

# Saving forecasts and residuals

png("arima-acre-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ac_ts, level = NULL) +
  labs(title = "Previsões de casos - Acre",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()

png("arima-acre-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs2) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Acre",
       subtitle = "ARIMA(2,1,0)(2,1,0)[12]")
dev.off()

png("arima-acre-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at1) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Acre",
       subtitle = "ARIMA(0,1,1)(1,0,0)[12]")
dev.off()

# Amazonas ------------------------------------------------------------------

mal_am <- malaria %>% filter(nm_uf == "Amazonas", year(mes) < 2020)

mal_am %>% autoplot(boxcox_api)

mal_am_difs <- mal_am %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_am_difs %>%
  features_at(vars(boxcox_api:dif_sdif),
              list(unitroot_ndiffs,
                   unitroot_nsdiffs,
                   unitroot_kpss)) %>%
  pivot_longer(!nm_uf)

mal_am_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial", lag_max = 36)
mal_am_difs %>% gg_tsdisplay(sdif,       plot_type = "partial", lag_max = 36)
mal_am_difs %>% gg_tsdisplay(dif,        plot_type = "partial", lag_max = 36)
mal_am_difs %>% gg_tsdisplay(dif_sdif,   plot_type = "partial", lag_max = 36)

# Statistics and visuals say simple difference
# After I considered single dif models, I decided to give doubly differenced a
# try

# Splits

mal_am_tr <- mal_am %>% filter_index(. ~ "2018-12")
mal_am_ts <- mal_am %>% filter_index("2019-01" ~ .)

# Candidates

# Hand selected = hs

# 015 001
# 510 100
# 014 011
# 110 110

# Automatic search with trace

mal_am_tr %>% model(ARIMA(boxcox_api, trace = TRUE))

# 1 1 0 1 0 0 0
# 1 1 0 1 0 0 1

# Candidate tests

fit <- mal_am_tr %>%
  model(
    # 015 001
    hs1 = ARIMA(boxcox_api ~ pdq(0,1,5) + PDQ(0,0,1)),
    # 510 100
    hs2 = ARIMA(boxcox_api ~ pdq(5,1,0) + PDQ(1,0,0)),
    # 014 011
    hs3 = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(0,1,1)),
    # 110 110
    hs4 = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,1,0)),
    # 1 1 0 1 0 0 0
    at1 = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,0,0) + 0),
    # 1 1 0 1 0 0 1
    at2 = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,0,0) + 1),
  )

fit %>% pivot_longer(!nm_uf) %>% print(n = Inf)

fit %>% glance() %>%
  arrange(AICc) %>%
  select(.model:BIC) %>%
  print(n = Inf)

# check residuals,

fit %>% select(hs2) %>% gg_tsresiduals()
fit %>% select(hs3) %>% gg_tsresiduals()

# residuals look pretty good for hs2, but hs3 has too many outliers

fit %>% select(at1) %>% gg_tsresiduals()

# these have too many outliers

# Ljung-Box test results
fit %>% select(hs2) %>%  augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 6)

fit %>% select(hs3) %>%  augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 5)

fit %>% select(at1) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 2)

# All were really bad, maybe I should try a doubly differenced?

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_am_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_am_ts, level = NULL)

# The double differenced models actually beat the other ones in predictive
# power, which is surprising considering their statistical measures and
# residuals were quite bad.

# Saving forecasts and residuals

png("arima-amazonas-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_am_ts, level = NULL) +
  labs(title = "Previsões de casos - Amazonas",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()

png("arima-amazonas-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs3) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Amazonas",
       subtitle = "ARIMA(0,1,4)(0,1,1)[12]")
dev.off()

png("arima-acre-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at1) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Amazonas",
       subtitle = "ARIMA(1,1,0)(1,0,0)[12]")
dev.off()

# Amapá -------------------------------------------------------------------

mal_ap <- malaria %>% filter(nm_uf == "Amapá", year(mes) < 2020)

mal_ap %>% autoplot(boxcox_api)

mal_ap_difs <- mal_ap %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_ap_difs %>%
  features_at(vars(boxcox_api:dif_sdif), list(unitroot_ndiffs, unitroot_nsdiffs)) %>%
  pivot_longer(!nm_uf)

mal_ap_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial")
mal_ap_difs %>% gg_tsdisplay(sdif, plot_type = "partial")
mal_ap_difs %>% gg_tsdisplay(dif, plot_type = "partial", lag_max = 36)
mal_ap_difs %>% gg_tsdisplay(dif_sdif, plot_type = "partial", lag_max = 36)

# I've changed my mind, instead of a dif, I think a dif_sdif is best

# Let's start with an auto model, because the acf and pacf are not obvious

mal_ap_tr <- mal_ap %>% filter_index(. ~ "2018-12")
mal_ap_ts <- mal_ap %>% filter_index("2019-01" ~ .)

# alternative models
fit <- mal_ap_tr %>%
  model(at1 = ARIMA(boxcox_api ~ 1),
        hs1 = ARIMA(boxcox_api ~ 1 + pdq(1,0,0) + PDQ(3,1,1)))

fit %>% pivot_longer(!nm_uf)

# check residuals,

fit %>% select(at1) %>% gg_tsresiduals()
fit %>% select(hs1) %>% gg_tsresiduals()

fit %>% select(at1) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 4)

fit %>% select(hs1) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 5)

# as usual, the stats are awful, but the plots are kind of okay. Especially
# the drift model found through restricted search

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_ap_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

# The error measures don't agree with each other, RMSE and MAPE point to
# distinct best model comparisons

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ap_ts, level = NULL)

# All three models performed quite well, but the restricted search managed to
# outperform the others by capturing a decreasing level in the second half of
# the year. I'm actually very surprised by this.

# Saving forecasts and residuals

png("arima-amapa-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ap_ts, level = NULL) +
  labs(title = "Previsões de casos - Amapá",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()

png("arima-amapa-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs1) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Amapá",
       subtitle = "ARIMA(1,0,0)(3,1,1)[12] w/ drift")
dev.off()

png("arima-amapa-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at1) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Amapá",
       subtitle = "ARIMA(1,0,1)(2,1,0)[12] w/ drift")
dev.off()

# Maranhão ----------------------------------------------------------------

mal_ma <- malaria %>% filter(nm_uf == "Maranhão", year(mes) < 2020)

mal_ma %>% autoplot(boxcox_api)

mal_ma_difs <- mal_ma %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_ma_difs %>%
  features_at(vars(boxcox_api:dif_sdif),
              list(unitroot_ndiffs, unitroot_nsdiffs)) %>%
  pivot_longer(!nm_uf)

mal_ma_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial",  lag_max = 36)
mal_ma_difs %>% gg_tsdisplay(sdif, plot_type = "partial",  lag_max = 36)
mal_ma_difs %>% gg_tsdisplay(dif, plot_type = "partial", lag_max = 36)
mal_ma_difs %>% gg_tsdisplay(dif_sdif, plot_type = "partial", lag_max = 36)

# Statistics and visuals suggest a first difference

# Splits

mal_ma_tr <- mal_ma %>% filter_index(. ~ "2018-12")
mal_ma_ts <- mal_ma %>% filter_index("2019-01" ~ .)

# Candidates:

# Hand selected

# 014 001
# 014 002
# 410 100
# 510 100

# 014 011
# 510 110

# Automatic trace

# 0 1 4 1 0 0 1
# 1 1 1 1 0 0 0
# 1 1 0 1 0 0 0
# 1 1 0 1 0 0 1

mal_ma_tr %>% model(ARIMA(boxcox_api, trace = TRUE))

mal_ma_tr %>% model(ARIMA(boxcox_api, stepwise = FALSE, approx = FALSE))

fit <- mal_ma_tr %>%
  model(
    # 014 001
    hs1 = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(0,0,1)),
    # 014 002
    hs2 = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(0,0,2)),
    # 410 100
    hs3 = ARIMA(boxcox_api ~ pdq(4,1,0) + PDQ(1,0,0)),
    # 510 100
    hs4 = ARIMA(boxcox_api ~ pdq(5,1,0) + PDQ(1,0,0)),
    # 510 110
    hs5_ = ARIMA(boxcox_api ~ pdq(5,1,0) + PDQ(1,1,0)),
    # 014 011
    hs6_ = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(0,1,1)),

    # 0 1 4 1 0 0 1
    at1 = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(1,0,0) + 1),
    # 1 1 1 1 0 0 0
    at2 = ARIMA(boxcox_api ~ pdq(1,1,1) + PDQ(1,0,0) + 0),
    # 1 1 0 1 0 0 0
    at3 = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,0,0) + 0),
    # 1 1 0 1 0 0 1
    at4 = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,0,0) + 1),
  )

fit %>% pivot_longer(!nm_uf)

fit %>% glance() %>% arrange(AICc)

# check residuals,

fit %>% select(hs6_) %>% gg_tsresiduals()
fit %>% select(at1) %>% gg_tsresiduals()
fit %>% select(hs1) %>% gg_tsresiduals()

fit %>% select(hs6_) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 5)

fit %>% select(at1) %>%  augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 5)

fit %>% select(hs1) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 6)

# The plots look fine, but the ljung_box test is really bad for the double
# diff model

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_ma_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ma_ts, level = NULL)

# It turns out the most parsimonious models won out in the end.

# Saving forecasts and residuals

png("arima-maranhao-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ma_ts, level = NULL) +
  labs(title = "Previsões de casos - Maranhão",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()

png("arima-maranhao-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs3) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Maranhão",
       subtitle = "<ARIMA(4,1,0)(1,0,0)[12]>")
dev.off()

png("arima-maranhao-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at3) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Maranhão",
       subtitle = "<ARIMA(1,1,0)(1,0,0)[12]>")
dev.off()

# Mato Grosso -------------------------------------------------------------

mal_mt <- malaria %>% filter(nm_uf == "Mato Grosso", year(mes) < 2020)

mal_mt %>% autoplot(boxcox_api)

mal_mt_difs <- mal_mt %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_mt_difs %>%
  features_at(vars(boxcox_api:dif_sdif),
              list(unitroot_ndiffs, unitroot_nsdiffs)) %>%
  pivot_longer(!nm_uf)

mal_mt_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial", lag_max = 36)
mal_mt_difs %>% gg_tsdisplay(sdif,       plot_type = "partial", lag_max = 36)
mal_mt_difs %>% gg_tsdisplay(dif,        plot_type = "partial", lag_max = 36)
mal_mt_difs %>% gg_tsdisplay(dif_sdif,   plot_type = "partial", lag_max = 36)

# Plots and stats suggest a first difference

# Splits

mal_mt_tr <- mal_mt %>% filter_index(. ~ "2018-12")
mal_mt_ts <- mal_mt %>% filter_index("2019-01" ~ .)

# Candidates:

# Hand selected

# 1 1 0 1 0 0
# 7 1 0 1 0 0
# 0 1 1 0 0 1
# 0 1 7 0 0 1

# Automatic search with trace

mal_mt_tr %>% model(ARIMA(boxcox_api))
mal_mt_tr %>% model(ARIMA(boxcox_api, stepwise = FALSE, approx = FALSE))

# ARIMA(1,1,1)(1,0,0)[12] w/ drift

fit <- mal_mt_tr %>%
  model(
    # 1 1 0 1 0 0
    hs1 = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,0,0)),
    # 7 1 0 1 0 0
    hs2 = ARIMA(boxcox_api ~ pdq(7,1,0) + PDQ(1,0,0),
                order_constraint = p + q + P + Q <= 8),
    # 0 1 1 0 0 1
    hs3 = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,1)),
    # 0 1 7 0 0 1
    hs4 = ARIMA(boxcox_api ~ pdq(0,1,7) + PDQ(0,0,1),
                order_constraint = p + q + P + Q <= 8),
    # ARIMA(1,1,1)(1,0,0)[12] w/ drift
    at1 = ARIMA(boxcox_api ~ pdq(1,1,1) + PDQ(1,0,0) + 1),
  )

fit %>% pivot_longer(!nm_uf) %>% print(n = Inf)

fit %>% glance() %>%
  arrange(AICc) %>%
  select(.model:BIC) %>%
  print(n = Inf)

# check residuals,

fit %>% select(at1) %>% gg_tsresiduals()
fit %>% select(hs3) %>% gg_tsresiduals()

fit %>% select(at1) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 3)
fit %>% select(hs3) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 2)

# The plots look very good, and the ljung box tests were really good

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_mt_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_mt_ts, level = NULL)

# None of these simpler models capture the large increase in cases, most of
# them seem very poorly calibrated as well, but maybe 2019 was an odd year.

# Saving forecasts and residuals

png("arima-matogrosso-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_mt_ts, level = NULL) +
  labs(title = "Previsões de casos - Mato Grosso",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()

png("arima-matogrosso-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs2) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Mato Grosso",
       subtitle = "<ARIMA(7,1,0)(1,0,0)[12]>")
dev.off()

png("arima-matogrosso-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at1) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Mato Grosso",
       subtitle = "<ARIMA(1,1,1)(1,0,0)[12] w/ drift>")
dev.off()

# Pará --------------------------------------------------------------------

mal_pa <- malaria %>% filter(nm_uf == "Pará", year(mes) < 2020)

mal_pa %>% autoplot(boxcox_api)

mal_pa_difs <- mal_pa %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_pa_difs %>%
  features_at(vars(boxcox_api:dif_sdif),
              list(unitroot_ndiffs,
                   unitroot_nsdiffs,
                   unitroot_kpss)) %>%
  pivot_longer(!nm_uf)

mal_pa_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial", lag_max = 36)
mal_pa_difs %>% gg_tsdisplay(sdif,       plot_type = "partial", lag_max = 36)
mal_pa_difs %>% gg_tsdisplay(dif,        plot_type = "partial", lag_max = 36)
mal_pa_difs %>% gg_tsdisplay(dif_sdif,   plot_type = "partial", lag_max = 36)

# The graphical analysis suggests a first difference

# Candidates:

# Hand selected = hs

# 014 001
# 014 003
# 410 100

# Automatic search with trace

# 2 1 1 0 0 2 0
# 1 1 2 0 0 2 0
# 0 1 1 0 0 2 0
# 0 1 1 0 0 1 0
# 0 1 1 0 0 1 1

# Splits

mal_pa_tr <- mal_pa %>% filter_index(. ~ "2018-12")
mal_pa_ts <- mal_pa %>% filter_index("2019-01" ~ .)

# Candidate tests

fit <- mal_pa_tr %>%
  model(
    # 014 001
    hs1  = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(0,0,1)),
    # 014 003
    hs2  = ARIMA(boxcox_api ~ pdq(0,1,4) + PDQ(0,0,3),
                 order_constraint = p + q + P + Q <= 8),
    # 410 100
    hs3  = ARIMA(boxcox_api ~ pdq(4,1,0) + PDQ(1,0,0)),
    # 2 1 1 0 0 2 0
    at1  = ARIMA(boxcox_api ~ pdq(2,1,1) + PDQ(0,0,2) + 0),
    # 1 1 2 0 0 2 0
    at2  = ARIMA(boxcox_api ~ pdq(1,1,2) + PDQ(0,0,2) + 0),
    # 0 1 1 0 0 2 0
    at3  = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,2) + 0),
    # 0 1 1 0 0 1 0
    at4  = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,1) + 0),
    # 0 1 1 0 0 1 1
    at5  = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,1) + 1),
  )

fit %>% pivot_longer(!nm_uf) %>% print(n = Inf)

fit %>% glance() %>%
  arrange(AICc) %>%
  select(.model:BIC) %>%
  print(n = Inf)

# check residuals,

fit %>% select(hs3) %>% gg_tsresiduals()

# residuals don't look heteroscedastic, but otherwise, ok.

fit %>% select(at1) %>% gg_tsresiduals()

# same deal

# Ljung-Box test results
fit %>% augment() %>% features(.innov, ljung_box, lag = 10, dof = 4)

# both relevant models pass the test

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_pa_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_pa_ts, level = NULL)

# Most of the models seem to capture the structure of the data well-enough
# The best ones were autoselected who managed to capture a low-point at the
# beginning of the year.

# Saving forecasts and residuals

png("arima-para-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_pa_ts, level = NULL) +
  labs(title = "Previsões de casos - Pará",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()

png("arima-para-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs1) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Pará",
       subtitle = "ARIMA(0,1,4)(0,0,1)[12]")
dev.off()

png("arima-para-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at5) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Pará",
       subtitle = "ARIMA(0,1,1)(0,0,1)[12] w/ drift")
dev.off()

# Rondônia ----------------------------------------------------------------

mal_ro <- malaria %>% filter(nm_uf == "Rondônia", year(mes) < 2020)

mal_ro %>% autoplot(boxcox_api)

mal_ro_difs <- mal_ro %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_ro_difs %>%
  features_at(vars(boxcox_api:dif_sdif),
              list(unitroot_ndiffs,
                   unitroot_nsdiffs,
                   unitroot_kpss)) %>%
  pivot_longer(!nm_uf)

mal_ro_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial", lag_max = 36)
mal_ro_difs %>% gg_tsdisplay(sdif,       plot_type = "partial", lag_max = 36)
mal_ro_difs %>% gg_tsdisplay(dif,        plot_type = "partial", lag_max = 36)
mal_ro_difs %>% gg_tsdisplay(dif_sdif,   plot_type = "partial", lag_max = 36)

# The graphical analysis is a bit murky: a first difference seems okay, but the
# statistical tests also suggest a seasonal difference and a first difference
# I have decided to go with a seasonal + first

# Candidates:

# Since the ACF seems sinusoidal (kinda), I will try pd0

# Hand selected = hs

# 510 010 0
# 510 110 0
# 510 110 1
# 510 210 1

# Automatic search with trace

# 1 1 1 1 0 0 1

# 1 1 0 1 0 0 1

# 1 1 0 1 0 0 0

# 1 1 1 1 0 0 0

# 1 1 1 1 0 0 1

# Splits

mal_ro_tr <- mal_ro %>% filter_index(. ~ "2018-12")
mal_ro_ts <- mal_ro %>% filter_index("2019-01" ~ .)

# Candidate tests

fit <- mal_ro_tr %>%
  model(
    # 510 010 0
    hs1  = ARIMA(boxcox_api ~ pdq(5,1,0) + PDQ(1,1,0) + 0),
    # 510 110 0
    hs2  = ARIMA(boxcox_api ~ pdq(5,1,0) + PDQ(1,1,0) + 1),
    # 510 110 0
    hs3  = ARIMA(boxcox_api ~ pdq(5,1,0) + PDQ(2,1,0) + 0,
                 order_constraint = p + q + P + Q <= 7),
    # 510 210 1
    hs4  = ARIMA(boxcox_api ~ pdq(5,1,0) + PDQ(1,1,0) + 0),
    # 1 1 1 1 0 0 1
    at1  = ARIMA(boxcox_api ~ pdq(1,1,1) + PDQ(1,0,0) + 1),
    # 1 1 0 1 0 0 1
    at2  = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,0,0) + 1),
    # 1 1 0 1 0 0 0
    at3  = ARIMA(boxcox_api ~ pdq(1,1,0) + PDQ(1,0,0) + 0),
    # 1 1 1 1 0 0 0
    at4  = ARIMA(boxcox_api ~ pdq(1,1,1) + PDQ(1,0,0) + 0),
    # 1 1 1 1 0 0 1
    at5  = ARIMA(boxcox_api ~ pdq(1,1,1) + PDQ(1,0,0) + 1),
  )

fit %>% pivot_longer(!nm_uf) %>% print(n = Inf)

fit %>% glance() %>%
  arrange(AICc) %>%
  select(.model:BIC) %>%
  print(n = Inf)

# check residuals,

fit %>% select(at1) %>% gg_tsresiduals()

# residuals look bad, lots of variance and outliers

fit %>% select(hs3) %>% gg_tsresiduals()

# these look a little better

# Ljung-Box test results
fit %>% augment() %>% features(.innov, ljung_box, lag = 10, dof = 4)

# The auto models fail pretty hard, but the HS models do okay-ish

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_ro_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ro_ts, level = NULL)

# Most of the models seem to capture the structure of the data well-enough
# The best ones were hand selected who managed to capture a the increase in the
# winter

# Saving forecasts and residuals

png("arima-rondonia-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_ro_ts, level = NULL) +
  labs(title = "Previsões de casos - Rondônia",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()


png("arima-rondo-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs1) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Rondônia",
       subtitle = "ARIMA(5,1,0)(2,1,0)[12]")
dev.off()

png("arima-rondo-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at5) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Rondônia",
       subtitle = "ARIMA(1,1,1)(1,0,0)[12]")
dev.off()

# Roraima -----------------------------------------------------------------

mal_rr <- malaria %>% filter(nm_uf == "Roraima", year(mes) < 2020)

mal_rr %>% autoplot(boxcox_api)

mal_rr_difs <- mal_rr %>%
  select(-lambda_guerrero) %>%
  mutate(sdif = boxcox_api %>% difference(lag=12),
         dif = boxcox_api %>% difference(),
         dif_sdif =  boxcox_api %>% difference(lag=12) %>% difference())

mal_rr_difs %>%
  features_at(vars(boxcox_api:dif_sdif),
              list(unitroot_ndiffs,
                   unitroot_nsdiffs,
                   unitroot_kpss)) %>%
  pivot_longer(!nm_uf)

mal_rr_difs %>% gg_tsdisplay(boxcox_api, plot_type = "partial", lag_max = 36)
mal_rr_difs %>% gg_tsdisplay(sdif,       plot_type = "partial", lag_max = 36)
mal_rr_difs %>% gg_tsdisplay(dif,        plot_type = "partial", lag_max = 36)
mal_rr_difs %>% gg_tsdisplay(dif_sdif,   plot_type = "partial", lag_max = 36)

# The graphical analysis suggests a first difference, same as the statistics

# Splits

mal_rr_tr <- mal_rr %>% filter_index(. ~ "2018-12")
mal_rr_ts <- mal_rr %>% filter_index("2019-01" ~ .)

# Candidates:

# Hand selected = hs

# 310 100
# 210 100

# Automatic search with trace

mal_rr_tr %>% model(ARIMA(boxcox_api, trace = TRUE))

# 0 1 1 0 0 1 0
# 0 1 1 0 0 1 1

# Candidate tests

fit <- mal_rr_tr %>%
  model(
    hs1 = ARIMA(boxcox_api ~ pdq(3,1,0) + PDQ(1,0,0)),
    hs2 = ARIMA(boxcox_api ~ pdq(2,1,0) + PDQ(1,0,0)),
    at1 = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,1) + 0),
    at2 = ARIMA(boxcox_api ~ pdq(0,1,1) + PDQ(0,0,1) + 1),
  )

fit %>% pivot_longer(!nm_uf) %>% print(n = Inf)

fit %>% glance() %>%
  arrange(AICc) %>%
  select(.model:BIC) %>%
  print(n = Inf)

# check residuals,

fit %>% select(at1) %>% gg_tsresiduals()

# residuals look pretty good, but right skewed

fit %>% select(hs1) %>% gg_tsresiduals()

# these look good also, right skewed too

# Ljung-Box test results
fit %>% select(hs1) %>%  augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 4)
fit %>% select(at1) %>% augment() %>%
  features(.innov, ljung_box, lag = 10, dof = 2)

# Both passed relatively well

# check predictive power

fit %>%
  forecast(h = 12) %>%
  accuracy(mal_rr_ts) %>%
  arrange(RMSE) %>%
  select(.model, nm_uf, RMSE:MAPE)

fit %>%
  forecast(h = 12) %>%
  autoplot(mal_rr_ts, level = NULL)

# The "worse" models actually did better in the RMSE. None could predict the
# fall in the level, but most were able to approximate the seasonal highs and
# lows

# Saving forecasts and residuals

png("arima-roraima-prev.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>%
  forecast(h = 12) %>%
  autoplot(mal_rr_ts, level = NULL) +
  labs(title = "Previsões de casos - Roraima",
       subtitle = "Modelos com menores AICcs",
       y = "IPA com transformação Box-Cox",
       x = NULL,
       color = "Modelo")
dev.off()

png("arima-roraima-res-best.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(hs2) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do melhor modelo - Roraima",
       subtitle = "ARIMA(3,1,0)(1,0,0)[12]")
dev.off()

png("arima-roraima-res-auto.png",
    width = 6, height = 6, units = "in", res = 300)
fit %>% select(at2) %>% gg_tsresiduals(lag_max = 36) +
  labs(title = "Resíduo do modelo automático - Roraima",
       subtitle = "ARIMA(0,1,1)(0,0,1)[12] w/ drift")
dev.off()

# ARIMA vs NNET --------------------------------------------------------

# This is a simple comparison between ARIMA and NNET models for each state.
# Here, I'm not particularly interested in finding the best possible model for
# each, I'm using simple automatic search algorithms to let the computer find
# the best ARIMA() and NNETAR() models for each state and comparing their results
# As an added experiment, I want to compare different training set windows of 1, 3, 5, 7, 9, 11 years and the full dataset.

# Full dataset

malaria_tr <- malaria %>% filter_index(. ~ "2018-12")
malaria_ts <- malaria %>% filter_index("2019-01" ~ "2019-12")

fit <- malaria_tr %>%
  model(arima = ARIMA(boxcox_api),
        nnet = NNETAR(boxcox_api))

fit

fit %>%
  forecast(h = 12, bootstrap = TRUE) %>%
  accuracy(malaria_ts) %>%
  arrange(nm_uf) %>%
  select(.model:MAPE)

fit %>% forecast(h = 12) %>%
  autoplot(level = NULL) +
  autolayer(malaria_ts, boxcox_api, color = "black") +
  facet_wrap(~nm_uf, ncol = 3, scales = "free_y")

# Different training set lengths

malaria_tr3  <- malaria %>% filter_index("2016-01" ~ "2018-12")
malaria_tr5  <- malaria %>% filter_index("2014-01" ~ "2018-12")
malaria_tr7  <- malaria %>% filter_index("2012-01" ~ "2018-12")
malaria_tr9  <- malaria %>% filter_index("2010-01" ~ "2018-12")
malaria_tr11 <- malaria %>% filter_index("2009-01" ~ "2018-12")

malaria_ts <- malaria %>% filter_index("2019-01" ~ "2019-12")

fit_mod <- function(training) {
  training %>%
    model(arima = ARIMA(boxcox_api),
          nnet = NNETAR(boxcox_api))
}

trainings <- lst(malaria_tr, malaria_tr3, malaria_tr5,
                 malaria_tr7, malaria_tr9, malaria_tr11)

fits <- purrr::map(trainings, fit_mod)

get_acc <- function(mod_list) {
  mod_list %>%
    forecast(h = 12, bootstrap = TRUE) %>%
    accuracy(malaria_ts) %>%
    arrange(nm_uf)
}

accs <- fits %>% purrr::map(get_acc)
accs %>%
  bind_rows(.id = "tr_window") %>%
  select(tr_window:.type, RMSE:MAPE) %>%
  arrange(nm_uf, RMSE) %>%
  print(n=Inf) %>%
  saveRDS("sensitivity.rds")

readRDS("sensitivity.rds") %>%
  select(tr_window:RMSE, MAPE) %>%
  group_by(nm_uf, .model) %>%
  slice_min(order_by = RMSE, n = 1) %>%
  ungroup() %>%
  gt::gt() %>%
  gt::fmt_number(c(RMSE), decimals = 3) %>%
  gt::fmt_number(c(MAPE), decimals = 1) %>%
  gt::gtsave("sensitivity.png")
