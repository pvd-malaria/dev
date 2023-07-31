source("dynamic.R")

# training/test sets for each state ---------------------------------------
# a partir daqui, o script requer um pouco de input manual. Cada estado precisa
# receber o número correto de lags (salvos no arquivo predictor_lag.rds). É
# necessário digitar a específicação no modelo variavel + lag(variavel) +
# lag(variavel, 2) até o número adequado de lags e só então rodar as funções de
# ajuste dos modelos, precisão e plotagem do resultado

# state code
code = 51

# proper number of predictor lags
readRDS("predictor_lag.rds") %>%
  filter(uf == code) %>%
  print(n = Inf)

resp <- expr(box_cox(apm, lambda))
prec_lags <- expr(prec + lag(prec))
tmax_lags <- expr(tmax + lag(tmax) + lag(tmax, 2))
tmin_lags <- expr(tmin)
desmat_lags <- expr(area_desmat)


# forecasts with a training/test set --------------------------------------

train_test = TRUE

if (train_test) {

  fit <- malaria_tr %>%
    filter(uf == code) %>%
    model(
      arima_puro     = ARIMA(!!resp),
      desmatamento   = ARIMA(!!resp ~ !!desmat_lags),
      temp_maxima    = ARIMA(!!resp ~ !!tmax_lags),
      temp_minima    = ARIMA(!!resp ~ !!tmin_lags),
      precipitacao   = ARIMA(!!resp ~ !!prec_lags),
      prec_tmax      = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags),
      prec_tmin      = ARIMA(!!resp ~ !!prec_lags + !!tmin_lags),
      prec_desmat    = ARIMA(!!resp ~ !!prec_lags + !!desmat_lags),
      prec_tmax_tmin = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags),
      completo       = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags +
                               !!desmat_lags)
    )

  tt_glance(fit)
  tt_accuracy(fit)
  tt_plot(fit)

}

# rolling origin (1, 3 or 6 months) for state ---------------------------------
rolling <- TRUE

if (rolling) {

  # 1 mes
  fit <- malaria_tscv %>%
    filter(uf == code) %>%
    model(
      arima_puro     = ARIMA(!!resp),
      desmatamento   = ARIMA(!!resp ~ !!desmat_lags),
      temp_maxima    = ARIMA(!!resp ~ !!tmax_lags),
      temp_minima    = ARIMA(!!resp ~ !!tmin_lags),
      precipitacao   = ARIMA(!!resp ~ !!prec_lags),
      prec_tmax      = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags),
      prec_tmin      = ARIMA(!!resp ~ !!prec_lags + !!tmin_lags),
      prec_desmat    = ARIMA(!!resp ~ !!prec_lags + !!desmat_lags),
      prec_tmax_tmin = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags),
      completo       = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags +
                               !!desmat_lags)
    )

  jd_accuracy(fit)
  jd_plot(fit)

}

if (rolling) {

  # 3 meses
  fit <- malaria_tscv_3m %>%
    filter(uf == code) %>%
    model(
      arima_puro     = ARIMA(!!resp),
      desmatamento   = ARIMA(!!resp ~ !!desmat_lags),
      temp_maxima    = ARIMA(!!resp ~ !!tmax_lags),
      temp_minima    = ARIMA(!!resp ~ !!tmin_lags),
      precipitacao   = ARIMA(!!resp ~ !!prec_lags),
      prec_tmax      = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags),
      prec_tmin      = ARIMA(!!resp ~ !!prec_lags + !!tmin_lags),
      prec_desmat    = ARIMA(!!resp ~ !!prec_lags + !!desmat_lags),
      prec_tmax_tmin = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags),
      completo       = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags +
                             !!desmat_lags)
    )

  jd_accuracy(fit, "3m")
  jd_plot(fit, "3m")

}

if (rolling) {

  # 6 meses
  fit <- malaria_tscv_6m %>%
    filter(uf == code) %>%
    model(
      arima_puro     = ARIMA(!!resp),
      desmatamento   = ARIMA(!!resp ~ !!desmat_lags),
      temp_maxima    = ARIMA(!!resp ~ !!tmax_lags),
      temp_minima    = ARIMA(!!resp ~ !!tmin_lags),
      precipitacao   = ARIMA(!!resp ~ !!prec_lags),
      prec_tmax      = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags),
      prec_tmin      = ARIMA(!!resp ~ !!prec_lags + !!tmin_lags),
      prec_desmat    = ARIMA(!!resp ~ !!prec_lags + !!desmat_lags),
      prec_tmax_tmin = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags),
      completo       = ARIMA(!!resp ~ !!prec_lags + !!tmax_lags + !!tmin_lags +
                             !!desmat_lags)
    )

  jd_accuracy(fit, "6m")
  jd_plot(fit, "6m")

}
