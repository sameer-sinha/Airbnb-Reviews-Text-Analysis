server <- function(input, output, session) {
  

   termCount <- reactive({
     if(input$boroughSelection == "Staten Island") {
       return (term.count.staten)
     } else {
       return (term.count.bronx)
     }
   })
  
  
  # First Panel 
  
  output$plot <- renderPlot({
    popular.terms.borough <- filter(termCount(),n > input$freqNo)
    if(nrow(popular.terms.borough)==0)
    {
      plot(1,1,col="white")
      text(1,1,"No data available for selected frequency range")
    }else {
      wordcloud(popular.terms.borough$Terms,popular.terms.borough$n,colors=brewer.pal(8,"Dark2"))
    }
  })
  
  
  #2nd Panel

  output$conditionalInput <- renderUI({
    if(input$checkbox){
    sliderInput("topFreqPc","Select Top Frequecy Percentage:",min = 1,  max = 10, value = 5)
    }  else {
      sliderInput("lowfreq","Select Low Frequency term:",min = 1000,  max = 5000, value = 2000)
    }
  })
  
  output$color1 <- renderUI({
    if(input$checkbox)
    {
      shinyjs::colourInput("p2bcol", "Bar colour", "blue", showColour = "background")
    }
  })

    
  output$color2 <- renderUI({
    if(input$checkbox)
    {
      shinyjs::colourInput("p2lcol", "Line colour", "black", showColour = "background")
    }
  })
  
  
  output$freqplot <- renderPlot({
    if(input$boroughSelection == "Staten Island"){
      if(input$checkbox)
      {
        term.count.staten %>% 
          filter(cume_dist(n) > (1 - (input$topFreqPc/10000))) %>% 
          ggplot(aes(x=reorder(Terms,n),y=n)) + geom_bar(stat='identity', colour=input$p2lcol, fill=input$p2bcol) + 
          coord_flip() + xlab('Counts') + ylab('')
      } else {
        len <- unique(findFreqTerms(dtm_bronx, lowfreq = input$lowfreq))
        x <- rnorm(length(len))
        plot(x,col="white")
        text(x,len)
      }
    } else {
      if(input$checkbox)
      {
        term.count.bronx %>% 
          filter(cume_dist(n) > (1 - (input$topFreqPc/10000))) %>% 
          ggplot(aes(x=reorder(Terms,n),y=n)) + geom_bar(stat='identity', colour=input$p2lcol, fill=input$p2bcol) + 
          coord_flip() + xlab('Counts') + ylab('')
      } else {
        len <- unique(findFreqTerms(dtm_bronx, lowfreq = input$lowfreq))
        x <- rnorm(length(len))
        plot(x,col="white")
        text(x,len, pos =1)
      }
    }
  })
  
  
  # 3rd Panel 
  
  output$dtm <- renderPlotly({
    if(input$boroughSelection == "Staten Island"){
      sum.terms <- as.data.frame(post.lda.staten$terms) %>% #matrix topic * terms
        mutate(topic=1:10) %>% #add a column
        gather(term,p,-topic) %>% #gather makes wide table longer, key=term, value=p, columns=-topic (exclude the topic column)
        group_by(topic) %>%
        mutate(rnk=dense_rank(-p)) %>% #add a column
        filter(rnk <= 10) %>%
        arrange(topic,desc(p))
    } else
    {
      sum.terms <- as.data.frame(post.lda.bronx$terms) %>% #matrix topic * terms
        mutate(topic=1:10) %>% #add a column
        gather(term,p,-topic) %>% #gather makes wide table longer, key=term, value=p, columns=-topic (exclude the topic column)
        group_by(topic) %>%
        mutate(rnk=dense_rank(-p)) %>% #add a column
        filter(rnk <= 10) %>%
        arrange(topic,desc(p))
    }
    sum.terms %>%
      filter(topic==input$numTopic) %>%
      ggplot(aes(x=reorder(term,p),y=p)) + geom_bar(stat='identity', colour=input$lcol, fill=input$bcol) + coord_flip() +
      xlab('Term')+ylab('Probability')+ggtitle(paste("Topic ",input$numTopic)) + theme(text=element_text(size=20))
      })
}