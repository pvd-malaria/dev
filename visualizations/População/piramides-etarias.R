# pkgs-opts ------------------------------------------------------------------
library(tidyverse)
library(scales)
library(plotly)

options(digits = 1, scipen = 50)

theme_set(theme_bw())

# import ---------------------------------------------------------------------
cd10 <- read_rds("dados/censo_2010_idade_sexo.rds")

# Estrutura etária das UFs em comparação com o Brasil 2010 -------------------
label <- c(sprintf("%s a %s", seq(0, 65, 5), seq(4, 69, 5)), "70 +")

uf <-
  cd10 %>%
  as_tibble() %>%
  filter(UF %in% c(11:21,51)) %>%
  mutate(UFf = factor(UF, labels = c("Rondônia", "Acre","Amazonas","Roraima",
                                     "Pará","Amapá","Tocantins","Maranhão",
                                     "Mato Grosso")),
         SEXO = factor(SEXO, labels = c("Masculino", "Feminino")),
         IDADEf = cut(IDADE,
                      breaks = c(seq(0, 70, 5), 139),
                      labels = label,
                      include.lowest = TRUE,
                      right = FALSE)) %>%
  group_by(UF, UFf, SEXO, IDADEf) %>%
  count(wt = PESO) %>%
  ungroup() %>%
  group_by(UF) %>%
  mutate(p = if_else(SEXO == "Masculino", -n/sum(n), n/sum(n)))

br <-
  cd10 %>%
  as_tibble() %>%
  mutate(SEXO = factor(SEXO, labels = c("Masculino", "Feminino")),
         IDADEf = cut(IDADE,
                      breaks = c(seq(0, 70, 5), 139),
                      labels = label,
                      include.lowest = TRUE,
                      right = FALSE)) %>%
  group_by(SEXO, IDADEf) %>%
  count(wt = PESO) %>%
  ungroup() %>%
  mutate(p = if_else(SEXO == "Masculino", -n/sum(n), n/sum(n)))

to_csv <- br %>%
  mutate(UF = "1", UFf = "Brasil") %>%
  bind_rows(uf, .)

p <-
  uf %>%
  highlight_key(~IDADEf) %>%
  ggplot(aes(IDADEf, p,
             fill = SEXO,
             text = paste0("Pop.:", number(n, accuracy = 1)))) +
  geom_col(data = br, aes(fill = "Brasil"), alpha = 0.5) +
  geom_col(alpha = 0.5, position = "identity") +
  coord_flip() +
  facet_wrap(~UFf, ncol = 3) +
  scale_y_continuous(labels = function(x) percent(abs(x), accuracy = 1)) +
  scale_fill_manual(values = c("grey50", "red2", "blue2"), name = NULL) +
  theme(strip.background = element_blank(),
        legend.position = "top") +
  labs(x = "Proporção", y = "Grupo etário",
       title = "Estrutura etária e por sexo")

p <-
  ggplotly(tooltip = "text") %>%
  highlight("plotly_click", "plotly_deselect") %>%
  layout(hovermode = "y") %>%
  style(hoverinfo = "none", traces = 1:9)

p

withr::with_dir("img/",{
  htmlwidgets::saveWidget(p, "piramides-etarias.html")
  write_excel_csv2(to_csv, "piramides-etarias.csv.xz")
})

