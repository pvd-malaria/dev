#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

suppressPackageStartupMessages({
  library(rsconnect)
  library(shiny)
  library(shinythemes)
  library(shinyBS)
  library(rCharts)
  library(shinyWidgets)
  library(shinydashboard)
  library(tidyverse)
  library(plotly)
  library(leaflet)
  library(sf)
  library(tmap)
  library(rintrojs)
  library(heatmaply)
  library(ggplot2)
  library(tmaptools)
  library(classInt)
  library(shinyjs)
})

#setwd('/home/nat/Documents/3.1 Malaria - PCA - Dashboard/PCA_app/PCA')

# data ------------------------------------------------------------
suppressMessages({
  municipios <- st_read('municipios_limite.gpkg', as_tibble = T, quiet = T)
  indicadores <- read.csv("Incidencia.csv", fileEncoding="UTF-8")
  loadings_vivax <- read.csv("Loadings_vivax.csv", fileEncoding="UTF-8")
  loadings_falciparum <- read.csv("Loadings_falciparum.csv", fileEncoding="UTF-8")
  cases <- read.csv("cases.csv", fileEncoding="UTF-8")
  scores <- read.csv('scores_total.csv')
  loadings_vivax$TipoPlasm <- 'Vivax'
  loadings_falciparum$TipoPlasm <- "Falciparum"
  loadings_total <- rbind(loadings_vivax,loadings_falciparum)
  loadings_total$TipoPlasm <- as.factor(loadings_total$TipoPlasm)
})

ano_select <- indicadores %>% pull(year_notif) %>% unique() %>% sort()

#### Vivax 
ano_loadingVivax <- loadings_vivax %>% pull(year_notif) %>% unique() %>% sort()
tipo_loadingVivax <- loadings_vivax %>% pull(TiposVar) %>% unique() %>% sort()
risco_loadingVivax <- loadings_vivax %>% pull(Risco) %>% unique() %>% sort()

#### Falciparum
ano_loadingFalc <- loadings_falciparum %>% pull(year_notif) %>% unique() %>% sort()
tipo_loadingFalc <- loadings_falciparum %>% pull(TiposVar) %>% unique() %>% sort()
risco_loadingFalc <- loadings_falciparum %>% pull(Risco) %>% unique() %>% sort()

#### Score
ano_scores <- scores %>% pull(Ano) %>% unique() %>% sort()
tipo_scores <- scores %>% pull(Tipo_Var) %>% unique() %>% sort()
risco_scores <- scores %>% pull(Risco) %>% unique() %>% sort()
PC_scores <- scores %>% pull(PC) %>% unique() %>% sort()
tipo_plasm <- scores %>% pull(Tipo_Plasm) %>% unique() %>% sort()

# munge -----------------------------------------------------------------------
# general
munic_names <- municipios %>%
  st_drop_geometry() %>%
  select(code_muni, name_muni)

# spatial
municipios2 <- municipios %>%
  st_make_valid() %>%
  filter(code_state %in% c(11:17, 21, 51)) %>%
  select(code = code_muni, name = name_muni) %>%
  mutate(cod6 = as.integer(substr(code, 1, 6))) %>%
  select(-code) %>%
  st_transform(crs = 4326)

base_bb <- st_sf(a = 1:2,
                 geom = st_sfc(
                   st_point(c(-1212183.85, 7945639.07)),
                   st_point(c(1850099.70, 10557683.96))),
                 crs = 4326)



server <- shinyServer(function(input, output, session) {
  
  # base map ------------------------------------------------------------------
  # ---------------- Aba MAPA dos riscos
  output$map <- renderLeaflet({
    basemap <-
      municipios2 %>%
      st_make_valid()
    
    leaflet(basemap) %>%
      addProviderTiles(provider = "OpenStreetMap.Mapnik") %>%
      fitBounds(-75, -18, -46, 5)
  })
  
 ### Mapa
  observe({
    year <- input$ano
    
    cases <- indicadores %>% filter(year_notif == year)
    df_all <- inner_join(municipios2, cases, by = c(cod6 = "MUN_INFE"))
    df_all$IPA_class <- ordered(df_all$IPA_class, levels = c("Baixo", "Medio", "Alto"))
  
    
    labels <-
      sprintf("<strong>%s</strong><br/>IPA/mil hab em %s: %s",
              df_all$name, year, round(df_all$IPA,2)) %>%
      lapply(FUN = HTML)
    
    poly_colors <- colorFactor(palette = "Reds", domain = df_all$IPA_class)
    
    leafletProxy("map", data = df_all) %>%
      clearShapes() %>%
      clearControls() %>%
      addPolygons(
        color = toRGB("gray30"),
        weight = 0.5,
        fillColor = ~ poly_colors(IPA_class),
        fillOpacity = 0.8,
        label = ~ labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"),
        highlight = highlightOptions(
          weight = 2,
          color = toRGB("black"),
          fillOpacity = 0.7)
      ) %>%
      addLegend(pal = poly_colors,
                values = ~ IPA_class,
                opacity = 0.7,
                title = "Risco",
                position = "bottomright") %>%
      fitBounds(-75, -18, -46, 5) })
  
 ## ------------- Texto com os casos totais 
  caso_total <- reactive({
    cases %>%
      filter(year_notif == input$ano) %>%
      group_by(year_notif) %>%
      summarise(n = sum(n))
  })
  
  output$casos <- renderText({
    paste0(prettyNum(caso_total()$n, big.mark="."), " casos de malária")
  })
  
 ## ------------------ Ranking gráfico os 10 maiores IPA
  df_ranking <- reactive({
    indicadores$IPA <- round(indicadores$IPA,0)
    indicadores %>%
      filter(year_notif == input$ano) %>%
      arrange(desc(IPA)) %>%
      slice(1:10)
    
  })
  
  output$ranking_alto <- renderPlotly({
                                        plot_ly() %>%
                                        add_trace(type = "bar",
                                        x = df_ranking()$IPA,
                                        y = reorder(df_ranking()$Nome, df_ranking()$IPA),
                                        marker = list(color = "#c92929")) %>% config(displayModeBar = F) %>%
                                        layout(title = list(text = '<b>Top 10 municípios com maior IPA</b>', y = 0.98, font = list(size = 14)))
    
    
  })
  
 ## -------------- Aba variáveis importantes no PCA -----------------------------------
  df_filter <- reactive({
    loadings_vivax$Loadings <- round(loadings_vivax$Loadings, 2)
    loadings_vivax %>% 
            filter(year_notif == input$ano_sele, Risco %in% input$risk) %>%
            filter(TiposVar == input$type)
  })
  
  
  output$heatmap_vivax <- renderPlotly({ 
            
                                  heat <- ggplot(data = df_filter()) +                           
                                          geom_tile(aes(x = PC, 
                                                     y = Var,
                                                     fill = Loadings)) +
                                    scale_fill_continuous() +
                                    xlab("Componentes Principais") +
                                    theme(panel.grid.major = element_blank(), 
                                          panel.grid.minor = element_blank(),
                                          panel.background = element_blank(),
                                          axis.title.y = element_blank()) +
                                    labs(fill="Loadings")
                                  ggplotly(heat)
                 
  
  })
  
  df_filter_falciparum <- reactive({
    loadings_falciparum$Loadings <- round(loadings_falciparum$Loadings, 2)
    loadings_falciparum %>% 
      filter(year_notif == input$ano_sele, Risco %in% input$risk) %>%
      filter(TiposVar == input$type)
  })
  
  output$heatmap_falciparum <- renderPlotly({ 
    
    heat <- ggplot(data = df_filter_falciparum()) +                           
      geom_tile(aes(x = PC, 
                    y = Var,
                    fill = Loadings)) +
      scale_fill_continuous() + 
      xlab("Componentes Principais") +
      theme(panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            axis.title.y = element_blank()
      ) +
      labs(fill="Loadings")
    ggplotly(heat)
  })
  
 ## --------------------------------- Aba Scores -----------------------------------
  
  df_scores_vivax <- reactive({
    scores$Scores <- round(scores$Scores, 2)
    scores %>% 
      filter(Ano %in% input$scores_ano & Risco %in% input$scores_risco) %>%
      filter(Tipo_Var %in% input$type_scores & PC %in% input$CP_scores) %>%
      filter(Tipo_Plasm %in% input$plasmodium)
  })
  
  df_filter_scores <- reactive({
    loadings_total$Loadings <- round(loadings_total$Loadings, 2)
    loadings_total %>% 
    filter(Loadings >= 0.25 | Loadings <= -0.25) %>%
    filter(year_notif == input$scores_ano, Risco %in% input$scores_risco) %>%
    filter(TiposVar == input$type_scores, PC %in% input$CP_scores) %>%
    filter(TipoPlasm == input$plasmodium)
    
    loadings_total <- rename(loadings_total, Variável = Var)
  })
  
  output$table <- DT::renderDataTable({
    DT::datatable(
      
      df_filter_scores()[c('Variável','Loadings')]
      
  )
    })
  
  observeEvent("", {
    showModal(modalDialog(
      includeHTML("text_popup.html"),
      easyClose = TRUE
    ))
  })
#----------------------- Mapa Scores -------
  # spatial
  municipios3 <- municipios2 %>%
    st_transform(29101) %>% 
    st_make_valid() %>%
    st_centroid() %>% 
    st_transform(crs = 4326)

  output$map_score <- renderLeaflet({
    basemap <-
      municipios3 %>%
      st_make_valid()
    
    leaflet(basemap) %>%
      addProviderTiles(provider = "OpenStreetMap.Mapnik") %>%
      fitBounds(-75, -18, -46, 5)
  })
  
  
  observe({
   
    df_all <- inner_join(municipios3, df_scores_vivax(), by = c(cod6 = "Mun"))
    df_all$Risco <- ordered(df_all$Risco, levels = c("Baixo", "Médio", "Alto"))
    
    
     labels <-
       sprintf("<strong>%s</strong><br/>Score: %s",
               df_all$name, df_all$Scores) %>%
       lapply(FUN = HTML)

    int <- c(-12, -2, 0, 4, Inf)
    
    poly_colors <- colorBin(palette = "YlOrRd", bin = int)
    
    leafletProxy("map_score", data = df_all) %>%
      clearShapes() %>%
      clearControls() %>%
      addCircles(radius = 50000,
        color = ~poly_colors(Scores),
        label = ~ labels,
        fill = TRUE,
        fillOpacity = 1,
        weight = 1,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
      ) %>%
      addLegend(pal = poly_colors,
                values = ~ Scores ,
                opacity = 0.7,
                title = "Scores",
                position = "bottomright") %>%
      fitBounds(-75, -18, -46, 5) })

 })





# ----------------------- UI --------------------------
ui <- bootstrapPage(
             navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
             HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">Análise por Município - Risco de Malária</a>'), id="nav",
             windowTitle = "Risco de Malária",
#-------------------------------- ui - aba Mapa de incidência -----------------------------------------------
             tabPanel("Mapa de Incidência Parasitária",
                      div(class="outer",
                          tags$head(includeCSS("styles.css")),
                          leafletOutput('map',width="100%", height="100%"),
                        
                          absolutePanel(id = "controls", class = "panel panel-default",
                                        top = 180, left = 55, width = 400, fixed=TRUE,
                                        draggable = TRUE, height = "auto",
                                        
                                        span(tags$i(h6("Índice Parasitário Anual - IPA/mil habitantes")), 
                                             style="color:#045a8d"),
                                        span(tags$i(h6("Escolha o ano para ver no mapa a classificação de risco de malária nos municípios da Amazônia Legal")), 
                                             style="color:#045a8d"),
                                        h3(textOutput("casos"), align = "right"),
                                                 selectizeInput(
                                                   inputId = 'ano',
                                                   label = 'Ano: ',
                                                   selected = 2019,
                                                   choices = ano_select
                                                 )),
                          
                          absolutePanel(id = "controls", class = "panel panel-default",
                                        top = 600, left = 55, width = 400, fixed=TRUE,
                                        draggable = TRUE, height = 400,
                                        
                                        plotlyOutput("ranking_alto") 
                        )
                        
                      
                      
             )),
 # ----------------------------------- ui - aba Variáveis importantes no PCA -----------------------------------            
             tabPanel("Variáveis Importantes no PCA",
                      
                      sidebarLayout(
                        sidebarPanel(
                          
                          span(tags$i(h6("Carga Vetorial (Loadings) das variáveis por Componente Principal")), style="color:#045a8d"),
                          span(tags$i(h6("Selecione o tipo de Plasmodium na aba em cima do mapa de calor")), style="color:#045a8d"),
                          
                          span(tags$i(h6("Selecione o ano (2011 - 2019)")), style="color:#045a8d"),
                          selectInput(
                            inputId = 'ano_sele',
                            label = 'Ano: ',
                            selected = 2019,
                            choices = ano_loadingVivax
                          ),
                          
                          span(tags$i(h6("Selecione o tipo de grupos de variáveis (Socioeconômicas e Demográficas ou Ambiental e Saúde)")), style="color:#045a8d"),
                          selectInput(
                            inputId = 'type',
                            label = 'Tipo: ',
                            selected = 'Ambiental e Saúde',
                            choices = tipo_loadingVivax
                          ),
                          
                          span(tags$i(h6("Escolha o grupo de municipios pela sua classificação de Risco: Baixo, Médio ou Alto")), style="color:#045a8d"),
                          selectInput(
                            inputId = 'risk',
                            label = 'Risco: ',
                            selected = 'Baixo',
                            choices = risco_loadingVivax
                          ),
                          
                          span(tags$i(h5("A análise de componentes principais (PCA em inglês) é uma técnica usada para enfatizar 
                                          a variação e revelar padrões fortes em um conjunto de dados. 
                                          Geralmente é usado para tornar os dados fáceis de explorar e visualizar.
                                          Loadings (cargas vetoriais): resulta em cargas vetoriais, que são os pesos dados a cada variável 
                                          para cada um dos componentes. Os coeficientes ou cargas vetoriais permitem a interpretação das 
                                          componentes. Os scores (pontuação) representam a distância que cada variável está em relação à média para cada uma das 
                                          componentes principais; scores com valores altos representam que aquela variável está mais próxima do 
                                          máximo descrito pela componente e, com valores baixos, estão mais próximos do mínimo descrito pela mesma componente.", align = "justify"))),
                          
                          
                          
                          span(tags$i(h5("Por exemplo, quando se olha para o mapa de calor ao lado, para o ano de 2019, em relação aos casos de Plasmodium Vivax,
                                          selecionando o grupo de variáveis 'Ambiental e Saúde', nos municípios de Risco Baixo, observa-se, 
                                          para a primeira coluna (PC1 - 1º componente Principal) que a Área Hidrográfica, Nuvem e Negativo para outros 
                                          hemoparasitas pesquisados são positivamente correlacionados com o primeiro componente principal e são os mais 
                                          importantes para explicar o mesmo.", align = "justify")))
                          
                         
                          ),
                        
                        mainPanel(
                          tabsetPanel(
                            tabPanel("Plasmodium Vivax", plotlyOutput("heatmap_vivax")),
                            tabPanel("Plasmodium Falciparum", plotlyOutput("heatmap_falciparum"))
                          
                          )
                        )
                        
                        )
                    ),
  # ----------------------------------- ui - aba Scores -----------------------------------       
          tabPanel("Pontuação (Scores)",
                   
                   sidebarLayout(
                     
                     sidebarPanel(
                       span(tags$i(h6("Selecione o ano (2011 - 2019)")), style="color:#045a8d"),
                       selectInput(
                       inputId = 'scores_ano',
                       label = 'Ano: ',
                       selected = 2019,
                       choices = ano_scores
                     ),
                     span(tags$i(h6("Selecione o tipo de grupos de variáveis (Socioeconômicas e Demográficas ou Ambiental e Saúde)")), style="color:#045a8d"),
                     selectInput(
                       inputId = 'type_scores',
                       label = 'Tipo: ',
                       selected = 'Ambiental e Saúde',
                       choices = tipo_scores
                     ),
                     span(tags$i(h6("Escolha o grupo de municipios pela sua classificação de Risco: Baixo, Médio ou Alto")), 
                          style="color:#045a8d"),
                     selectInput(
                       inputId = 'scores_risco',
                       label = 'Risco: ',
                       selected = 'Baixo',
                       choices = risco_scores
                     ),
                     span(tags$i(h6("Escolha o componente principal: PC1 até o PC5")), style="color:#045a8d"),
                     selectInput(
                       inputId = 'CP_scores',
                       label = 'Componente Principal: ',
                       selected = 'PC1',
                       choices = PC_scores
                     ),
                     span(tags$i(h6("Escolha o tipo de Plasmodium: Vivax ou Falciparum")), style="color:#045a8d"),
                     selectInput(
                       inputId = 'plasmodium',
                       label = 'Plasmodium: ',
                       selected = 'Vivax',
                       choices = tipo_plasm
                     ),
                     
                     span(tags$i(h5("A análise de componentes principais (PCA em inglês) é uma técnica usada para enfatizar 
                                     a variação e revelar padrões fortes em um conjunto de dados e, portanto, é uma maneira de identificar a
                                     relação entre características extraídas de dados.
                                     Geralmente é usado para tornar os dados fáceis de explorar e visualizar.
                                     As pontuações (scores) fornecem a composição  dos componentes principais (PCs)  em  relação  a amostra, no caso um 
                                     agrupamento de municípios dividos por sua classificação de risco, ou seja, através deles pode-se ver a 
                                     contribuição de cada munícipio para a decisão do algoritmo na construção daquele componente principal.", 
                                    align = "justify"))),

                     
                     span(tags$i(h5("Nesta aba, após selecionar todas as características necessárias, do lado direito da tela, irá aparecer 
                                     no mapa, os diferentes scores de cada município dentro do componente principal selecionado,
                                     dado a seleção do ano de notificação, do grupo de variáveis, risco do município e tipo de plasmodium. 
                                     Logo abaixo do mapa, aparecerá os loadings das variáveis que obtiveram acima de 0.25 relacionadas ao 
                                     componente principal selecionado. Assim, é possível analisar as influências das variáveis dentro 
                                     daquele agrupamento de municípios.", align = "justify")))
                     
                     
                     
                       
                     ),
                     
                     mainPanel(leafletOutput("map_score"),
                               DT::dataTableOutput("table"))
                   )
          )
))



shinyApp(ui, server)
