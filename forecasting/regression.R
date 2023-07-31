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
  summarise(n = sum(n),
            p_fem     = mean(sexo == "Feminino", na.rm = TRUE),
            p_crianca = mean(g_idade == "[0,5)", na.rm = TRUE),
            p_vivax    = mean(tp_parasi == "Vivax", na.rm = TRUE))

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

malaria2


# linear model ------------------------------------------------------------

malaria2 %>% GGally::ggpairs(columns = c(6, 3:5))

# fit procedure

mal_tslm <- malaria2 %>%
  model(TSLM(api_1000 ~ p_crianca + p_vivax))

# model estimates

mal_tslm %>% report()

mal_tslm %>% filter(nm_uf == "Acre") %>% report()
mal_tslm %>% filter(nm_uf == "Rondônia") %>% report()
mal_tslm %>% filter(nm_uf == "Roraima") %>% report()

# plot of observed and fitted

mal_tslm %>%
  augment() %>%
  ggplot(aes(x = mes)) +
  geom_line(aes(y = api_1000, color = "Observed")) +
  geom_line(aes(y = .fitted, color = "Fitted")) +
  facet_wrap(~nm_uf, scales = "free") +
  labs(title = "Plot of observed and fitted values",
       color = NULL, y = "Índice parasitário anual (* 1000)")

# plot of observed vs fitted

mal_tslm %>%
  augment() %>%
  ggplot(aes(x = api_1000, y = .fitted)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  labs(title = "Observed versus fitted values",
       x = "Data (actual values)", y = "Fitted (predicted values)")

# residual displays

mal_tslm %>% filter(nm_uf == "Acre") %>% gg_tsresiduals()
mal_tslm %>% filter(nm_uf == "Rondônia") %>% gg_tsresiduals()

# residual plots against predictors

malaria2 %>%
  left_join(residuals(mal_tslm)) %>%
  pivot_longer(c(p_fem:p_vivax), names_to = "regressor", values_to = "x") %>%
  ggplot(aes(x = x, y = .resid)) +
  geom_point() +
  facet_grid(nm_uf ~ regressor, scales = "free_x")

# residuals against fitted values

mal_tslm %>%
  augment() %>%
  ggplot(aes(x = .fitted, y = .resid, color = nm_uf)) +
  geom_point() +
  facet_wrap(~nm_uf) +
  ggtitle("Heteroscedasticidade!!!")

# some useful predictors --------------------------------------------------

# try to apply a few of the specials in TSLM
mal_tslm <- malaria2 %>%
  filter(nm_uf != "Tocantins") %>%
  model(tslm_frk1  = TSLM(api_1000 ~ trend() + fourier(K = 1)),
        tslm_frk2  = TSLM(api_1000 ~ trend() + fourier(K = 2)),
        tslm_prds  = TSLM(api_1000 ~ trend() + season() + p_crianca + p_vivax),
        tslm_prdf  = TSLM(api_1000 ~ trend() + fourier(K = 1) + p_crianca + p_vivax),
        tslm_prdf2 = TSLM(api_1000 ~ trend() + fourier(K = 2) + p_crianca + p_vivax))
mal_tslm

# selecting predictors ----------------------------------------------------

# check statistics of predictive ability
mal_tslm %>%
  glance() %>%
  select(nm_uf, .model, CV, AICc, adj_r_squared) %>%
  arrange(nm_uf, CV, AICc, -adj_r_squared) %>%
  print(n = Inf)

mal_tslm %>%
  glance() %>%
  select(nm_uf, .model, CV, AICc, adj_r_squared) %>%
  pivot_longer(c(CV, AICc, adj_r_squared), names_to = "acc") %>%
  ggplot(aes(x = nm_uf, y = value, fill = .model)) +
  facet_grid(acc~., scales = "free_y") +
  geom_col(position = "dodge") +
  labs(title = "Medidas de qualidade do ajuste",
       x = NULL, y = NULL) +
  scale_fill_viridis_d(name   = "Modelo",
                       guide  = guide_legend(nrow = 2, byrow = TRUE)) +
  theme(legend.position = "bottom")

ggsave("qual-ajuste.png")

# I've opted to ignore significance coefficients for now, let's evaluate forecasts

# remember the limitations of forecasting with predictor variables that
# cannot be estimated

# forecasting with regression ---------------------------------------------
malaria_full <- malaria2 %>% filter(nm_uf != "Tocantins", year(mes) <= 2020)
malaria_train <- malaria2 %>% filter(nm_uf != "Tocantins", year(mes) < 2019)
malaria_test <- malaria2 %>% filter(nm_uf != "Tocantins", year(mes) == 2019)

malaria_cv <- malaria2 %>%
  filter(nm_uf != "Tocantins", year(mes) < 2019) %>%
  stretch_tsibble(.step = 1, .init = 12)

# models without predictors

malaria_fc <- malaria_cv %>%
  model(

    Mean = MEAN(api_1000),
    Naive = NAIVE(api_1000),
    SNaive = SNAIVE(api_1000),
    Drift = RW(api_1000 ~ drift()),

  ) %>%
  forecast(h = 12)

acc_nopred <- malaria_fc %>% accuracy(malaria_full) %>% arrange(nm_uf, RMSE)

# models with predictors

malaria_fc_pred <- malaria_train %>%
  model(
    Mean = MEAN(api_1000),
    Naive = NAIVE(api_1000),
    SNaive = SNAIVE(api_1000),
    Drift = RW(api_1000 ~ drift()),
    tslm_prds  = TSLM(api_1000 ~ trend() + season() + p_crianca + p_vivax),
    tslm_prdf  = TSLM(api_1000 ~ trend() + fourier(K = 1) + p_crianca + p_vivax),
    tslm_prdf2 = TSLM(api_1000 ~ trend() + fourier(K = 2) + p_crianca + p_vivax)
  ) %>%
  forecast(malaria_test)

acc_wpred <- malaria_fc_pred %>% accuracy(malaria_full) %>%  arrange(nm_uf, RMSE)

# Gráfico

bind_rows(acc_nopred, acc_wpred) %>%
  ggplot(aes(x = nm_uf, y = RMSE, fill = .model)) +
  geom_col(position = 'dodge') +
  scale_fill_brewer(palette = "Paired") +
  labs(title = "RMSE para diversos modelos",
       subtitle = "Teste em 2019")

best_models <- bind_rows(acc_nopred, acc_wpred) %>%
  group_by(nm_uf) %>%
  filter(min_rank(RMSE) <= 3)
best_models

malaria_fc_pred %>%
  semi_join(best_models, by = c("nm_uf", ".model")) %>%
  autoplot(malaria_test, level = NULL) +
  labs(title = "Avaliação das previsões dos melhores modelos lineares",
       x     = "Mês",
       y     = "Índice parasitário anual",
       color = "Modelo") +
  scale_color_brewer(palette = "Paired")

ggsave("prediction-tslm.png")

# Parece que adicionar alguns preditores, mesmo que muito simples, melhorou muito a
# capacidade preditiva dos modelos. Portanto, o uso de cenários de predição com
# algumas variáveis identificadas deve melhorar bastante os modelos

# use ex-post model to calibrate scenarios and define spike/step variables

# scenario based forecasting for malaria

# consider using lagged predictors to estimate the ex-ante model

# nonlinear regression ----------------------------------------------------

# consider nonlinear terms for a TSLM

# I think I'm gonna stop here because I feel like these issues will be raised
# in further chapters, and I have a very fragmented understanding of these terms,
# their use and their effects on predictions.
