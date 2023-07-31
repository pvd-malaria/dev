library(stars)
library(tidyverse)

temp <- tempdir(check = TRUE)

var1 <- readline("Variable (tmin, tmax, prec): ")

file1 <- paste0("../dados/worldclim/wc2.1_2.5m_", var1, "_2000-2009.zip")
file2 <- paste0("../dados/worldclim/wc2.1_2.5m_", var1, "_2010-2018.zip")

unzip(file1, list = TRUE)

(extract_files <- sprintf(
  "wc2.1_2.5m_%s_%d-%s.tif",
  var1,
  2007:2009,
  str_pad(rep(1:12, each = 3), 2, pad = 0)
))

unzip(file1, files = extract_files, exdir = temp)
unzip(file2, exdir = temp)

(files <- dir(temp, pattern = ".tif$", full.names = T))

amazonia <- st_read("../banco-mun/estados_aml.gpkg")

clima_crs <- "WGS84"

amazonia2 <- amazonia %>% st_transform(st_crs(clima_crs)) %>% st_make_valid()

get_median <- function(file) {

  cat("Reading file:", file, as.character(Sys.time()), "\n")

  clima <- read_stars(file)

  clima_amazonia <- clima[st_bbox(amazonia2)]

  mediana <- aggregate(
    clima_amazonia,
    by = st_geometry(amazonia2),
    FUN = median,
    na.rm = TRUE)

  mediana[[1]]

}

# Informal testing
amazonia2 %>% slice(5)

map(files[6], ~ get_median(.x))[[1]] %>% set_names(amazonia2$abbrev_state)

# Results
column_names <- files %>%
  str_extract(paste0(var1, "_\\d+-\\d+"))

res <- map(files, ~ get_median(.x)) %>%
  bind_cols(amazonia2, .) %>%
  rename_with(~ column_names, starts_with("..."))

res %>%
  as_tibble() %>%
  select(code_state, starts_with(var1)) %>%
  pivot_longer(!code_state,
               names_to = c("var", "mes"),
               names_sep = "_",
               names_repair = "universal",
               values_to = "mediana") %>%
  write_rds(paste0("clima_", var1, ".rds"))
