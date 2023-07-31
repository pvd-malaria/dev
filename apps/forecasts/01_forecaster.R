print("Program starting")
print(Sys.time())

rm(list = ls())
source("00_preparation.R")

# rolling origin (1, 3, 6 or 12 months) for state ---------------------------------
runForecaster <- function(state_code) {

  if (!state_code %in% c(11:17, 21, 51)) stop("Incorrect state code")

  code = state_code

  # 1 mes
  print("Fitting models for H = 1...")
  print(Sys.time())

  fit <- malaria_tscv %>%
    filter(uf == code) %>%
    model(
      arima  = ARIMA(log(casos)),
      nnetar = NNETAR(log(casos))
    )

  print("Running H = 1 forecasts...")
  print(Sys.time())

  f1m <- fit %>% forecast(malaria_tscv_test)

  print("Done")
  print(Sys.time())

  # 3 meses
  print("Fitting models for H = 3...")
  print(Sys.time())

  fit <- malaria_tscv_3m %>%
    filter(uf == code) %>%
    model(
      arima  = ARIMA(log(casos)),
      nnetar = NNETAR(log(casos))
    )

  print("Running H = 3 forecasts...")
  print(Sys.time())

  f3m <- fit %>% forecast(malaria_tscv_test)
  print("Done")
  print(Sys.time())

  # 6 meses
  print("Fitting models for H = 6...")
  print(Sys.time())

  fit <- malaria_tscv_6m %>%
    filter(uf == code) %>%
    model(
      arima  = ARIMA(log(casos)),
      nnetar = NNETAR(log(casos))
    )

  print("Running H = 6 forecasts...")
  print(Sys.time())

  f6m <- fit %>% forecast(malaria_tscv_test)

  print("Done")
  print(Sys.time())

  # 12 meses
  print("Fitting models for H = 12...")

  fit <- malaria_tscv_12m %>%
    filter(uf == code) %>%
    model(
      arima  = ARIMA(log(casos)),
      nnetar = NNETAR(log(casos))
    )
  print("Running H = 12 forecasts...")
  print(Sys.time())

  f12m <- fit %>% forecast(malaria_tscv_test)

  print("Done")
  print(Sys.time())

  # Save forecasts
  files = paste(c("f1-", "f3-", "f6-", "f12-"), code, ".rds", sep = "")

  walk2(.x = list(f1m, f3m, f6m, f12m),
        .y = files,
        .f = write_rds)
  print(paste0(c("Files saved to: ", files), collapse = " "))

}

# Run for 1 state ---------------------------------------------------------
if (TRUE) {
  runForecaster(state_code = readline(prompt = "Enter state code: ") %>% as.integer())
}

# Run for all states ------------------------------------------------------
if (FALSE) {
  states = c(11:16, 21, 51)
  walk(.x = states, .f = runForecaster)
}

print("Program finished")
print(Sys.time())
