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

update_map <-  function(code, year) {

  cases <- flows %>% filter(destino == code, ano == year)

  fluxos = flows %>%
    filter(destino == code) %>%
    pull(fluxos)

  int = fluxos %>% classIntervals(n = 5, style = "fisher")

  m1 <- inner_join(municipios2, cases, by = c(cod6 = "origem"))
  m2 <- inner_join(paises2, cases, by = c(cod6 = "origem"))
  sp_cases <- rbind(m1, m2)

  tm_remove_layer(401) +
    tm_shape(sp_cases) +
    tm_polygons(col = "fluxos",
                style = "fixed",
                breaks = int$brks,
                title = "Casos",
                alpha = 0.75,
                zindex = 401) +
    tm_view(bbox = base_bb)
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
  flows <- read_csv2("flows.csv.xz")
  cases <- read_csv2("09_cases_data.csv.xz")
  idade <- read_csv2("09_idade_data.csv.xz")
  sexo  <- read_csv2("09_sexo_data.csv.xz")
  raca  <- read_csv2("09_raca_data.csv.xz")
  educ  <- read_csv2("09_educ_data.csv.xz")
  ocup  <- read_csv2("09_ocup_data.csv.xz")
  mes   <- read_csv2("09_mes_data.csv.xz")
  tipm  <- read_csv2("09_tipm_data.csv.xz")
  qtdp  <- read_csv2("09_qtdp_data.csv.xz")
  esqm  <- read_csv2("09_esqm_data.csv.xz")
})

# munge -----------------------------------------------------------------------
# general
munic_names <- municipios %>%
  st_drop_geometry() %>%
  unite(name, name_muni, abbrev_state, sep = " - ") %>%
  select(code_muni, name)

# spatial
municipios2 <- municipios %>%
  st_make_valid() %>%
  filter(code_state %in% c(11:17, 21, 51)) %>%
  select(code = code_muni, name = name_muni) %>%
  mutate(cod6 = as.integer(substr(code, 1, 6))) %>%
  select(-code) %>%
  st_transform(crs = 31981)

paises2 <- paises %>%
  filter(paises != "Burundi") %>%
  st_make_valid() %>%
  select(-iso_a2, cod6 = codigos, name = paises) %>%
  st_transform(crs = 31981)

base_bb <- st_sf(a = 1:2,
                 geom = st_sfc(
                   st_point(c(-1212183.85, 7945639.07)),
                   st_point(c(1850099.70, 10557683.96))),
                 crs = 31981)

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
  output$map <- renderTmap({
    basemap <-
      rbind(municipios2, paises2) %>%
      st_make_valid()

    tm_shape(basemap) +
      tm_polygons(col = "springgreen4",
                  title = "Casos",
                  alpha = 0.75,
                  zindex = 401) +
      tm_shape(municipios2) +
      tm_borders(lwd = 0.5, alpha = 0.3) +
      tm_basemap(leaflet::providers$OpenStreetMap.Mapnik) +
      tm_view(bbox = base_bb)
  })

  # update map --------------------------------------------------------------
  observe({
    year <- input$ano
    code <- get_mun_code(input$municipio)
    lang <- ifelse(click_lang(), "en", "pt")

    tmapProxy('map', session, {
      update_map(code, year)
    })

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
  })
}
