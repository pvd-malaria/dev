# init ----
library(tidyverse, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(broom)
library(survminer)
library(Hmisc)
library(survival)


options(scipen = 6,
        na.action = 'na.exclude')

#file.copy("../reclin/sivep_completo.rds", "sivep_completo.rds")

df <- read_rds("sivep_completo.rds")

df <- as_tibble(df)

# Renomeando os fatores -----
# Ocupação
df$COD_OCUP <- factor(df$COD_OCUP,
                      levels = c(1:11),
                      labels = c("Agricultura",
                                 "Pecuária",
                                 "Doméstica",
                                 "Turismo",
                                 "Garimpagem",
                                 "Exploração Vegetal",
                                 "Caça/Pesca",
                                 "Construção de estradas/barragens",
                                 "Mineração",
                                 "Viajante",
                                 "Outros"))

# Escolaridade
df$NIV_ESCO <- factor(df$NIV_ESCO,
                      levels = c(0:8),
                      labels = c("Analfabeto",
                                 "1ª a 4ª série incompleta do EF",
                                 "4ª série completa do EF",
                                 "5ª a 8ª série incompleta do EF",
                                 "Ensino fundamental completo",
                                 "Ensino médio incompleto",
                                 "Ensino médio completo",
                                 "Educação superior incompleto",
                                 "Educação superior completa"))

# Estado gestacional
df$GESTANTE. <- factor(df$GESTANTE.,
                       levels = c(1:5),
                       labels = c("1º Trimestre",
                                  "2º Trimestre",
                                  "3º Trimestre",
                                  "Idade gestacional ignorada",
                                  "Não"))

# Raça
df$RACA <- factor(df$RACA,
                  levels = c(1:5),
                  labels = c("Branca", "Preta", "Amarela", "Parda", "Indigena"))

# Quantidade de cruzes
df$QTD_CRUZ <- factor(df$QTD_CRUZ,
                      levels = c(1:6),
                      labels = c("< +/2",
                                 "+/2",
                                 "+",
                                 "++",
                                 "+++",
                                 "++++"))

# Resultado do exame
df$RES_EXAM <- factor(df$RES_EXAM,
                      levels = c(2:11),
                      labels = c("Falciparum",
                                 "F+Fg",
                                 "Vivax",
                                 "F+V",
                                 "V+Fg",
                                 "Fg",
                                 "Malariae",
                                 "F+M",
                                 "Ovale",
                                 "Não Falciparum"))

# Tipo de detecção
df$TIPO_LAM <- factor(df$TIPO_LAM,
                      levels = c(1:3),
                      labels = c("Detecção Passiva", "Detecção Ativa", "LVC"))

# Esquema
df$ESQUEMA <- factor(df$ESQUEMA,
                     levels = c(1:12, 83, 85:89, 99),
                     labels = c("Infecções pelo P. vivax, ou P. ovale com cloroquina em 3 dias e primaquina em 7 dias (esquema curto)",
                                "Infecções pelo P. vivax, ou P. ovale com cloroquina em 3 dias e primaquina em 14 dias (esquema longo)",
                                "Infecções pelo P. malariae para todas as idades e por P. vivax ou P. ovale em gestantes e crianças com menos de 6 meses, com cloroquina em 3 dias",
                                "Prevenção das recaídas frequentes por P. vivax ou P. ovale com cloroquina semanal em 12 semanas",
                                "Infecções por P. falciparum com a combinação fixa de artemeter+lumefantrina em 3 dias",
                                "Infecções por P. falciparum com a combinação fixa de artesunato+mefloquina em 3 dias",
                                "Infecções por P. falciparum com quinina em 3 dias, doxiciclina em 5 dias e primaquina no 6º dia)",
                                "Infecções mistas por P. falciparum e P. vivax ou P. ovale com Artemeter + Lumefantrina ou Artesunato + Mefloquina em 3 dias e Primaquina em 7 dias",
                                "Infecções não complicadas por P. falciparum no 1º trimestre da gestação e crianças com menos de 6 meses, com quinina em 3 dias e clindamicina em 5",
                                "Malária grave e complicada pelo P. falciparum em todas as faixas etárias",
                                "Infecções por P. falciparum com a combinação fixa de artemeter+lumefantrina em 3 dias e primaquina em dose única",
                                "Infecções por P. falciparum com a combinação fixa de artesunato+mefloquina em 3 dias e primaquina em dose única",
                                "Infecções mistas por Pv + Pf com Mefloquina em dose única e primaquina em 7 dias",
                                "Infecções por Pv em crianças apresentando vômitos, com cápsulas retais de artesunato em 4 dias e Primaquina em 7 dias",
                                "Infecções por Pf com Mefloquina em dose única e primaquina no segundo dia",
                                "Infecções por Pf com Quinina em 7 dias",
                                "Infecções por Pf de crianças com cápsulas retais de artesunato em 4 dias e dose única de Mefloquina no 3º dia e Primaquina no 5º ida",
                                "Infecções mistas por Pv + Pf com Quinina em 3 dias, doxiciclina em 5 dias e Primaquina em 7 dias",
                                "Outro esquema utilizado (por médico)"))

# Sexo
df$SEXO <- factor(df$SEXO, levels = c("M", "F"), labels = c("Masculino", "Feminino"))

# Id_lvc
df$ID_LVC <- factor(df$ID_LVC, levels = c(1:2), labels = c("LVC", "Não LVC"))

# Exame
df$EXAME <- factor(df$EXAME, levels = c(1:2), labels = c("Gota espessa/esfregaço", "Teste rápido"))

# Falciparum
df$FALCIPARUM <- factor(df$FALCIPARUM, levels = c(1:2), labels = c("Sim", "Não"))

# Vivax
df$VIVAX <- factor(df$VIVAX, levels = c(1:2), labels = c("Sim", "Não"))

# Hemoparasitas
df$HEMOPARASI <- factor(df$HEMOPARASI, levels = c(1:4, 9), labels = c("Negativo", "Trypanosoma sp.", "Microfilária", "Trypanosoma sp.+ Microfilária", "Não pesquisados"))

# Idade ou grupo de idade
df$ID_PACIE <- ifelse(df$ID_DIMEA != "A", 0, df$ID_PACIE)
df$age_groups <- cut(df$ID_PACIE, breaks = c(0, 5, 40, 60, Inf), right = FALSE)

# Apenas pacientes com data dos sintomas e data do início do tratamento
# Apenas pacientes com data dos sintomas ANTERIOR a data do tratamento
# Apenas notificações primárias
df <- df %>% filter(
  !is.na(date_sinto),
  !is.na(date_trata),
  date_sinto <= date_trata,
  ID_LVC == "Não LVC")

# Censura a esquerda, pacientes que levaram mais de 48h para iniciar o atendimento
df <- df %>% mutate(
  tempo = difftime(date_trata, date_sinto, units = 'days'), # Variável tempo
  trat48 = if_else(tempo <= 2, 1, 0), # Variável tratamento dentro de 48h
  year = factor(year(date_trata)))

# Variáveis de estudo
df <- df %>% select(
  tempo, trat48, age_groups, year, COD_OCUP, ESQUEMA, EXAME, FALCIPARUM,
  GESTANTE., HEMOPARASI, ID_LVC, ID_PACIE, NIV_ESCO, QTD_CRUZ, RACA, RES_EXAM,
  SEXO, TIPO_LAM, VIVAX)

# html(describe(df), size = 80, scroll = TRUE)


# Kaplan-Meier ----
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ 1)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                title = "Kaplan-Meier sem covariáveis",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = T,
                legend = 'right',
                palette = "Set1")

ggsave("km-geral.png", print(g), width = 8, height = 6)

# Kaplan-Meier estratificado ----
# Ano
df$year2 <- factor(df$year, c(2007, 2013, 2017, 2019))

km_fit <- survfit(data = df, Surv(tempo, trat48) ~ year2)

g <- ggsurvplot(km_fit,
           xlim = c(0, 3),
           break.time.by = 1,
           linetype = 'strata',
           title = "Kaplan-Meier estratificado por ano",
           xlab = "Dias", ylab = "Sobrev.",
           risk.table = "percentage",
           tables.y.text = FALSE,
           legend = 'right',
           palette = "Set1")

ggsave("km-ano.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ year2)

knitr::kable(glance(log_rank))


# Sexo
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ SEXO)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por sexo",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-sexo.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ SEXO)

knitr::kable(glance(log_rank))

# Ocupação
df$ocup2 <- fct_lump_n(df$COD_OCUP, n = 7, other_level = "Outros")

km_fit <- survfit(data = df, Surv(tempo, trat48) ~ ocup2)

# Plot
g <- ggsurvplot(km_fit,
           xlim = c(0, 3),
           break.time.by = 1,
           linetype = 'strata',
           title = "Kaplan-Meier estratificado por ocupação",
           xlab = "Dias", ylab = "Sobrev.",
           risk.table = "percentage",
           tables.y.text = FALSE,
           legend = 'right',
           palette = "Set1")

ggsave("km-ocup.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ ocup2)

knitr::kable(glance(log_rank))

# Nível de escolaridade
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ NIV_ESCO)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por escolaridade",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-esco.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ NIV_ESCO)

knitr::kable(glance(log_rank))


# Gestante
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ GESTANTE.)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por estado gestacional",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-gest.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ GESTANTE.)

knitr::kable(glance(log_rank))

# Idade
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ age_groups)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por grupos de idade",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-age.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ age_groups)

knitr::kable(glance(log_rank))

# Raça/Cor
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ RACA)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por raça/cor",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-raca.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ RACA)

knitr::kable(glance(log_rank))

# Qtd cruz
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ QTD_CRUZ)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por gravidade da infecção",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-cruz.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ QTD_CRUZ)

knitr::kable(glance(log_rank))

# Tipo de detecção
km_fit <- survfit(data = df, Surv(tempo, trat48) ~ TIPO_LAM)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por tipo de detecção",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-detec.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ TIPO_LAM)

knitr::kable(glance(log_rank))

# Parasita
df$tipo_malaria <- fct_lump_n(df$RES_EXAM, 3, other_level = "Outra")

km_fit <- survfit(data = df, Surv(tempo, trat48) ~ tipo_malaria)

# Plot
g <- ggsurvplot(km_fit,
                xlim = c(0, 3),
                break.time.by = 1,
                linetype = 'strata',
                title = "Kaplan-Meier estratificado por tipo de parasita",
                xlab = "Dias", ylab = "Sobrev.",
                risk.table = "percentage",
                tables.y.text = FALSE,
                legend = 'right',
                palette = "Set1")

ggsave("km-parasi.png", print(g), width = 8, height = 6)

log_rank <- survdiff(data = df, Surv(tempo, trat48) ~ tipo_malaria)

knitr::kable(glance(log_rank))


# Análise das diferenças ----
# # comparação entre as pessoas que são atendidas em 48h ou não
#
# # Ocupação
# df %>%
#   count(COD_OCUP, trat48) %>%
#   group_by(COD_OCUP) %>%
#   mutate(nn = sum(n),
#          prop = n/nn) %>%
#   summarise(diff = diff(prop)) %>%
#   ggplot(aes(COD_OCUP, diff, label = percent(diff))) +
#   geom_col(position = 'dodge') +
#   geom_text(nudge_y = 0.01) +
#   scale_x_discrete(labels = label_wrap(14)) +
#   scale_fill_discrete(name = "Tratamento em 48h", labels = c("Não", "Sim")) +
#   labs(x = "Ocupação", y = "Diferença entre tratados e não tratados", title = "Tratamento em 48h") +
#   theme_light() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.4))
#
# # Grupo de idade
#
# # Sexo
# df %>%
#   count(SEXO, trat48) %>%
#   group_by(SEXO) %>%
#   mutate(nn = sum(n),
#          prop = n/nn) %>%
#   summarise(diff = diff(prop)) %>%
#   ggplot(aes(SEXO, diff, label = percent(diff))) +
#   geom_col(position = 'dodge') +
#   geom_text(nudge_y = 0.01) +
#   scale_x_discrete(labels = label_wrap(14)) +
#   scale_fill_discrete(name = "Tratamento em 48h", labels = c("Não", "Sim")) +
#   labs(x = "Sexo", y = "Diferença entre tratados e não tratados", title = "Tratamento em 48h") +
#   theme_light() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.4))
#
# # Nível de escolaridade
# df %>%
#   count(NIV_ESCO, trat48) %>%
#   group_by(NIV_ESCO) %>%
#   mutate(nn = sum(n),
#          prop = n/nn) %>%
#   summarise(diff = diff(prop)) %>%
#   ggplot(aes(NIV_ESCO, diff, label = percent(diff))) +
#   geom_col(position = 'dodge') +
#   geom_text(nudge_y = 0.01) +
#   scale_x_discrete(labels = label_wrap(14)) +
#   scale_fill_discrete(name = "Tratamento em 48h", labels = c("Não", "Sim")) +
#   labs(x = "Nível de escolaridade",
#        y = "Diferença entre tratados e não tratados",
#        title = "Tratamento em 48h") +
#   theme_light() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.4))
#
# # Gestação
# df %>%
#   count(GESTANTE., trat48) %>%
#   group_by(GESTANTE.) %>%
#   mutate(nn = sum(n),
#          prop = n/nn) %>%
#   summarise(diff = diff(prop)) %>%
#   ggplot(aes(GESTANTE., diff, label = percent(diff))) +
#   geom_col(position = 'dodge') +
#   geom_text(nudge_y = 0.01) +
#   scale_x_discrete(labels = label_wrap(14)) +
#   scale_fill_discrete(name = "Tratamento em 48h", labels = c("Não", "Sim")) +
#   labs(x = "Gestação",
#        y = "Diferença entre tratados e não tratados",
#        title = "Tratamento em 48h") +
#   theme_light() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.4))
#
# # Raça
# df %>%
#   count(RACA, trat48) %>%
#   group_by(RACA) %>%
#   mutate(nn = sum(n),
#          prop = n/nn) %>%
#   summarise(diff = diff(prop)) %>%
#   ggplot(aes(RACA, diff, label = percent(diff))) +
#   geom_col(position = 'dodge') +
#   geom_text(nudge_y = 0.01) +
#   scale_x_discrete(labels = label_wrap(14)) +
#   scale_fill_discrete(name = "Tratamento em 48h", labels = c("Não", "Sim")) +
#   labs(x = "Raça",
#        y = "Diferença entre tratados e não tratados",
#        title = "Tratamento em 48h") +
#   theme_light() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.4))
#
# # Quantidade de cruzes
# df %>%
#   count(QTD_CRUZ, trat48) %>%
#   group_by(QTD_CRUZ) %>%
#   mutate(nn = sum(n),
#          prop = n/nn) %>%
#   summarise(diff = diff(prop)) %>%
#   ggplot(aes(QTD_CRUZ, diff, label = percent(diff))) +
#   geom_col(position = 'dodge') +
#   geom_text(nudge_y = 0.01) +
#   scale_x_discrete(labels = label_wrap(14)) +
#   scale_fill_discrete(name = "Tratamento em 48h", labels = c("Não", "Sim")) +
#   labs(x = "Quantidade de cruzes",
#        y = "Diferença entre tratados e não tratados",
#        title = "Tratamento em 48h") +
#   theme_light() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.4))
#
# # Resultado do exame
# df %>%
#   count(RES_EXAM, trat48) %>%
#   group_by(RES_EXAM) %>%
#   mutate(nn = sum(n),
#          prop = n/nn) %>%
#   summarise(diff = diff(prop)) %>%
#   ggplot(aes(RES_EXAM, diff, label = percent(diff))) +
#   geom_col(position = 'dodge') +
#   geom_text(nudge_y = 0.01) +
#   scale_x_discrete(labels = label_wrap(14)) +
#   scale_fill_discrete(name = "Tratamento em 48h", labels = c("Não", "Sim")) +
#   labs(x = "Resultado do exame",
#        y = "Diferença entre tratados e não tratados",
#        title = "Tratamento em 48h") +
#   theme_light() +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.4))

# Transform 0 times to 1 times.
# df2 <- df %>%
#   mutate(tempo2 = if_else(tempo == 0, as.difftime(1, units = "hours"), tempo)) %>%
#   filter(year > 2014)

# # Testes log-rank ----
# survdiff(data = df2, Surv(tempo2, trat48) ~ age_groups)
#
# survdiff(data = df2, Surv(tempo2, trat48) ~ SEXO)
#
# survdiff(data = df2, Surv(tempo2, trat48) ~ RACA)
#
# survdiff(data = df2, Surv(tempo2, trat48) ~ NIV_ESCO)
#
# survdiff(data = df2, Surv(tempo2, trat48) ~ COD_OCUP)
#
# survdiff(data = df2, Surv(tempo2, trat48) ~ QTD_CRUZ)

# # Modelo paramétrico ----
# # Agreement with a weibull distributio
# result.km <- survfit(Surv(tempo2)~1, data = df2)
# survEst <- result.km$surv
# survEst[which(survEst == 0)] <- NA
# survTime <- result.km$time
# logLogSurvEst <- log(-log(survEst))
# logSurvTime <- log(survTime)
# result.lm <- lm(logLogSurvEst ~ logSurvTime)
# result.lm
#
# # A concordância está boa? Acho que sim....
# plot(logLogSurvEst ~ logSurvTime)
# abline(result.lm)
#
#
# # Variable selection and model development
# psm.trat48 <- psm(Surv(tempo2) ~ age_groups + RACA + NIV_ESCO + COD_OCUP + QTD_CRUZ,
#                   data = df2,
#                   dist = 'weibull')
#
# plot(anova(psm.trat48), margin = c('chisq', 'df', 'P'))
#
# fastbw(psm.trat48, rule = "aic")
#
# # Final variables
# # age_groups + RACA + NIV_ESCO + COD_OCUP + QTD_CRUZ
#
# # install.packages("eha")
# trat48 <- weibreg(Surv(tempo2)~ age_groups + SEXO + RACA + NIV_ESCO + COD_OCUP + QTD_CRUZ, data = df2)
# trat48
#
# plot(trat48, fn = c("sur"), xlim = c(0, 2000),
#      new.data = c(0, 0, 0, 1, # age_group
#                   0, 0, 0, 0, 1, # raça
#                   1, 0, 0, 0, 0, 0, 0, 0, # escolaridade
#                   0, 0, 0, 0, 0, 0, 0, 0, 0, 1, # ocupação
#                   0, 0, 0, 0, 0)) # qtd_cruzes
#
# # Goodness of Fit comparisons
# phreg.trat48 <- phreg(
#   Surv(tempo2)~ age_groups + RACA + NIV_ESCO + COD_OCUP + QTD_CRUZ,
#   data = df2,
#   dist = 'weibull')
# coxreg.trat48 <- coxreg(
#   Surv(tempo2)~ age_groups + RACA + NIV_ESCO + COD_OCUP + QTD_CRUZ,
#   data = df2)
#
# check.dist(coxreg.trat48, phreg.trat48)

# Modelo de Cox
# cph(Surv(tempo2, trat48) ~ RACA + NIV_ESCO + COD_OCUP, data = df2)
