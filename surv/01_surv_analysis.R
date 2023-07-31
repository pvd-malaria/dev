# init ----
library(tidyverse, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(survival)
library(survMisc)
library(survminer)


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
                     levels = c(1:12, 83, 85:89, 99))

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
# Apenas pacientes de atendimento primário
df <- df %>% filter(!is.na(date_sinto),
                    !is.na(date_trata),
                    date_sinto <= date_trata,
                    ID_LVC == "Não LVC")

# Censura a esquerda, pacientes que levaram mais de 48h para iniciar o atendimento
df <- df %>% mutate(tempo = difftime(date_trata, date_sinto, units = 'hours'), # Variável tempo
                    status = if_else(tempo <= 48, 1, 0), # Variável tratamento dentro de 48h
                    year = year(date_trata))

# Variáveis de estudo
df <- df %>%
  select(tempo, status, age_groups, year, COD_OCUP, ESQUEMA, EXAME, GESTANTE.,
         ID_PACIE, NIV_ESCO, QTD_CRUZ, RACA, RES_EXAM, SEXO)

# Apenas casos sem missing para o modelo
df2 <- df %>%
  filter(year > 2010) %>%
  filter(complete.cases(.)) %>%
  rowid_to_column()

m1 <- coxph(Surv(tempo, status) ~ age_groups + strata(SEXO), data = df2)

m2 <- coxph(Surv(tempo, status) ~ age_groups + NIV_ESCO + COD_OCUP + RACA + strata(SEXO),
            data = df2)

m3 <- coxph(Surv(tempo, status) ~ age_groups + COD_OCUP + ESQUEMA + EXAME + NIV_ESCO +
             QTD_CRUZ + RACA + RES_EXAM + strata(SEXO),
           data = df2)

m4 <- coxph(Surv(tempo + status) ~ age_groups + year + COD_OCUP + ESQUEMA + EXAME + GESTANTE. +
            ID_PACIE + NIV_ESCO + QTD_CRUZ + RACA + RES_EXAM + strata(SEXO), data = df2)

summary(m3)

# Medida global de qualidade do ajuste ----
# Deviance
anova(m1, m2, m3)

# R2
cbind(rsq(m1), rsq(m2), rsq(m3))

# Concordancia
summary(m3)$concordance

# Sobrevivência por índice de prognóstico
df3 <- df2 %>%
  mutate(ip = m3$linear.predictors,
         ip2 = cut_interval(ip, 3))

fit <- survfit(data = df3, Surv(tempo, status) ~ SEXO)
cox.fit <- survfit(m3)

l <- list('km'=fit, 'cox'=cox.fit)

ggsurvplot_combine(l, data = df2, xlim = c(0, 72), linetype = 'strata')
