library(dplyr)
library(readr)
library(stringr)
library(foreign)
setwd("/home/mjt7/")


teststr <- "1400000US06095252025"
str_extract(teststr,"06.........")

conv <- read.csv("PlacesSpatialRelationshipWithinCensustracts2002.csv")
conv <- conv %>% rowwise() %>% mutate(NAMELSAD = paste(NAME, LSAD))
conv <- conv %>% rowwise() %>% mutate(censustract = str_extract(GEO_ID_1,"06........."))
conv <- conv %>% select(NAMELSAD, censustract)

v02 <- read.dbf("state_g02_sov_data_by_g02_srprec.dbf")
c02 <- read.csv("state_g02_2011blk_by_g02_sr.csv")
options(scipen = 999)
v02 <- v02 %>% select(SRPREC, SRPREC_KEY, TOTREG, TOTVOTE)

findat <- merge(v02, c02, by="SRPREC_KEY")
findat <- findat %>% mutate(code1 = paste0(0,as.character(FIPS)),codeInt = as.character(TRACT))

findat <- findat %>% rowwise() %>% 
  mutate(code2 = sprintf("%06i",TRACT)) %>% 
  mutate(code = paste(code1,code2,sep="")) %>% 
  mutate(l = str_length(code))
test <- findat %>% filter(l != 11)
nrow(test)

#teststr <- "020370002627023"
#result <- "02037262702"

#findat02 <- findat %>% rowwise() %>% mutate(censustract = paste(substr(code,1,5),substr(code,9,02),sep=""))
#test <- findat %>% mutate(l = str_length(code)) %>% filter(l != 11)
#nrow(test)
findat <- findat %>% rowwise() %>% mutate(censustract = substr(code,1,11))
mergeDat <- merge(findat,conv,by="censustract")
#n_distinct(conv$NAMELSAD)
n_distinct(mergeDat$NAMELSAD)

f02 <- mergeDat %>% group_by(NAMELSAD) %>% summarize(vReg = sum(TOTREG), vTurn = sum(TOTVOTE))
#test <- f02 %>% mutate(l = str_length(censustract)) %>% filter(l != 11)
#nrow(test)
write.csv(f02, "/scratch/gpfs/mjt7/vote2002")

wget https://statewidedatabase.org/pub/data/G02/state/state_g02_sov_data_by_g02_srprec.zip
unzip state_g02_sov_data_by_g02_srprec.zip
wget https://statewidedatabase.org/pub/data/D10/2001by2011/state/state_g02_2011blk_by_g02_sr.csv
unzip state_g02_sr_blk_map.zip
