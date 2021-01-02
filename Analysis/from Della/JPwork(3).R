setwd("/tigress/mjt7/shapefiles") # Set this to be the un-zipped folder for your CA shapefiles
dyn.load("/usr/local/gdal/2.2.4/lib64/libgdal.so.20")
library(dplyr)
library(magrittr)
library(readr)
library(R.utils)
library(stringr)
library(rgdal)
library(sp)
library(zoo)

agrepOP <- function(str1, str2){
  if(is.na(str2)){return(10000)}
  val1 <- agrep(str2, str1)
  val2 <- agrep(str1, str2)
  if(length(val1) == 0){val1 <- 10000} #agrep gives integer(0) for all vlaues 
  if(length(val2) == 0){val2 <- 10000}
  if(val1 > val2){return(val2)}
  else{return(val1)}
}

census.places <- readOGR(dsn = './',layer = 'gz_2010_06_160_00_500k')
census.places@data %<>% mutate(NAMELSAD = paste(NAME, LSAD))

#gunzip("/tigress/mjt7/contribDB_1990.csv.gz")
dat1990 <- read_csv("/tigress/mjt7/contribDB_1990.csv")
ca1990 <- dat1990 %>% filter(contributor.state=="CA")
ca1990 %<>% filter(!is.na(longitude), !is.na(latitude))

# Amount, #, median and mean month, % individual, % corporation, % male, 
# employer isFacebook isGoogle isAmazon isMicrosoct indicators, %recipientRep/Ind/Lib, %com, %local/state, meancontCFscore, meancandcfScore
#f test stat for difference in contributor/candidate CF score by candidate party per city
#ttest for difference in Q1 (liberal) and Q3 (conservative)

  #head(tempdata$contributor.type)
#mutate(month = ??date ) %>% #date is in an indeterminate format??
  tempdat2 <- ca1990 %>% rowwise() %>% 
    mutate(isContEng = ifelse((agrepOP("engineer", contributor.occupation) < 2) | (agrepOP("swe", contributor.occupation) < 2) | (agrepOP("programmer", contributor.occupation) < 2) | (agrepOP("computer", contributor.occupation) < 2) | (agrepOP("software", contributor.occupation) < 2), 1, 0),
           isBigTechEmp = ifelse((agrepOP("google", contributor.employer) < 2) | (agrepOP("alphabet", contributor.employer) < 2) | (agrepOP("apple", contributor.employer) < 2) | (agrepOP("microsoft", contributor.employer) < 2) | (agrepOP("amazon", contributor.employer) < 2) | (agrepOP("facebook", contributor.employer) < 2), 1, 0),
           isBigTech = ifelse((agrepOP("google", contributor.name) < 2) | (agrepOP("alphabet", contributor.name) < 2) | (agrepOP("apple", contributor.name) < 2) |  (agrepOP("microsoft", contributor.name) < 2) | (agrepOP("amazon", contributor.name) < 2) | (agrepOP("facebook", contributor.name) < 2), 1, 0))
  tempdat2 <- tempdat2 %>% mutate(isIndvCont = ifelse(contributor.type == "I", 1, 0),
                                  isCorp = ifelse(is.corp == "corp", 1, 0),
                                  isContribMale = ifelse(contributor.gender == "M", 1, 0),
                                  isDemRec = ifelse(recipient.party == 100, 1, 0),
                                  isRepRec = ifelse(recipient.party == 200, 1, 0),
                                  isIndRec = ifelse(recipient.party == 328, 1, 0),
                                  isComRec = ifelse(recipient.type == "COMM", 1, 0),
                                  isGeneral = ifelse(election.type == "G", 1, 0),
                                  cfDiff = as.numeric(contributor.cfscore) - as.numeric(candidate.cfscore))                           
#  sum(tempdat2$isContEng)
#  sum(tempdat2$isBigTechEmp)
#  sum(tempdat2$isBigTech)                            
#  View(tempdat2)
  tempdat3 <- tempdat2 %>% select(latitude, longitude, cycle, amount, starts_with("is"), contributor.cfscore, candidate.cfscore, cfDiff)
  tempdat4 <- tempdat3 %>% mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  sp_caDat <- 
    SpatialPointsDataFrame(coords = select(tempdat4, longitude, latitude), data = tempdat4)
  
  ca.places <- census.places[census.places$STATE=="06", ]
  ca.places %<>% spTransform(CRS("+proj=longlat +datum=WGS84"))
  sp_caDat@proj4string <- ca.places@proj4string
  temp <- over(sp_caDat, ca.places)
  caDat_w_places <- sp_caDat@data %>% bind_cols(temp)
  
  #cycle is year, NAME is city; to convert to actual city name just take of "city" "town" "CDP"
  findat <- caDat_w_places %>% group_by(NAMELSAD) %>% 
    summarize(yr=median(cycle),
              area = median(CENSUSAREA),
              count=n(),
              nIndv=sum(isIndvCont),
              nCorp=sum(isCorp),
              nIndvTech=sum(isContEng),
              nIndvBigTech=sum(isBigTechEmp),
              nCorpBigTech=sum(isBigTech),
              nDemRec=sum(isDemRec),
              nRepRec=sum(isRepRec),
              nIndRec=sum(isIndRec),
              nComRec=sum(isComRec),
              nGen=mean(isGeneral),
              aTot=sum(amount),
              aIndv=sum(subset(amount, isIndvCont==1)),
              aCorp=sum(subset(amount, isCorp==1)),
              aIndvBigTech=sum(subset(amount, isBigTechEmp==1)),
              aIndvTech=sum(subset(amount, isContEng==1)),
              aCorpTech=sum(subset(amount, isBigTech==1)),
              aDemRec=sum(subset(amount, isDemRec==1)),
              aRepRec=sum(subset(amount, isRepRec==1)),
              aIndRec=sum(subset(amount, isIndRec==1)),
              aComRec=sum(subset(amount, isComRec==1)),
              aGen=sum(subset(amount, isGeneral==1)),
              meanCFCont=mean(contributor.cfscore),
              sdCFCont=sd(contributor.cfscore),
              meanCFCand=mean(candidate.cfscore),
              sdCFCand=mean(candidate.cfscore),
              meanCFDiff=mean(cfDiff),
              sdCFDiff = sd(cfDiff))
  
  cadat <- findat %>% filter(!is.na(NAMELSAD))
  leftOut <- findat %>% filter(is.na(NAMELSAD))
  
  write.csv(cadat, "/tigress/mjt7/dat1990")
  write.csv(leftOut, "/tigress/mjt7/error1990")
  
  mean(cadat$yr)
  
  
#  summarize(pnotIndvCorp = ) %>%  faster to do later

  #i can interact for differences big tech individual vs all individuals with pIndvTech
  # interct for differences between big tech corp and all corp by pCorpTech
  
  #BUT i can't interact for indv vs corporate: (come back once i see whats meaningful)
  #Committee vs Candidate, CF, general vs primaryParty donations (total (or mean) money going to Dems - total money going to Reps)