Filename: state_g06_sov_data_by_g06_srprec.dbf

File URL: http://statewidedatabase.org/pub/data/G06/state/state_g06_sov_data_by_g06_srprec.zip

Dataset: 2006 General Election Precinct Data

Description: Statewide Statement of Vote data file containing precinct level voting results for statewide races.

Unit of analysis: SR precincts are derived from consolidated precincts and are a geographic unit constructed for statistical merging purposes by the Statewide Database.

Data source:	Statewide Database - University of California, Berkeley

Technical documentation:  http://statewidedatabase.org/d10/Creating%20CA%20Official%20Redistricting%20Database.pdf

Codebooks:  There are 58 Statement of Vote codebooks, one for each county and can be accessed from the election's precinct data page, http://statewidedatabase.org/d00/g06.html

Note about using SOV data codebooks to determine candidate names in district races: 

There is a SOV data codebook for each county, for each election to account for the specific combination of Assembly, Senate, Congressional and Board of Equalization districts that are within each of the 58 counties. 

The Assembly, Congressional, Senate and Board of Equalization districts that each precinct are located in are listed
in the fields labeled ADDIST, CDDIST, SDDIST and BOEDIST. 

To determine the names of the district candidates that were on a ballot in a given
precinct, look up the district number in the SOV data table and then look up the candidate's name in 
the county's SOV data codebook.
 
For example, in order to determine the identity of the cngdem01 candidate in the 2012 Primary Election in Sonoma County's sv precincts 1001 and 1048 look first at the CDDIST field in the sov data file to determine which congressional district the precincts are in, http://statewidedatabase.org/pub/data/P12/state/state_p12_sov_data_by_p12_svprec.dbf. 

For SV precinct 1001, CDDIST=5 indicating that precinct 1001 is in the 5th Congressional district and for SV precinct 1048, CDDIST=2 indicating that precinct 1048 is in the 2nd Congressional district. 

Refering to the 2012 Primary Sonoma County sov data codebook, http://statewidedatabase.org/pub/data/P12/c097/097.codes, indicates that the cngdem01 candidate in the 2012 Primary 5th congressional district corresponds to CNG05DEM01, Mike Thompson while the cngdem01 candidate running in svprec 1048, in the 2nd Congressional district corresponds to CNG02dem01, Susan  Adams. 

In cases where there was no party candidate running in the race, the records in the sov data table will be all zeros. The 2012 Primary 2nd Congressional Green Party candidate, cnggrn01 in the state_p12_sov_data_by_p12_svprec.dbf is an example of this case.

Date last modified:	07/22/2015

Previous versions:	01/15/2010

County records not available or unavailable at time of file creation: none