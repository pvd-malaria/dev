# pkgs-opts ------------------------------------------------------------------
library(tidyverse)
library(scales)
library(plotly)

options(digits = 1, scipen = 50)

theme_set(theme_bw())

# import ----------------------------------------------------------------------
ae_uf <- read_csv2("dados/pnad_2001-2015_anos_estudo.csv")
ae_br <- read_csv2("dados/pnad_2001-2015_anos_estudo_br.csv")

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

