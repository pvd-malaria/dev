# pkgs-opts ------------------------------------------------------------------
library(tidyverse)
library(scales)
library(plotly)

options(digits = 1, scipen = 50)

theme_set(theme_bw())

# import ---------------------------------------------------------------------
gini_uf <- read_csv2("dados/pnad_2001-2011_gini.csv")
gini_br <- read_csv2("dados/pnad_2001-2011_gini_br.csv")

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


