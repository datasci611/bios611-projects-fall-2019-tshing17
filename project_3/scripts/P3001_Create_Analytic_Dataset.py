
# coding: utf-8

# # 3001_Create Analytic Dataset
# 
# This notebook is for data wrangling of the Urban Ministries of Durham (UMD) homeless shelter data.

# ## Import Data

# In[3]:


import pandas as pd
import numpy as np


# ### CLIENT_191102.tsv

# In[8]:


client = pd.read_csv("./data/CLIENT_191102.tsv", delimiter='\t', encoding='utf-8')
client.head()


# In[3]:


client.groupby("Client ID").size().max()


# There are multiple records per Client ID in this file with a maximum number of records of 37.

# In[4]:


client_records=client.groupby("Client ID").size().reset_index(name='Size')
client_records[client_records.Size==37]


# In[5]:


client.groupby("EE Provider ID").size()


# I will limit the analyses to records with EE Provider ID=Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838) because I don't know what the other things are.

# In[6]:


client=client[client["EE Provider ID"]=='Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)']
client.groupby("EE Provider ID").size()


# Also not really sure what the difference between "Client Unique ID" and "Client ID" so I'm only going to use "Client ID". So I'm going to drop "Client Unique ID" and "EE Provider ID" since it should all be records from the Urban Ministries of Durham - Singles Emergency Shelter and nothing with xxxClosed.

# In[7]:


client = client.drop(['Client Unique ID', 'EE Provider ID'],1)
client.head()


# In[8]:


client.groupby("Client Gender").size()
client.groupby("Client Primary Race").size()
client.groupby("Client Ethnicity").size()
client.groupby("Client Veteran Status").size()


# In[9]:


## change Trans Female (MTF or Male to Female) to missing for identifiable purposes
client['Client Gender'] = client['Client Gender'].replace('Trans Female (MTF or Male to Female)', np.NaN)
client.groupby("Client Gender").size()


# In[10]:


# Remove the "(HUD)" from this response, convert don't know to missing
client['Client Primary Race']=client['Client Primary Race'].str.rstrip(" (HUD)").replace("Client doesn't know", np.NaN).replace("Client refused", np.NaN).replace("Data not collected", np.NaN)
client.groupby("Client Primary Race").size()


# In[11]:


# Remove the "(HUD)" from this response, convert don't know to missing
client['Client Ethnicity']=client['Client Ethnicity'].str.rstrip(" (HUD)").replace("Client doesn't know", np.NaN).replace("Client refused", np.NaN).replace("Data not collected", np.NaN)
client.groupby("Client Ethnicity").size()


# In[12]:


# Remove the "(HUD)" from this response, convert don't know to missing
client['Client Veteran Status']=client['Client Veteran Status'].str.rstrip(" (HUD)").replace("Data not collected", np.NaN)
client.groupby("Client Veteran Status").size()


# ### ENTRY_EXIT_191102.tsv

# In[13]:


entry_exit = pd.read_csv("./data/ENTRY_EXIT_191102.tsv", delimiter='\t', encoding='utf-8')
entry_exit.head()


# In[14]:


entry_exit.groupby("EE Provider ID").size()


# In[15]:


entry_exit=entry_exit[entry_exit["EE Provider ID"]=='Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)']
entry_exit.groupby("EE Provider ID").size()


# In[16]:


entry_exit = entry_exit[['EE UID', 'Entry Date', 'Exit Date', 'Destination']]
entry_exit.head()


# In[17]:


entry_exit[['Entry Date', 'Exit Date']] = entry_exit[['Entry Date', 'Exit Date']].apply(pd.to_datetime)
entry_exit.head()


# In[18]:


entry_exit['LOS']=entry_exit['Exit Date'] - entry_exit['Entry Date']
entry_exit.head()


# In[19]:


entry_exit["LOS"] = entry_exit["LOS"].apply(lambda row: row.days)


# ### DISABILITY_ENTRY_191102.tsv

# In[20]:


disab_entry = pd.read_csv("./data/DISABILITY_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')
disab_entry.head()


# In[21]:


disab_entry.groupby("EE Provider ID").size()


# In[22]:


disab_entry = disab_entry[disab_entry["EE Provider ID"]=='Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)']
disab_entry.groupby("EE Provider ID").size()


# In[23]:


disab_entry = disab_entry[['EE UID', 'Client ID', 'Disability Determination (Entry)', 'Disability Type (Entry)', 'Date Added (417-date_added)']]
disab_entry.head()


# In[24]:


disab_entry.groupby("Disability Determination (Entry)").size()


# In[25]:


# Remove the "(HUD)" from this response and combine "Client doesn't know" and "Data not collected" into "Unknown"
disab_deter_map = {"Client doesn't know (HUD)":'Unk', "Data not collected (HUD)":'Unk', "No (HUD)":"No", "Yes (HUD)":"Yes"}
disab_entry['Disab Determination'] = disab_entry['Disability Determination (Entry)'].map(disab_deter_map)

# change data not collected to NaN
disab_entry['Disab Determination'] = disab_entry["Disab Determination"].replace('Unk', np.NaN)
disab_entry.groupby("Disab Determination").size()


# In[26]:


disab_entry.groupby("Disability Type (Entry)").size()


# In[27]:


# Remove the "(HUD)" from this response
disab_entry['Disability Type']=disab_entry['Disability Type (Entry)'].str.rstrip(" (HUD)")
disab_entry.groupby("Disability Type").size()


# In[28]:


# Drop old variables.
disab_entry=disab_entry.drop(['Disability Determination (Entry)', 'Disability Type (Entry)'], axis=1)
disab_entry.head()


# In[29]:


# sorting by first name 
disab_entry.sort_values(by=['EE UID', 'Client ID', 'Disability Type', 'Date Added (417-date_added)'], inplace=True)
disab_entry.head()


# In[30]:


# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
disab_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Disability Type'], keep='first',inplace=True)
disab_entry.head()


# In[31]:


# drop date
disab_entry=disab_entry.drop(['Date Added (417-date_added)'], axis=1)
disab_entry.head()


# In[32]:


#Transform data so 1 column for each disability type and disab determination as the values.
disab_entry_t = disab_entry.pivot(index='EE UID', columns='Disability Type', values='Disab Determination')
disab_entry_t.head()


# In[33]:


disab_entry_t['Any Disability']="No"
for index in disab_entry_t.index:
    any_disability="No"
    for col in disab_entry_t.columns:
        if disab_entry_t[col][index] == "Yes":
            any_disability="Yes"
    disab_entry_t['Any Disability'][index]=any_disability
disab_entry_t.head()


# ### EE_UDES_191102.tsv 

# In[34]:


ee_udes = pd.read_csv("./data/EE_UDES_191102.tsv", delimiter='\t', encoding='utf-8')
ee_udes.head()


# In[35]:


ee_udes = ee_udes[ee_udes["EE Provider ID"]=='Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)']
ee_udes.groupby("EE Provider ID").size()


# In[36]:


ee_udes.groupby("Prior Living Situation(43)").size()


# In[37]:


ee_udes['temp prior living']=ee_udes['Prior Living Situation(43)'].fillna("0")
ee_udes['Prior Living'] = pd.np.where(ee_udes['temp prior living'].str.contains("doesn't know|0|refused|not collected", case=False),"UNK",
                                      pd.np.where(ee_udes['temp prior living'].str.contains("hospital|nursing|treatment", case=False), "HOSPITAL",
                                                  pd.np.where(ee_udes['temp prior living'].str.contains("rental", case=False), "RENTAL",
                                                              pd.np.where(ee_udes['temp prior living'].str.contains("friend|family", case=False), "FRIEND or FAMILY",
                                                                          pd.np.where(ee_udes['temp prior living'].str.contains("jail", case=False), "PRISON",
                                                                                      pd.np.where(ee_udes['temp prior living'].str.contains("owned|permanent", case=False), "PERMANENT",
                                                                                                  pd.np.where(ee_udes['temp prior living'].str.contains("habitation", case=False), "NOT HABITABLE", 
                                                                                                              pd.np.where(ee_udes['temp prior living'].str.contains("transition|halfway|safe|interim|foster", case=False), "INTERIM",
                                                                                                                          pd.np.where(ee_udes['temp prior living'].str.contains("Host Home shelter"), "SHELTER","OTHER")))))))))


# In[38]:


ee_udes.groupby("Prior Living").size()


# In[39]:


list(ee_udes.columns.values)


# In[40]:


ee_udes.groupby('Domestic violence victim/survivor(341)').size()


# In[41]:


# Remove the "(HUD)" from this response and combine "Client doesn't know" and "Data not collected" into "Unknown"
dv_deter_map = {"Client doesn't know (HUD)":'Unk', "Client refused (HUD)":'Unk', "No (HUD)":"No", "Yes (HUD)":"Yes"}
ee_udes['Domestic violence victim/survivor'] = ee_udes['Domestic violence victim/survivor(341)'].map(dv_deter_map)
ee_udes['Domestic violence victim/survivor'] = ee_udes['Domestic violence victim/survivor'].replace('Unk', np.NaN)
ee_udes.groupby('Domestic violence victim/survivor').size()


# In[42]:


# select columns of interest
ee_udes= ee_udes[['EE UID', 'Prior Living', 'Domestic violence victim/survivor']]
ee_udes.head()


# ### HEALTH_INS_ENTRY_191102.tsv

# In[43]:


health_ins_entry = pd.read_csv("./data/HEALTH_INS_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')
health_ins_entry.head()


# In[44]:


health_ins_entry = health_ins_entry[health_ins_entry["EE Provider ID"]=='Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)']
health_ins_entry.groupby("EE Provider ID").size()


# In[45]:


health_ins_entry.groupby("Health Insurance Type (Entry)").size()


# In[46]:


health_ins_entry.groupby("Covered (Entry)").size()


# In[47]:


# change data not collected to NaN
health_ins_entry['Covered'] = health_ins_entry["Covered (Entry)"].replace('Data Not Collected', np.NaN)
health_ins_entry.groupby("Covered").size()


# In[48]:


# sorting 
health_ins_entry.sort_values(by=['EE UID', 'Client ID', 'Health Insurance Type (Entry)', 'Date Added (4307-date_added)'], inplace=True)
health_ins_entry


# In[49]:


# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
health_ins_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Health Insurance Type (Entry)'], keep='first',inplace=True)
health_ins_entry


# In[50]:


# keep variables of interest
health_ins_entry=health_ins_entry[['EE UID', 'Covered', 'Health Insurance Type (Entry)']]
health_ins_entry.head()


# In[51]:


# delete entries where health insurance type is NAN - all of these have covered values = nan too
health_ins_entry=health_ins_entry.dropna(subset=['Health Insurance Type (Entry)'])


# In[52]:


#Transform data so 1 column for each insurance type and covered entry as the values.
health_ins_entry_t = health_ins_entry.pivot(index='EE UID', columns='Health Insurance Type (Entry)', values='Covered')
health_ins_entry_t.head()


# In[53]:


health_ins_entry_t['Any Health Insurance']="No"
for index in health_ins_entry_t.index:
    any_ins="No"
    for col in health_ins_entry_t.columns:
        if health_ins_entry_t[col][index] == "Yes":
            any_ins="Yes"
    health_ins_entry_t['Any Health Insurance'][index]=any_ins
health_ins_entry_t.head()


# ### INCOME_ENTRY_191102.tsv

# In[54]:


income_entry = pd.read_csv("./data/INCOME_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')
income_entry.head()


# In[55]:


income_entry = income_entry[income_entry["EE Provider ID"]=='Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)']
income_entry.groupby("EE Provider ID").size()


# In[56]:


income_entry.groupby("Income Source (Entry)").size()


# In[57]:


# Remove the "(HUD)" from this response
income_entry['Income Source']=income_entry['Income Source (Entry)'].str.rstrip(" (HUD)")
income_entry.groupby('Income Source').size()


# In[58]:


income_entry.groupby('Receiving Income (Entry)').size()


# In[59]:


# change data not collected to NaN
income_entry['Receiving Income'] = income_entry["Receiving Income (Entry)"].replace('Data Not Collected', np.NaN)
income_entry.groupby("Receiving Income").size()


# In[60]:


# sorting 
income_entry.sort_values(by=['EE UID', 'Client ID', 'Income Source', 'Date Added (140-date_added)'], inplace=True)
income_entry


# In[61]:


# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
income_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Income Source'], keep='first',inplace=True)
income_entry


# In[62]:


# keep variables of interest
income_entry=income_entry[['EE UID', 'Receiving Income', 'Income Source']]
income_entry.head()


# In[63]:


income_entry=income_entry.dropna(subset=['Income Source'])


# In[64]:


#Transform data so 1 column for each insurance type and covered entry as the values.
income_entry_t = income_entry.pivot(index='EE UID', columns='Income Source', values='Receiving Income')
income_entry_t.head()


# In[65]:


income_entry_t['Any Income Source']="No"
for index in income_entry_t.index:
    any_income="No"
    for col in income_entry_t.columns:
        if income_entry_t[col][index] == "Yes":
            any_income="Yes"
    income_entry_t['Any Income Source'][index]=any_income
income_entry_t.head()


# ### NONCASH_ENTRY_191102.tsv

# In[66]:


noncash_entry = pd.read_csv("./data/NONCASH_ENTRY_191102.tsv", delimiter='\t', encoding='utf-8')
noncash_entry.head()


# In[67]:


noncash_entry = noncash_entry[noncash_entry["EE Provider ID"]=='Urban Ministries of Durham - Durham County - Singles Emergency Shelter - Private(5838)']
noncash_entry.groupby("EE Provider ID").size()


# In[68]:


noncash_entry.groupby("Non-Cash Source (Entry)").size()


# In[69]:


# Remove the "(HUD)" from this response
noncash_entry['Noncash Source']=noncash_entry['Non-Cash Source (Entry)'].str.rstrip(" (HUD)")
noncash_entry.groupby('Noncash Source').size()


# In[70]:


noncash_entry.groupby("Receiving Benefit (Entry)").size()


# In[71]:


# change data not collected to NaN
noncash_entry['Receiving Benefit'] = noncash_entry["Receiving Benefit (Entry)"].replace('Data Not Collected', np.NaN)
noncash_entry.groupby("Receiving Benefit").size()


# In[72]:


# sorting 
noncash_entry.sort_values(by=['EE UID', 'Client ID', 'Noncash Source', 'Date Added (2704-date_added)'], inplace=True)
noncash_entry


# In[73]:


# dropping duplicate values - we will only keep the last dated record because this looks to me like it was an "update"
noncash_entry.drop_duplicates(subset=['EE UID', 'Client ID', 'Noncash Source'], keep='first',inplace=True)
noncash_entry


# In[74]:


# keep variables of interest
noncash_entry=noncash_entry[['EE UID', 'Receiving Benefit', 'Noncash Source']]
noncash_entry.head()


# In[75]:


noncash_entry=noncash_entry.dropna(subset=['Noncash Source'])


# In[76]:


#Transform data so 1 column for each insurance type and covered entry as the values.
noncash_entry_t = noncash_entry.pivot(index='EE UID', columns='Noncash Source', values='Receiving Benefit')
noncash_entry_t.head()


# In[77]:


noncash_entry_t['Any Noncash Source']="No"
for index in noncash_entry_t.index:
    any_noncash="No"
    for col in noncash_entry_t.columns:
        if noncash_entry_t[col][index] == "Yes":
            any_noncash="Yes"
    noncash_entry_t['Any Noncash Source'][index]=any_noncash
noncash_entry_t.head()


# ## Merge to create analytic dataset

# In[78]:


from functools import reduce


# In[79]:


data_frames = [client, entry_exit, ee_udes, disab_entry_t, health_ins_entry_t, income_entry_t, noncash_entry_t]
anl = reduce(lambda  left,right: pd.merge(left,right,on=['EE UID'], how='left'), data_frames)


# In[80]:


anl.head()


# In[81]:


for col in anl.columns: 
    print(col)


# In[82]:


anl.sort_values(by=['Client ID', 'Entry Date'], inplace=True)


# In[83]:


# output first record only
anl_first = anl.drop_duplicates(subset='Client ID', keep='first')
anl_first.head()


# In[84]:


anl.to_csv("./data/analytic.tsv", sep='\t')
anl_first.to_csv("./data/analytic_first.tsv", sep='\t')

