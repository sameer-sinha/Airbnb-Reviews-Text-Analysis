ui <- fluidPage(theme = shinytheme('superhero'),
  titlePanel("AirBnB Reviews Text Analytics"),
  
  
  sidebarLayout(
    sidebarPanel(
      
      selectInput("boroughSelection", "Select a Borough",choices = boroughs, selected = "Bronx"),
      hr(),
      
      
      conditionalPanel(
        condition = "input.mytabs == 'panel1'",
        sliderInput("freqNo","Select Minimum Frequecy:",min = 100,  max = 5000, value = 1000)
      ),
      
      
      conditionalPanel(
        condition = "input.mytabs == 'panel2'",
        checkboxInput("checkbox", "Filter by Top Percentage", FALSE),
        uiOutput("conditionalInput"),
        hr(),
        uiOutput("color1"),
        uiOutput("color2")
      ),
      
      conditionalPanel(
        condition = "input.mytabs == 'panel3'",
        radioButtons("numTopic","Topic#",choices = c(1:10),selected = NULL,inline = FALSE),
        hr(),
        shinyjs::colourInput("bcol", "Bar colour", "blue", showColour = c("background")),
        shinyjs::colourInput("lcol", "Line colour", "black", showColour = "background")
      )
      
      
      
      
    ),
    
    mainPanel(
      tabsetPanel(id = "mytabs",
                  tabPanel(title = "WordCloud",plotOutput("plot"), value = "panel1"),
                  tabPanel(title = "High Frequency Words",plotOutput("freqplot"), value = "panel2"),
                  tabPanel(title = "Topic Model, k = 10",plotlyOutput("dtm"), value = "panel3")
                  
      )
    )
    
  )
)
