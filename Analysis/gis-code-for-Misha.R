setwd("~/Desktop/Data/JP/gz_2010_06_160_00_500k")
library(dplyr)
library(magrittr)
library(readr)
library(rgdal)
library(sp)
library(zoo)

# Set this to be the un-zipped folder for your CA shapefiles
ca.places <- readOGR(dsn = './',layer = 'gz_2010_06_160_00_500k')
census.places@data %<>% mutate(NAMELSAD = paste(NAME, LSAD))


View(ca.places@data) # You can inspect the data layer of the shapefiles for yourself.
conv <- ca.places@data
conv <- conv %>% mutate(NAMELSAD = paste(NAME, LSAD), GEOID = paste0(STATE,PLACE))

#create GEO_FIPS (add STATE + PLACE OR take the last 7 characters of GEO_ID) and GEO_Name (NAME + " " + LSAD)

GEOID_to_name <- conv %>% select(GEOID, NAMELSAD, CENSUSAREA) # I have double-checked that each GEOID corresponds to a unique place name
#works until here

ca2010 <- read.csv("~/Desktop/Data/JP/pre clean/merge2010")
ca2010 <- ca2010 %>% mutate(ct = paste0("0",censustract))

ca2010 %<>% # Let this data frame be the one you extracted from DIME (before all the summarize() operations!)
  mutate(
    GEOID = str_sub(ct, 1, 7),
    varCFCont = rangeContCF^2,
    varCFCand = rangeCandCF^2,
    varCFDiff = rangeCFDiff^2
  )

grouped <- ca2010 %>% group_by(GEOID) %>%
  summarise(
    yr = median(yr),
    count = sum(count),
    tot = sum(aTot),
    nIndv = sum(nIndv),
    nCorp = sum(nCorp),
    nIndvTech = sum(nIndvTech),
    nIndvBT = sum(nIndvBigTech),
    nCorpBT = sum(nCorpBigTech),
    nDemRec = sum(nDemRec),
    nRepRec = sum(nRepRec),
    nIndRec = sum(nIndRec),
    nComRec = sum(nComRec),
    nGen = sum(nGen),
    nVote = sum(vTurn),
    nReg = sum(vReg),
    aIndv = sum(aIndv),
    aCorp = sum(aCorp),
    aIndvTech = sum(aIndvTech),
    aIndvBT = sum(aIndvBigTech),
    aCorpBT = sum(aCorpTech),
    aDemRec = sum(aDemRec),
    aRepRec = sum(aRepRec),
    aIndRec = sum(aIndRec), 
    aComRec = sum(aComRec),
    aGen = sum(aGen),
    meanCFCont = sqrt(sum(meanContCF)/sum(count)),
    meanCFCant = sqrt(sum(meanCandCF)/sum(count)),
    meanCFDiff = sqrt(sum(meanCFDiff)/sum(count)),
    rangeCFCont = sqrt(sum(varCFCont)/sum(count)),
    rangeCFCand = sqrt(sum(varCFCand)/sum(count)),
    rangeCFDiff = sqrt(sum(varCFDiff)/sum(count)))

coded2010 <- merge(grouped, GEOID_to_name, by="GEOID") 



#ca2010 %<>% left_join(GEOID_to_name, by="GEOID") # This merges the census places data with your DIME data
#ca2010 %<>% rename(cleaned.city.name = NAMELSAD) # You can rename the census place name variable to whatever you like, such as "cleaned.city.name"
  