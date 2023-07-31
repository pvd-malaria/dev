suppressPackageStartupMessages({
  library(rsconnect)
  library(shiny)
  library(shinydashboard)
  library(dplyr)
  library(data.table)
  library(tidyr)
  library(forcats)
  library(stringr)
  library(plotly)
  library(sf)
  library(leaflet)
  library(tmaptools)
  library(viridisLite)
  library(htmltools)
})

# some_data ------------------------------------------------------------
suppressMessages({
  municipios <- st_read('municipios_limite.gpkg', as_tibble = T, quiet = T)
  flows <- fread("flows.csv") %>%
    filter(fluxos > 10)
})

munic_select <-
  municipios %>%
  st_drop_geometry() %>%
  mutate(cod6 = as.double(substr(code_muni, 1, 6))) %>%
  filter(cod6 %in% flows$destino,
         code_state %in% c(11:17, 21, 51)) %>%
  unite(name, name_muni, abbrev_state, sep = " - ") %>%
  pull(name) %>%
  fct_drop()

ano_select <- flows %>% pull(ano) %>% unique() %>% sort()

rm(municipios, flows);gc()

# ui definition ------------------------------------------------------------
header <- dashboardHeader(
  title = textOutput('dashboard_header_title'),
  tags$li(
    class = "dropdown",
    tags$li(
      class = "dropdown",
      actionLink("language", textOutput("lang"))
    )
  )
)

sidebar <- dashboardSidebar(

  sidebarMenu(

    menuItem(
      text = textOutput('importados_text'),
      tabName = 'importados',
      icon = icon('sync-alt')
    ),

    menuItem(
      selectInput(
        inputId = 'municipio',
        label = textOutput('municipio_label'),
        selected = 'Manaus - AM',
        choices = munic_select
      )
    ),

    menuItem(
      sliderInput(
        inputId = 'ano',
        label =  textOutput("ano_label"),
        min = min(ano_select),
        max = max(ano_select),
        value = 2019L,
        step = 1,
        sep = '',
        ticks = FALSE
      )
    ),

    menuItem(uiOutput('var_select'))
  )
)

body <- dashboardBody(

  fluidRow(
        valueBoxOutput('caso_total'),
        valueBoxOutput('caso_auto'),
        valueBoxOutput('caso_imp')
  ),

  fluidRow(
    box(
      title = textOutput('map_box_title'),
      status = 'primary',
      width = 4,
      leafletOutput('map')
    ),
    box(
      title = textOutput('var_box_title'),
      status = 'warning',
      width = 8,
      plotlyOutput('plot')
    )
  ),
  fluidRow(
    box(
      background = "red",
      width = 12,
      textOutput('fonte_label', h4)
    )
  )
)

ui <- dashboardPage(header, sidebar, body, skin = 'red')
