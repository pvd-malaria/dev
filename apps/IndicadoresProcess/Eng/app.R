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
  library(rCharts)
  library(shinydashboard)
  library(tidyverse)
  library(plotly)
  library(sf)
  library(leaflet)
  library(shinyjs)
  library(classInt)
})

#tmaptools::palette_explorer()

make_basemap <- function() {

  leaflet() %>%
    addTiles() %>%
    fitBounds(-75, -10, -48, 5)

}

make_basemapFalc <- function() {

  leaflet() %>%
    addTiles() %>%
    fitBounds(-75, -10, -48, 5)

}

make_basemapVivax <- function() {

  leaflet() %>%
    addTiles() %>%
    fitBounds(-75, -10, -48, 5)

}

update_map <-  function(year, brks = brks_pro_trat) {

  cases <- indicadores %>% filter(year_notif == year)

  int <- brks

  df_all <- inner_join(municipios2, cases, by = c(cod6 = "MUN_INFE"))

  poly_colors <- colorBin(palette = "PRGn", bins = int)

  labels <-
    sprintf("<strong>%s</strong><br/>Proporção pro tratamento %d: %3.2f",
            df_all$name, df_all$year_notif, df_all$pro_tratamento) %>%
    lapply(FUN = HTML)

  leafletProxy("map", data = df_all) %>%
    clearShapes() %>%
    clearControls() %>%
    addPolygons(
      color = toRGB("gray30"),
      weight = 0.5,
      fillColor = ~ poly_colors(pro_tratamento),
      fillOpacity = 0.5,
      label = ~ labels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"),
      highlight = highlightOptions(
        weight = 2,
        color = toRGB("black"),
        fillOpacity = 0.7)) %>%
    addLegend(pal = poly_colors,
              values = ~ pro_tratamento,
              opacity = 0.7,
              title = "%",
              position = "bottomright") %>%
    fitBounds(-75, -10, -48, 5)

}

update_mapFalc <-  function(year, brks = brks_pct_falc) {

  cases <- indicadores %>% filter(year_notif == year)

  int <- brks

  df_all <- inner_join(municipios2, cases, by = c(cod6 = "MUN_INFE"))

  poly_colors <- colorBin(palette = "Set2", bins = int)

  labels <-
    sprintf("<strong>%s</strong><br/>Proporção Falciparum em %d: %3.2f",
            df_all$name, df_all$year_notif, df_all$perc_falciparum) %>%
    lapply(FUN = HTML)

  leafletProxy("map2", data = df_all) %>%
    clearShapes() %>%
    clearControls() %>%
    addPolygons(
      color = toRGB("gray30"),
      weight = 0.5,
      fillColor = ~ poly_colors(perc_falciparum),
      fillOpacity = 0.5,
      label = ~ labels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"),
      highlight = highlightOptions(
        weight = 2,
        color = toRGB("black"),
        fillOpacity = 0.7)) %>%
    addLegend(pal = poly_colors,
              values = ~ perc_falciparum,
              opacity = 0.7,
              title = "%",
              position = "bottomright") %>%
    fitBounds(-75, -10, -48, 5)

}

update_mapVivax <-  function(year, brks = brks_pct_vivax) {

  cases <- df_vivax %>% filter(year_notif == year)

  int <- brks

  df_all <- inner_join(municipios2, cases, by = c(cod6 = "MUN_INFE"))

  poly_colors <- colorBin(palette = "Set2", bins = int)

  labels <-
    sprintf("<strong>%s</strong><br/>Proporção Vivax em %d: %3.2f",
            df_all$name, df_all$year_notif, df_all$perc_vivax) %>%
    lapply(FUN = HTML)

  leafletProxy("map3", data = df_all) %>%
    clearShapes() %>%
    clearControls() %>%
    addPolygons(
      color = toRGB("gray30"),
      weight = 0.5,
      fillColor = ~ poly_colors(perc_vivax),
      fillOpacity = 0.5,
      label = ~ labels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"),
      highlight = highlightOptions(
        weight = 2,
        color = toRGB("black"),
        fillOpacity = 0.7)) %>%
    addLegend(pal = poly_colors,
              values = ~ perc_vivax,
              opacity = 0.7,
              title = "%",
              position = "bottomright") %>%
    fitBounds(-75, -10, -48, 5)

}
# map data ------------------------------------------------------------------------
municipios <- st_read('municipios_limite.gpkg', as_tibble = T, quiet = T)

# some_data ------------------------------------------------------------
options(readr.default_locale = locale(encoding = "latin1"))

suppressMessages({
  municipios <- st_read('municipios_limite.gpkg', as_tibble = T, quiet = T)
  indicadores <- read_delim ("Dataset_IndicadorProcesso.csv", delim = " ", escape_backslash = T)
  indicadores_uf <- read_delim ("Dataset_IndicadorProcesso_uf.csv", delim = " ", escape_backslash = T)
  df_vivax <- read_delim("Dataset_PercVivax.csv", delim = " ", escape_backslash = T)
  df_vivax_uf<- read_delim("Dataset_PercVivax_uf.csv", delim = " ", escape_backslash = T)

  indicadores_uf$pro_tratamento <- as.numeric(indicadores_uf$pro_tratamento, digits = 2)
  indicadores$pro_tratamento <- as.numeric(format(indicadores$pro_tratamento*100, digits = 2))

  indicadores_uf$perc_falciparum <- as.numeric(indicadores_uf$perc_falciparum, digits = 2)
  indicadores$perc_falciparum <- as.numeric(format(indicadores$perc_falciparum*100, digits = 2))

  df_vivax_uf$perc_vivax <- as.numeric(df_vivax_uf$perc_vivax, digits = 2)
  df_vivax$perc_vivax <- as.numeric(format(df_vivax$perc_vivax*100, digits = 2))
})

ano_select <- indicadores %>% pull(year_notif) %>% unique() %>% sort()

# munge -----------------------------------------------------------------------
# general
munic_names <- municipios %>%
  st_drop_geometry() %>%
  select(code_muni, name_muni)

# breaks for map classes
brks_pro_trat <- classIntervals(indicadores$pro_tratamento, n = 5, style = "fisher")$brks
brks_pct_falc <- classIntervals(indicadores$perc_falciparum, n = 5, style = "fisher")$brks
brks_pct_vivax <- classIntervals(df_vivax$perc_vivax, n = 5, style = "fisher")$brks

# spatial
municipios2 <- municipios %>%
  st_make_valid() %>%
  filter(code_state %in% c(11:17, 21, 51)) %>%
  select(code = code_muni, name = name_muni) %>%
  mutate(cod6 = as.integer(substr(code, 1, 6))) %>%
  select(-code) %>%
  st_transform(crs = 4326)


# server ----------------------------------------------------------------------
server <- shinyServer(function(input, output, session) {

  # base map ------------------------------------------------------------------
  year <- 2007

  output$map <- renderLeaflet({make_basemap()})
  output$map2 <- renderLeaflet({make_basemapFalc()})
  output$map3 <- renderLeaflet({make_basemapVivax()})

  # map -----------------------------------------------------------------------
  observe({
    year <- input$ano
    update_map(year)
  })

  observe({
    year <- input$ano
    update_mapFalc(year)
  })

  observe({
    year <- input$ano
    update_mapVivax(year)
  })


  output$plot <- renderChart({

    pt1 <- nPlot(y = 'pro_tratamento', x = 'year_notif', group = 'uf', data =  indicadores_uf ,
                 type = 'lineChart')
    pt1$chart(useInteractiveGuideline=TRUE, margin = list(left = 100, right = 100))
    pt1$addParams(dom = 'plot')
    pt1$xAxis(tickValues = indicadores_uf$year_notif)
    pt1$yAxis(tickFormat = "#!d3.format('%')!#",
              axisLabel = "")
    return(pt1)
  })

  output$plotFalcip <- renderChart({

    pt2 <- nPlot(y = 'perc_falciparum', x = 'year_notif', group = 'uf', data =  indicadores_uf ,
                 type = 'lineChart')
    pt2$chart(useInteractiveGuideline=TRUE, margin = list(left = 100, right = 100))
    pt2$addParams(dom = 'plotFalcip')
    pt2$xAxis(tickValues = indicadores_uf$year_notif)
    pt2$yAxis(tickFormat = "#!d3.format('%')!#",
              axisLabel = "")
    return(pt2)
  })

  output$plotVivax <- renderChart({

    pt3 <- nPlot(y = 'perc_vivax', x = 'year_notif', group = 'uf', data =  df_vivax_uf ,
                 type = 'lineChart')
    pt3$chart(useInteractiveGuideline=TRUE, margin = list(left = 100, right = 100))
    pt3$addParams(dom = 'plotVivax')
    pt3$xAxis(tickValues = df_vivax_uf$year_notif)
    pt3$yAxis(tickFormat = "#!d3.format('%')!#",
              axisLabel = "")
    return(pt3)
  })

})


# ui definition ------------------------------------------------------------

header <- dashboardHeader(title = "Malaria")

sidebar <- dashboardSidebar(

  sidebarMenu(
    width = 4,
    menuItem(
      text = "Treatment",
      tabName = 'tratamento'
    ),
    menuItem(text = "Proportion of Malaria Falciparum",
             tabName = 'falciparum'),

    menuItem(text = "Proportion of Malaria Vivax",
             tabName = 'vivax'),

    menuItem(
      sliderInput(
        inputId = 'ano',
        label =  "Ano: ",
        min = 2007,
        max = 2019,
        value = 2007,
        sep = '',
        ticks = FALSE
      )
    )

  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = 'tratamento',
            h2(

              fluidRow(
                box(
                  title = "Map by municipality",
                  status = 'primary',
                  width = 6,
                  leafletOutput('map')
                ),

                box(
                  title = "Comparative by State*",
                  status = 'danger',
                  width = 6,
                  showOutput("plot","nvd3"),
                  footer = HTML('*Proportion of cases that started treatment within 48 hours of symptoms onset
                                in relation to the total number of cases')
                  )),

              fluidRow(
                box(
                  title = 'Fonte',
                  status = 'danger',
                  width = 12,
                  h4(
                    paste0(
                      "Sistema de Informações de Vigilância Epidemiológica ",
                      "da Malária, - SIVEP Malária, Ministério da Saúde.")
                  )
                )
              )
                )),

    tabItem(tabName = 'falciparum',
            h2(
              fluidRow(
                box(
                  title = "Map by municipality",
                  status = 'primary',
                  width = 6,
                  leafletOutput('map2')
                ),

                box(
                  title = "Comparative by State*",
                  status = 'danger',
                  width = 6,
                  showOutput("plotFalcip","nvd3"),
                  footer = HTML('*Percentage of cases by Malaria Plasmodium Falciparum')
                )),

              fluidRow(
                box(
                  title = 'Fonte',
                  status = 'danger',
                  width = 12,
                  h4(
                    paste0(
                      "Sistema de Informações de Vigilância Epidemiológica ",
                      "da Malária, - SIVEP Malária, Ministério da Saúde.")
                  )
                )
              ))),

    tabItem(tabName = 'vivax',
            h2(
              fluidRow(
                box(
                  title = "Map by municipality",
                  status = 'primary',
                  width = 6,
                  leafletOutput('map3')
                ),

                box(
                  title = "Comparative by State*",
                  status = 'danger',
                  width = 6,
                  showOutput("plotVivax","nvd3"),
                  footer = HTML('*Percentage of cases by Malaria Plasmodium Vivax')
                )),

              fluidRow(
                box(
                  title = 'Fonte',
                  status = 'danger',
                  width = 12,
                  h4(
                    paste0(
                      "Sistema de Informações de Vigilância Epidemiológica ",
                      "da Malária, - SIVEP Malária, Ministério da Saúde.")
                  )
                )
              )))
    )
  )


ui <- dashboardPage(header, sidebar, body, skin = 'red')


shinyApp(ui, server)




