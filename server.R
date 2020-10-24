shinyServer(function(input, output, session) {
    
    ######## DATA PREPROCESSING ####
    # GET DATA
    data <- read.csv("new_cases.csv",header = T, sep = ',')
    
    # FILL NAs with zero
    data[is.na(data)] <- 0
    # DROP LISTED COLUMN
    data = data[ , !(names(data) %in% 'listed')]
    # TO BE CONSISTENT CHANGE THE NAMES OF THE COLUMNS
    colnames(data) = c("School", "CloseContact", "PositiveCase", "SuspectedCase", "Total", "Date", "Cluster")
    # CONVERT THE DATE COLUMN TO DATE FORMAT
    data$Date <- as.Date(data$Date, format="%m/%d/%y")
    # SORT DATA ACCORDING TO DATA
    data = data[order(data$Date),]
    # REMOVING TOTAL COLUMN
    data = data[!data$School == "Total",]
    
    ##### INPUTS ####   ####
        
    observe({
        updateSelectInput(session, "selectCluster", choices = sort(data$Cluster), selected = data$Cluster[1])
    })

    observe({
        updateSelectInput(session, "SelectSchool", choices = sort(data$School), selected = data$School[1])
    })
        
    
    ####### OVERVIEW TAB ####
    
    output$totalcases <- renderPlotly({
            data %>% dplyr::group_by(Date) %>% 
                summarise(CloseContact=sum(CloseContact),PositiveCase=sum(PositiveCase),
                          SuspectedCase=sum(SuspectedCase), Total=sum(Total)) %>%
                plot_ly(x = ~Date, y = ~Total, type = 'scatter', mode='lines', name = 'Total Active Cases') %>%
                add_lines(y = ~CloseContact, name = 'Close Contacts') %>%
                add_lines(y = ~PositiveCase, name = 'Positive Cases') %>%
                add_lines(y = ~SuspectedCase, name = 'Suspected Cases') %>%
                add_trace(x = as.Date("2020/08/12"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase I",name = 'Phase I', showlegend = F) %>%
                add_trace(x = as.Date("2020/08/26"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase II",name = 'Phase II', showlegend = F) %>%
                add_trace(x = as.Date("2020/09/02"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase III",name = 'Phase III', showlegend = F) %>%
                add_trace(x = as.Date("2020/09/09"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase IV",name = 'Phase IV', showlegend = F) %>%
                layout(hovermode = "x unified", title = "Daily Cases", font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases"))
    })
    
    output$CummulativeTotals <- renderPlotly({
        data %>%
            group_by(Date) %>%
            arrange(Date) %>%
            summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
            mutate(CloseContact = cumsum(CloseContact), PositiveCase = cumsum(PositiveCase), SuspectedCase = cumsum(SuspectedCase), Total = cumsum(Total)) %>%
            plot_ly(x = ~Date, y = ~CloseContact, type = 'scatter', mode = 'lines', name = 'Close Contacts', stackgroup='one', line=list(color='rgb(255, 127, 14)')) %>%
            add_trace(y = ~ PositiveCase, name = 'Positive Cases', stackgroup = 'one', line=list(color='rgb(44, 160, 44)')) %>%
            add_trace(y = ~ SuspectedCase, name = 'Suspected Cases', stackgroup = 'one', line=list(color='rgb(214, 39, 40)')) %>%
            add_trace(x = as.Date("2020/08/12"), stackgroup=F, line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase I",name = 'Phase I', showlegend = F) %>%
            add_trace(x = as.Date("2020/08/26"), stackgroup=F, line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase II",name = 'Phase II', showlegend = F) %>%
            add_trace(x = as.Date("2020/09/02"), stackgroup=F, line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase III",name = 'Phase III', showlegend = F) %>%
            add_trace(x = as.Date("2020/09/09"), stackgroup=F, line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase IV",name = 'Phase IV', showlegend = F) %>%
            layout(hovermode = "x unified", title = "Cummulative Distribution of Total Active Cases", font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases"))
        
    })
    
    output$topdates <- renderPlotly({
        data %>%
            group_by(Date) %>%
            summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
            arrange(desc(Total)) %>%
            filter(dplyr::row_number() <= 5L) %>%
            mutate(Date = as.vector(format(Date, "%d-%b"))) %>%
            plot_ly(x = ~Date, y = ~Total, type = 'bar', name = 'Total Active Cases') %>%
            add_trace(y = ~CloseContact, name = 'Close Contacts') %>%
            add_trace(y = ~PositiveCase, name = 'Positive Cases') %>%
            add_trace(y = ~SuspectedCase, name = 'Suspected Cases') %>%
            layout(title = "Days with Most Reported Active Cases", font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases"))
    })
    
    
    ##### CLUSTERS PANEL #######
    
    output$allclusters <- renderPlotly({
        data %>% group_by(Date, Cluster) %>%
            summarise(Total = sum(Total)) %>% group_by(Cluster) %>%
            mutate(TotalMA = zoo::rollapply(Total, 5, mean, partial=T)) %>%
            plot_ly(x = ~Date, y = ~TotalMA, type='scatter', mode='lines', color = ~Cluster, line = list(shape = 'spline',smoothing = 0.8)) %>%
            add_trace(x = as.Date("2020/08/12"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase I",name = 'Phase I', showlegend = F) %>%
            add_trace(x = as.Date("2020/08/26"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase II",name = 'Phase II', showlegend = F) %>%
            add_trace(x = as.Date("2020/09/02"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase III",name = 'Phase III', showlegend = F) %>%
            add_trace(x = as.Date("2020/09/09"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase IV",name = 'Phase IV', showlegend = F) %>%
            layout(title = "Total Active Cases by Cluster", font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases (Smoothed with MA=5)", showlegend = F))
        
    })
    
    output$onecluster <- renderPlotly({
        data %>% group_by(Date, Cluster) %>%
            summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
            filter(Cluster==as.character(input$selectCluster)) %>%
            ungroup() %>%
            plot_ly(x = ~Date, y = ~Total, type = 'scatter', mode="markers+lines",name = 'Total Active Cases', fill='tozeroy') %>%
            add_trace(y = ~CloseContact, name = 'Close Contacts') %>%
            add_trace(y = ~PositiveCase, name = 'Positive Cases') %>%
            add_trace(y = ~SuspectedCase, name = 'Suspected Cases') %>%
            add_trace(x = as.Date("2020/08/12"), mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase I",name = 'Phase I', showlegend = F) %>%
            add_trace(x = as.Date("2020/08/26"), mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase II",name = 'Phase II', showlegend = F) %>%
            add_trace(x = as.Date("2020/09/02"), mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase III",name = 'Phase III', showlegend = F) %>%
            add_trace(x = as.Date("2020/09/09"), mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase IV",name = 'Phase IV', showlegend = F) %>%
            layout(hovermode = "x unified", title = paste(as.character(input$selectCluster), "Cluster Daily Cases"), font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases"))
    })
    
    
    output$Summariesbycluster <- renderDT({
        summary = data %>% group_by(Cluster) %>% summarise(Total = sum(Total)) %>% arrange(desc(Total))
        datatable(summary, rownames= FALSE, options = list(dom='t', lengthMenu=list(c(-1)), columnDefs = list(list(className = 'dt-center', targets = 0:1))))
    })
                
    
    ### SCHOOLS TAB
    
    output$allschools <- renderPlotly({
        data %>% group_by(Date, School) %>%
            summarise(Total = sum(Total)) %>% group_by(School) %>%
            mutate(TotalMA = rollapply(Total, 5, mean, partial=T), 
            ) %>%
            plot_ly(x = ~Date, y = ~TotalMA, type='scatter', mode='lines', color = ~School, line = list(shape = 'spline',smoothing = 0.6)) %>%
            #add_trace(x = as.Date("2020/08/12"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase I",name = 'Phase I', showlegend = F) %>%
            #add_trace(x = as.Date("2020/08/26"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase II",name = 'Phase II', showlegend = F) %>%
            #add_trace(x = as.Date("2020/09/02"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase III",name = 'Phase III', showlegend = F) %>%
            #add_trace(x = as.Date("2020/09/09"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase IV",name = 'Phase IV', showlegend = F) %>%
            layout(title = "Covid Cases in Schools", font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases (Smoothed with MA=5)"))
    })
    
    output$piechart <- renderPlotly({
        values = data %>% group_by(School) %>%
            summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
            filter(School==as.character(input$SelectSchool)) %>%
            unlist(use.names = F)
        total = values[5]
        values = values[2:4]
        names = c("Close Contacts", "Positive Cases", "Suspected Cases")
        
        plot_ly(labels=names, values=values, type='pie', textposition='inside', textinfo='label+percent', insidetextfont = list(color = '#FFFFFF'), hoverinfo='text', 
                text=paste(values, names, "of", total, "Total"), showlegend=F, 
                marker=list(colors=c('rgb(211,94,96)', 'rgb(128,133,133)', 'rgb(144,103,167)'),line = list(color = '#FFFFFF', width = 1))) %>%
            layout(title = paste('Percentage of Active Cases in', as.character(input$SelectSchool)),
                   xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    })
        
    
    output$SummarybySchool <- renderDT({
        sumbyschool <- data %>% group_by(School) %>%
            summarise(SuspectedCase = sum(SuspectedCase), PositiveCase = sum(PositiveCase), CloseContact=sum(CloseContact)) %>%
            mutate(Ratio = round(ifelse(CloseContact==0, CloseContact, (PositiveCase + SuspectedCase) / CloseContact),1)) %>%
            arrange(desc(Ratio)) %>% 
            select(School, Ratio)
        datatable(sumbyschool, rownames= FALSE, options = list(dom='t', lengthMenu=list(c(-1)), columnDefs = list(list(className = 'dt-center', targets = 0:1))))
    })
                
    
    
    ### TABLE
        
    output$table <- renderDT({
        datatable(data, options = list(columnDefs = list(list(className = 'dt-center', targets = 0:6))), class = 'cell-border stripe', rownames= FALSE)
    })
    
    
    output$download_filtered <- downloadHandler(
        filename = "Filtered Data.csv",
        content = function(file){ 
            write.csv(data[input[["table_rows_all"]], ],file, row.names = F)
            })        
    
    ### ABOUT
    output$abouttemplate <- renderText({
        includeHTML("about.html")
    })
    

})
