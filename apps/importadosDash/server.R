# funs ------------------------------------------------------------------------
get_mun_code <- function(x) {
  stopifnot(is.character(x) | is.factor(x))
  y <- filter(munic_names, name == x) %>%
    pull(code_muni) %>%
    substr(1, 6) %>%
    as.double()
  if (length(y) == 0) {
    return("Município não encontrado")
  } else {
    y
  }
}

idade_plotly <- function(code, year, lang = "pt") {
  idade %>%
    mutate(age2 = fct_relevel(age2, '5 a 9 anos', after = 1L)) %>%
    filter(ano == year, mun == code, !is.na(group)) %>%
    plot_ly(y = ~ age2, x = ~ p, color = ~ group,
            colors = cividis(2), showlegend = F) %>%
    add_bars(hovertemplate = ifelse(lang == "en", "Cases: %{x} <br> Age: %{y}",
                                    "Casos: %{x} <br> Idade: %{y}")) %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang != "pt", "Age", "Idade")),
           xaxis = list(title = ifelse(lang != "pt", "Cases", "Casos"),
                        tickformat = '%'),
           yaxis = list(title = ifelse(lang != "pt", "Age group", "Grupo etário")))
}

sexo_plotly <- function(code, year, lang = "pt") {
  sexo %>%
    filter(ano == year, mun == code, sexo != 'Ignorado', !is.na(group)) %>%
    plot_ly(y = ~ sexo, x = ~ p, color = ~ group,
            colors = cividis(2), showlegend = F) %>%
    add_bars(hovertemplate = ifelse(lang == "en", "Cases: %{x} <br>Sexo: %{y}",
                                    "Casos: %{x} <br>Sexo: %{y}")) %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang == "en", "Sex", "Sexo")),
           xaxis = list(title = ifelse(lang == "en", "Cases", "Casos"),
                        tickformat = '%'),
           yaxis = list(title = ifelse(lang == "en", "Sex", "Sexo")))
}

raca_plotly <- function(code, year, lang = "pt") {
  raca %>%
    filter(ano == year, mun == code, !is.na(group)) %>%
    plot_ly(y = ~ fct_reorder(raca, p), x = ~ p, showlegend = F,
            color = ~ group, colors = cividis(2)) %>%
    add_bars(hovertemplate = ifelse(lang == "en", "Casos %{x} <br>Raça: %{y}",
                                    "Casos: %{x} <br>Raça: %{y}")) %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang == "en", "Race", 'Raça/Cor')),
           xaxis = list(title = ifelse(lang == "en", "Cases", 'Casos'),
                        tickformat = '%'),
           yaxis = list(title = ifelse(lang == "en", "Race", 'Raça')))
}

educ_plotly <- function(code, year, lang = "pt") {
  educ %>%
    filter(mun == code, ano == year) %>%
    plot_ly(y = ~educ, x = ~p, color = ~group,
            colors = cividis(2), showlegend = F) %>%
    add_bars() %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang == "en", "Education", "Educação")),
           yaxis = list(title = ifelse(lang == "en", "Level", "Nível"),
                        tickformat = '%'),
           xaxis = list(title = ifelse(lang == "en", "Proportion", "Proporção")))
}

ocup_plotly <- function(code, year, lang = "pt") {
  ocup %>%
    filter(ano == year, mun == code, !is.na(group)) %>%
    plot_ly(y = ~ fct_reorder(ocup, p, .desc = F), x = ~ p,
            color = ~ group, colors = cividis(2), showlegend = F) %>%
    add_bars() %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang == "en", "Occupation", "Ocupação")),
           xaxis = list(title = ifelse(lang == "en", "Cases", "Casos"),
                        tickformat = "%"),
           yaxis = list(title = ifelse(lang == "en", "Occupation type", "Categoria ocupacional")))
}

mes_plotly <- function(code, year, lang = "pt") {
  mes %>%
    mutate(mes = ordered(mes, levels = c('jan', 'fev', 'mar', 'abr', 'mai',
                                         'jun', 'jul', 'ago', 'set', 'out',
                                         'nov', 'dez'))) %>%
    filter(ano == year, mun == code, !is.na(group)) %>%
    plot_ly(x = ~ mes, y = ~ n,
            color = ~ group,
            colors = cividis(2),
            type = 'scatter',
            mode = 'lines+markers',
            showlegend = F,
            hovertemplate = ifelse(lang == "en", "Month: %{x}<br>Cases: %{y}",
                                   'Mês: %{x}<br>Casos: %{y}')) %>%
    layout(xaxis = list(title = ifelse(lang == "en", "Notification month", "Mês da notificação")),
           yaxis = list(title = ifelse(lang == "en", "Cases", "Casos")),
           title = list(text = ifelse(lang == "en", "Month", 'Mês')))
}
tipm_plotly <- function(code, year, lang = "pt") {
  tipm %>%
    filter(ano == year, mun == code, !is.na(group)) %>%
    plot_ly(y = ~ fct_reorder(tipo_pl, p), x = ~ p, showlegend = F,
            color = ~ group, colors = viridisLite::cividis(2)) %>%
    add_bars(hovertemplate = ifelse(lang == "en", "Cases: %{x} <br>Type: %{y}",
                                    "Casos: %{x} <br>Tipo: %{y}")) %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang == "en", "Plasmodium species", 'Tipo de Plasmódio')),
           xaxis = list(title = ifelse(lang == "en", "Cases", "Casos"),
                        tickformat = "%"),
           yaxis = list(title = ifelse(lang == "en", "Infection type", "Tipo de infecção")))
}
qtdp_plotly <- function(code, year, lang = "pt") {
  qtdp %>%
    mutate(qtdp = ordered(
      qtdp, levels = c('<200', '200-300', '300-500', '500-10k', '10k-100k',
                       '>100k'))) %>%
    filter(ano == year, mun == code, !is.na(group)) %>%
    plot_ly(y = ~ qtdp, x = ~ p,
            color = ~ group,
            colors = cividis(2),
            showlegend = F,
            hovertemplate = ifelse(lang == "en", 'Cases: %{x}<br>Count: %{y}',
                                   'Casos: %{x}<br>Qtd.: %{y}')) %>%
    add_bars() %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang == "en", "Parasite count",
                                      'Quantidade de Parasitos')),
           xaxis = list(title = ifelse(lang == "en", "Cases", "Casos"),
                        tickformat = "%"),
           yaxis = list(title = ifelse(lang == "en", "Parasites/mm³",
                                       "Parasitos/mm³")))
}
esqm_plotly <- function(code, year, lang = "pt") {
  esqm %>%
    filter(ano == year, mun == code, !is.na(group)) %>%
    plot_ly(y = ~ fct_reorder(esq, p) , x = ~ p, showlegend = F,
            color = ~ group, colors = viridisLite::cividis(2)) %>%
    add_bars(hovertemplate = "Casos: %{x} <br>Tipo: %{y}") %>%
    layout(barmode = 'dodge',
           title = list(text = ifelse(lang == "en", "Treatment regimen",
                                      'Esquema de tratamento')),
           xaxis = list(title = ifelse(lang == "en", "Cases", "Casos"),
                        tickformat = "%"),
           yaxis = list(title = ifelse(lang == "en", "Regimen", "Esquema"),
                        tickfont = list(size = 8)),
           margin = list(l = 300))
}

# data ------------------------------------------------------------------------
# spatial
municipios <- st_read('municipios_limite.gpkg', as_tibble = T, quiet = T)
paises <- st_read("07_paises_positivos_sivep.gpkg", as_tibble = T, quiet = T)

# sivep data
suppressMessages({
  flows <- fread("flows.csv", encoding = "UTF-8", dec = ",")
  cases <- fread("09_cases_data.csv", encoding = "UTF-8")
  idade <- fread("09_idade_data.csv", encoding = "UTF-8", dec = ",")
  sexo  <- fread("09_sexo_data.csv", encoding = "UTF-8", dec = ",")
  raca  <- fread("09_raca_data.csv", encoding = "UTF-8", dec = ",")
  educ  <- fread("09_educ_data.csv", encoding = "UTF-8", dec = ",")
  ocup  <- fread("09_ocup_data.csv", encoding = "UTF-8", dec = ",")
  mes   <- fread("09_mes_data.csv", encoding = "UTF-8", dec = ",")
  tipm  <- fread("09_tipm_data.csv", encoding = "UTF-8", dec = ",")
  qtdp  <- fread("09_qtdp_data.csv", encoding = "UTF-8", dec = ",")
  esqm  <- fread("09_esqm_data.csv", encoding = "UTF-8", dec = ",")
})

# munge -----------------------------------------------------------------------
# general
munic_names <- municipios %>%
  st_drop_geometry() %>%
  unite(name, name_muni, abbrev_state, sep = " - ") %>%
  select(code_muni, name)

# spatial↔
municipios2 <- municipios %>%
  st_make_valid() %>%
  filter(code_state %in% c(11:17, 21, 51)) %>%
  select(code = code_muni, name = name_muni) %>%
  mutate(cod6 = as.integer(substr(code, 1, 6))) %>%
  select(-code) %>%
  st_transform(crs = 4326)

paises2 <- paises %>%
  filter(paises != "Burundi") %>%
  st_make_valid() %>%
  select(-iso_a2, cod6 = codigos, name = paises) %>%
  st_transform(crs = 4326)

base_bb <- st_sf(a = 1:2,
                 geom = st_sfc(
                   st_point(c(-1212183.85, 7945639.07)),
                   st_point(c(1850099.70, 10557683.96))),
                 crs = 4326)

x <- c(
  "Analfabeto",
  "1ª a 4ª série incompleta do EF",
  "4ª série completa do EF",
  "5ª a 8ª série incompleta do EF",
  "Ensino fundamental completo",
  "Ensino médio incompleto",
  "Ensino médio completo",
  "Educação superior incompleto",
  "Educação superior completa",
  "(Missing)"
)

educ <- educ %>% mutate(educ = factor(educ, x))

# server ----------------------------------------------------------------------

server <- function(input, output, session) {

  # Language button ---------------------------------------------------------
  click_lang <- reactiveVal(FALSE)

  observeEvent(input$language, {
    click_lang(ifelse(click_lang(), FALSE, TRUE))
  })

  output$lang <- renderText({
    if (click_lang()) return("English")
    return("Português")
  })

  output$dashboard_header_title <- renderText({
    if (click_lang()) return("Malaria") # retorne em inglês
    return("Malária")  # retorne em português
  })
  output$importados_text <- renderText({
    if (click_lang()) return("Imported") # retorne em inglês
    return("Importados")  # retorne em português
  })

  output$municipio_label <- renderText({
    if (click_lang()) return("County: ") # retorne em inglês
    return("Município: ")  # retorne em português
  })
  output$ano_label <- renderText({
    if (click_lang()) return("Year: ") # retorne em inglês
    return("Ano: ")  # retorne em português
  })
  output$variavel_label <- renderText({
    if (click_lang()) return("Variable: ") # retorne em inglês
    return("Variável: ")  # retorne em português
  })
  output$map_box_title <- renderText({
    if (click_lang()) return("Map") # retorne em inglês
    return("Mapa")  # retorne em português
  })
  output$var_box_title <- renderText({
    if (click_lang()) return("Variable") # retorne em inglês
    return("Variável")  # retorne em português
  })

  output$fonte_label <- renderText({
    if (click_lang()) return("Source: Malaria Epidemiological Surveillance System (SIVEP - Malaria), Brazilian Health Ministry.") # retorne em inglês
    return("Fonte: Sistema de Vigilância Epidemiológica da Malária (SIVEP - Malária), Ministério da Saúde.")  # retorne em português
  })

  output$var_select <- renderUI({
    choices_en = c('Age', 'Sex', 'Race', 'Education',
                   'Occupation', 'Month', 'Infection Type',
                   'Parasite Count', 'Treatment')
    choices_pt = c('Idade', 'Sexo', 'Raça', 'Educação',
                   'Ocupação', 'Mês', 'Tipo de infecção',
                   'Qtd. de Parasitas', 'Tratamento')

    selectInput(
      inputId = 'variavel',
      label = ifelse(click_lang(), "Variable", "Variável"),
      choices =
        if (click_lang()) {
          choices_en
        } else {
          choices_pt
        },
      selected = ifelse(click_lang(), "Age", "Idade")
    )
  })

  # value boxes ---------------------------------------------------------------
  output$caso_total <- renderValueBox({
    n_casos <- cases %>%
      filter(src == get_mun_code(input$municipio),
             ano == input$ano,
             group == 'Total') %>%
      pull(casos)
    label <- ifelse(click_lang(), "Cases", "Casos")
    valueBox(n_casos, label, color = 'red', icon = icon('plus-square'))
  })

  output$caso_auto <- renderValueBox({
    n_casos <- cases %>%
      filter(src == get_mun_code(input$municipio),
             ano == input$ano,
             group == 'Autóctone') %>%
      pull(casos)
    label <- ifelse(click_lang(), "Autochthonous", "Autóctones")
    valueBox(n_casos, label, color = 'navy', icon = icon('plus-square'))
  })

  output$caso_imp <- renderValueBox({
    n_casos <- cases %>%
      filter(src == get_mun_code(input$municipio),
             ano == input$ano,
             group == 'Importado') %>%
      pull(casos)
    label <- ifelse(click_lang(), "Imported", "Importados")
    valueBox(n_casos, label, color = 'yellow', icon = icon('plus-square'))
  })

  # base map ------------------------------------------------------------------
  output$map <- renderLeaflet({
    basemap <-
      rbind(municipios2, paises2) %>%
      st_make_valid()

    leaflet(basemap) %>%
      addProviderTiles(provider = "OpenStreetMap.Mapnik") %>%
      fitBounds(-75, -18, -46, 5)
  })

  # update map --------------------------------------------------------------
  observe({
    year <- input$ano
    code <- get_mun_code(input$municipio)
    lang <- ifelse(click_lang(), "en", "pt")

    cases <- flows %>% filter(destino == code, ano == year)
    fluxos <- flows %>% filter(destino == code) %>% pull(fluxos)
    int <- c(0, 10, 50, 100, 500, 1000, Inf)

    m1 <- inner_join(municipios2, cases, by = c(cod6 = "origem"))
    m2 <- inner_join(paises2, cases, by = c(cod6 = "origem"))
    sp_cases <- rbind(m1, m2)

    poly_colors <- colorBin(palette = "YlOrRd", bins = int)

    labels <-
      sprintf("<strong>%s</strong><br/>Casos em %d: %d",
              sp_cases$name, year, sp_cases$fluxos) %>%
      lapply(FUN = HTML)

    leafletProxy("map", data = sp_cases) %>%
      clearShapes() %>%
      clearControls() %>%
      addPolygons(
        color = toRGB("gray30"),
        weight = 0.5,
        fillColor = ~ poly_colors(fluxos),
        fillOpacity = 0.5,
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
                  values = ~ fluxos,
                  opacity = 0.7,
                  title = "Casos",
                  position = "bottomright") %>%
        fitBounds(-75, -18, -46, 5)

    plottest <- reactive({
      if ('Idade'             %in% input$variavel) return(idade_plotly(code, year, lang))
      if ('Age'               %in% input$variavel) return(idade_plotly(code, year, lang))
      if ('Sexo'              %in% input$variavel) return(sexo_plotly(code, year, lang))
      if ('Sex'               %in% input$variavel) return(sexo_plotly(code, year, lang))
      if ('Raça'              %in% input$variavel) return(raca_plotly(code, year, lang))
      if ('Race'              %in% input$variavel) return(raca_plotly(code, year, lang))
      if ('Educação'          %in% input$variavel) return(educ_plotly(code, year, lang))
      if ('Education'         %in% input$variavel) return(educ_plotly(code, year, lang))
      if ('Ocupação'          %in% input$variavel) return(ocup_plotly(code, year, lang))
      if ('Occupation'        %in% input$variavel) return(ocup_plotly(code, year, lang))
      if ('Mês'               %in% input$variavel) return(mes_plotly(code, year, lang))
      if ('Month'             %in% input$variavel) return(mes_plotly(code, year, lang))
      if ('Tipo de infecção'  %in% input$variavel) return(tipm_plotly(code, year, lang))
      if ('Infection Type'    %in% input$variavel) return(tipm_plotly(code, year, lang))
      if ('Qtd. de Parasitas' %in% input$variavel) return(qtdp_plotly(code, year, lang))
      if ('Parasite Count'    %in% input$variavel) return(qtdp_plotly(code, year, lang))
      if ('Tratamento'        %in% input$variavel) return(esqm_plotly(code, year, lang))
      if ('Treatment'         %in% input$variavel) return(esqm_plotly(code, year, lang))
    })

    output$plot <- renderPlotly({
      plottest()
    })

    gc()
  })
}
