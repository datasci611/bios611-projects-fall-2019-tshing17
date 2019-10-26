source('helper_functions.R')

library(plotly)
library(shiny)
library(shinydashboard)


ui <- dashboardPage(
  dashboardHeader(title="Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Background", tabName = "background", icon = icon("home")),
      menuItem("Clients and Visits", tabName = "clients", icon = icon("users")),
      menuItem("Resources", tabName = "resources", icon = icon("socks"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "background",
              
              h2("Background"),
              p("Urban Ministries of Durham (UMD) is an organization that connects with the community 
                to end homelessness and fight poverty. UMD has three 
                main programs: the Community Shelter, the Community Cafe, and the Food Pantry and
                Clothing Closet."),
              p("Over the years, UMD has collected data on their services
                provided at the Community Resource Center which consists of both the Community Cafe 
                and the Food Pantry and Clothing Closet. This includes a record of whether food, clothing, 
                or other items were received by an individual who visited the community center."),
              h3("Goals"),
              p("Using this shiny dashboard, users will be able to view and interact with data from
                UMD regarding their records of service."),
              p("On the dashboard, users will be able to view:"),
              p("1. Trends in the number of clients and visits to the resource center"),
              p("2. Trends in the amount of food in pounds and clothing items being provided"),
              p("Via the shiny dashboard, users will be able to select the resource of interest, 
                remove outliers, and view specific dates of interest for totals resource use over time.
                Plots will be viewable with and without extreme values for an individual client visit."),
              h3("Data"),
              p("Data comes directly from UMD in a file called UMD_Services_Provided_20190719.tsv.
                This data is available on ", a("github.", 
                                              href = "https://github.com/datasci611/bios611-projects-fall-2019-tshing17/tree/master/project_2/data"),
                " It is important to note that the data file consists of 1 record per visit, 
                wherein a single client (identified by the Client.File.Number) may have multiple records. 
                Thus, monthly plots are aggregated totals of all resources used during the month."),
              p("Extreme date values (before 1983 and after 2019) have been excluded for unreasonableness.
                Extreme values of food in pounds consisted of more than 60 pounds provided to a client 
                during a single visit to the resource center. Similarly, extreme values of clothing items
                consisted of providing more than 28 clothing items to a client during a single visit to the
                resource center.  Users can view plots with and without these extreme values of food and clothing.")
                
      ),
      
      tabItem(tabName = "clients", h2("Clients and Visits"),
              
              fluidRow(
                box(title="Inputs", status="primary", solidHeader=TRUE,
                  radioButtons("selectclient", "Variable",
                                   choices = list("Visits" = 'total.visits',
                                                  "Clients" = 'total.clients'),
                                   selected = 'total.clients'),
                  sliderInput("dateclient", "Dates", 
                                  min = as.Date("1983-01-01"),
                                  max = as.Date("2019-12-31"),
                                  value = c(as.Date("2001-01-01"), as.Date("2019-06-01")),
                                  timeFormat="%b %Y")
                  ),
                box(title="Description", status="primary", solidHeader=TRUE,
                    p("A client is defined as a single individual or family entity that uses the 
                      resource center based on a unique Client File Number. A client visit is defined
                      as single record in which a client was provided any food, clothing, or other resources.
                      Thus, a client visit is a unique date in which a unique client receives any resources."),
                    textOutput("ClientText"))
              ),
              
              fluidRow(
                  column(width=12,
                    box(title="Monthly Plot", status="primary", solidHeader=TRUE,
                        plotlyOutput("Plot1"), width=12))
              )
      ),
      
      tabItem(tabName = "resources", h2("Food and Clothing"),
              
              fluidRow(
                box(title="Inputs", status="primary", solidHeader=TRUE,
                  radioButtons("selectresource", "Variable",
                               choices = list("Food in Pounds" = 'total.food.pounds',
                                              "Clothing Items" = 'total.clothing'),
                               selected = 'total.food.pounds'),
                  radioButtons("outlieryn", "Remove Outliers?",
                                   choices = list("Yes" = 1, "No" = 0),
                                   selected = 0),
                  helpText("There are some extreme values of Food in Pounds and Clothing Items.
               Remove Outliers to view plots with and without these data points."),
                  sliderInput("dateresource", "Dates", 
                              min = as.Date("1983-01-01"),
                              max = as.Date("2019-12-31"),
                              value = c(as.Date("2001-01-01"), as.Date("2019-06-01")),
                              timeFormat="%b %Y")
                ),
                box(title="Boxplot", status="primary", solidHeader=TRUE,
                    plotlyOutput("Boxplot"))
              ),
              
              fluidRow(
                column(width=12,
                       box(title="Monthly Plot", status="primary", solidHeader=TRUE,
                           plotlyOutput("Plot2"), width=12))
              )
      )
    )
  )
)

server <- function(input, output) {
  
  # Plot for Clients and Visits
  output$Plot1 <- renderPlotly({
    vartext <- switch(input$selectclient, 
                      total.visits = "Total Visits",
                      total.clients = "Total Clients")
    
    create_plot(0, input$selectclient, vartext, input$dateclient[1], input$dateclient[2])
  })
  
  # text for clients and visits
  output$ClientText <- renderText({
    vartext <- switch(input$selectclient, 
                      total.visits = "total visits",
                      total.clients = "total clients")
    output_overalltot(input$selectclient, vartext, input$dateclient[1], input$dateclient[2])
  })
  
  # Plot for Food and Clothing
  output$Plot2 <- renderPlotly({
    vartext <- switch(input$selectresource, 
                      total.clothing = "Total Clothing Items",
                      total.food.pounds = "Total Food in Pounds")
    
    create_plot(input$outlieryn, input$selectresource, vartext, input$dateresource[1], input$dateresource[2])
  })
  
  # Boxplot for Food and Clothing (with and without outliers)
  output$Boxplot <- renderPlotly({
    var <- switch(input$selectresource, 
                      total.clothing = "Clothing.Items",
                      total.food.pounds = "Food.Pounds")
    vartext <- switch(input$selectresource, 
                      total.clothing = "Clothing Items",
                      total.food.pounds = "Food in Pounds")
     create_boxplot(input$outlieryn, var, vartext, input$dateresource[1], input$dateresource[2])
  })
  
}

shinyApp(ui, server)