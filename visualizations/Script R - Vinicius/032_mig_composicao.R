library(tidyverse)
library(plotly)
library(htmlwidgets)

# cut2 function ----------------------------------------------------------
cut2 <- function(x = 1:100) {
cut(x,
    breaks = c(seq(0, 60, 15), max(x)),
    labels = c(paste(seq(0, 45, 15), "a", seq(0, 45, 15) + 14, sep = " "), "60 e +"),
    right = FALSE,
    include.lowest = TRUE)
}

# Ler o censo ------------------------------------------------------------
cd <- readRDS("dados/censo_2010_migracao.rds")
cd <- cd %>% as.tbl(cd)
cd
# Cozinha dos dados ------------------------------------------------------
label_nvins <- c(
  "Sem instrução e fundamental incompleto",
  "Fundamental completo e médio incompleto",
  "Médio completo e superior incompleto",
  "Superior completo",
  "Não determinado"
)

label_uf <- c("Rondônia",
              "Acre",
              "Amazonas",
              "Roraima",
              "Pará",
              "Amapá",
              "Tocantins",
              "Maranhão",
              "Piauí",
              "Ceará",
              "Rio Grande do Norte",
              "Paraíba",
              "Pernambuco",
              "Alagoas",
              "Sergipe",
              "Bahia",
              "Minas Gerais",
              "Espírito Santo",
              "Rio de Janeiro",
              "São Paulo",
              "Paraná",
              "Santa Catarina",
              "Rio Grande do Sul",
              "Mato Grosso do Sul",
              "Mato Grosso",
              "Goiás",
              "Distrito Federal")

level_uf05 <- c("1100000",
                "1200000",
                "1300000",
                "1400000",
                "1500000",
                "1600000",
                "1700000",
                "2100000",
                "2200000",
                "2300000",
                "2400000",
                "2500000",
                "2600000",
                "2700000",
                "2800000",
                "2900000",
                "3100000",
                "3200000",
                "3300000",
                "3500000",
                "4100000",
                "4200000",
                "4300000",
                "5000000",
                "5100000",
                "5200000",
                "5300000",
                "8888888",
                "9899999",
                "9900000")

label_uf05 <- c("RONDÔNIA",
                "ACRE",
                "AMAZONAS",
                "RORAIMA",
                "PARÁ",
                "AMAPÁ",
                "TOCANTINS",
                "MARANHÃO",
                "PIAUÍ",
                "CEARÁ",
                "RIO GRANDE DO NORTE",
                "PARAÍBA",
                "PERNAMBUCO",
                "ALAGOAS",
                "SERGIPE",
                "BAHIA",
                "MINAS GERAIS",
                "ESPÍRITO SANTO",
                "RIO DE JANEIRO",
                "SÃO PAULO",
                "PARANÁ",
                "SANTA CATARINA",
                "RIO GRANDE DO SUL",
                "MATO GROSSO DO SUL",
                "MATO GROSSO",
                "GOIÁS",
                "DISTRITO FEDERAL",
                "IGNORADO",
                "NÃO SABE UF NEM PAIS ESTRANGEIRO",
                "NÃO SABE UF")


data <- cd %>%
  select(-mun) %>%
  mutate(
    nv_ins2 = factor(nv_ins, levels = 1:5, labels = label_nvins),
    uf2 = factor(uf,
                 levels = c(11:17, 21:29, 31:33, 35, 41:43, 50:53),
                 labels = label_uf),
    sexo2 = factor(sexo, labels = c("Masculino", "Feminino")),
    uf_ant = as.integer(substr(uf05, 1, 2)),
    uf_ant2 = factor(uf05, levels = level_uf05, labels = label_uf05)
  ) %>%
  filter(uf %in% c(11:17, 21, 51)) %>%
  mutate(
    # Criar categorias de migração ----------------------------------------

    cat_mig = case_when(uf_ant %in% c(11:21,51) ~ "Interno",
                        uf_ant %in% c(22:50, 52:53) ~ "Externo",
                        is.na(uf_ant) ~ "Não migrante",
                        TRUE ~ NA_character_),
    # Criar categorias de estrutura etária ---------------------------------
    cat_ida = cut2(idade)
  )



# Analisar ---------------------------------------------------------------
# volume
(vol <- data %>%
   count(cat_mig, wt = peso, name = "populacao") %>%
   filter(cat_mig != "Não migrante")
)


# estrutura etária
(etaria <- data %>%
    count(cat_mig, cat_ida, wt = peso, name = "populacao") %>%
    group_by(cat_mig) %>%
    mutate(p.populacao = populacao/sum(populacao)) %>%
    filter(!is.na(cat_mig))
)

# escolaridade
(escola <- data %>%
    filter(idade >= 25) %>%
    count(cat_mig, nv_ins2, wt = peso, name = "populacao") %>%
    group_by(cat_mig) %>%
    mutate(p.populacao = populacao/sum(populacao))
)

# renda
(renda <- data %>%
    filter(r_mens > 1, !is.na(cat_mig)) %>%
    select(cat_mig, r_mens)
)

# Viz --------------------------------------------------------------------
a <- list(
  x = 0,
  y = -0.21,
  text = "Fonte: IBGE, Censo Demográfico 2010",
  showarrow = FALSE,
  xref = "paper",
  yref = "paper"
)

p.vol <-
  plot_ly(data = vol, x = ~cat_mig, y = ~populacao) %>%
  add_bars() %>%
  layout(title = "Volume de migrantes por categoria",
         xaxis = list(title = "Categoria"),
         yaxis = list(title = "Número de migrantes",
                      hoverformat = ".3s"),
         annotations = a)
p.vol

p.idade <- plot_ly(data = etaria, x = ~cat_mig, y = ~p.populacao) %>%
  add_bars(color = ~cat_ida) %>%
  layout(title = "Idade da população por categoria",
         legend = list(title = list(text = "Grupo etário")),
         xaxis = list(title = "Categoria"),
         yaxis = list(title = "Proporção",
                      tickformat = "%",
                      hoverformat = ".1%"),
         annotations = a)
p.idade

p.escola <- plot_ly(data = escola, x = ~cat_mig, y = ~p.populacao) %>%
  add_bars(color = ~nv_ins2) %>%
  layout(title = "Escolaridade da população por categoria",
         xaxis = list(title = "Categoria"),
         yaxis = list(title = "Proporção",
                      hoverformat = ".1%"),
         annotations = a)
p.escola

p.renda <-
  plot_ly(data = renda, color = ~cat_mig, y = ~r_mens) %>%
  add_boxplot() %>%
  layout(title = "Renda da população por categoria",
         showlegend = FALSE,
         xaxis = list(title = "Categoria"),
         yaxis = list(title = "log da Renda (R$)",
                      type = "log",
                      hoverformat = "$,.2r"),
         annotations = a)
p.renda

# export ------------------------------------------------------------
list <- list(p.vol, p.idade, p.escola, p.renda)
files <- c(
  "volume_catmig.html",
  "idade_catmig.html",
  "escola_catmig.html",
  "renda_catmig.html"
)

withr::with_dir(
  "atlas/",
  walk2(list, files, ~ saveWidget(.x, .y, selfcontained = TRUE))
)


list <- list(vol, etaria, escola, renda)
files <- c(
  "volume_catmig.csv.xz",
  "idade_catmig.csv.xz",
  "escola_catmig.csv.xz",
  "renda_catmig.csv.xz"
)

withr::with_dir(
  "atlas/",
  walk2(list, files, ~ write_excel_csv2(.x, .y))
)
