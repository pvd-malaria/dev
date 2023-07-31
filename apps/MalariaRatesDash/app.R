#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(devtools)
library(rCharts)
library(shinydashboard)


ObitosIdade <- read.table ("TBMPad_TxInc.csv", fileEncoding="latin1", header = T ,sep=',', dec='.')

ObitosIdade$Ano <- as.numeric(ObitosIdade$Ano)

header <- dashboardHeader(title = "Malaria - Brazil")  

#Sidebar content of the dashboard
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "Choose State", icon = icon("dashboard")),
  
    selectInput(inputId = "uf",
                label = "Choose State:",
                choices = unique(ObitosIdade$UF),
                selected = "RO")
  )
  
)


frow1 <- fluidRow(
  
  box(
    title = "Incidence Rate from selected state"
    ,status = "warning"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,showOutput("plotIncidence", "nvd3")
    ,footer = HTML('Source: Sistema de Informações de Vigilância Epidemiológica (SIVEP) - Malária <br/> Resident population by IBGE'
  ))
  
  ,box(
    title = "Age-standardized death rates* from malaria of the selected state"
    ,status = "danger"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,showOutput("PlotDeath","nvd3")
    ,footer = HTML('Source: Datasus - Malaria <br/> Resident population by IBGE </br> 
    *Age-standardization assumes a constant population age & structure (Population of Brazil, 2010) to allow for comparisons between states and
    with time'
  )) 
  
)

# combine the two fluid rows to make the body
body <- dashboardBody(frow1)

ui <- dashboardPage(title = 'Malaria Rates - Brazil', header, sidebar, body, skin='black')

# create the server functions for the dashboard  
server <- shinyServer(function(input, output) { 
  
  #creating the plotOutput content
  data_input <- reactive({
  subset(ObitosIdade, UF == input$uf)
})
  
output$PlotDeath <- renderChart({
  
  pt1 <- nPlot(y = 'TEMPad', x = 'Ano', group = 'Idade', data =  data_input() , 
               type = 'stackedAreaChart')
  pt1$chart(useInteractiveGuideline=TRUE, showControls = F, margin = list(left = 100, right = 100))
  pt1$addParams(dom = 'PlotDeath')
  pt1$xAxis(tickValues = ObitosIdade$Ano)
  pt1$yAxis(axisLabel = "Age-standardized death rates from malaria per 100,000 population")
  return(pt1)
})

output$plotIncidence <- renderChart({
  
  pt2<-nPlot(TxInc~Ano, group = 'Idade', data =  data_input(), 
             type = 'stackedAreaChart')
  pt2$chart(useInteractiveGuideline=TRUE, showControls = F, margin = list(left = 100, right = 100))
  pt2$addParams(dom = 'plotIncidence')
  pt2$xAxis(tickValues = ObitosIdade$Ano)
  pt2$yAxis(axisLabel = "Incidence Rate per 1,000 population")
  return(pt2)
  
})

})


shinyApp(ui, server)
