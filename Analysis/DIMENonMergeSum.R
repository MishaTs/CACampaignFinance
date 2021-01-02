#merge DIME and Voting by census tract
#create first 7 character called GEO_FIPS

setwd("~/Desktop/Data/JP/")
library(tidyverse)
library(readr)
library(stringr)

merge1988 <- read.csv("dime/dat1988")

#View(dime1988)

#drop X.x aMean, pIndv, pCorp, pDemRec, pRepRec, pIndRec, pComRec, pGen, mIndv, mCorp, 
#add nDemRec, nRepRec, nIndRec, nComRec, nGen
merge1988 <- merge1988 %>% mutate(nDemRec = pDemRec*count, nRepRec = pRepRec*count, nIndRec = pIndRec*count, nComRec = pComRec*count, nGen = pGen*count)
merge1988 <- merge1988 %>% select(-c("X", "aMean", "pIndv", "pCorp", "pDemRec", "pRepRec", "pIndRec", "pComRec", "pGen", "mIndv", "mCorp", "mIndvBigTech", "mIndvTech", "mCorpTech", "mDemRec", "mRepRec", "mIndRec", "mComRec", "mGen"))

merge1988 %>% summarise_all(funs(sum(is.na(.))))

merge1988 <- merge1988 %>% mutate_each(funs(replace(., which(is.na(.)), 0))) #get rid of NAs

merge1988 <- merge1988 %>% mutate(vReg = NA, vTurn=NA)
write.csv(merge1988, "clean 1/merge1988")



# create NA column vectors with vReg vTurn