#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(gt)
library(tidyverse)
library(fpp3)
library(showtext)

# Some pre ui elements
source("00_preparation.R")

stateChoices <- list("Rondônia" = 11,
                     "Acre" = 12,
                     "Amazonas" = 13,
                     "Roraima" = 14,
                     "Pará" = 15,
                     "Amapá" = 16,
                     "Maranhão" = 21,
                     "Mato Grosso" = 51)

font_add_google("Roboto", "Roboto")

showtext_auto()

# Function definitions ----------------------------------------------------

# Data preparation
graphdata <- function(x) {
    x %>%
        mutate(.id = NULL) %>%
        hilo(level = 95) %>%
        unpack_hilo(`95%`) %>%
        transmute(cases_pred = .mean,
                  cases_high = `95%_upper`,
                  cases_low = `95%_lower`,
                  casos)
}

# Plotting
graphplot <- function(x, h, od) {
    x %>%
        ggplot(aes(x = mes,
                   y = cases_pred,
                   ymin = cases_low,
                   ymax = cases_high,
                   fill = .model)) +
        facet_grid(. ~ .model, labeller = labeller(.model = toupper)) +
        geom_ribbon(alpha = 0.5, ) +
        geom_line(aes(color = .model)) +
        geom_line(data = od,
                  aes(ymin = NULL, ymax = NULL, fill = NULL)) +
        labs(x = "Mês", y = "Casos", fill = "Modelo", color = "Modelo",
             title = "Projeção de casos de Malária por mês",
             subtitle = paste0("H = ", h)) +
        scale_color_manual(values = c("#BE1724", "#1674B9")) +
        scale_fill_manual(values = c("#BE1724", "#1674B9")) +
        theme_bw() +
        theme(text = element_text(family = "Roboto", size = 14))
}

# Tabling
tabledata <- function(x, od) {
    x %>%
        mutate(.id = NULL) %>%
        hilo(level = 95) %>%
        unpack_hilo(`95%`) %>%
        transmute(cases_pred = .mean,
                  cases_high = `95%_upper`,
                  cases_low = `95%_lower`,
                  casos) %>%
        left_join(od, by = c("uf", "mes")) %>%
        rename(cases_pred = cases_pred.x,
               cases_real = cases_pred.y)
}

tabler <- function(x) {
    x %>%
        select(
            Mês = mes,
            Modelo = .model,
            Observado = cases_real,
            Estimativa = cases_pred,
            `95% Superior` = cases_high,
            `95% Inferior` = cases_low
        ) %>%
        mutate(Modelo = recode_factor(Modelo, arima = "ARIMA", nnetar = "NNETAR")) %>%
        gt(rowname_col = "Mês",
           groupname_col = "Modelo") %>%
        tab_stubhead("Mês") %>%
        fmt_integer(2:6) %>%
        tab_style(style = cell_text(align = "center"), locations = cells_row_groups())
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # CSS
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap_custom.css")
    ),

    # Application title
    titlePanel("Malaria forecasts"),

    # Sidebar
    sidebarLayout(

        #sidebar Panel
        sidebarPanel(
            selectInput('statePicker', "Escolha estado",
                        stateChoices, selected = 11),

            br(),

            radioButtons("horizon", "Horizonte de projeção",
                         selected = 1,
                         c("1 mês" = 1,
                           "3 meses" = 3,
                           "6 meses" = 6,
                           "12 meses" = 12)),

            br(),

            h2("Descrição"),
            h5("Utilizamos modelos autoregressão integrada a média móvel (ARIMA) e rede neural com autoregressão (NNETAR) nos dados do SIVEP para estimar o número de casos em um determinado horizonte futuro em uma Unidade da Federação (UF), escolhidos pelo usuário. No teste ao lado, os modelos são treinados em anos anteriores (-2018) e os modelos com a melhor performance são utilizados para prever o número médio de casos e os intervalos de confiança de 95% para o ano de 2019. A principal diferença entre os modelos neste caso, é que o modelo ARIMA prediz melhor séries mais estáveis (menor variância), enquanto o NNETAR se ajusta melhor as séries mais instáveis. Por outro lado, o NNETAR é mais intensivo computacionalmente e produz intervalos de confiança menos plausíveis, razão pelo qual ele é menos recomendado em séries com variância menor (ex. Amapá). Ambos os modelos tem melhor performance preditiva nos horizontes de 1 e 12 meses, nos quais eles conseguem captar regularidades. Nenhum modelo é capaz de antecipar grandes variações ano-a-ano e as estimativas devem ser utilizadas como medidas da tendência observada em anos anteriores.")
        ),

        # Main panel with results in tabsets
        mainPanel(

            tabsetPanel(type = "tabs",
                        # Tabset 1: plots
                        tabPanel("Gráficos", plotOutput("plot")),

                        # Tabset 2: Tables
                        tabPanel("Tabelas", gt_output("table"))
            )

        )

    ),

)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$plot <- renderPlot({
        s <- input$statePicker
        h <- input$horizon

        f1 <- read_rds(paste0("f1-", s, ".rds"))
        f3 <- read_rds(paste0("f3-", s, ".rds"))
        f6 <- read_rds(paste0("f6-", s, ".rds"))
        f12 <- read_rds(paste0("f12-", s, ".rds"))

        original_data <- malaria2 %>%
            rename(cases_pred = casos) %>%
            filter_index("2019-01" ~ "2019-12") %>%
            filter(uf == s)

        if (h == 1) {
            f1  %>% graphdata() %>% graphplot(h, original_data)
        } else if (h == 3) {
            f3  %>% graphdata() %>% graphplot(h, original_data)
        } else if (h == 6) {
            f6  %>% graphdata() %>% graphplot(h, original_data)
        } else if (h == 12) {
            f12 %>% graphdata() %>% graphplot(h, original_data)
        } else {
            "Erro"
        }

    })

    output$table <- render_gt({
        s <- input$statePicker
        h <- input$horizon

        f1 <- read_rds(paste0("f1-", s, ".rds"))
        f3 <- read_rds(paste0("f3-", s, ".rds"))
        f6 <- read_rds(paste0("f6-", s, ".rds"))
        f12 <- read_rds(paste0("f12-", s, ".rds"))

        original_data <- malaria2 %>%
            rename(cases_pred = casos) %>%
            filter_index("2019-01" ~ "2019-12") %>%
            filter(uf == s)


        if (h == 1) {
            f1 %>% tabledata(original_data) %>% tabler()
        } else if (h == 3) {
            f3 %>% tabledata(original_data) %>% tabler()
        } else if (h == 6) {
            f6 %>% tabledata(original_data) %>% tabler()
        } else if (h == 12) {
            f12 %>% tabledata(original_data) %>% tabler()
        } else {
            "Erro"
        }

    })
}

# Run the application
shinyApp(ui = ui, server = server)
