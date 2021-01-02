setwd("~/Desktop/Data/JP/")
library(tidyverse)
library(readr)
library(stringr)
#library(foreign)

#hh06 <- hh2006
#fixeddat <- hh06
#keep <- hh06$Geo_FIPS

text <- read_file("ACSDataRaw.txt")
ul <- unlist(strsplit(text, split = ":"))
names <- str_extract(ul, '\\w+$')
acsnames <- names %>% str_subset(pattern = "_")
acsnames <- paste0("SE_", acsnames)

#error1990 <- read_csv("error1990")

#dat2006 <- read_csv("dat2006")
#dat2006 <- dat2006 %>% mutate(ct = as.numeric(censustract))

#nas <- dat2006 %>% 
#  select_if(function(x) any(is.na(x))) %>% 
#  summarise_each(funs(sum(is.na(.))))

#dat2006 <- dat2006 %>% replace(., is.na(.), 0)

#election data only exists from 1996
#conversions only exist from 2004

#census data only from 2006

acs2006 <- read.csv("acs/2006.csv")
#work2006 <- acs2006[acs2006$Geo_FIPS %in% keep, ]
#acs2006 <- work2006[colSums(!is.na(work2006)) == nrow(work2006)]

#acs2006 %>% select(SE_A00003_002, SE_A00002_003)

#setdiff(acsnames, colnames(acs2006))

hh2006 <- acs2006 %>% select("Geo_FIPS", "Geo_NAME", all_of(acsnames))
#remove SE_A18007_004, 

#remove ", California" from GEO_Name and

#hh2006 %>% summarise_all(funs(sum(is.na(.))))

dem2006 <- hh2006 %>% rowwise() %>% mutate(place = str_remove(Geo_NAME, ", California"))
write.csv(dem2006, "acs clean/acs2006")


#add leading 0 to GEO_FIPS??