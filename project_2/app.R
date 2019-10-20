source('helper_functions.R')

library(plotly)
library(shiny)

# Define UI for app that draws a histogram and a data table----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Total Monthly Resources over Time"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      selectInput("umdresource", "Resource",
                  choices = list("Visits" = 'total.visits',
                                 "Clients" = 'total.clients',
                                 "Food in Pounds" = 'total.food.pounds',
                                 "Clothing Items" = 'total.clothing'),
                  selected = 'total.clients'),
      
      helpText("UMD resource data was collected per visit.  Select the resource to view
               the total per month."),
      
      radioButtons("outlieryn", "Remove Outliers?",
                   choices = list("Yes" = 1, "No" = 0),
                   selected = 0),
      
      helpText("There are some extreme values of Food in Pounds and Clothing Items.
               Remove Outliers to view plots without these data points."),
      
      sliderInput("date", "Dates", 
                  min = as.Date("1983-01-01"),
                  max = as.Date("2019-12-31"),
                  value = c(as.Date("2001-01-01"), as.Date("2019-06-01")),
                  timeFormat="%b %Y")
      #textOutput("SliderText")
      
    ),
    
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram and table----
      plotlyOutput("Plot"),
      #plotOutput("Boxplot"),
      dataTableOutput("Table")
    )
  )
)


# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # to display Month/Year as date on slider
  sliderMonth <- reactiveValues()
  observe({
    full.date <- as.POSIXct(input$date, tz="GMT")
    sliderMonth$Month <- as.character(monthStart(full.date))
  })
  #output$SliderText <- renderText({sliderMonth$Month})
  
  # renderPlot creates histogram and links to ui
  output$Plot <- renderPlotly({
    vartext <- switch(input$umdresource, 
                      total.visits = "Total Visits",
                      total.clients = "Total Clients",
                      total.food.pounds = "Total Food in Pounds",
                      total.clothing = "Total Clothing Items")
    
    create_plot(input$outlieryn, input$umdresource, vartext, input$date[1], input$date[2])
    })
  
  # output$Boxplot <- renderPlot({
  #   rawvar <- switch(input$umdresource, 
  #                     total.visits = "Total Visits",
  #                     total.clients = "Total Clients",
  #                     total.food.pounds = 'Food.Pounds',
  #                     total.clothing = 'Clothing.Items')
  # 
  # create_Boxplot(input$outlieryn, rawvar)
  # })
  
  # renderDateTable creates table and links to ui
  output$Table <- renderDataTable({
    create_Table(input$outlieryn, input$umdresource, input$date[1], input$date[2])
  })
}

shinyApp(ui = ui, server = server)