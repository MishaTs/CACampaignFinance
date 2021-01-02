clear
import delimited "/Users/mishat/Desktop/Data/JP/final/fullTS.csv", case(preserve) encoding(ISO-8859-2) numericcols(229 230 231 232 233 234 235 236 237 238 239 275 276 277 278 279 280 281 282 283) clear 
desc
sum

log using lassoLambda.log, replace

/* Note for standardization : 
(1) We have to standardize all variables that will be included as predictors 
(2) Use in-sample mean and standard deviation to standardize out-of-sample predictors  
(3) Prediction on the out-of-sample observations will be "demeaned" -- so you have to add back the in-sample mean of y */

local k = 1
/* Create standardized predictors */
foreach x of varlist SE* {
	rename `x' x`k'
	local k = `k' + 1
} 

forvalues k = 1/292 {
	/* First compute in-sample mean and standard deviation */
	sum x`k'
	
	/* Standardize using the in-sample mean and standard deviation */
	gen z`k' = (x`k' - `r(mean)') / `r(sd)'
	
	/* Note that this means that for in-sample, z`k' follows mean 0, s.d. 1 but not for the whole sample */
	sum z`k'
}

//look at nIndv, aIndv, vTurn, vReg

/* Demean the target variable : Remember after computing the prediction, you need to add the 
in-sample mean of test scores to the prediction to get predicted "average" variable */
sum nIndv
local mean_nIndv = `r(mean)'
gen ts_nIndv = nIndv - `mean_nIndv'

/* Cross Validation for lambda in Lasso */ 
cvlasso ts_nIndv z*, noconstant alpha(1) prestd nfolds(10) lopt seed(84675)


/* Estimate Lasso with specified lambda value 									 
   Note Lambda in Lasso is defined in same way as SW4E, Chapter 14 					 
   Run estimation only using the in_sample data and predict for only out_sample data */
//lasso2 ts_nIndv z*, noconstant alpha(1) prestd lambda(11171.182) long


sum aIndv
local mean_aIndv = `r(mean)'
gen ts_aIndv = aIndv - `mean_aIndv'

/* Cross Validation for lambda in Lasso */ 
cvlasso ts_aIndv z*, noconstant alpha(1) prestd nfolds(10) lopt seed(84675)

/*
/* Estimate Lasso with specified lambda value 									 
   Note Lambda in Lasso is defined in same way as SW4E, Chapter 14 					 
   Run estimation only using the in_sample data and predict for only out_sample data */
lasso2 ts_aIndv z*, noconstant alpha(1) prestd lambda(1644.7045) long */


/* Demean the target variable : Remember after computing the prediction, you need to add the 
in-sample mean of test scores to the prediction to get predicted "average" variable */
sum vTurn
local mean_vTurn = `r(mean)'
gen ts_vTurn = vTurn - `mean_vTurn'

/* Cross Validation for lambda in Lasso */ 
cvlasso ts_vTurn z*, noconstant alpha(1) prestd nfolds(10) lopt seed(84675)

/*
/* Estimate Lasso with specified lambda value 									 
   Note Lambda in Lasso is defined in same way as SW4E, Chapter 14 					 
   Run estimation only using the in_sample data and predict for only out_sample data */
lasso2 ts_vTurn z*, noconstant alpha(1) prestd lambda(1644.7045) long */


/* Demean the target variable : Remember after computing the prediction, you need to add the 
in-sample mean of test scores to the prediction to get predicted "average" variable */
sum vReg
local mean_vReg = `r(mean)'
gen ts_vReg = vReg - `mean_vTurn'

/* Cross Validation for lambda in Lasso */ 
cvlasso ts_vReg z*, noconstant alpha(1) prestd nfolds(10) lopt seed(84675)

/*
/* Estimate Lasso with specified lambda value 									 
   Note Lambda in Lasso is defined in same way as SW4E, Chapter 14 					 
   Run estimation only using the in_sample data and predict for only out_sample data */
lasso2 ts_vReg z*, noconstant alpha(1) prestd lambda(1644.7045) long */

gen turnoutR = vTurn/vReg
sum turnoutR
local mean_turnoutR = `r(mean)'
gen ts_turnoutR = turnoutR - `mean_turnoutR'

/* Cross Validation for lambda in Lasso */ 
cvlasso ts_turnoutR z*, noconstant alpha(1) prestd nfolds(10) lopt seed(84675)


log close
