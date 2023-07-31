# Composição socioeconômica da população -------------------------------------
# pkgs-opts ------------------------------------------------------------------
library(tidyverse)
library(scales)
library(plotly)

options(digits = 1, scipen = 50)

theme_set(theme_bw())

# import ---------------------------------------------------------------------
ae_uf <- read_csv2("dados/pnad_2001-2015_anos_estudo.csv")
ae_br <- read_csv2("dados/pnad_2001-2015_anos_estudo_br.csv")
gini_uf <- read_csv2("dados/pnad_2001-2011_gini.csv")
gini_br <- read_csv2("dados/pnad_2001-2011_gini_br.csv")
renda_uf <- read_csv2("dados/pnad_2001-2015_renda.csv")
renda_br <- read_csv2("dados/pnad_2001-2015_renda_br.csv")
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
  mutate(UF = "99", UFf = "Brasil") %>%
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

# Renda média das UFs em comparação com o Brasil 2007-2019 ------------------
renda <- bind_rows(renda_br, renda_uf)

r <- renda %>%
  filter(uf %in% c(1:21,51)) %>%
  highlight_key(~uf_n) %>%
  ggplot(aes(ano, renda,
             color = reorder(uf_n, uf),
             text = paste0("território: ", uf_n))) +
  geom_line(size = 0.5) +
  geom_point(size = 1) +
  scale_x_continuous(breaks = breaks_extended(12)) +
  scale_y_continuous(labels = label_number(big.mark = ".",
                                           decimal.mark = ",")) +
  scale_color_manual(values = c("grey50", "darkred", "seagreen", "steelblue",
                                "gold2", "orange", "purple", "coral",
                                "forestgreen", "khaki")) +
  labs(x = "Ano", y = "Rendimento",
       title = "Valor do rendimento médio mensal",
       color = "Estado") # População de 10 anos ou mais

p <- r %>%
  ggplotly(tooltip = c("ano", "renda", "text")) %>%
  highlight(on = "plotly_hover", off = "plotly_deselect")
p

withr::with_dir("img/",{
  htmlwidgets::saveWidget(p, "renda.html")
  write_excel_csv2(renda, "renda.csv.xz")
})

# Índices de gini das UFs em boxplot, 2007 e 2019 -----------------------
gini <- bind_rows(gini_br, gini_uf)

g <- gini %>%
  filter(uf %in% c(1:21,51),
         ano >= 2007) %>%
  highlight_key(~uf_n) %>%
  ggplot(aes(ano, Valor,
             color = reorder(uf_n, uf),
             text = paste0("território: ", uf_n))) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = breaks_extended(6)) +
  scale_y_continuous(limits = c(0.4, 0.6)) +
  scale_color_manual(values = c("grey50", "darkred", "seagreen", "steelblue",
                                "gold2", "orange", "purple", "coral",
                                "forestgreen", "khaki")) +
  labs(x = "Ano", y = "Índice", color = "Estado",
       title = "Índice de Gini (menor é melhor)")

p <- g %>%
  ggplotly(tooltip = c("ano", "Valor", "text")) %>%
  highlight(on = "plotly_hover", off = "plotly_deselect")

p

withr::with_dir("img/",{
  htmlwidgets::saveWidget(p, "gini.html")
  write_excel_csv2(gini, "gini.csv.xz")
})

# Grupos de anos de estudo das UFs em comparação com o Brasil ----------------
anos_estudo <- bind_rows(ae_br, ae_uf) %>%
  mutate(
    aes2 = fct_collapse(
      aes,
      `Sem instrução e\nmenos de 1 ano` = c("Sem instrução e menos de 1 ano"),
      `1 a 3 anos` = c("1 ano", "2 anos", "3 anos"),
      `4 a 7 anos` = c("4 anos", "5 anos", "6 anos", "7 anos"),
      `8 a 10 anos` = c("8 anos", "9 anos", "10 anos"),
      `11 a 14 anos` = c("11 anos", "12 anos", "13 anos", "14 anos"),
      `15 ou mais anos` = c("15 anos ou mais"),
      `Não determinados` = c("Não determinados e sem declaração",
                             "Não determinados")) %>%
      fct_relevel(
        "Sem instrução e\nmenos de 1 ano",
        "1 a 3 anos",
        "4 a 7 anos",
        after = 0L)) %>%
  group_by(uf, uf_n, ano, aes2) %>%
  summarise(v = sum(v, na.rm = TRUE)) %>%
  mutate(p = v/sum(v, na.rm = TRUE))

anos_estudo

g <-
  anos_estudo %>%
  highlight_key(~aes2) %>%
  ggplot(aes(ano, p,
             fill = aes2)) +
  facet_wrap(~fct_reorder(uf_n, uf), ncol = 2) +
  geom_area(aes(text = NULL)) +
  scale_x_continuous(name = "Ano", breaks = breaks_width(2)) +
  scale_y_continuous(name = "Proporção",
                     labels = label_percent(accuracy = 1)) +
  scale_fill_viridis_d(name = "Grupos de anos\nde estudo",
                       labels = label_wrap(12),
                       option = "E") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        strip.background = element_blank()) +
  ggtitle("Grupos de anos de estudo")

p <-
  ggplotly(g,
           tooltip = c("ano", "p"),
           height = 1000,
           width = 700) %>%
  highlight(on = "plotly_click", off = "plotly_relayout", debounce = 25)

p

withr::with_dir("img/",{
  htmlwidgets::saveWidget(p, "anos_estudo.html")
  write_excel_csv2(anos_estudo, "anos_estudo.csv.xz")
})

