library(tidyverse)

files <- dir(pattern = "df_UF")
files

map(files, read_lines, n_max = 2)

sivep <- map_dfr(files, data.table::fread)

glimpse(sivep)

write_rds(sivep, "sivep_completo.rds")
