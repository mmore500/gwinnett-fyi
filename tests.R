Sys.setlocale("LC_ALL","C")
library(dplyr)
library(plotly)
library(zoo)
# GET DATA
data <- read.csv("new_cases.csv",header = T, sep = ',')

# for debugging locally
# data <- read.csv(file.choose)

# FILL NAs with zero
data[is.na(data)] <- 0
# TO BE CONSISTENT CHANGE THE NAMES OF THE COLUMNS
colnames(data) = c("School", "CloseContact", "PositiveCase", "SuspectedCase", "Total", "Date", "Cluster", "Listed")
# CONVERT THE DATE COLUMN TO DATE FORMAT
data$Date <- as.Date(data$Date, format="%m/%d/%Y")
# SORT DATA ACCORDING TO DATA
data = data[order(data$Date),]
# GET ALL TOTALS
#Totals = data[data$School == "Total",]

# REMOVING TOTAL COLUMN
data = data[!data$School == "Total",]

#test = log(data2$Total)

# OVERVIEW

t <- list(family = "sans serif",size = 12)
# TOTAL CASES
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
  
# Cumulative Distribution of Cases
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


# Top 10 Dates
data %>%
  group_by(Date) %>%
  summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
  arrange(desc(Total)) %>%
  filter(dplyr::row_number() <= 5L) %>%
  mutate(Date = as.vector(format(Date, "%d-%b"))) %>%
  plot_ly(x = ~Date, y = ~Total, type = 'bar', name = 'Total') %>%
  add_trace(y = ~CloseContact, name = 'Close Contact') %>%
  add_trace(y = ~PositiveCase, name = 'Positive Case') %>%
  add_trace(y = ~SuspectedCase, name = 'Suspected Case') %>%
  layout(title = "Days With Most Reported Cases", font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases"))




  # CLUSTERS:


#data %>% group_by(Date, Cluster) %>%
 # summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
  #plot_ly(x = ~Date, y = ~Total, type='scatter', mode='line',
   #       color = ~Cluster)


# ALL Clusters Graph with MA=5.
data %>% group_by(Date, Cluster) %>%
  summarise(Total = sum(Total)) %>% group_by(Cluster) %>%
  mutate(TotalMA = zoo::rollapply(Total, 5, mean, partial=T)) %>%
  plot_ly(x = ~Date, y = ~TotalMA, type='scatter', mode='lines', color = ~Cluster, line = list(shape = 'spline',smoothing = 0.8)) %>%
  add_trace(x = as.Date("2020/08/12"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase I",name = 'Phase I', showlegend = F) %>%
  add_trace(x = as.Date("2020/08/26"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase II",name = 'Phase II', showlegend = F) %>%
  add_trace(x = as.Date("2020/09/02"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase III",name = 'Phase III', showlegend = F) %>%
  add_trace(x = as.Date("2020/09/09"), line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase IV",name = 'Phase IV', showlegend = F) %>%
  layout(title = "Total Active Cases by Cluster", font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases (Smoothed with MA=5)", showlegend = F))


# SElected cluster's plot   
data %>% group_by(Date, Cluster) %>%
  summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
  filter(Cluster=="Archer") %>%
  ungroup() %>%
  plot_ly(x = ~Date, y = ~Total, type = 'scatter', mode="markers+lines",name = 'Total Active Cases', fill='tozeroy') %>%
  add_trace(y = ~CloseContact, name = 'Close Contacts') %>%
  add_trace(y = ~PositiveCase, name = 'Positive Cases') %>%
  add_trace(y = ~SuspectedCase, name = 'Suspected Cases') %>%
  add_trace(x = as.Date("2020/08/12"), type='scatter', mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase I",name = 'Phase I', showlegend = F) %>%
  add_trace(x = as.Date("2020/08/26"), type='scatter', mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase II",name = 'Phase II', showlegend = F) %>%
  add_trace(x = as.Date("2020/09/02"), type='scatter', mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase III",name = 'Phase III', showlegend = F) %>%
  add_trace(x = as.Date("2020/09/09"), type='scatter', mode='lines', line = list(dash="dash", color = 'gray'),hoverinfo='text', text="Phase IV",name = 'Phase IV', showlegend = F) %>%
  layout(hovermode = "x unified", title = paste("Archer", "Cluster Daily Cases"), font=t, xaxis=list(title='Date'), yaxis=list(title="Number of Cases"))



# Totals by Cluster:
data %>% group_by(Cluster) %>% summarise(Total = sum(Total)) %>% arrange(desc(Total))

  

#### SCHOOLS:

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

  
#Pie chart:
values = data %>% group_by(School) %>%
  summarise(CloseContact = sum(CloseContact), PositiveCase = sum(PositiveCase), SuspectedCase = sum(SuspectedCase), Total = sum(Total)) %>%
  filter(School=="Archer HS") %>%
  unlist(use.names = F) 
values = values[2:4]
names = c("Close Contacts", "Positive Case", "Suspected Case")
  
plot_ly(labels=names, values=values, type='pie', textposition='inside', textinfo='label+percent', insidetextfont = list(color = '#FFFFFF'), hoverinfo='text', 
        text=paste("Archer HS", 'School Percentages'), showlegend=F, marker=list(colors=c('rgb(211,94,96)', 'rgb(128,133,133)', 'rgb(144,103,167)'),
                                                                                 line = list(color = '#FFFFFF', width = 1))) %>%
  layout(title = paste('Percentage of Total Active Cases in', 'Archer HS'),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))


# (Positive + Suspected) / Closecontact Ration
data %>% group_by(School) %>%
  summarise(SuspectedCase = sum(SuspectedCase), PositiveCase = sum(PositiveCase), CloseContact=sum(CloseContact))

data %>% group_by(School) %>%
  summarise(SuspectedCase = sum(SuspectedCase), PositiveCase = sum(PositiveCase), CloseContact=sum(CloseContact)) %>%
  mutate(Ratio = round(ifelse(CloseContact==0, CloseContact, (PositiveCase + SuspectedCase) / CloseContact)), 2) %>%
  arrange(desc(Ratio)) %>% 
  select(School, Ratio)


                plot_ly(
  x = data2$Date,
  y = test,
  color = data2$Cluster,
  type = 'scatter',
  name = data2$School,
  hoverinfo = "text",
  hovertext = paste(data2$School, "<br>Total:", data2$Total),
  mode = 'lines',
  line = list(
    width = data2$Total / 2,
    dash = "solid",
    shape = 'spline',
    smoothing = 0.8
  )
) %>% layout(
  title = "All Schools",
  xaxis = list(title = 'Time', anchor = "y3"),
  yaxis = list(title = "Total Cases in Schools (log10 scale)")
)

#aggregate(data[c('CloseContact','PositiveCase', 'SuspectedCase')], by=data['Cluster'], sum)

library(dplyr)
summary = data2 %>% group_by(Date, Cluster) %>%
  summarise(
    CloseContact = sum(CloseContact),
    PositiveCase = sum(PositiveCase),
    SuspectedCase = sum(SuspectedCase),
    Total = sum(Total)
  )
test2 = log(summary$Total)
scales = scale(summary$Total)
plot_ly(
  x = summary$Date,
  y = scales,
  color = summary$Cluster,
  type = 'scatter',
  mode = 'lines',
  name = summary$Cluster,
  line = list(
    width = summary$Total / 2,
    dash = "solid",
    shape = 'spline',
    smoothing = 0.8
  )
) %>% layout(
  title = "All Clusters",
  xaxis = list(title = 'Time', anchor = "y3"),
  yaxis = list(title = "Total Cases in Schools (log10 scale)")
)
