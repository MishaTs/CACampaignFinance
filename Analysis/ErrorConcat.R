setwd("~/Desktop/Data/JP/dime clean/")
library(dplyr)
library(magrittr)
library(readr)
library(R.utils)
library(stringr)

error1980 <- read.csv("error1980")
error1982 <- read.csv("error1982")
error1984 <- read.csv("error1984")
error1986 <- read.csv("error1986")
error1988 <- read.csv("error1988")
error1990 <- read.csv("error1990")
error1992 <- read.csv("error1992")
error1994 <- read.csv("error1994")
error1996 <- read.csv("error1996")
error1998 <- read.csv("error1998")
error2000 <- read.csv("error2000")
error2002 <- read.csv("error2002")
error2004 <- read.csv("error2004")
error2006 <- read.csv("error2006")
error2008 <- read.csv("error2008")
error2010 <- read.csv("error2010")
error2012 <- read.csv("error2012")
error2014 <- read.csv("error2014")
error2016 <- read.csv("error2016")
error2018 <- read.csv("error2018")

errors <- rbind(error1980,error1982,error1984,error1986,error1988,error1990,error1990,error1992,error1994,error1996,error1998,error2000,error2002,error2004,error2006,error2008,error2010,error2012,error2014,error2016,error2018)
errors <- errors %>% select(-c(X,NAMELSAD,area,nGen,aGen))
errors <- errors %>% select(-c(starts_with('n')))
errors <- errors %>% select(-c(starts_with('sd')))

dimeExcluded <- errors %>% select(-meanCFDiff)
write.csv(dimeExcluded, "~/Desktop/Data/JP/dimeExcluded.csv")