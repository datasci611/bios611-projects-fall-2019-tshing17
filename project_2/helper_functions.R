library(tidyverse)

# Read in original UMD Data
dat<-read.delim("./data/UMD_Services_Provided_20190719.tsv", sep="\t", header=TRUE)


# Initial clean of data file - Separate month/year/day, delete blank fields
dat = dat %>%
  separate(Date, into = c("month", "day", "year"), sep = "/", convert=TRUE) %>%
  mutate(mthyr = as.Date(paste(sprintf("%d-%02d", year, month),"-01",sep="")))%>%
  mutate(mthdyyr = as.Date(paste(year, month, day,sep="-"), "%Y-%m-%d")) %>% 
  select(-(Field1:Field3)) %>%
  arrange(year, month, day)

# Exclude really unreasonable dates (ie when UMD didn't exist and dates after 2019)
dat = filter(dat, year>=1983, year<=2019)


# data for clients and visits including outliers
dat_monthyr = dat %>%
  group_by(year, month, mthyr) %>%
  summarise(total.visits=n(),
            total.clients=n_distinct(Client.File.Number),
            total.food.pounds = sum(Food.Pounds, na.rm=TRUE),
            total.clothing = sum(Clothing.Items, na.rm=TRUE)
            )

# data for clients and visits excluding outliers
dat_monthyr_outliers = dat %>%
  mutate(Food.Pounds.b = ifelse(Food.Pounds>60, NA, Food.Pounds),
         Clothing.Items.b = ifelse(Clothing.Items>28, NA, Clothing.Items)) %>%
  group_by(year, month, mthyr) %>%
  summarise(total.visits=n(),
            total.clients=n_distinct(Client.File.Number),
            total.food.pounds = sum(Food.Pounds.b, na.rm=TRUE),
            total.clothing = sum(Clothing.Items.b, na.rm=TRUE)
  )


# FUNCTIONS

# Plot of total clients/visits/food in pounds/clothing items by month
create_plot <- function(outyn, var, vartext, mindate, maxdate){
  if (outyn == 0){
    p=ggplot(filter(dat_monthyr, mthyr>=as.Date(mindate), mthyr<=as.Date(maxdate)), 
           aes(x=mthyr, y=get(var),group = 1,
               text = paste('Date:', format(as.Date(mthyr), "%b-%Y"), '\n',vartext,': ', get(var))))+
      geom_point(color='darkblue', size=0.8, alpha=0.8)+
      geom_line(color='darkblue', size=0.5)+
      labs(x='Date', y=vartext, title=paste('Monthly', vartext, 'Over Time'))+
      theme_light()
    ggplotly(p, tooltip = c("text"))
  } 
  else {
    p=ggplot(filter(dat_monthyr_outliers, mthyr>=as.Date(mindate), mthyr<=as.Date(maxdate)), 
           aes(x=mthyr, y=get(var),group = 1,
               text = paste('Date:', format(as.Date(mthyr), "%b-%Y"), '\n',vartext,': ', get(var))))+
      geom_point(color='darkblue', size=0.8, alpha=0.8)+
      geom_line(color='darkblue', size=0.5)+
      labs(x='Date', y=vartext, title=paste('Monthly', vartext,'Over Time'))+
      theme_light()
    ggplotly(p, tooltip = c("text"))
  }
}

# Text for overall total
output_overalltot <- function(var, vartext, mindate, maxdate){
  if (var=='total.clients'){
  tot = dat %>% 
    filter(mthyr>=as.Date(mindate), mthyr<=as.Date(maxdate)) %>%
    summarise(n_distinct(Client.File.Number))
  }
  if (var=='total.visits'){
    tot = dat %>% 
      filter(mthyr>=as.Date(mindate), mthyr<=as.Date(maxdate)) %>%
      summarise(n())
  }
    paste("There were ", as.numeric(tot), vartext, "to the resource center between", 
          format(as.Date(mindate), "%b %Y"), "and ", format(as.Date(maxdate), "%b %Y"), ".")
}

# boxplots to show outliers of food and clothing
create_boxplot <- function(outyn, var, vartext, mindate, maxdate){
    if (outyn == 0){
      b = dat %>%
        filter(mthyr>=as.Date(mindate), mthyr<=as.Date(maxdate)) %>%
        ggplot(aes(y=get(var)))+
        geom_boxplot(fill='lightblue', color="darkblue")+
        labs(y=vartext, title=paste('Boxplot of Visit Recorded', vartext))+
        theme_light()+theme(axis.text.x=element_blank())
      ggplotly(b)
    }
    else {
      b = dat %>%
        filter(mthyr>=as.Date(mindate), mthyr<=as.Date(maxdate)) %>%
        mutate(Food.Pounds = ifelse(Food.Pounds>60, NA, Food.Pounds),
               Clothing.Items = ifelse(Clothing.Items>28, NA, Clothing.Items)) %>%
        ggplot(aes(y=get(var)))+
        geom_boxplot(fill='lightblue', color="darkblue")+
        labs(y=vartext, title=paste('Boxplot of Visit Recorded', vartext))+
        theme_light()+theme(axis.text.x=element_blank())
      ggplotly(b)
    }
}

