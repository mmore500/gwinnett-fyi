shinyUI(
    tagList(#shinythemes::themeSelector(),
        tags$head(
            tags$style(HTML("hr {border-top: 5px solid;}"))
        ),
        navbarPage("COVID-19 MONITORING", selected = "About",
                   theme = shinytheme('flatly'),

    tabPanel("Overview",
        mainPanel(width=12,
            fluidRow(width=10, align='center', plotlyOutput("totalcases")
                ), br(), hr(),
            fluidRow(width=10, align='center', plotlyOutput("CummulativeTotals")
                     ), br(), hr(),
            fluidRow(width=10, align='center', plotlyOutput("topdates")
                     ),
            )
        ),
    
    
    tabPanel("Clusters",
             sidebarPanel(width=3, style = "overflow-y:scroll; max-height: 100vh; position:relative;",
                 selectInput("selectCluster", "Select Cluster", choices = NULL),
                 h5("Total Active Cases by Cluster"),
                 DTOutput("Summariesbycluster")
             ),
             mainPanel(width=9,
                 fluidRow(width=8, align='center', plotlyOutput("allclusters")
                    ), br(), hr(),
                 fluidRow(
                     width=8, align='center', plotlyOutput("onecluster"),
                 ),
             ),
             
             ),
    tabPanel("Schools",
             sidebarPanel(width=3, style = "overflow-y:scroll; max-height: 100vh; position:relative;",
                    selectInput("SelectSchool", "Select School", choices=NULL),
                    h5("Positive and Suspected Cases compared to Close Contacts"),
                    DTOutput("SummarybySchool"),
             ),
             mainPanel(width=9,
                       fluidRow(width=9, align='center', plotlyOutput("allschools")
                       ), br(), hr(),
                       fluidRow(width=9, align='center', plotlyOutput('piechart')
                        ),
             ),
             ),
    tabPanel("Table",
             mainPanel(width=12, br(),
                       downloadButton('download_filtered',"Download Data"),
                       br(),br(),
                       fluidRow(width=10, align='center', DTOutput("table")
                       ))),
    tabPanel("About",
             mainPanel(width=12, br(),
                       fluidRow(width=10, align='center', htmlOutput("abouttemplate")),
            
             )
             )
)))
