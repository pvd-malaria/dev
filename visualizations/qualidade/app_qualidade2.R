# Libraries:
library(tidyverse)
library(shiny)
library(ggdark)
library(scales)


viz <- readxl::read_excel("qualidade.xlsx") %>%
    janitor::clean_names() # column names to lowercase

summary(viz)

server <- shinyServer(function(input, output) {

    output$p <- renderPlot({
        viz %>%
            filter(descricao %in% input$descricao) %>%
            ggplot(aes(x = ano)) +
            geom_point(
                aes(y = missing),
                color = "magenta3",
                size = 3,
                group = 1,
                shape = 19
            ) +
            geom_line(
                aes(y = missing),
                color = "magenta3",
                size = 1,
                group = 1,
                linetype = 1
            ) +
            facet_wrap( ~ uf) +
            theme_gray() +
            scale_x_continuous(breaks = scales::breaks_width(1)) +
            coord_cartesian(ylim = c(0, 1)) +
            labs(x = "Ano",
                 y = "% de informações ausentes") +
            labs(caption = "Fonte: SIVEP Malaria, 2007-2019") +
            dark_theme_gray()
    })

    output$uf <- renderText({
        df <- nearPoints(
            df = viz %>% filter(descricao %in% input$descricao),
            coordinfo = input$plot_hover,
            panelvar1 = 'uf',
            maxpoints = 1
        )

        paste("UF:", df$uf)
    })

    output$ano <- renderText({
        df <- nearPoints(
            df = viz %>% filter(descricao %in% input$descricao),
            coordinfo = input$plot_hover,
            panelvar1 = 'uf',
            maxpoints = 1
        )

        paste("Ano:", df$ano)
    })

    output$miss <- renderText({
        df <- nearPoints(
            df = viz %>% filter(descricao %in% input$descricao),
            coordinfo = input$plot_hover,
            panelvar1 = 'uf',
            maxpoints = 1
        )

        paste("Missing:", percent(df$missing))
    })
})


# UI ----------------------------------------------------------------------
ui <- fluidPage(
    headerPanel(
        h2(paste0("Porcentagem de informações ausentes segundo variável ",
                  "do SIVEP e UF, 2007-2019"))
    ),

    sidebarPanel(
        fluidRow(
            selectInput(
                inputId = "descricao",
                label = "Variável",
                choices = unique(viz$descricao),
                selected = "Código do agente que realizou a notificação"
            ),
        ),
        fluidRow(
            wellPanel(
                textOutput('uf'),
                textOutput('ano'),
                textOutput('miss')
            )
        )
    ),
    mainPanel(
        plotOutput(outputId = "p", hover = 'plot_hover')
    )

)

shinyApp(ui = ui, server = server)
