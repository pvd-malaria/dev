library(fpp3, warn.conflicts = FALSE, verbose = FALSE)
library(tidyverse, warn.conflicts = FALSE, verbose = FALSE)

# data input --------------------------------------------------------------

malaria <- readRDS("malaria_covars.rds")

malaria2 <- malaria %>%
  mutate(prec = NULL,
         tmax = NULL,
         tmin = NULL,
         area_desmat = NULL,
         incremento = NULL)

# autoplot(malaria2, apm)

# Lagged predictor tests --------------------------------------------------
# do_predictor_tests = FALSE
#
# if (do_predictor_tests) {
#
#   best_fit <- function(n, var) {
#     malaria2 %>%
#       filter(uf == n) %>%
#       model(lag0 = ARIMA(box_cox(apm, lambda) ~ {{var}} + pdq(d = 1)),
#             lag1 = ARIMA(box_cox(apm, lambda) ~ lag({{var}}) + pdq(d = 1)),
#             lag2 = ARIMA(box_cox(apm, lambda) ~ lag({{var}}) +
#                            lag({{var}}, 2) + pdq(d = 1)),
#             lag3 = ARIMA(box_cox(apm, lambda) ~ lag({{var}}) + lag({{var}}, 2) +
#                       lag({{var}}, 3) + pdq(d = 1)),
#             lag4 = ARIMA(box_cox(apm, lambda) ~ lag({{var}}) + lag({{var}}, 2) +
#                            lag({{var}}, 3) + lag({{var}}, 4) + pdq(d = 1)),
#             lag5 = ARIMA(box_cox(apm, lambda) ~ lag({{var}}) + lag({{var}}, 2) +
#                            lag({{var}}, 3) + lag({{var}}, 4) + lag({{var}}, 5) +
#                            pdq(d = 1)),
#             lag6 = ARIMA(box_cox(apm, lambda) ~ lag({{var}}) + lag({{var}}, 2) +
#                            lag({{var}}, 3) + lag({{var}}, 4) + lag({{var}}, 5) +
#                            lag({{var}}, 6) + pdq(d = 1))) %>%
#       glance() %>%
#       mutate(variavel = rlang::as_name(var)) %>%
#       select(uf, variavel, .model, AICc) %>%
#       slice_min(AICc)
#   }
#
#   best_ufs <- function(ufs) {
#     my_vars <- syms(names(malaria2)[-c(1,2,6)])
#     my_vars %>% map_dfr(best_fit, n = ufs)
#   }
#
#   unique(malaria2$uf) %>%
#     map_dfr(best_ufs) %>%
#     print(n=Inf) %>%
#     write_rds("predictor_lag.rds")
#
# }

# Training/test set preparations ---------------------------------------------
malaria_tr <- malaria2 %>% filter_index(. ~ "2018-12")

malaria_ts <- malaria2 %>%
  filter_index("2019-01" ~ "2019-12")

malaria_complete <- bind_rows(malaria_tr, malaria_ts)

malaria_complete %>% filter_index("2018-01" ~ .) %>% print(n = 100)

# 1 mês = .init = 144
malaria_tscv <- malaria_complete %>%
  stretch_tsibble(.init = 144)

# 3 meses = .init = 141
malaria_tscv_3m <- malaria_complete %>%
  stretch_tsibble(.init = 141)

# 6 meses = .init = 138
malaria_tscv_6m <- malaria_complete %>%
  stretch_tsibble(.init = 138)

# 12 meses = .init = 132
malaria_tscv_12m <- malaria_complete %>%
  stretch_tsibble(.init = 132)

malaria_tscv %>%
  filter(mes >= yearmonth("2018-01"), uf == 11) %>%
  print(n = 100)

malaria_tscv_test <- malaria_ts %>%
  group_by(uf) %>%
  mutate(.id = row_number()) %>%
  ungroup() %>%
  update_tsibble(key = c(.id, uf))

# malaria_tscv_test %>% print(n = Inf)


# Training/test functions -------------------------------------------------

# tt_glance <- function(fit) {
#   uf <- unique(fit$uf)
#
#   fit %>%
#     glance() %>%
#     arrange(AICc) %>%
#     select(-c(ar_roots, ma_roots)) %>%
#     print(n = Inf) %>%
#     gt::gt() %>%
#     gt::gtsave(paste(uf, "_aicc_tt.png"))
# }
#
# tt_accuracy <- function(fit) {
#   uf <- unique(fit$uf)
#
#   fit %>%
#     forecast(new_data = malaria_ts) %>%
#     accuracy(malaria_ts,
#              measures = list(rmse = RMSE,mape = MAPE)) %>%
#     arrange(rmse) %>%
#     print() %>%
#     gt::gt() %>%
#     gt::gtsave(paste(uf, "_accuracy_tt.png"))
# }
#
# tt_plot <- function(fit) {
#
#   uf <- unique(fit$uf)
#
#   g <- fit %>%
#     forecast(new_data = malaria_ts) %>%
#     autoplot(level = NULL, alpha = 0.5) +
#     autolayer(malaria_ts %>% filter(uf == unique(fit$uf)), apm) +
#     scale_color_viridis_d(option = "C") +
#     labs(title = "Modelos candidatos - Test/Training sets",
#          subtitle = paste("Uf =", uf),
#          x = "Mês", y = "Taxa mensal de malária",
#          level = "IC")
#
#   ggsave(paste(uf, "_modelos_tt.png"), print(g), width = 7, height = 7)
#
#   return(g)
# }

# Sliding window/rolling origin functions ---------------------------------

jd_accuracy <- function(fit, window_length = "1m") {

  uf <- unique(fit$uf)

  fit %>%
    forecast(malaria_tscv_test) %>%
    accuracy(malaria_complete,
             measures = list(rmse = RMSE,mape = MAPE)) %>%
    arrange(rmse) %>%
    print(n = Inf) %>%
    write_csv(file = paste("accuracy", window_length, uf, sep = "_"))
}

jd_plot <- function(fit, window_length = "1m") {

  uf <- unique(fit$uf)

  g <- fit %>%
    forecast(malaria_tscv_test) %>%
    mutate(.id = NULL) %>%
    autoplot(alpha = 0.5) +
    autolayer(malaria_ts %>% filter(uf == unique(fit$uf)), apm) +
    labs(title = "Janela deslizante",
         subtitle = paste("Uf =", uf, "-", window_length),
         x = "Mês", y = "Taxa de incidência (*1000)") +
    scale_y_continuous(labels = scales::label_number(scale = 1e3)) +
    scale_color_viridis_d(option = "C")

  ggsave(paste0(uf, "_tscv_", window_length, ".png"), print(g), width = 6, height = 6)

  return(g)

}

