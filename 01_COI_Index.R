#Set working directory

# ==================================
# TITLE: COI INDEX
# Created: 	2024-05-16
# Modified:	2024-08-09
# ==================================

# Description: This file expands the COI-INDEX and matches into an incorporation
# data since 2000 for a map at the tract-level for Gwinnett, Fulton, & DeKalb
#County in Metro-Atlanta, GA This file also creates the visualization for 
#incorporation since 2000 at the state level. 


########################library statements##################

library(tidyverse)
library(tidyr)
library(dplyr)
library(ggplot2)
library(stringr)
remotes::install_github("UrbanInstitute/urbnthemes")
remotes::install_github("UrbanInstitute/urbnmapr")
library(urbnthemes)
library(urbnmapr)
library(readxl)
library(writexl)
library(tigris)
library(sf)
options(tigris_class = "sf")
options(tigris_use_cache = TRUE)
library(rayshader)
library(tidylog)
library(readr)
library(ggrepel)


#########################Importing the Data#############################

#COI data
coi <- read_csv("Data/1_index.csv")
sub <- read_csv("Data/2_subdomains.csv")
race <- read_csv("Data/3_pop.csv")

#Municipal State level Incorporation dataset
  #Keeping Observations after 2000
State <- read_csv("exports/muni-incorp-state-full.csv")  %>% 
  filter(year>=2000) %>%
  arrange(year) %>% arrange(statefips) %>% 
  group_by(statefips,state_abbv) %>% 
  summarise(total= sum(incorp_count)) %>%
  rename(state_fips = statefips )

#municipal incorporation and georgia census tract data
#pulling in georgia cities after 2000:

municip <- read_csv("exports/muni-incorp-full.csv") %>%
  filter(yr_incorp >=2000, state_abbv == 'GA') %>%
  arrange(yr_incorp) %>%
  rename(state_fips = statefips) %>%
  mutate(muniname = str_remove_all(muniname, "CITY OF ")) %>%
  mutate(muniname = str_to_title(muniname)) %>%
  mutate(countyname = str_to_title(countyname)) %>%
  select(-statename, -state_abbv)

#pulling georgia census tract data
  #identifying duplicated tracts and filtering to three counties : Dekalb, Fulton, Gwinnett
  #fixing tract rounding issues

ga_census_tract <- read_excel("Data/Georgia_Census Tracts.xlsx", sheet = "Georgia_Census Tracts") %>%
  filter(state != 'State code') %>%
  mutate(tract= as.numeric(tract)) %>%
  mutate(tract = sprintf("%.2f", tract))%>% 
  mutate(tract = as.numeric(tract)) %>%
  mutate(PlaceName = gsub("city, GA", "", PlaceName)) %>%
  mutate(CountyName = str_remove_all(CountyName, " GA")) %>%
  mutate(CountyName = str_to_title(CountyName)) %>%
  filter(CountyName %in% c('Fulton', 'Dekalb', 'Gwinnett')) %>%
  arrange(desc(`municipal incorporation indicator`)) %>%
  mutate(keep_row = if_else(`municipal incorporation indicator` == 1, 
                            !duplicated(tract), 
                            TRUE))%>%  
  group_by(tract) %>%
  mutate(id = row_number()) %>%
  ungroup() %>%distinct(tract,.keep_all = TRUE) %>%
  rename("state_fips"  = state, 
         "state_abbv"  = stab, 
         "county_fips" = county,
         placecity= place, 
         city = PlaceName) %>%
  select(-keep_row, -id, -pop20, -afact)


#Pulling Census tracts to GEOID20 data from Census Gov
fulton_tract<- read_delim(file = "Data/census_2020/Fulton_tract_geoid20.txt", delim = ";", col_names = TRUE)  %>%
  select(-STATE, -COUNTY)
gwinnett_tract <- read_delim(file = "Data/census_2020/Gwinnett_tract_geoid20.txt", delim = ";", col_names = TRUE) %>%
  select(-STATE, -COUNTY)
dekalb_tract <- read_delim(file = "Data/census_2020/Dekalb_tract_geoid20.txt", delim = ";", col_names = TRUE) %>%
  select(-STATE,-COUNTY)

#Pulling Atlanta tracts for Fulton, Gwinnett, & Dekalb: 750 tracts
atl_tracts <- tracts("GA", c("Fulton", "Dekalb", "Gwinnett"), year= 2021, cb = TRUE ) %>% 
  rename(geometry_metro = geometry, geoid20 = GEOID, tract = NAME) %>%
  mutate(tract = as.numeric(tract))

#pulling state map 
map_state <- get_urbn_map(map = "states", sf = TRUE)

####################Merging Datasets#######################################
#creating a merge column variable list
merge_cols <- c('geoid20', 'year', 'state_fips', 'state_usps', 'state_name', 
                'county_fips', 'county_name', 'metro_fips', 'metro_name', 
                'metro_type')
race_cat <- c('aian', 'asian','black', 'hisp' , 'white', 'total')



#appending datasets for tract to Geoid20
tract_geoid20 <- bind_rows(fulton_tract, gwinnett_tract, dekalb_tract) %>%
  select(-TYPE, -SHEETS) %>%
  mutate(FULLCODE = as.character(FULLCODE)) %>%
  rename(tract = TRACT, geoid20 = FULLCODE)

#merging COI, subdomains, and Race demographic data together
  #identifying the Atlanta-Metro counties of interest in COI

index <- coi %>% 
  full_join(sub, by = merge_cols) %>%
  left_join(race, by = c('geoid20', 'year')) %>%
  filter(state_fips == "13" & metro_fips == 12060) %>%
  select(all_of(merge_cols),
         r_COI_nat, r_COI_stt, r_COI_met, c5_COI_met,
         r_SE_EI_nat, r_SE_EI_stt, r_SE_EI_met,
         all_of(race_cat), -metro_type,
         -state_fips, -state_usps)%>% 
  filter(year == 2021) %>%
  filter(county_fips %in% c('13121', '13089', '13135')) 


#merging Municipality data and ga_census_tract together
place_data <- ga_census_tract %>%
  left_join(tract_geoid20, by = "tract") %>%
  arrange(tract, `municipal incorporation indicator`) %>%
  full_join(municip, by = c('state_fips','placecity')) #Matched on 210 rows
  

#merging the COI index and the place data
data <- index %>%
  full_join(place_data, by = c("geoid20", "county_fips")) %>%
  select(-metro_fips, metro_name)
  

#Merging State maps together
data2000 <- State %>%
  left_join(map_state, by = c('state_fips', 'state_abbv'))

##Creating the Municipality Map

########Tracts & Municip - mapping atl_tracts with municipal data

##FUll Dataset : Both Incorporated and Unincorporated Cities
df <- data %>% #full dataset
  left_join(atl_tracts, by = c('tract', 'geoid20'))

df2012 <- data %>% #full dataset
  left_join(atl_tracts, by = c('tract', 'geoid20'))

##Incorporated Datasets ONLY
geo_merged <- data %>%
  filter(`municipal incorporation indicator` == 1) %>%
  left_join(atl_tracts, by = c('tract')) %>%
  select(-c(state_abbv, state_name, county_fips, 
            CountyName, countyfips, countyname, NAMELSADCO, STATE_NAME, LSAD, ALAND, 
            AWATER, STATEFP, COUNTYFP, STUSPS, geoid20.y)) %>%
  rename(geoid20 = geoid20.x) %>%
  rename(indicator = `municipal incorporation indicator`) %>%
  mutate(color = case_when(city %in% c('Sandy Springs ', 'Milton ',  'Johns Creek ') ~ "#db2b27",
                           city %in% c( 'Dunwoody ', 'Chattahoochee Hills ') ~"#fdbf11" ,
                            city %in% c( 'Brookhaven ', 'Peachtree Corners ' ) ~ "green",
                           city %in% c( 'Stonecrest ', 'South Fulton ' , 'Tucker ') ~ "#ca5800" ))%>%
  select(c(muniname, yr_incorp , indicator, starts_with('r_'), race_cat, everything(), -indicator))



##Unincorporated Datasets ONLY
geo_merged_non <- data %>%
  filter(`municipal incorporation indicator`== 0) %>%
  left_join(atl_tracts, by = c('tract')) %>%
  select(-c(state_abbv, state_name, county_fips, 
            CountyName, countyfips, countyname, STATE_NAME, LSAD, ALAND, 
            AWATER, STATEFP, COUNTYFP, STUSPS, geoid20.y, census_id_pid6, lat, long,
            muniname, yr_incorp, census_id, geoid, NAMELSADCO)) %>%
  rename(geoid20 = geoid20.x) 


#Grouping the municipalities together for the map
atl_city <- geo_merged %>%
  distinct(city, .keep_all = TRUE) %>%
  mutate(label = paste(muniname, yr_incorp, sep = ": ")) %>%
  arrange(yr_incorp)


#COI MAP Visualization
Map <- 
  ggplot() +
  geom_sf(data = df, aes(geometry = geometry_metro, fill = r_COI_met), color = "white") + 
  labs(title = 'Child Opportunity Index in Atlanta - Metropolitan Normed, 2021') +
  geom_sf(data =  geo_merged, color = geo_merged$color, size = 5, aes( geometry = geometry_metro,
                                                                       fill = r_COI_met ), lwd = .8)+
  geom_label_repel(data = atl_city, 
                   mapping = aes(label = label, x = long, y = lat) ,
                   size = 3, box.padding = 0.1,
                   nudge_y  = c(0,0.07,0,-0.1,0.05,-0.04,0.1,-0.08,0,-0.015),
                   nudge_x = c(-.18, .05, -.12, 0, -0.2, -.25, -0.35, .27, 0.25, .25),
                   label.padding = unit(0.75, "mm"),
                   colour = "black",
                   segment.colour = atl_city$color,
                   segment.size = .75) +
  scale_fill_gradientn(name = "COI")+
  theme_urbn_map() 


print(Map)
#Creating a second Map version

Mapv2 <- 
  ggplot() +
  geom_sf(data = df, aes(geometry = geometry_metro, fill = r_COI_met), color = "grey") + 
  labs(title = 'Child Opportunity Index in Atlanta - Metropolitan Normed, 2021') +
  geom_sf(data =  geo_merged, color = geo_merged$color, size = 5, aes( geometry = geometry_metro,
                                                                       fill = r_COI_met ), lwd = .5)+
  geom_label_repel(data = atl_city, 
                   mapping = aes(label = label, x = long, y = lat) ,
                   size = 3, box.padding = 0.1,
                   nudge_y  = c(0,0.07,0,-0.1,0.05,-0.04,0.1,-0.08,0,-0.015),
                   nudge_x = c(-.18, .05, -.12, 0, -0.2, -.25, -0.35, .27, 0.25, .25),
                   label.padding = unit(0.75, "mm"),
                   colour = "black",
                   segment.colour = atl_city$color,
                   segment.size = .75) +
  scale_fill_gradient(name = "COI"  , low = "#0a4c6a", high = "#a2d4ec") +
  theme_urbn_map() 

print(Mapv2)


#Incporation by State Visualization
  #Adding Urban Map design
set_urbn_defaults(style = "map")
state_2000 <- data2000 %>% 
  ggplot() +
  geom_sf(aes( geometry = geometry,
               fill = total)) + 
  labs(title = 'Municipal Incorporation by State, 2000-2022') + scale_fill_gradientn(name = "Total")



###########################Exporting Data#####################################

#ShapeFiles
dataset_list <- list('full_2012' = df, 
                      'incorporated' = geo_merged, 
                      'unincorporated' = geo_merged_non)
write_xlsx(dataset_list, "exports/COI_Shape_Map.xlsx")
##Exporting the Dataset of incorporations since 2000

#Municipal Incorporation since 2000 export
write_xlsx(State, "exports/state_incorpration.xlsx")


#Visualizations
  #COI data
ggsave("graphs/COI_Visualizationv1.png",plot = urbn_plot(Map, urbn_logo_text(),ncol=1,heights=c(30,1)), width = 7, height = 5)
ggsave("graphs/COI_Visualizationv2.png",plot = urbn_plot(Mapv2, urbn_logo_text(),ncol=1,heights=c(30,1)), width = 7, height = 5)

  #State Incorporation Data
ggsave("graphs/state_total.png",plot = urbn_plot(state_2000, urbn_logo_text(),ncol=1,heights=c(30,1)), width = 6.5, height = 3.7)