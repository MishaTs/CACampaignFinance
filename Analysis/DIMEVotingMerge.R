#merge DIME and Voting by census tract
#create first 7 character called GEO_FIPS

setwd("~/Desktop/Data/JP/")
library(tidyverse)
library(readr)
library(stringr)

dime2018 <- read.csv("dime/dat2018")
vote2018 <- read.csv("voting clean/vote2018")

#View(vote2018)
#View(dime2018)

merge2018 <- merge(dime2018, vote2018, by="censustract")

#drop X.x aMean, pIndv, pCorp, pDemRec, pRepRec, pIndRec, pComRec, pGen, mIndv, mCorp, 
#add nDemRec, nRepRec, nIndRec, nComRec, nGen
merge2018 <- merge2018 %>% mutate(nDemRec = pDemRec*count, nRepRec = pRepRec*count, nIndRec = pIndRec*count, nComRec = pComRec*count, nGen = pGen*count)
merge2018 <- merge2018 %>% select(-c("X.x", "aMean", "pIndv", "pCorp", "pDemRec", "pRepRec", "pIndRec", "pComRec", "pGen", "mIndv", "mCorp", "mIndvBigTech", "mIndvTech", "mCorpTech", "mDemRec", "mRepRec", "mIndRec", "mComRec", "mGen", "X.y"))

merge2018 %>% summarise_all(funs(sum(is.na(.))))

merge2018 <- merge2018 %>% mutate_each(funs(replace(., which(is.na(.)), 0))) #get rid of NAs
write.csv(merge2018, "clean 1/merge2018")

