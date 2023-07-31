state_code = 11

library(gt)

source("00_preparation.R")

f1 <- read_rds(paste0("f1-", state_code, ".rds"))
f3 <- read_rds(paste0("f3-", state_code, ".rds"))
f6 <- read_rds(paste0("f6-", state_code, ".rds"))
f12 <- read_rds(paste0("f12-", state_code, ".rds"))

original_data <- malaria2 %>%
  rename(cases_pred = casos) %>%
  filter_index("2019-01" ~ "2019-12") %>%
  filter(uf == state_code)

# Example code ------------------------------------------------------------

if (FALSE) {
  # Graph data preparation
  f1_graphdata <- f1 %>%
    mutate(.id = NULL) %>%
    hilo(level = 95) %>%
    unpack_hilo(`95%`) %>%
    transmute(cases_pred = .mean,
              cases_high = `95%_upper`,
              cases_low = `95%_lower`,
              casos)

  f1_graphdata

  # Graph drawing settings
  f1_graphdata %>%
    ggplot(aes(x = mes,
               y = cases_pred,
               ymin = cases_low,
               ymax = cases_high,
               fill = .model)) +
    facet_grid(. ~ .model) +
    geom_ribbon(alpha = 0.5, ) +
    geom_line(aes(color = .model)) +
    geom_line(data = original_data,
              aes(ymin = NULL, ymax = NULL, fill = NULL)) +
    labs(x = "Mês", y = "Casos", fill = "Modelo", color = "Modelo",
         title = "Projeção de casos de Malária por mês",
         subtitle = "H = 1")

  # Table data preparation
  f1_tabledata <- f1 %>%
    mutate(.id = NULL) %>%
    hilo(level = 95) %>%
    unpack_hilo(`95%`) %>%
    transmute(cases_pred = .mean,
              cases_high = `95%_upper`,
              cases_low = `95%_lower`,
              casos) %>%
    left_join(original_data, by = c("uf", "mes")) %>%
    rename(cases_pred = cases_pred.x,
           cases_real = cases_pred.y)

  # Tables for presentation
  f1_tabledata %>%
    select(
      Mês = mes,
      Modelo = .model,
      Observado = cases_real,
      Estimativa = cases_pred,
      `95% Superior` = cases_high,
      `95% Inferior` = cases_low
    ) %>%
    mutate(Modelo = recode_factor(Modelo, arima = "ARIMA", nnetar = "NNETAR")) %>%
    gt(rowname_col = "Mês",
       groupname_col = "Modelo") %>%
    tab_stubhead("Mês") %>%
    fmt_integer(2:6) %>%
    tab_style(style = cell_text(align = "center"), locations = cells_row_groups())

}


# Extracted functions -----------------------------------------------------

# Data preparation
graphdata <- function(x) {
  x %>%
    mutate(.id = NULL) %>%
    hilo(level = 95) %>%
    unpack_hilo(`95%`) %>%
    transmute(cases_pred = .mean,
              cases_high = `95%_upper`,
              cases_low = `95%_lower`,
              casos)
}

# Plotting
graphplot <- function(x, h) {
  x %>%
    ggplot(aes(x = mes,
               y = cases_pred,
               ymin = cases_low,
               ymax = cases_high,
               fill = .model)) +
    facet_grid(. ~ .model) +
    geom_ribbon(alpha = 0.5, ) +
    geom_line(aes(color = .model)) +
    geom_line(data = original_data,
              aes(ymin = NULL, ymax = NULL, fill = NULL)) +
    labs(x = "Mês", y = "Casos", fill = "Modelo", color = "Modelo",
         title = "Projeção de casos de Malária por mês",
         subtitle = paste0("H = ", h))
}

# Tabling
tabledata <- function(x) {
  x %>%
    mutate(.id = NULL) %>%
    hilo(level = 95) %>%
    unpack_hilo(`95%`) %>%
    transmute(cases_pred = .mean,
              cases_high = `95%_upper`,
              cases_low = `95%_lower`,
              casos) %>%
    left_join(original_data, by = c("uf", "mes")) %>%
    rename(cases_pred = cases_pred.x,
           cases_real = cases_pred.y)
}

tabler <- function(x) {
  x %>%
    select(
      Mês = mes,
      Modelo = .model,
      Observado = cases_real,
      Estimativa = cases_pred,
      `95% Superior` = cases_high,
      `95% Inferior` = cases_low
    ) %>%
    mutate(Modelo = recode_factor(Modelo, arima = "ARIMA", nnetar = "NNETAR")) %>%
    gt(rowname_col = "Mês",
       groupname_col = "Modelo") %>%
    tab_stubhead("Mês") %>%
    fmt_integer(2:6) %>%
    tab_style(style = cell_text(align = "center"), locations = cells_row_groups())
}


# Examples ----------------------------------------------------------------
if (FALSE) {
  # Graphs
  g1 <- graphdata(f1) %>% graphplot(h = 1)
  g3 <- graphdata(f3) %>% graphplot(h = 3)
  g6 <- graphdata(f6) %>% graphplot(h = 6)
  g12 <- graphdata(f12) %>% graphplot(h = 12)

  # Tables
  t1 <- tabledata(f1) %>% tabler()
  t3 <- tabledata(f3) %>% tabler()
  t6 <- tabledata(f6) %>% tabler()
  t12 <- tabledata(f12) %>% tabler()
}

