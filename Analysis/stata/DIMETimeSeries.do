set more off
set linesize 240
clear all
ssc install outreg2
cd "/Users/mishat/Desktop/Data/JP/stata"

log using DIMETimeSeries.log, replace
//few nonlinear transformations have been tried (square and log terms)
//nIndv and aIndv robust to logarithmic transformations
//with aIndv, nCorp, count, nIndvTech robust to transformations
//with nIndv,
import delimited "/Users/mishat/Desktop/Data/JP/final/dimeTS.csv", case(preserve) numericcols(28 32) 
drop v1 nGen aGen sdCFCont sdCFDiff

desc
sum
outreg2 using sum1.doc, replace sum(log)
format yr %ty
xtset id yr

gen mIndv = aIndv/nIndv
gen mIndvTech = aIndvTech/nIndvTech
gen mIndvBigTech = aIndvBigTech/nIndvBigTech
gen mBigTech = aCorpTech/nCorpBigTech
gen mCorp = aCorp/nCorp

//Ftests
mvtest means mIndv mIndvTech mIndvBigTech
mvtest means mCorp mBigTech
//test mIndv=mIndvTech=mIndvBigTech
//test mCorp=mBigTech
ttest mCorp=mBigTech

//create time FE
tab yr, gen(year)

//nCorp nIndvTech nIndvBigTech nCorpBigTech nDemRec nRepRec nIndRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec aIndRec aComRec aGen meanCFCont meanCFCand sdCFCand meanCFDiff
//aIndv nIndv

//dataset1 regressions
xtreg aIndv aCorp aTot, fe vce(cluster id)
outreg2 using amountReg1.doc, replace
 
xtreg aIndv aCorp aTot year*, fe vce(cluster id)
outreg2 using amountReg1.doc, append
 
xtreg aIndv aCorp aTot count nCorp nIndvTech nIndvBigTech nCorpBigTech aIndvBigTech aIndvBigTech aIndvTech aCorpTech year*, fe vce(cluster id)
outreg2 using amountReg1.doc, append
 
xtreg aIndv aCorp aTot aDemRec aRepRec aIndRec meanCFCand meanCFCont aIndvTech aIndvBigTech aCorpTech count nCorp nIndvTech nIndvBigTech nCorpBigTech nCom nDemRec nRepRec nIndRec year*, fe vce(cluster id)
outreg2 using amountReg1.doc, append
 

xtreg nIndv nCorp, fe vce(cluster id)
outreg2 using numReg1.doc, replace
 
xtreg nIndv nCorp count year*, fe vce(cluster id)
outreg2 using numReg1.doc, append
 
xtreg nIndv aCorp aTot count nCorp nIndvTech nIndvBigTech nCorpBigTech aIndvBigTech aIndvBigTech aIndvTech aCorpTech year*, fe vce(cluster id)
outreg2 using numReg1.doc, append
 
xtreg nIndv aTot aCorp aComRec meanCFCand meanCFCont aIndvTech aIndvBigTech aCorpTech count nCorp nIndvTech nIndvBigTech nCorpBigTech nCom nDemRec nRepRec nIndRec year*, fe vce(cluster id)
outreg2 using numReg1.doc, append
 

clear


import delimited "/Users/mishat/Desktop/Data/JP/final/dimeVoteTS.csv", case(preserve) numericcols(28 32) 
drop v1 nGen aGen sdCFCont sdCFDiff
desc
sum
xtset id yr
tab yr, gen(year)
//ys are vTurn, vReg, turnoutR (also aIndv and nIndv but we have higher-power regressions earlier)
//no need to repeat on the subset 2006-2018
//the turnout and registration data looks too strange to include in any fractions 
gen turnoutR = vTurn/vReg
sum
outreg2 using sum2.doc, replace sum(log)

/*
gen logTurn = log(vTurn)
gen logReg = log(vReg)
gen logR = log(turnoutR)
gen logaCorp = log(aCorp)
gen lognCorp = log(nCorp)
gen logaCorpTech = log(aCorpTech)
gen lognCorpBigTech = log(nCorpBigTech)
gen lognIndvTech = log(nIndvTech)
gen logaIndvTech = log(aIndvTech)
gen lognIndvBigTech = log(nIndvBigTech)
gen logaIndvBigTech = log(aIndvBigTech)

xtreg vTurn aCorp nCorp nIndvBigTech aIndvBigTech nIndvTech aIndvTech nCorpBigTech aCorpTech year*, fe vce(cluster id)
xtreg logTurn aCorp nCorp nIndvBigTech aIndvBigTech nIndvTech aIndvTech nCorpBigTech aCorpTech year*, fe vce(cluster id)
xtreg vTurn logaCorp lognCorp lognIndvBigTech logaIndvBigTech lognIndvTech logaIndvTech lognCorpBigTech logaCorpTech year*, fe vce(cluster id)
xtreg logTurn logaCorp lognCorp lognIndvBigTech logaIndvBigTech lognIndvTech logaIndvTech lognCorpBigTech logaCorpTech year*, fe vce(cluster id)

xtreg turnoutR aCorp nCorp nIndvBigTech aIndvBigTech nIndvTech aIndvTech nCorpBigTech aCorpTech year*, fe vce(cluster id)
xtreg logR aCorp nCorp nIndvBigTech aIndvBigTech nIndvTech aIndvTech nCorpBigTech aCorpTech year*, fe vce(cluster id)
xtreg turnoutR logaCorp lognCorp lognIndvBigTech logaIndvBigTech lognIndvTech logaIndvTech lognCorpBigTech logaCorpTech year*, fe vce(cluster id)
xtreg logR logaCorp lognCorp lognIndvBigTech logaIndvBigTech lognIndvTech logaIndvTech lognCorpBigTech logaCorpTech year*, fe vce(cluster id) */


xtreg vReg aCorp, fe vce(cluster id)
outreg2 using regReg2.doc, replace
 
xtreg vReg nCorp, fe vce(cluster id)
outreg2 using regReg2.doc, append
 
xtreg vReg aCorp nCorp aTot count year*, fe vce(cluster id)
outreg2 using regReg2.doc, append
 
xtreg vReg aCorp nCorp aTot count nIndvBigTech aIndvBigTech nIndvTech aIndvTech nCorpBigTech aCorpTech year*, fe vce(cluster id)
outreg2 using regReg2.doc, append
 
xtreg vReg nCorp nIndvTech nIndvBigTech nCorpBigTech count nDemRec nRepRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec aComRec meanCFCont meanCFDiff year*, fe vce(cluster id)
outreg2 using regReg2.doc, append
 

xtreg vTurn aCorp, fe vce(cluster id)
outreg2 using turnReg2.doc, replace
 
xtreg vTurn nCorp, fe vce(cluster id)
outreg2 using turnReg2.doc, append
 
xtreg vTurn aCorp nCorp aTot count year*, fe vce(cluster id)
outreg2 using turnReg2.doc, append
 
xtreg vTurn aCorp nCorp aTot count nIndvBigTech aIndvBigTech nIndvTech aIndvTech nCorpBigTech aCorpTech year*, fe vce(cluster id)
outreg2 using turnReg2.doc, append
 
xtreg vTurn nCorp nIndvTech nIndvBigTech nCorpBigTech count nDemRec nRepRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec aIndRec aComRec meanCFDiff year*, fe vce(cluster id)
outreg2 using turnReg2.doc, append
 

xtreg turnoutR aCorp, fe vce(cluster id)
outreg2 using turnrReg2.doc, replace
 
xtreg turnoutR nCorp, fe vce(cluster id)
outreg2 using turnrReg2.doc, append
 
xtreg turnoutR aCorp nCorp aTot count year*, fe vce(cluster id)
outreg2 using turnrReg2.doc, append
 
xtreg turnoutR aCorp nCorp aTot count nIndvBigTech aIndvBigTech nIndvTech aIndvTech nCorpBigTech aCorpTech year*, fe vce(cluster id)
outreg2 using turnrReg2.doc, append
 
xtreg turnoutR nCorp nIndvTech nIndvBigTech nCorpBigTech count nDemRec nRepRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec meanCFCont meanCFCand year*, fe vce(cluster id)
outreg2 using turnrReg2.doc, append
 

clear

import delimited "/Users/mishat/Desktop/Data/JP/final/fullTS.csv", case(preserve) encoding(ISO-8859-2) numericcols(229 230 231 232 233 234 235 236 237 238 239 275 276 277 278 279 280 281 282 283) clear 
desc
sum
xtset id yr
tab yr, gen(year)

gen pop = SE_A02002_002 + SE_A02002_015
rename SE_A00002_001 popDen
rename SE_A14028_001 gini
rename SE_A14024_001 incomePC
gen pforeignBorn = SE_A06001_003/pop
rename SE_A14016_001 medIncome 
rename SE_A14019_001 aggIncome
gen pHousingOwners = SE_A10060_001/SE_A10060_002
gen povertyR = SE_A13003B_002/SE_A13003B_001
//only for 16-64
rename SE_A09001_002 nWorkersOutside
rename SE_A09001_003 travel0t9
rename SE_A09001_004 travel10t19
rename SE_A09001_005 travel20t29
rename SE_A09001_006 travel30t39
rename SE_A09001_007 travel40t59
rename SE_A09001_008 travel60t89
rename SE_A09001_009 travel90p
rename SE_A14023_002 aggIncomeWhite
rename SE_A14023_009 aggIncomeLatino		  
rename SE_A18007_002 move2005p
rename SE_A18007_003 move2000t04
rename SE_A10036_001 medianHomeValue
rename SE_A18004_001 aggRent
rename SE_A14027_001 meanQ1Inc
rename SE_A14027_002 meanQ2Inc
rename SE_A14027_003 meanQ3Inc
rename SE_A14027_004 meanQ4Inc
rename SE_A14027_005 meanQ5Inc
rename SE_A14027_006 mean5pInc
rename SE_C01001B_002 age5p
rename SE_C01001B_003 age10p
rename SE_C01001B_004 age15p
rename SE_C01001B_005 age18p
rename SE_C01001B_006 age20p
rename SE_C01001B_007 age21p
rename SE_C01001B_008 age22p
rename SE_C01001B_009 age25p
rename SE_C01001B_010 age30p
rename SE_C01001B_011 age35p
rename SE_C01001B_012 age40p
rename SE_C01001B_013 age45p
rename SE_C01001B_014 age50p
rename SE_C01001B_015 age55p
rename SE_C01001B_016 age60p
rename SE_C01001B_017 age62p
rename SE_C01001B_018 age65p
rename SE_C01001B_019 age67p
rename SE_C01001B_020 age70p
rename SE_C01001B_021 age75p
rename SE_C01001B_022 age80p
rename SE_C01001B_023 age85p
gen turnoutR = vTurn/vReg

sum
outreg2 using sum3.doc, replace sum(log)

//rVote and rReg are regularly greater than 1, which obviously is not possible and implies either
// ACS undercounting or voting data issues (potentially also people voting outside their precincts)

//nCorp nIndvTech nIndvBigTech nCorpBigTech count nDemRec nRepRec nIndRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec aIndRec aComRec meanCFCont meanCFCand meanCFDiff pop popDen gini incomePC pforeignBorn medIncome aggIncome pHousingOwners povertyR nWorkersOutside travel0t9 travel10t19 travel20t29 travel30t39 travel40t59 travel60t89 travel90p aggIncomeWhite aggIncomeLatino move2005p move2000t04 medianHomeValue aggRent meanQ1Inc meanQ2Inc meanQ3Inc meanQ4Inc meanQ5Inc mean5pInc age5p age10p age15p age18p age20p age21p age22p age25p age30p age35p age40p age45p age50p age55p age60p age62p age65p age67p age70p age75p age80p age85p year*

xtreg nIndv nCorp aCorp year*, fe vce(cluster id)
outreg2 using numReg3.doc, replace
 
xtreg nIndv pop nCorp aCorp aTot year*, fe vce(cluster id)
outreg2 using numReg3.doc, append
 
xtreg nIndv pop nCorp aCorp aTot nIndvBigTech nIndvTech nCorpBigTech aIndvBigTech aIndvTech aCorpTech year*, fe vce(cluster id)
outreg2 using numReg3.doc, append
 
xtreg nIndv nCorp nIndvTech nIndvBigTech nCorpBigTech nDemRec nRepRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec aComRec meanCFCont meanCFCand pop popDen povertyR nWorkersOutside travel40t59 travel60t89 travel90p aggIncomeWhite aggIncomeLatino move2005p move2000t04 medianHomeValue meanQ1Inc meanQ2Inc meanQ3Inc meanQ4Inc meanQ5Inc mean5pInc age5p age10p age15p age18p age20p age21p age22p age25p age30p age35p age40p age45p age50p age55p age60p age62p age65p age67p age70p year*, fe vce(cluster id)
outreg2 using numReg3.doc, append
 

xtreg aIndv nCorp aCorp year*, fe vce(cluster id)
outreg2 using amountReg3.doc, replace
 
xtreg aIndv pop aggIncome nCorp aCorp aTot year*, fe vce(cluster id)
outreg2 using amountReg3.doc, append
 
xtreg aIndv pop aggIncome nCorp aCorp aTot nIndvBigTech nIndvTech nCorpBigTech aIndvBigTech aIndvTech aCorpTech year*, fe vce(cluster id)
outreg2 using amountReg3.doc, append
 
xtreg aIndv nCorp nIndvTech nIndvBigTech nCorpBigTech nDemRec nRepRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec aComRec meanCFCont meanCFCand pop popDen incomePC pforeignBorn pHousingOwners nWorkersOutside travel40t59 travel60t89 travel90p aggIncomeWhite aggIncomeLatino move2005p move2000t04 medianHomeValue meanQ1Inc meanQ2Inc meanQ3Inc meanQ4Inc meanQ5Inc mean5pInc age5p age10p age15p age18p age20p age25p age30p age35p age40p age45p age50p age55p age60p age62p age65p age67p age70p year*, fe vce(cluster id)
outreg2 using amountReg3.doc, append
 

xtreg vReg nCorp aCorp year*, fe vce(cluster id)
outreg2 using regReg3.doc, replace
 
xtreg vReg pop nCorp aCorp aTot year*, fe vce(cluster id)
outreg2 using regReg3.doc, append
 
xtreg vReg pop nCorp aCorp aTot nIndvBigTech nIndvTech nCorpBigTech aIndvBigTech aIndvTech aCorpTech year*, fe vce(cluster id)
outreg2 using regReg3.doc, append
 
xtreg vReg nCorp nIndvTech nIndvBigTech nCorpBigTech nDemRec nComRec aTot aCorp aIndvTech aIndvBigTech aCorpTech aDemRec aIndRec meanCFCont sdCFDiff pop popDen incomePC pforeignBorn medIncome nWorkersOutside travel90p aggIncomeLatino medianHomeValue age22p age25p age35p age40p age50p age60p age70p year*, fe vce(cluster id)
outreg2 using regReg3.doc, append
 

xtreg vTurn nCorp aCorp year*, fe vce(cluster id)
outreg2 using turnReg3.doc, replace
 
xtreg vTurn pop nCorp aCorp aTot year*, fe vce(cluster id)
outreg2 using turnReg3.doc, append
 
xtreg vTurn pop nCorp aCorp aTot nIndvBigTech nIndvTech nCorpBigTech aIndvBigTech aIndvTech aCorpTech year*, fe vce(cluster id)
outreg2 using turnReg3.doc, append
 
xtreg vTurn nCorp nIndvTech nIndvBigTech nCorpBigTech count nDemRec nRepRec nIndRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aDemRec aRepRec aIndRec meanCFCont meanCFCand pop gini incomePC pforeignBorn aggIncome povertyR nWorkersOutside travel0t9 travel10t19 travel20t29 travel30t39 travel40t59 travel60t89 travel90p  aggIncomeLatino medianHomeValue aggRent meanQ1Inc meanQ2Inc meanQ3Inc meanQ4Inc meanQ5Inc age5p age10p age20p age22p age25p age30p age40p age60p age70p year*, fe vce(cluster id)
outreg2 using turnReg3.doc, append
 

xtreg turnoutR nCorp aCorp year*, fe vce(cluster id)
outreg2 using turnrReg3.doc, replace
 
xtreg turnoutR pop nCorp aCorp aTot year*, fe vce(cluster id)
outreg2 using turnrReg3.doc, append
 
xtreg turnoutR pop nCorp aCorp aTot nIndvBigTech nIndvTech nCorpBigTech aIndvBigTech aIndvTech aCorpTech year*, fe vce(cluster id)
outreg2 using turnrReg3.doc, append
 
xtreg turnoutR nCorp nIndvTech nIndvBigTech nCorpBigTech nRepRec nIndRec nComRec aTot aCorp aIndvBigTech aIndvTech aCorpTech aRepRec aIndRec meanCFCont meanCFCand meanCFDiff pop popDen gini medIncome travel30t39 travel40t59 travel60t89 travel90p aggIncomeWhite aggIncomeLatino move2005p move2000t04 medianHomeValue aggRent meanQ1Inc meanQ2Inc meanQ3Inc meanQ4Inc meanQ5Inc mean5pInc age5p age10p age18p age20p age21p age25p age30p age35p age40p age45p age50p age55p age60p age65p age75p age85p year*, fe vce(cluster id)
outreg2 using turnrReg3.doc, append
 

log close
