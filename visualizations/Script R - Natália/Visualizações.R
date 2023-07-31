
### ESCOLARIDADE POR ESTADO E POR ANO ####      
#df_esc <- BRASIL %>% 
#  filter(year_notif >= 2011) %>%
#  group_by(uf, year_notif, escolaridade) %>% 
#  summarise(count = n()) %>%
#  mutate(perc = count/sum(count)*100)
#  group_by(uf, year_notif, escolaridade) 

df_esc<-read.table('Dataset_Escolaridade.csv')

f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#7f7f7f"
)
x <- list(
  title = "State",
  titlefont = f
)
y <- list(
  title = "Percent",
  titlefont = f,
  hoverformat = '.2f',
  ticksuffix = "%",
  standoff=50
)

mrg <- list(l = 100, r = 100,
            b = 200, t = 100,
            pad = 0)


fig <- df_esc %>%
  plot_ly(
    x = ~uf, 
    y = ~perc, 
    color = ~escolaridade, 
    frame = ~year_notif, 
    type = 'bar',
    width=1000, height=900)


plot_esc <- fig %>% layout(title="Nível de escolaridade <br> Testados Positivos - Malária, 2011-2019", 
                      barmode = 'stack', xaxis = x, yaxis = y, margin = mrg,
                      annotations = 
                        list(x = 0, y = -0.28, #position of text adjust as needed 
                             text = "Source: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária", 
                             showarrow = F, xref='paper', yref='paper', 
                             xanchor='left', xshift=0, yshift=0,
                             font=list(size=12))) %>% 
                      animation_slider(currentvalue = list(prefix = "Year ",  font = list(color="red")))


htmlwidgets::saveWidget(as_widget(plot_esc), "Escolaridade.html")

## Casos de malária por mês - Plotly ####

#df_casos <- BRASIL %>% 
  #filter(year_notif >=2011) %>%
#  group_by(uf, year_notif, month) %>% 
#  summarise(n=n()) %>% 
#  group_by(uf, year_notif, month)

df_casos <- read.table('Dataset_CasosUF_month.csv')

f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#7f7f7f"
)
x <- list(
  title = "Notification month",
  titlefont = f,
  showline = TRUE
)
y <- list(
  title = "Number of positive cases",
  titlefont = f,
  showline = TRUE
)

mrg <- list(l = 100, r = 100,
            b = 200, t = 100,
            pad = 0)
rm(fig)

fig <- df_casos %>%
  plot_ly(
    x = ~month, 
    y = ~n, 
    size = 30,
    color = ~uf, 
    frame = ~year_notif, 
    #text = ~uf, 
    #hoverinfo = "text",
    type = 'scatter',
    mode = 'markers'
  )

fig <- fig %>% layout(title="Casos de Malária - 2007-2019", xaxis = x, yaxis = y, margin = mrg,
                      annotations = 
                        list(x = 0, y = -0.3, #position of text adjust as needed 
                             text = "Source: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária", 
                             showarrow = F, xref='paper', yref='paper', 
                             xanchor='left', xshift=0, yshift=0,
                             font=list(size=12)))

plot <- fig %>% animation_slider(currentvalue = list(prefix = "Year ", font = list(color="red")))
  
htmlwidgets::saveWidget(as_widget(plot), "Cases_BubbleGraph.html")

### taxa de incidencia de malária ####

df_taxa_filter<-read.table('Dataset_TaxaIncidência_Munic.csv')

f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#7f7f7f"
)
x <- list(
  title = "Ano de notificação",
  titlefont = f,
  autotick = TRUE,
  xlim = 2007:2019
)
y <- list(
  title = "Taxa de incidência por mil habitantes",
  titlefont = f)

mrg <- list(l = 100, r = 100,
            b = 200, t = 100,
            pad = 0)

col = c("#FF0000FF","#FF00E6FF","#00FF00FF",
        "#6A6A6AFF","#FF3300FF","#3300FFFF",
        "#9900FFFF","#00FFFFFF","#CCFF00FF")

fig <- df_taxa_filter %>%
  plot_ly(
    x = ~as.factor(year_notif), 
    y = ~txinc, 
    size = 80,
    color = ~uf, 
    #frame = ~year_notif, 
    text = ~municipio, 
    hoverinfo = "text",
    type = 'scatter',
    colors = col,
    mode = 'markers'
  )

fig <- fig %>% layout(title="Taxa de Incidencia de Malária - 2007-2019", xaxis = x, yaxis = y,
                      margin = mrg,
                      annotations = 
                        list(x = 0, y = -0.3, #position of text adjust as needed 
                             text = "Source: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária", 
                             showarrow = F, xref='paper', yref='paper', 
                             xanchor='left', xshift=0, yshift=0,
                             font=list(size=12)))



htmlwidgets::saveWidget(as_widget(fig), "TXINC.html")

## Ocupação - Plotly ####

#df_ocup <- BRASIL %>% 
  #filter(year_notif >=2011) %>%m
#  group_by(uf, year_notif, ocup) %>% 
#  summarise(count =n()) %>% 
#  group_by(uf, year_notif)

df_ocup<- read.table('Dataset_Ocup.csv')

df_ocup$ocup <- factor(df_ocup$ocup, 
                    levels = c("Agricultura", "Pecuária","Doméstica", "Turismo","Garimpagem",
                               "Exploração Vegetal","Caça/Pesca", "Consts. Estrada e Barragens",
                               "Mineração","Viajante", "Outros","Ignorado"))



write.csv(df_ocup, 'Dataset_Ocup.csv', fileEncoding="latin1", row.names = FALSE)

cols <- c("#1f77b4","#ff7f0e",
          "#2ca02c","#d62728",
          "#9467bd","#8c564b",
          "#e377c2","#7f7f7f",
          "#bcbd22","#17becf",
          "#f3d573","#6785be")


rm(fig_ocup)
fig_ocup <- df_ocup %>% plot_ly(type = 'pie', frame = ~year_notif, width=1500, height=1000, 
                                rotation = 100, 
                                textposition = 'inside',
                                colors = cols)



  #### RONDÔNIA - Subplot ####
fig_ocup <- fig_ocup %>% add_pie(hole = 0.5,
                                 data = df_ocup %>% filter (uf == 'Rondônia'),
                                 labels = ~ocup, 
                                 values = ~count,
                                 title = 'Rondônia',
                                 domain = list(row = 0, column = 0)) #%>% 
                                 #layout(annotations = list(text = 'Rondõnia',
                                #                           x = 0.155,  y = 0.5+0.37,
                                 #                          xanchor="center",  yanchor="center",
                                  #                         font=list(size=12),
                                   #                        showarrow = FALSE))
  #### ACRE - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Acre'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Acre',
                                  domain = list(row = 0, column = 1)) #%>% 
                                  #layout(annotations = list(text = 'Acre',
                                  #                          x = 0.5,  y = 0.5+0.37,
                                  #                          xanchor="center",  yanchor="center",
                                  #                          font=list(size=12),
                                  #                          showarrow = FALSE))

  #### AMAZONAS - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Amazonas'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Amazonas',
                                  domain = list(row = 0, column = 2)) #%>% 
                                  #layout(annotations = list(text = 'Amazonas',
                                  #                          x = 0.5+0.345,  y = 0.5+0.37,
                                  #                          xanchor="center",  yanchor="center",
                                  #                          font=list(size=12),
                                  #                          showarrow = FALSE))
  #### RORAIMA - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Roraima'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Roraima',
                                  domain = list(row = 1, column = 0)) #%>% 
                                  #layout(annotations = list(text = 'Roraima',
                                  #                          x = 0.15,  y = 0.5,
                                  #                          xanchor="center",  yanchor="center",
                                  #                          font=list(size=12),
                                  #                          showarrow = FALSE))



  #### PARÁ - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Pará'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Pará',
                                  domain = list(row = 1, column = 1)) #%>% 
                                  #layout(annotations = list(text = 'Pará',
                                  #                          x = 0.5,  y = 0.5,
                                  #                          xanchor="center",  yanchor="center",
                                  #                          font=list(size=12),
                                  #                          showarrow = FALSE))


  #### AMAPÁ - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Amapá'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Amapá',
                                  domain = list(row = 1, column = 2))#%>% 
                                           #layout(annotations = list(text = 'Amapá',
                                          #                           x = 0.5+0.35,  y = 0.5,
                                           #                          xanchor="center",  yanchor="center",
                                            #                         font=list(size=12),
                                             #                        showarrow = FALSE))

  #### TOCANTINS - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Tocantins'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Tocantins',
                                  domain = list(row = 2, column = 0))#%>% 
  #layout(annotations = list(text = 'Tocantins',
  #                         x = 0.15,  y = 0.5-0.355,
  #                          xanchor="center",  yanchor="center",
  #                          font=list(size=12),
  #                          showarrow = FALSE))

  #### MARANHÃO - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Maranhão'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Maranhão',
                                  domain = list(row = 2, column = 1))#%>% 
  #layout(annotations = list(text = 'Maranhão',
  #                          x = 0.5,  y = 0.5-0.355,
  #                          xanchor="center",  yanchor="center",
  #                          font=list(size=12),
  #                          showarrow = FALSE))

  #### MATO GROSSO - Subplot ####
fig_ocup <- fig_ocup  %>% add_pie(hole = 0.5,
                                  data = df_ocup %>% filter (uf == 'Mato Grosso'),
                                  labels = ~ocup, 
                                  values = ~count,
                                  title = 'Mato Grosso',
                                  domain = list(row = 2, column = 2),
                                  hoverinfo = FALSE)
#### Juntanto pie charts ocup ####

mrg <- list(l = 100, r = 100,
            b = 200, t = 100,
            pad = 0)

fig_ocup <- fig_ocup %>% layout(title = "Ocupação - Testados Positivos - Malária <br> Período 2007-2019 <br><br>", 
                                showlegend = F, margin = mrg,
                                grid=list(rows=3, columns=3), 
                                xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                annotations = 
                                  list(x = 0, y = -0.28, #position of text adjust as needed 
                                       text = "Source: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária", 
                                       showarrow = F, xref='paper', yref='paper', 
                                       xanchor='left', xshift=0, yshift=0,
                                       font=list(size=12))) %>% 
                                animation_slider(currentvalue = list(prefix = "Year ", font = list(color="red")))

htmlwidgets::saveWidget(as_widget(fig_ocup), "Ocupação.html")



#### GESTANTE - UF - Plotly #####

#df_gestante <- BRASIL %>% 
#  filter(year_notif >=2011) %>%
#  filter(sexo == 'Feminino') %>%
#  filter(ID_PACIE >= 14 & ID_PACIE <=59) %>%
#  group_by(uf, year_notif, gestante) %>% 
#  summarise(count = n()) %>% 
#  mutate(perc=count/sum(count)*100) %>%
#  group_by(uf, year_notif, gestante) 

df_gestante<-read.table('Dataset_Gestante.csv')

#"1o Trimestre"
#"2o Trimestre"
#"3o Trimestre"
#"Idade gestacional ignorada"
#"Não"
#"Não se aplica"

f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#7f7f7f"
)
x <- list(
  title = "State",
  titlefont = f
)
y <- list(
  title = "Percent",
  titlefont = f,
  hoverformat = '.2f',
  ticksuffix = "%",
  standoff=50
)

mrg <- list(l = 100, r = 100,
            b = 200, t = 100,
            pad = 0)


fig <- df_gestante %>%
  plot_ly(
    x = ~uf, 
    y = ~perc, 
    color = ~gestante, 
    frame = ~year_notif, 
    #text = ~gestante , 
    #hoverinfo = "text",
    type = 'bar'
  )
fig <- fig %>% layout(title="Gestantes entre 14 e 59 anos <br> 2011-2019", 
                      barmode = 'stack', xaxis = x, yaxis = y, margin = mrg,
                      annotations = 
                        list(x = 0, y = -0.28, #position of text adjust as needed 
                             text = "Source: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária", 
                             showarrow = F, xref='paper', yref='paper', 
                             xanchor='left', xshift=0, yshift=0,
                             font=list(size=12)))


plot <-fig %>% 
  animation_slider(currentvalue = list(prefix = "Year ",  font = list(color="red")))

htmlwidgets::saveWidget(as_widget(plot), "Gestante.html")



### QUANTIDADE EM CRUZES ####

#df_cruz <- BRASIL %>% 
  #filter(year_notif >=2011) %>%
#  group_by(uf, year_notif, cruzes) %>% 
#  summarise(count = n()) %>% 
#  mutate(perc=count/sum(count)*100) %>% 
#  group_by(uf, year_notif, cruzes)

df_cruz<-read.table('Dataset_ParasetemiaCruzes.csv')



x <- list(
  title = "Estado",
  titlefont = f
)

y <- list(
  title = "Proporção",
  titlefont = f,
  hoverformat = '.2f',
  ticksuffix = "%",
  standoff=50
)

mrg <- list(l = 100, r = 100,
            b = 200, t = 100,
            pad = 0)

fig_cruzes<- df_cruz %>%
  plot_ly(x = ~uf,
          y = ~perc,
          color = ~cruzes,
    type = 'bar',
    frame = ~year_notif)

fig_cruzes <- fig_cruzes %>% 
  layout(title="Quantidade de Cruzes <br> Período 2007-2019 <br> Amazônia Legal", barmode = 'stack', xaxis = x, yaxis = y,
         margin = mrg,
         annotations = 
           list(x = 0, y = -0.28, #position of text adjust as needed 
                text = "Source: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária", 
                showarrow = F, xref='paper', yref='paper', 
                xanchor='left', xshift=0, yshift=0,
                font=list(size=12))) %>%
  animation_slider(currentvalue = list(prefix = "Year ", font = list(color="red")))


htmlwidgets::saveWidget(as_widget(fig_cruzes), "Cruzes.html")

