
# coding: utf-8

# # P3001_Create Analytic Dataset
# 
# This notebook is for data wrangling of the Urban Ministries of Durham (UMD) homeless shelter data.

# ## Import Data

# In[1]:


import pandas as pd                   ## for data wrangling
import numpy as np                    ## for datetime
from functools import reduce          ## for removing duplicate data


# In[2]:


# import client data
client = pd.read_csv("../data/CLIENT_191102.tsv", delimiter='\t', encoding='utf-8')
entry_exit = pd.read_csv("../data/ENTRY_EXIT_191102.tsv", delimiter='\t', encoding='utf-8')
ee_udes = pd.read_csv("../data/EE_UDES_191102.tsv", delimiter='\t', encoding='utf-8')

#import data from entry
disab_entry = pd.read_csv("../data/DISABILITY_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')
health_ins_entry = pd.read_csv("../data/HEALTH_INS_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')
income_entry = pd.read_csv("../data/INCOME_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')
noncash_entry = pd.read_csv("../data/NONCASH_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')

#import data from exit
disab_exit = pd.read_csv("../data/DISABILITY_EXIT_191102.tsv", delimiter='\t', encoding='utf-8')
health_ins_exit = pd.read_csv("../data/HEALTH_INS_EXIT_191102.tsv", delimiter='\t', encoding='utf-8')
income_exit = pd.read_csv("../data/INCOME_EXIT_191102.tsv", delimiter='\t', encoding='utf-8')
noncash_exit = pd.read_csv("../data/NONCASH_EXIT_191102.tsv", delimiter='\t', encoding='utf-8')


# ## Data Cleaning

# ### General cleaning (for all datasets)

# I will limit the analyses to records with EE Provider ID=Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838) because the other areas have been closed.

# In[3]:


subset_to_open = 'Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)'

# client data
client = client.loc[client['EE Provider ID'] == subset_to_open]
entry_exit = entry_exit.loc[entry_exit['EE Provider ID'] == subset_to_open]
ee_udes = ee_udes.loc[ee_udes['EE Provider ID'] == subset_to_open]

# data at entry
disab_entry = disab_entry.loc[disab_entry['EE Provider ID'] == subset_to_open]
health_ins_entry = health_ins_entry.loc[health_ins_entry['EE Provider ID'] == subset_to_open]
income_entry = income_entry.loc[income_entry['EE Provider ID'] == subset_to_open]
noncash_entry = noncash_entry.loc[noncash_entry['EE Provider ID'] == subset_to_open]

# data at exit
disab_exit = disab_exit.loc[disab_exit['EE Provider ID'] == subset_to_open]
health_ins_exit = health_ins_exit.loc[health_ins_exit['EE Provider ID'] == subset_to_open]
income_exit = income_exit.loc[income_exit['EE Provider ID'] == subset_to_open]

# noncash at exit has EE Provider instead of EE Provider ID
noncash_exit = noncash_exit.loc[noncash_exit['EE Provider'] == subset_to_open]


# I will only going to use "Client ID" as the unique identifier in this dataset.  Therefore I will drop "Client Unique ID". "EE Provider ID" should all be the same now so I will also drop this column.

# In[4]:


drop_columns=['Client Unique ID', 'EE Provider ID']
# client data
client = client.drop(drop_columns, 1)
entry_exit = entry_exit.drop(drop_columns, 1)
ee_udes = ee_udes.drop(drop_columns, 1)

# data at entry
disab_entry = disab_entry.drop(drop_columns, 1)
health_ins_entry = health_ins_entry.drop(drop_columns, 1)
income_entry = income_entry.drop(drop_columns, 1)
noncash_entry = noncash_entry.drop(drop_columns, 1)

# data at exit
disab_exit = disab_exit.drop(drop_columns, 1)
health_ins_exit = health_ins_exit.drop(drop_columns, 1)
income_exit = income_exit.drop(drop_columns, 1)

# noncash at exit has EE Provider instead of EE Provider ID
noncash_exit = noncash_exit.drop(['Client Unique ID', 'EE Provider'],1)


# ### Cleaning client data

# In the CLIENT file, are some demographic variables of interest.  For these variables, I will convert "Doesn't know", "Refused", and "Data not collected" to missing.

# In[5]:


# Remove the "(HUD)" from this response and convert don't know to missing
client['Client Primary Race']=client['Client Primary Race'].str.rstrip(" (HUD)").    replace("Client doesn't know", np.NaN).    replace("Client refused", np.NaN).    replace("Data not collected", np.NaN)
client.groupby("Client Primary Race").size()

client['Client Ethnicity']=client['Client Ethnicity'].str.rstrip(" (HUD)").    replace("Client doesn't know", np.NaN).    replace("Client refused", np.NaN).    replace("Data not collected", np.NaN)
client.groupby("Client Ethnicity").size()

client['Client Veteran Status']=client['Client Veteran Status'].str.rstrip(" (HUD)").    replace("Data not collected", np.NaN)
client.groupby("Client Veteran Status").size()


# In[6]:


## change Trans Female (MTF or Male to Female) to missing for identifiable purposes
client['Client Gender'] = client['Client Gender'].replace('Trans Female (MTF or Male to Female)', np.NaN)
client.groupby("Client Gender").size()


# In[7]:


client.head()


# ### Clean entry exit data

# Of interest in this data is the length of stay at the homeless shelter.  This new variables will be calculated.

# In[8]:


# select variables of interest
entry_exit = entry_exit[['EE UID', 'Entry Date', 'Exit Date', 'Destination']]

# convert columns to datetime
entry_exit[['Entry Date', 'Exit Date']] = entry_exit[['Entry Date', 'Exit Date']].apply(pd.to_datetime)

# calculate date
entry_exit['LOS']=entry_exit['Exit Date'] - entry_exit['Entry Date']

# convert length of stay to days
entry_exit["LOS"] = entry_exit["LOS"].apply(lambda row: row.days)


# We are also interested in what a client's destination is after their stay.  There are too many destination categories, therefore I will re-categorize some of these destinations.

# In[9]:


# reclassify prior living
entry_exit['temp dest']=entry_exit['Destination'].fillna("0")
entry_exit['Destination'] = pd.np.where(entry_exit['temp dest'].str.contains("doesn't know|0|refused|not collected", case=False),"UNKNOWN",
                                      pd.np.where(entry_exit['temp dest'].str.contains("hospital|nursing|treatment", case=False), "HOSPITAL",
                                                  pd.np.where(entry_exit['temp dest'].str.contains("rental", case=False), "RENTAL",
                                                              pd.np.where(entry_exit['temp dest'].str.contains("friend|family", case=False), "FRIEND or FAMILY",
                                                                          pd.np.where(entry_exit['temp dest'].str.contains("jail", case=False), "PRISON",
                                                                                      pd.np.where(entry_exit['temp dest'].str.contains("owned|permanent", case=False), "PERMANENT",
                                                                                                  pd.np.where(entry_exit['temp dest'].str.contains("habitation", case=False), "NOT HABITABLE", 
                                                                                                              pd.np.where(entry_exit['temp dest'].str.contains("transition|halfway|safe|interim|foster", case=False), "INTERIM",
                                                                                                                          pd.np.where(entry_exit['temp dest'].str.contains("Host Home shelter"), "SHELTER","OTHER")))))))))
entry_exit.groupby("Destination").size()


# ### Clean Entry Exit UDES data

# This data table contains prior living situation and domestic violence.  There are over 20 different prior living situations.  Therefore I will re-categorize some of these livings situations to a smaller number of categories.  I will also remove "(HUD)" from the domestic violence response variable and change "don't know" and "refused" to missing.

# In[10]:


# reclassify prior living
ee_udes['temp prior living']=ee_udes['Prior Living Situation(43)'].fillna("0")
ee_udes['Prior Living'] = pd.np.where(ee_udes['temp prior living'].str.contains("doesn't know|0|refused|not collected", case=False),"UNKNOWN",
                                      pd.np.where(ee_udes['temp prior living'].str.contains("hospital|nursing|treatment", case=False), "HOSPITAL",
                                                  pd.np.where(ee_udes['temp prior living'].str.contains("rental", case=False), "RENTAL",
                                                              pd.np.where(ee_udes['temp prior living'].str.contains("friend|family", case=False), "FRIEND or FAMILY",
                                                                          pd.np.where(ee_udes['temp prior living'].str.contains("jail", case=False), "PRISON",
                                                                                      pd.np.where(ee_udes['temp prior living'].str.contains("owned|permanent", case=False), "PERMANENT",
                                                                                                  pd.np.where(ee_udes['temp prior living'].str.contains("habitation", case=False), "NOT HABITABLE", 
                                                                                                              pd.np.where(ee_udes['temp prior living'].str.contains("transition|halfway|safe|interim|foster", case=False), "INTERIM",
                                                                                                                          pd.np.where(ee_udes['temp prior living'].str.contains("Host Home shelter"), "SHELTER","OTHER")))))))))
ee_udes.groupby("Prior Living").size()


# In[11]:


# Remove the "(HUD)" from this domestic violence victim/survivor variable and combine "Client doesn't know" and "Data not collected" into "Unknown"
dv_deter_map = {"Client doesn't know (HUD)":'Unk', "Client refused (HUD)":'Unk', "No (HUD)":"No", "Yes (HUD)":"Yes"}
ee_udes['Domestic violence victim/survivor'] = ee_udes['Domestic violence victim/survivor(341)'].map(dv_deter_map)
ee_udes['Domestic violence victim/survivor'] = ee_udes['Domestic violence victim/survivor'].replace('Unk', np.NaN)
ee_udes.groupby('Domestic violence victim/survivor').size()


# In[12]:


# select columns of interest from ee udes
ee_udes= ee_udes[['EE UID', 'Prior Living', 'Domestic violence victim/survivor']]
ee_udes.head()


# ### Clean disability data at entry

# For the disability data, there appears to be a set number of questions asked of each client regarding a series of disabilities.  I will remove the extra '(HUD)' from the disabillity determination values and change values of 'Doesn't know' or 'Data not collected' to missing. I will also remove the extra '(HUD)' from the disabillity type.  Finally, I will transform this data from long to wide. 

# In[13]:


# select variables of interest
disab_entry = disab_entry[['EE UID', 'Client ID', 'Disability Determination (Entry)',                           'Disability Type (Entry)', 'Date Added (417-date_added)']]

# Remove the "(HUD)" from disability determination response
# combine "Client doesn't know" and "Data not collected" into "Unknown"
disab_deter_map = {"Client doesn't know (HUD)":'Unknown', "Data not collected (HUD)":'Unknown',                    "No (HUD)":"No", "Yes (HUD)":"Yes"}
disab_entry['Disab Determination'] = disab_entry['Disability Determination (Entry)'].map(disab_deter_map)

# change disability determination data not collected to NaN
disab_entry['Disab Determination'] = disab_entry["Disab Determination"].replace('Unknown', np.NaN)

# Remove the "(HUD)" from disability type
disab_entry['Disability Type']=disab_entry['Disability Type (Entry)'].str.rstrip(" (HUD)")

# Drop old variables 
disab_entry=disab_entry.drop(['Disability Determination (Entry)', 'Disability Type (Entry)'], axis=1)
disab_entry.head()


# In order to transform the data, I will remove duplicate records.  That is, for records with the same entry date to the shelter, identified with a unique EE UID, I will only keep the most up to date record ie the latest Date Added, because those records look like they were updated.

# In[14]:


# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
disab_entry.sort_values(by=['EE UID', 'Client ID', 'Disability Type', 'Date Added (417-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
disab_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Disability Type'], keep='first',inplace=True)

# drop date variable because it's no longer needed
disab_entry=disab_entry.drop(['Date Added (417-date_added)'], axis=1)

#Transform data so 1 column for each disability type and disab determination as the values.
disab_entry_t = disab_entry.pivot(index='EE UID', columns='Disability Type', values='Disab Determination')
disab_entry_t.head()


# Finally, I will create a variable that indicates if there were ANY disability.

# In[15]:


disab_entry_t['Any Disability']="No"
for index in disab_entry_t.index:
    any_disability="No"
    for col in disab_entry_t.columns:
        if disab_entry_t[col][index] == "Yes":
            any_disability="Yes"
    disab_entry_t['Any Disability'][index]=any_disability
disab_entry_t.head()


# ### Clean disability data at exit

# The same data cleaning for the disability data at entry will be performed the disability data at exit.

# In[16]:


# select variables of interest
disab_exit = disab_exit[['EE UID', 'Client ID', 'Disability Determination (Exit)',                           'Disability Type (Exit)', 'Date Added (417-date_added)']]

# Remove the "(HUD)" from disability determination response
# combine "Client doesn't know" and "Data not collected" into "Unknown"
disab_deter_map = {"Client doesn't know (HUD)":'Unknown', "Data not collected (HUD)":'Unknown',                    "No (HUD)":"No", "Yes (HUD)":"Yes"}
disab_exit['Disab Determination'] = disab_exit['Disability Determination (Exit)'].map(disab_deter_map)

# change disability determination data not collected to NaN
disab_exit['Disab Determination'] = disab_exit["Disab Determination"].replace('Unknown', np.NaN)

# Remove the "(HUD)" from disability type
disab_exit['Disability Type']=disab_exit['Disability Type (Exit)'].str.rstrip(" (HUD)")

# Drop old variables 
disab_exit=disab_exit.drop(['Disability Determination (Exit)', 'Disability Type (Exit)'], axis=1)
disab_exit.head()


# In[17]:


# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
disab_exit.sort_values(by=['EE UID', 'Client ID', 'Disability Type', 'Date Added (417-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
disab_exit.drop_duplicates(subset=['EE UID', 'Client ID', 'Disability Type'], keep='first',inplace=True)

# drop date variable because it's no longer needed
disab_exit=disab_exit.drop(['Date Added (417-date_added)'], axis=1)

# Transform data so 1 column for each disability type and disab determination as the values.
disab_exit_t = disab_exit.pivot(index='EE UID', columns='Disability Type', values='Disab Determination')

# Add variable for ANY disability
disab_exit_t['Any Disability']="No"
for index in disab_exit_t.index:
    any_disability="No"
    for col in disab_exit_t.columns:
        if disab_exit_t[col][index] == "Yes":
            any_disability="Yes"
    disab_exit_t['Any Disability'][index]=any_disability
disab_exit_t.head()


# ### Clean health insurance data at entry

# For the health insurance data, there appears to be a set number of questions asked of each client regarding a series of health insurances, like the disability data.  I will first change values of 'Doesn't know' or 'Data not collected' to missing. I will transform this data from long to wide. 

# In[18]:


# change data not collected to NaN
health_ins_entry['Covered'] = health_ins_entry["Covered (Entry)"].replace('Data Not Collected', np.NaN)

# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
health_ins_entry.sort_values(by=['EE UID', 'Client ID', 'Health Insurance Type (Entry)',                                  'Date Added (4307-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
health_ins_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Health Insurance Type (Entry)'], keep='first',inplace=True)

# select variables of interest
health_ins_entry=health_ins_entry[['EE UID', 'Covered', 'Health Insurance Type (Entry)']]

# delete entries where health insurance type is NAN - all of these have covered values = nan too
health_ins_entry=health_ins_entry.dropna(subset=['Health Insurance Type (Entry)'])

#Transform data so 1 column for each insurance type and covered entry as the values.
health_ins_entry_t = health_ins_entry.pivot(index='EE UID', columns='Health Insurance Type (Entry)', values='Covered')
health_ins_entry_t.head()


# Finally, I will create a variable that indicates if there were ANY health insurance.

# In[19]:


health_ins_entry_t['Any Health Insurance']="No"
for index in health_ins_entry_t.index:
    any_ins="No"
    for col in health_ins_entry_t.columns:
        if health_ins_entry_t[col][index] == "Yes":
            any_ins="Yes"
    health_ins_entry_t['Any Health Insurance'][index]=any_ins
health_ins_entry_t.head()


# ### Clean insurance data at exit

# The same cleaning for insurance data at entry will be used.

# In[20]:


# change data not collected to NaN
health_ins_exit['Covered'] = health_ins_exit["Covered (Exit)"].replace('Data Not Collected', np.NaN)

# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
health_ins_exit.sort_values(by=['EE UID', 'Client ID', 'Health Insurance Type (Exit)',                                  'Date Added (4307-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
health_ins_exit.drop_duplicates(subset=['EE UID', 'Client ID', 'Health Insurance Type (Exit)'], keep='first',inplace=True)

# select variables of interest
health_ins_exit=health_ins_exit[['EE UID', 'Covered', 'Health Insurance Type (Exit)']]

# delete entries where health insurance type is NAN - all of these have covered values = nan too
health_ins_exit=health_ins_exit.dropna(subset=['Health Insurance Type (Exit)'])

#Transform data so 1 column for each insurance type and covered exit as the values.
health_ins_exit_t = health_ins_exit.pivot(index='EE UID', columns='Health Insurance Type (Exit)', values='Covered')

# add variable for ANY insurance
health_ins_exit_t['Any Health Insurance']="No"
for index in health_ins_exit_t.index:
    any_ins="No"
    for col in health_ins_exit_t.columns:
        if health_ins_exit_t[col][index] == "Yes":
            any_ins="Yes"
    health_ins_exit_t['Any Health Insurance'][index]=any_ins
health_ins_exit_t.head()


# ### Clean income data at entry

# For the income data, there appears to be a set number of questions asked of each client regarding any income.  I will first change values of 'Doesn't know' or 'Data not collected' to missing. Then I will transform this data from long to wide. 

# In[21]:


# Remove the "(HUD)" from this response
income_entry['Income Source']=income_entry['Income Source (Entry)'].str.rstrip(" (HUD)")

# change data not collected to NaN
income_entry['Receiving Income'] = income_entry["Receiving Income (Entry)"].replace('Data Not Collected', np.NaN)

# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
income_entry.sort_values(by=['EE UID', 'Client ID', 'Income Source', 'Date Added (140-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
income_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Income Source'], keep='first',inplace=True)

# keep variables of interest
income_entry=income_entry[['EE UID', 'Receiving Income', 'Income Source']]

# delete entries where income type is NAN - all of these have covered values = nan too
income_entry=income_entry.dropna(subset=['Income Source'])

#Transform data so 1 column for each insurance type and covered entry as the values.
income_entry_t = income_entry.pivot(index='EE UID', columns='Income Source', values='Receiving Income')
income_entry_t.head()


# Finally, I will create a variable that indicates if there were ANY income.

# In[22]:


income_entry_t['Any Income Source']="No"
for index in income_entry_t.index:
    any_income="No"
    for col in income_entry_t.columns:
        if income_entry_t[col][index] == "Yes":
            any_income="Yes"
    income_entry_t['Any Income Source'][index]=any_income
income_entry_t.head()


# ### Clean income data at exit

# This data will be cleaned the same was as income data at entry

# In[23]:


income_exit.head()


# In[24]:


# Remove the "(HUD)" from this response
income_exit['Income Source']=income_exit['Source of Income (Exit)'].str.rstrip(" (HUD)")

# change data not collected to NaN
income_exit['Receiving Income'] = income_exit["ReceivingIncome (Exit)"].replace('Data Not Collected', np.NaN)

# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
income_exit.sort_values(by=['EE UID', 'Client ID', 'Income Source', 'Date Added (140-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
income_exit.drop_duplicates(subset=['EE UID', 'Client ID', 'Income Source'], keep='first',inplace=True)

# keep variables of interest
income_exit=income_exit[['EE UID', 'Receiving Income', 'Income Source']]

# delete entries where income type is NAN - all of these have covered values = nan too
income_exit=income_exit.dropna(subset=['Income Source'])

# Transform data so 1 column for each insurance type and covered exit as the values.
income_exit_t = income_exit.pivot(index='EE UID', columns='Income Source', values='Receiving Income')

# create variable for ANY income
income_exit_t['Any Income Source']="No"
for index in income_exit_t.index:
    any_income="No"
    for col in income_exit_t.columns:
        if income_exit_t[col][index] == "Yes":
            any_income="Yes"
    income_exit_t['Any Income Source'][index]=any_income
income_exit_t.head()


# ### Clean Noncash data at entry

# For the noncash income data, there appears to be a set number of questions asked of each client regarding any noncash income.  I will first change values of 'Doesn't know' or 'Data not collected' to missing. Then I will transform this data from long to wide. 

# In[25]:


# Remove the "(HUD)" from this response
noncash_entry['Noncash Source']=noncash_entry['Non-Cash Source (Entry)'].str.rstrip(" (HUD)")

# change data not collected to NaN
noncash_entry['Receiving Benefit'] = noncash_entry["Receiving Benefit (Entry)"].replace('Data Not Collected', np.NaN)

# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
noncash_entry.sort_values(by=['EE UID', 'Client ID', 'Noncash Source', 'Date Added (2704-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
noncash_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Noncash Source'], keep='first',inplace=True)

# keep variables of interest
noncash_entry=noncash_entry[['EE UID', 'Receiving Benefit', 'Noncash Source']]

# delete entries where income type is NAN - all of these have covered values = nan too
noncash_entry=noncash_entry.dropna(subset=['Noncash Source'])

#Transform data so 1 column for each insurance type and covered entry as the values.
noncash_entry_t = noncash_entry.pivot(index='EE UID', columns='Noncash Source', values='Receiving Benefit')
noncash_entry_t.head()


# Finally, I will create a variable that indicates if there were ANY noncash income.

# In[26]:


noncash_entry_t['Any Noncash Source']="No"
for index in noncash_entry_t.index:
    any_noncash="No"
    for col in noncash_entry_t.columns:
        if noncash_entry_t[col][index] == "Yes":
            any_noncash="Yes"
    noncash_entry_t['Any Noncash Source'][index]=any_noncash
noncash_entry_t.head()


# ### Clean noncash source at exit

# This will be cleaned the same as noncash source at entry.

# In[27]:


# Remove the "(HUD)" from this response
noncash_exit['Noncash Source']=noncash_exit['Non-Cash Source (Exit)'].str.rstrip(" (HUD)")

# change data not collected to NaN
noncash_exit['Receiving Benefit'] = noncash_exit["Receiving Benefit (Exit)"].replace('Data Not Collected', np.NaN)

# sorting by unique shelter visit id, client id, disability type, and date added (if any updates)
noncash_exit.sort_values(by=['EE UID', 'Client ID', 'Noncash Source', 'Date Added (2704-date_added)'], inplace=True)

# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
noncash_exit.drop_duplicates(subset=['EE UID', 'Client ID', 'Noncash Source'], keep='first',inplace=True)

# keep variables of interest
noncash_exit=noncash_exit[['EE UID', 'Receiving Benefit', 'Noncash Source']]

# delete entries where income type is NAN - all of these have covered values = nan too
noncash_exit=noncash_exit.dropna(subset=['Noncash Source'])

#Transform data so 1 column for each insurance type and covered exit as the values.
noncash_exit_t = noncash_exit.pivot(index='EE UID', columns='Noncash Source', values='Receiving Benefit')

# add variable for ANY noncash source
noncash_exit_t['Any Noncash Source']="No"
for index in noncash_exit_t.index:
    any_noncash="No"
    for col in noncash_exit_t.columns:
        if noncash_exit_t[col][index] == "Yes":
            any_noncash="Yes"
    noncash_exit_t['Any Noncash Source'][index]=any_noncash
noncash_exit_t.head()


# ## Merge all data to create analytic datasets

# ### At entry

# In[28]:


# merge all data frames together to create an analytic dataset with 1 record per EE UID
data_frames_entry = [client, entry_exit, ee_udes, disab_entry_t, health_ins_entry_t, income_entry_t, noncash_entry_t]
anl_entry = reduce(lambda  left,right: pd.merge(left,right,on=['EE UID'], how='left'), data_frames_entry)

# sort values by client id and entry date
anl_entry.sort_values(by=['Client ID', 'Entry Date'], inplace=True)

# output first record only to get the FIRST entry of shelter use for a client
anl_first_entry = anl_entry.drop_duplicates(subset='Client ID', keep='first')

# output data to tsv files for data analysis in R
anl_entry.to_csv("../data/analytic_entry.tsv", sep='\t')
anl_first_entry.to_csv("../data/analytic_first_entry.tsv", sep='\t')


# ### At exit

# Similar to data at entry, I will create a dataframe containing information from the first EXIT from the shelter

# In[46]:


# merge all data frames together to create an analytic dataset with 1 record per EE UID
data_frames_exit = [client, entry_exit, ee_udes, disab_exit_t, health_ins_exit_t, income_exit_t, noncash_exit_t]
anl_exit = reduce(lambda  left,right: pd.merge(left,right,on=['EE UID'], how='left'), data_frames_exit)

# sort values by client id and exit date
anl_exit.sort_values(by=['Client ID', 'Exit Date'], inplace=True)

# output first record only to get the FIRST exit of shelter use for a client
anl_first_exit = anl_exit.drop_duplicates(subset='Client ID', keep='first')


# Of interest to be analyzed is whether or not a client returned to the center after their first visit based on their exit information.

# In[47]:


# create variable for clients with more than 1 visit i.e. a client returned
num_visit = pd.DataFrame(anl_exit.groupby('Client ID').size(), columns=['NumVis'])
num_visit['returned'] = num_visit['NumVis'].apply(lambda x: 1 if x > 1 else 0)

# merge exit dataframe with number of visits data frame
anl_first_exit2 = pd.merge(anl_first_exit, num_visit, on=['Client ID'], how='left')


# Output data

# In[50]:


# output data to tsv files for data analysis in R
anl_exit.to_csv("../data/analytic_exit.tsv", sep='\t')
anl_first_exit2.to_csv("../data/analytic_first_exit.tsv", sep='\t')

