library(dplyr)
library(magrittr)
library(readr)
library(rgdal)
library(sp)
library(zoo)

setwd("~/Desktop/ca-places-boundaries/") # Set this to be the un-zipped folder for your CA shapefiles
ca.places <- readOGR(dsn = './',layer = 'CA_Places_TIGER2016')

View(ca.places@data) # You can inspect the data layer of the shapefiles for yourself.

GEOID_to_name <- ca.places@data %>% select(GEOID, NAME) # I have double-checked that each GEOID corresponds to a unique place name

ca2010 %<>% # Let this data frame be the one you extracted from DIME (before all the summarize() operations!)
  mutate( 
    GEOID = str_sub(censustract, 1, 7)
  )  
ca2010 %<>% left_join(GEOID_to_name, by="GEOID") # This merges the census places data with your DIME data
ca2010 %<>% rename(cleaned.city.name = NAME) # You can rename the census place name variable to whatever you like, such as "cleaned.city.name"
  