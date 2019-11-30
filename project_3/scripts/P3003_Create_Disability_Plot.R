# DISABILITY PLOTS
library(tidyverse)

setwd("C:/Users/tshin/Documents/GitHub/bios611-projects-fall-2019-tshing17/project_3/")
first_entry<-read.delim('./data/analytic_first_entry.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))
first_exit<-read.delim('./data/analytic_first_exit.tsv', sep="\t", header=TRUE, na.strings = c("", "NA"))

#############################
# ENTRY
# select disability variables
disab_entry = first_entry %>% select(EE.UID, Client.ID, Alcohol.Abuse:Any.Disability)

# calculate the number of each response ie number who responded Yes, number who responded No, and number that were missing
# for each column ie columns totals
disab_entry2 = data.frame(Yes=apply(select(disab_entry,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                    No=apply(select(disab_entry,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(x=='No', na.rm=TRUE)}),
                    Missing=apply(select(disab_entry,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(is.na(x))}))

# convert index from totals calculation to new variable called Type
disab_entry2 = rownames_to_column(disab_entry2, "Type")

# gather data so there are 3 rows for each disability type
disab_entry2 = disab_entry2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

# create disability bar chart
disab_entry_plot = ggplot(data=disab_entry2, aes(x=factor(Type), y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Disability Type at Entry', title='Figure 5. Disability Reported at Entry')+
  scale_fill_discrete(name = "Response")+
  scale_x_discrete(labels = c('Alcohol Abuse',
                              'Alcohol and Drug Abuse',
                              'Chronic Health Condition',
                              'Developmental',
                              'Drug Abuse',
                              'Dual Diagnosis',
                              'Hearing Impaired',
                              'HIV/AIDS',
                              'Mental Health',
                              'Other Learning',
                              'Other Speech',
                              'Other',
                              'Physical',
                              'Physical (medical)',
                              'Vision Impaired'))+
  theme(plot.title = element_text(hjust = 1.9, vjust=1, size=12))
disab_entry_plot

ggsave("./results/disab_entry_plot.png", disab_entry_plot)

##################
# EXIT
# select disability variables
disab_exit = first_exit %>% select(EE.UID, Client.ID, Alcohol.Abuse:Any.Disability)

# calculate the number of each response ie number who responded Yes, number who responded No, and number that were missing
# for each column ie columns totals
disab_exit2 = data.frame(Yes=apply(select(disab_exit,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(x=='Yes', na.rm=TRUE)}),
                          No=apply(select(disab_exit,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(x=='No', na.rm=TRUE)}),
                          Missing=apply(select(disab_exit,-EE.UID, -Client.ID, -Any.Disability),2, function(x){sum(is.na(x))}))

# convert index from totals calculation to new variable called Type
disab_exit2 = rownames_to_column(disab_exit2, "Type")

# gather data so there are 3 rows for each disability type
disab_exit2 = disab_exit2 %>% 
  gather('Yes', 'No', 'Missing', key = "Category", value = "Freq") %>%
  arrange(Type)

# create disability bar chart
disab_exit_plot = ggplot(data=disab_exit2, aes(x=factor(Type), y=Freq, fill=Category))+
  geom_col(position="stack")+
  coord_flip()+
  labs(y='Number of Clients', x='Disability Type at Exit', title='Figure 6. Disability Reported at Exit')+
  scale_fill_discrete(name = "Response")+
  scale_x_discrete(labels = c('Alcohol Abuse',
                              'Alcohol and Drug Abuse',
                              'Chronic Health Condition',
                              'Developmental',
                              'Drug Abuse',
                              'Dual Diagnosis',
                              'Hearing Impaired',
                              'HIV/AIDS',
                              'Mental Health',
                              'Other Learning',
                              'Other Speech',
                              'Other',
                              'Physical',
                              'Physical (medical)',
                              'Vision Impaired'))+
  theme(plot.title = element_text(hjust = 2.1, vjust=1, size=12))
disab_exit_plot

ggsave("./results/disab_exit_plot.png", disab_exit_plot)


# analysis
disab_entry3 = disab_entry2 %>% spread(key = Category, value = Freq) %>% mutate(time='Entry')
disab_exit3 = disab_exit2 %>% spread(key = Category, value = Freq) %>% mutate(time='Exit')
disab_anl = disab_entry3 %>% full_join(disab_exit3) %>% arrange(Type)

typelist = unique(disab_anl$Type)
chisq_stat = list()
chisq_pval = list()
for (type in typelist){
  chisq_stat[type] = chisq.test(disab_anl %>% filter(Type == type ) %>% select(Yes,No,Missing))$statistic
  print(chisq_stat[type])
  chisq_pval[type] = chisq.test(disab_anl %>% filter(Type == type ) %>% select(Yes,No,Missing))$p.value
  print(chisq_pval[type])
}

