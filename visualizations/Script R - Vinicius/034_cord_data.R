rm(list = ls())

xfun::pkg_attach("tidyverse", "readxl", "circlize")

# import census ---------------------------------------------------------------
cd10 <- readRDS("dados/censo_2010_migracao.rds")

# tidy variables --------------------------------------------------------------
cd10 <- as_tibble(cd10)
cd10


uf_ant_label <- read_excel(
  "dados/etc/Migracao e deslocamento _Unidades da Federacao.xls",
  col_names = c("uf_nome", "uf_cod"), skip = 4)


uf_label <- read_excel(
  "dados/etc/divisao territorial brasil.xls",
  col_types = c("text", "text", "skip", "skip", "skip", "skip", "skip", "skip"),
  skip = 2
)

cd_tidy <-
  cd10 %>%
  mutate(
    ufb = factor(uf, levels = uf_label$UF, labels = toupper(uf_label$Nome_UF)),
    uf = as.numeric(uf),
    sexo = factor(sexo, labels = c("Masculino", "Feminino")),
    uf05b = factor(
      uf05,
      labels = uf_ant_label$uf_nome,
      exclude = ""),
    uf05 = as.numeric(substr(uf05, 1, 2)),
    nv_ins2 = factor(nv_ins, labels = c(
      "Sem instrução e fundamental incompleto",
      "Fundamental completo e médio incompleto",
      "Médio completo e superior incompleto",
      "Superior completo",
      "Não determinado")),
    # Variável região
    regat = factor(
      case_when(
        uf %in% c(11:21, 51) ~ as.character(ufb),
        uf %in% c(22:50, 52:53) ~ "OUTRAS",
        TRUE ~ NA_character_)),
    regant = factor(
      case_when(
        uf05 %in% c(11:21, 51) ~ as.character(uf05b),
        uf05 %in% c(22:50, 52:53) ~ "OUTRAS",
        TRUE ~ NA_character_))
  ) %>%
  mutate(
    regat = fct_relevel(regat, "OUTRAS", after = Inf),
    regant = fct_relevel(regant, "OUTRAS", after = Inf)
  ) %>%
  select(-mun)

levels(cd_tidy$regat)
levels(cd_tidy$regant)

# Adjacency list de migração
mig <- cd_tidy %>% count(regant, regat, wt = peso, name = "fluxo")

# save file -------------------------------------------------------------------
write_excel_csv2(mig, "atlas/coord_plot_data.csv.xz")
