library(fpp3)

options(pillar.sigfig = 5, scipen = 999)

# simple exponential smoothing --------------------------------------------

malaria2 <- readRDS("malaria2.rds")
malaria2

test <- malaria2 %>%
  filter(nm_uf != "Tocantins", year(mes) == 2019)

fit <- malaria2 %>%
  filter(nm_uf != "Tocantins", between(year(mes), 2011, 2018)) %>%
  model(ETS(api_1000))

fit

glance(fit)

tidy(fit)

fc <- fit %>% forecast(h = 12)

fc %>% autoplot(test) +
  labs(title = "Projeção para 2019 - Modelos ETS",
       subtitle = "Estimados por menor AICc",
       y = "Índice parasitário anual (* 1000)",
       level = "ICs (%)")

ggsave("ETS-models.png")

components(fit) %>%
  autoplot() +
  scale_color_brewer(palette = "Paired")

ggsave("ETS-dcmp.png")

augment(fit) %>%
  pivot_longer(c(.resid, .innov)) %>%
  ggplot(aes(x = mes, y = value)) +
  facet_grid(name~., scales = "free_y") +
  geom_line()

