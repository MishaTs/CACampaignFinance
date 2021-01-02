import delimited "/Users/mishat/Desktop/Data/JP/final/dimeTS.csv", case(preserve) numericcols(28 32) 
drop v1 nGen aGen sdCFCont sdCFDiff

***************************************************************;
**************** Chow Test for Break after 1981 ... ;
***************************************************************;
generate break_ind = t > tq(1981)
generate b_L1_dirp = break_ind*L1_dirp
generate b_L2_dirp = break_ind*L2_dirp    
* Look at Data set Here 
regress dirp L1_dirp L2_dirp break_ind b_L1_dirp b_L2_dirp if tin(1960q1,2018q4),r
test break_ind b_L1_dirp b_L2_dirp
***************************************************************;
**************** QLR Tests ;
***************************************************************;
***************************************************************;
generate fstat = . 
scalar fdate = ceil(ty(1980) + 0.15*(tq(2018)-ty(1980)+1)) + ty(1980)-t[1]+1
scalar ldate = floor(ty(1980) + 0.85*(tq(2018)-ty(1980)+1))+ ty(1980)-t[1]+1
dis "Index of first date for test  " fdate
dis "Index of last date for test   " ldate

* 89 is fdate, 253 is ldate *
* ii is a "local variable". To refer to it use ` (open quote), then ii (value), then ' (close quote)*
* r(F) is the F-statistic computed in "test" 
* Save value if fstat
forvalues ii = 89/253 { 	
  quiet replace break_ind = t >= t[`ii']
  quiet replace b_L1_dirp = break_ind*L1_dirp
  quiet replace b_L2_dirp = break_ind*L2_dirp
  quiet regress dirp L1_dirp L2_dirp break_ind b_L1_dirp b_L2_dirp,r
  quiet test break_ind b_L1_dirp b_L2_dirp
  scalar chow_test = r(F)            
  quiet replace fstat = chow_test in `ii'  
  display %tq t[`ii'] " Chow F-statistic  " chow_test
}

* Look at maximum value ;
summarize fstat     
list t fstat
