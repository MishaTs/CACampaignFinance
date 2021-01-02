setwd("~/Desktop/Data/JP/thistime/")
library(dplyr)
library(magrittr)
library(readr)
library(R.utils)
library(stringr)

allyears <- list.files(pattern="contribDB_201")
print(allyears)
iter <- 0

#date, Bonica CID and RID, Contributor name, Contributor type, city, employer, corporation, Recipient name, Recipient party,
# Recipient type, Seat, Election type, Contributor cfscore, Candidate cfscore
#by contributor.city

# Amount, #, median and mean month, % individual, % corporation, % male, 
# employer isFacebook isGoogle isAmazon isMicrosoct indicators, %recipientRep/Ind/Lib, %com, %local/state, meancontCFscore, meancandcfScore
#f test stat for difference in contributor/candidate CF score by candidate party per city
#ttest for difference in Q1 (liberal) and Q3 (conservative)

agrepOP <- function(str1, str2){
  if(length(str2) > 1) { #this if condition controls for when we get a vector of values in the target string and iterates through them all
    vr <- c(replicate(length(str2), 10000))
    j <- 1
    for (i in 1:length(str2)) { 
      vr[j] <- agrepOP(str1, i)
      j <- j + 1
    }
    str2 <- str2[which.min(vr)]
  }
  val1 <- agrep(str2, str1)
  val2 <- agrep(str1, str2)
  if(length(val1) == 0){val1 <- 10000} #agrep gives integer(0) for all vlaues 
  if(length(val2) == 0){val2 <- 10000}
  if(val1 > val2){return(val2)}
  else{return(val1)}
}

#| !is.character(contributor.occupation)

f = function(x,pos) { #Filters and aggregates the chunked data you read in. Function input "x" represents the chunk of data. You can ignore "pos" and just leave it there in the function input.
  tempdata <- x %>% filter(contributor.state=="CA")
  #head(tempdata$contributor.type)
  tempdat2 <- tempdata %>% #mutate(month = ??date ) %>% #date is in an indeterminate format??
    mutate(isIndvCont = ifelse(contributor.type == "I", 1, 0)) %>% 
    mutate(isContEng = ifelse((agrepOP("engineer", contributor.occupation) < 2) | (agrepOP("swe", contributor.occupation) < 2) | (agrepOP("computer", contributor.occupation) < 2) | (agrepOP("software", contributor.occupation) < 2), 1, 0)) %>% 
    #maybe include Oracle? Intel? Cisco?
    mutate(isBigTechEmp = ifelse((agrepOP("google", contributor.employer) < 2) | (agrepOP("alphabet", contributor.employer) < 2) | (agrepOP("apple", contributor.employer) < 2) | (agrepOP("microsoft", contributor.employer) < 2) | (agrepOP("amazon", contributor.employer) < 2) | (agrepOP("facebook", contributor.employer) < 2), 1, 0)) %>% 
    mutate(isCorp = ifelse(is.corp == "corp", 1, 0)) %>% 
    mutate(isBigTech = ifelse((agrepOP("google", contributor.ffname) < 2) | (agrepOP("alphabet", contributor.ffname) < 2) | (agrepOP("apple", contributor.ffname) < 2) |  (agrepOP("microsoft", contributor.ffname) < 2) | (agrepOP("amazon", contributor.ffname) < 2) | (agrepOP("facebook", contributor.ffname) < 2), 1, 0)) %>% 
    mutate(isContribMale = ifelse(contributor.gender == "M", 1, 0)) %>% 
    mutate(isDemRec = ifelse(recipient.party == 100, 1, 0)) %>% 
    mutate(isRepRec = ifelse(recipient.party == 200, 1, 0)) %>% 
    mutate(isIndRec = ifelse(recipient.party == 328, 1, 0)) %>% 
    mutate(isComRec = ifelse(recipient.type == "COMM", 1, 0)) %>%    
    mutate(isGeneral = ifelse(election.type == "G", 1, 0)) %>% 
    mutate(cfDiff = as.numeric(contributor.cfscore) - as.numeric(candidate.cfscore))
  
    #View(tempdat2)
  tempdat3 <- tempdat2 %>% mutate_each(funs(replace(., which(is.na(.)), 0))) #get rid of NAs
  
  #testing the code out: looks like it's a bit outdated but works for numeric varibles (and not the rest)
  #testdat <- data.frame(c(NA, "abc", "BCD"), c(0, 1, NA))
  #testdat2 <- testdat %>% mutate_each(funs(replace(., which(is.na(.)), 0)))
  
  #tempdat4 <- data.frame(sapply(tempdat3, function(x) as.numeric(as.character(x)))) #the summary function doesn't work not on non-numerics
  
  
  findat <- tempdat3 %>% group_by(contributor.city) %>% 
    summarize(totAmt = sum(as.numeric(amount)), meanAmt = mean(as.numeric(amount))) %>% 
    summarize(pIndv = mean(as.numeric(tempdat2$isIndvCont))) %>% 
    summarize(pCorp = mean(as.numeric(tempdat2$isCorp))) %>% 
    summarize(pIndvTech = sum(as.numeric(tempdat2$isBigTechEmp))/sum(as.numeric(tempdat2$isIndvCont))) %>%
    summarize(pCorpTech = sum(as.numeric(tempdat2$isBigTech))/sum(as.numeric(tempdat2$isCorp))) %>% 
 #   summarize(pnotIndvCorp = ) %>%  faster to do later
    summarize(pDemRec = mean(as.numeric(tempdat2$isDemRec))) %>%
    summarize(pRepRec = mean(as.numeric(tempdat2$isRepRec))) %>%
    summarize(pIndRec = mean(as.numeric(tempdat2$isIndRec))) %>% 
#   summarize(meanMonth = ) %>%  ??? is it even useful, not sure how to process dates
    summarize(pComRec = mean(as.numeric(tempdat2$isComRec))) %>% 
    summarize(pGen = mean(as.numeric(tempdat2$isGeneral))) %>% 
    summarize(meanContCF = mean(as.numeric(tempdat2$contributor.cfscore))) %>%
    summarize(rangeContCF = sd(as.numeric(tempdat2$contributor.cfscore))) %>% 
    summarize(meanCandCF = mean(as.numeric(tempdat2$candidate.cfscore))) %>% 
    summarize(rangeCandCF = mean(as.numeric(tempdat2$candidate.cfscore))) %>% 
    summarize(meanCFDiff = mean(tempdat2$cfDiff)) %>% 
    summarize(rangeCFDiff = sd(tempdat2$cfDiff))
  
    
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