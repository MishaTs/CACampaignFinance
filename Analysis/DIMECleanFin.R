setwd("~/Desktop/Data/JP/gz_2010_06_160_00_500k")
library(dplyr)
library(magrittr)
library(readr)
library(R.utils)
library(stringr)
library(rgdal)
library(sp)
library(zoo)

census.places <- readOGR(dsn = './',layer = 'gz_2010_06_160_00_500k')
census.places@data %<>% mutate(NAMELSAD = paste(NAME, LSAD))

setwd("~/Desktop/Data/JP/thistime/")
allyears <- list.files(pattern="contribDB_201")
print(allyears)
iter <- 0

agrepOP <- function(str1, str2){
  if(is.na(str2)){return(10000)}
  val1 <- agrep(str2, str1)
  val2 <- agrep(str1, str2)
  if(length(val1) == 0){val1 <- 10000} #agrep gives integer(0) for all vlaues 
  if(length(val2) == 0){val2 <- 10000}
  if(val1 > val2){return(val2)}
  else{return(val1)}
}

f = function(x,pos) { #Filters and aggregates the chunked data you read in. Function input "x" represents the chunk of data. You can ignore "pos" and just leave it there in the function input.
  tempdata <- x %>% filter(contributor.state=="CA")
  #head(tempdata$contributor.type)
  tempdat2 <- tempdata %>% rowwise() %>% 
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
  
  tempdat2 <- tempdat2 %>% filter(!is.na(longitude), !is.na(latitude))
  
  caDat <- tempdat2 %>% select(latitude, longitude, cycle, amount, starts_with("is"), contributor.cfscore, candidate.cfscore, cfDiff)
  
  sp_caDat <- 
    SpatialPointsDataFrame(coords = select(caDat, longitude, latitude), data = caDat)
  
  ca.places <- census.places[census.places$STATE=="06", ]
  ca.places %<>% spTransform(CRS("+proj=longlat +datum=WGS84"))
  sp_caDat@proj4string <- ca.places@proj4string
  temp <- over(sp_caDat, ca.places)
  caDat_w_places <- sp_ca2010@data %>% bind_cols(temp)
  
  tempdat4 <- caDat_w_places %>% mutate_each(funs(replace(., which(is.na(.)), 0))) #get rid of NAs
  
  #testing the code out: looks like it's a bit outdated but works for numeric varibles (and not the rest)
  #testdat <- data.frame(c(NA, "abc", "BCD"), c(0, 1, NA))
  #testdat2 <- testdat %>% mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  #tempdat4 <- data.frame(sapply(tempdat3, function(x) as.numeric(as.character(x)))) #the summary function doesn't work not on non-numerics
  
  
  findat <- tempdat4 %>% group_by(censustract) %>% 
    summarize(yr=median(cycle),
              count=n(),
              aTot=sum(amount),
              aMean=mean(amount),
              pIndv=mean(isIndvCont),
              nIndv=sum(isIndvCont),
              nCorp=sum(isCorp),
              pCorp=mean(isCorp),
              nIndvTech=sum(isContEng),
              nIndvBigTech=sum(isBigTechEmp),
              nCorpBigTech=sum(isBigTech),
              pDemRec=mean(isDemRec),
              pRepRec=mean(isRepRec),
              pIndRec=mean(isIndRec),
              pComRec=mean(isComRec),
              pGen=mean(isGeneral),
              meanContCF=mean(contributor.cfscore),
              rangeContCF=sd(contributor.cfscore),
              meanCandCF=mean(candidate.cfscore),
              rangeCandCF=mean(candidate.cfscore),
              meanCFDiff=mean(cfDiff),
              rangeCFDiff = sd(cfDiff),
              aIndv=sum(subset(amount, isIndvCont==1)),
              aCorp=sum(subset(amount, isCorp==1)),
              aIndvBigTech=sum(subset(amount, isBigTechEmp==1)),
              aIndvTech=sum(subset(amount, isContEng==1)),
              aCorpTech=sum(subset(amount, isBigTech==1)),
              aDemRec=sum(subset(amount, isDemRec==1)),
              aRepRec=sum(subset(amount, isRepRec==1)),
              aIndRec=sum(subset(amount, isIndRec==1)),
              aComRec=sum(subset(amount, isComRec==1)),
              aGen=sum(subset(amount, isGeneral==1)))
  
  #i can interact for differences big tech individual vs all individuals with pIndvTech
  # interct for differences between big tech corp and all corp by pCorpTech
  
  #BUT i can't interact for indv vs corporate: (come back once i see whats meaningful)
  #Committee vs Candidate, CF, general vs primaryParty donations (total (or mean) money going to Dems - total money going to Reps)
  
  return(findat)
}

ca_donations <- vector("list", length(allyears)) 

for (filename in allyears) {
  iter <- iter + 1
  print(iter)
  print(filename)
  gunzip(filename) # read_csv_chunked() can malfunction with zipped data, so you need to unzip each file here and re-zip it after extracting what you need. gunzip() is from the R.utils package.
  csvname <- str_sub(filename, 1, -4) # This grabs the unzipped .csv file rather than the original, zipped .csv.gz file.
  ca_donations[[iter]] <- 
    read_csv_chunked(csvname,col_types=cols(.default=col_character()),
                     DataFrameCallback$new(f), chunk_size=2e6) # Set the size of each chunk of data you want to read into RAM at a time. Your computer with 16GB should be able to handle 2 million rows at a time.
  gzip(csvname) # Re-zip your file here to not overwhelm your drive space. gzip() is also from the R.utils package.
}
ca_donations %<>% bind_rows()


# To summarize contributions from a given firm:
#   find the desired firm using column "contributor.name" in the contribution database (i.e., files with names like "contribDB_2018.csv.gz").
#   find the corresponding time-invariant contributor ID, i.e., column "bonica.cid" ("c" for contributor; not to be confused with "bonica.rid"), for said firm.
# Aggregate corporate contributions by city of the corporation:  full address of contributors in the contribution database (e.g., "contributor.city" in the contribution database)

# Aggregate your data on corporate contributions by the city of the recipient candidate:
#   Open up the recipient database ("dime_recipients_all_1979_2018.csv") and subset by election cycle ("cycle") if desired. 
#   further subset to the desired CA candidates by looking at the variables "election type" and "district" in the recipient database (read the codebook)
#   Collapse the filtered recipient database by unique candidate (as identified by "bonica.rid", where "r" stands for recipient) and election cycle ("cycle). 
#   you may have to do a bit of manual coding to link each candidate to the city they represent, since city boundaries and district boundaries are not the same.
# Save the resulting database somewhere and call it, say, "CA-candidates.csv".
# Now, return to the contribution database, and filter this database to only rows where "bonica.rid" corresponds to one of the "bonica.rid" values in "CA-candidates.csv".
# Next, still within the contribution database, summarize firm-level contributions ("bonica.cid") by recipient ("bonica.rid") and election cycle ("cycle").
# Finally, merge the resulting aggregated data from the contribution database with "CA-candidates.csv" by "bonica.rid" and "cycle". Now you have successfully linked firm-level contribution data by the geographic units that each recipient candidate represents. And you can further aggregate your firm-level contribution data by these geographic units as you desire.

# To get total contributions by individuals from a given geographic unit (much more straightforward):
# Open up the contribution database (i.e., files with names like "contribDB_2018.csv.gz") and filter to just Californian data (by filtering on "contributor.state") and just contributions from individuals (by filtering on "recipient.type") if desired.
# To aggregate the data by geographic unit, you can simply use the desired geography-related variable in this database, which include street-level address, zip code, city, state, congressional district, and census tract (see codebook).
# If you need to do such aggregation separately for federal, state, and local elections, you can infer election type by looking at the "seat" variable in the contribution database (see codebook for how to interpret this variable).

#contribDB_2010 <- read_csv("Desktop/Data/JP/contribDB_2010.csv")
#head(contribDB_2010)