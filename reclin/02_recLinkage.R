suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(lubridate)
  library(reclin)
})


df <- read_rds("sivep_completo.rds")

dfb <-
  df %>% as_tibble() %>%
  mutate(date_exam = date(parse_date_time(DT_EXAME, orders = c("y-m-d", "d-m-y"))),
         date_nasc = date(parse_date_time(DT_NASCI, orders = c("y-m-d", "d-m-y"))),
         year_exam = year(date_exam),
         month_exam = month(date_exam),
         day_exam = day(date_exam),
         idade     = if_else(ID_DIMEA == "A", ID_PACIE, 0)) %>%
  select(-c(`Unnamed: 0`))

df2 <- dfb %>%
  filter(ID_LVC == 1 | TIPO_LAM == 3,
         across(c(MUN_RESI, MUN_INFE, SEXO, idade, date_sinto, date_nasc),
                ~ !is.na(.x))) %>%
  mutate(id_x = 1:nrow(.))

df3 <- dfb %>%
  filter(ID_LVC == 2,
         across(c(MUN_RESI, MUN_INFE, SEXO, idade, date_sinto, date_nasc),
                ~ !is.na(.x))) %>%
  mutate(id_y = 1:nrow(.))

nrow(df2)
nrow(df3)

rm(df, dfb);gc()

p <- pair_blocking(df2, df3,
                   large = FALSE,
                   blocking_var = c(
                     "COD_UNIN",
                     "MUN_RESI",
                     "MUN_INFE",
                     "LOC_RESI",
                     "LOC_INFE",
                     "date_nasc",
                     "SEXO",
                     "COD_OCUP",
                     "NIV_ESCO",
                     "GESTANTE."
                     )) %>%
  add_from_x("id_x", date_exam_lvc = "date_exam", res_exam_lvc = "RES_EXAM") %>%
  add_from_y("id_y", date_exam = "date_exam", res_exam = "RES_EXAM")

p

matches <- p %>% filter(date_exam_lvc > date_exam,
             date_exam_lvc - date_exam < 28,
             res_exam == 2    & res_exam_lvc %in%   c(2,3) |
               res_exam == 3  & res_exam_lvc %in%   c(2,3) |
               res_exam == 4  & res_exam_lvc ==          4 |
               res_exam == 5  & res_exam_lvc %in%   c(2:7) |
               res_exam == 6  & res_exam_lvc %in%   c(2:7) |
               res_exam == 7  & res_exam_lvc %in%   c(2:7) |
               res_exam == 8  & res_exam_lvc ==          8 |
               res_exam == 9  & res_exam_lvc %in%  c(2:7,9)|
               res_exam == 10 & res_exam_lvc ==         10)
matches

dups <- matches %>% filter(duplicated(.$x) | duplicated(.$y))
dups

unique_matches <- matches %>% filter(!duplicated(.$x) & !duplicated(.$y))

setDT(df2)
setDT(df3)

set(df2, j = "key", value = NA_real_)
set(df3, j = "key", value = NA_real_)

for (k in seq_len(nrow(unique_matches))) {
  i <- which(df2$id_x == unique_matches$id_x[[k]])
  j <- which(df3$id_y == unique_matches$id_y[[k]])

  set(df2, i, "key", as.integer(k))
  set(df3, j, "key", as.integer(k))
}

x <- df2[!is.na(key)]
y <- df3[!is.na(key)]

setkey(x, key)
setkey(y, key)

dt <- merge(x, y, suffixes = c("_lvc", "_prim"))

fwrite(dt, "sivep_linked_csv.gz")
