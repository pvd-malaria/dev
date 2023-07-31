# pkgs-opts ------------------------------------------------------------------
library(tidyverse)
library(scales)
library(plotly)

options(digits = 1, scipen = 50)

theme_set(theme_bw())

# import ---------------------------------------------------------------------
renda_uf <- read_csv2("dados/pnad_2001-2015_renda.csv")
renda_br <- read_csv2("dados/pnad_2001-2015_renda_br.csv")

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

