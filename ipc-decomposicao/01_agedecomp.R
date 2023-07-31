library(tidyverse)
library(gt)
library(kableExtra)

theme_set(theme_bw())

try(setwd("ipc-decomposicao"))

df <- read_csv2("data.csv", col_types = cols(
  uf_code = col_factor(),
  ano = col_factor(),
  age_group = col_factor(),
  pop = col_double(),
  pop_percent = col_double(),
  cases = col_double()
))

# yearly rate -------------------------------------------------------------

yr <-
  df %>%
  group_by(uf_code, ano) %>%
  summarise(pop = sum(pop, na.rm = T),
            cases = sum(cases, na.rm = T)) %>%
  mutate(rate = cases/pop) %>%
  pivot_wider(names_from = ano, values_from = c(pop, cases, rate)) %>%
  select(!c(pop_2007:cases_2019)) %>%
  mutate(change = 1 - rate_2019/rate_2007)

write_csv2(yr, "rate_change.csv")

# Age viz -----------------------------------------------------------------

df %>%
  mutate(pop_percent = if_else(sexo == "Men", -pop_percent, pop_percent)) %>%
  unite("sexo_ano", sexo, ano, sep = " - ") %>%
  ggplot(aes(age_group, pop_percent,
             color = sexo_ano, linetype = sexo_ano, group = sexo_ano)) +
  facet_wrap(~uf_code) +
  geom_line() +
  coord_flip() +
  scale_color_viridis_d() +
  guides(linetype = FALSE) +
  labs(y = "Population proprtions", x = "Age group", color = "Sex and year",
       caption = "Source: Brazilian Institute of Geography and Statistics and Ministry of Health.") +
  theme(legend.position = "top") +
  ggsave("piramide.pdf", width = 6, height = 8)

# Rates viz ---------------------------------------------------------------

df %>%
  mutate(case_rate = cases/pop,
         age_group = fct_relabel(age_group, ~ str_remove(.x, "anos")),
         uf_code = fct_reorder(uf_code, case_rate, .desc = TRUE)) %>%
  unite("sexo_ano", sexo, ano, sep = " - ") %>%
  ggplot(aes(age_group, case_rate,
             color = sexo_ano, linetype = sexo_ano, group = sexo_ano)) +
  geom_line() +
  facet_wrap(~uf_code, scales = "free_y") +
  scale_color_viridis_d() +
  guides(linetype = FALSE) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        legend.position = "top") +
  labs(x = "Age group", y = "Age-specific rate", color = "Sex and year",
       caption = "Source: Brazilian Institute of Geography and Statistics and Ministry of Health.") +
  ggsave("taxa-especifica-uf.pdf", width = 6, height = 8)

# Decomposition -----------------------------------------------------------
decomp <- df %>%
  mutate(case_rate = cases/pop) %>%
  pivot_wider(id_cols = c(uf_code, age_group),
              names_from = c("ano", "sexo"),
              values_from = c("pop_percent", "case_rate"))  %>%
  mutate(age_contrib_men  =
           (pop_percent_2007_Men - pop_percent_2019_Men) *
           ((case_rate_2007_Men   + case_rate_2019_Men) / 2),
         rate_contrib_men =
           (case_rate_2007_Men   - case_rate_2019_Men) *
           ((pop_percent_2007_Men + pop_percent_2019_Men) / 2),
         age_contrib_women  =
           (pop_percent_2007_Women - pop_percent_2019_Women) *
           ((case_rate_2007_Women + case_rate_2019_Women) / 2),
         rate_contrib_women =
           (case_rate_2007_Women - case_rate_2019_Women) *
           ((pop_percent_2007_Women + pop_percent_2019_Women) / 2)) %>%
  group_by(uf_code) %>%
  summarise(age_contrib_men = sum(age_contrib_men, na.rm = T),
            rate_contrib_men = sum(rate_contrib_men, na.rm = T),
            age_contrib_women = sum(age_contrib_women, na.rm = T),
            rate_contrib_women = sum(rate_contrib_women, na.rm = T)) %>%
  mutate(total_contrib_men = age_contrib_men + rate_contrib_men,
         contr_age_men = age_contrib_men/total_contrib_men,
         contr_rate_men = rate_contrib_men/total_contrib_men,
         total_contrib_women = age_contrib_women + rate_contrib_women,
         contr_age_women = age_contrib_women/total_contrib_women,
         contr_rate_women = rate_contrib_women/total_contrib_women) %>%
  pivot_longer(cols = c(-uf_code),
               names_to = c(".value", "sexo"),
               names_pattern = "(.*_.*)_(.*)") %>%
  select(uf_code:sexo,
         age = age_contrib, rate = rate_contrib,
         everything(), -total_contrib)

write_rds(decomp, "decomp_table.rds")

# The decomposition did not really provide very powerful results, the changes in
# age structure account for less than 10%, since the difference in rate schedules
# was very pronounced over the period. One thing I could try is to make the comparison
# visual through changes in age composition and rate schedule through pyramids.
# Another possibility is to try standardizing the rate schedules and applying to
# different age structures in the period.
