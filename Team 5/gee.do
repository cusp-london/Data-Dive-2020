/* GEE. This document fits a GLM using GEE to predict crime
 * Author: Robert Greener @ LSHTM
 */

/** Data preprocessing **/
// Clear any dataset in memory
// You may need to change the working directory before this section
clear

// Open a log file for this session
log using gee, replace
// Import the weekly crime data
import delimited "Data/general datasets/Crime/MPS/Ward by Weekending.csv"
// Convert week ending to a date
gen weekending = date(weekendingdatesundays, "DMY")
// Get a human-readable date representation
format weekending %td
// Include only the weeks of interest
gen included = (weekending >= td(9feb2020) & weekending <= td(26apr2020))
// Drop not included rows
drop if !included
// Drop the included column
drop included
// Wardwardcode is a string, encode it as a factor variable
encode wardwardcode, gen(wardid)
// Generate the lockdown and covid intervention points
gen lockdown = (weekending >= td(23mar2020))
gen covid = (weekending >= td(15mar2020))
// Convert the weeks to ints starting from 0 at w/e 9feb2020
gen int week = floor((weekending - td(9feb2020)) / 7)
// Weekcovid interaction variable is centered at intervention date of covid
gen weekcovid = covid * (week - 4)
// Weeklockdown interaction variable is centered at intervention date of lockdown
gen weeklockdown = lockdown * (week - 6)
// This column is no longer needed
drop weekending

/** Merge in the data, thanks to Colin and Xu for the R code on which this is based **/
save crime, replace
import delimited "Data/general datasets/Deprivation Index/IMD 2019.csv", clear
rename wardcode wardwardcode
drop if wardwardcode == ""
save imd, replace
use crime
merge m:1 wardwardcode using imd, nogenerate
save crime, replace

import excel "Data/general datasets/Houses/Houses by ward.xlsx", sheet("Sheet1") firstrow case(lower) clear
rename wards wardwardcode
save housesbyward, replace
use crime
merge m:1 wardwardcode using housesbyward, nogenerate
save crime, replace

/** Preliminary analysis **/
xtset wardid week

xtline tnooffs, overlay

/** First GEE - all crime **/
/* We can interpret this as follows
 * - week is the WoW change in TNOs prior to COVID
 * - lockdown is the step change due to lockdown
 * - weeklockdown is the change in trajectory after lockdown from covid
 * - weekcovid is the change in trajectory due to covid
 * We use a Poisson family with a log link function
 * We use an exchangeable working correlations structure though if this is mis-specified this is still consistent
 * Huber-White standard errors are used (this is what makes it consistent)
 * We exponentiate the coefficients so they can be interpreted as % change per unit increase
 */
xtgee tnooffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
// This is the new trajectory after covid
lincom week + weekcovid, eform
// This is the new trajectory after lockdown
lincom week + weekcovid + weeklockdown, eform

/** GEE by crime type **/
xtgee violenceagainstthepersonoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee sexualoffencesoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee robberyoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee burglaryoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee vehicleoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee theftoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee arsonandcriminaldamageoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee drugoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform
xtgee possessionofweaponsoffs week lockdown weeklockdown weekcovid, family(poisson) link(log) corr(exch) vce(robust) eform


/** Do "cheaper" areas cause difference in effect of crime **/
replace averagehouseprices2018 = "" if averagehouseprices2018 == "N/A"
destring averagehouseprices2018, replace
gen housethousands = averagehouseprices2018 / 100000
summarize housethousands, meanonly
gen housethousandscent = housethousands - r(mean)
xtgee tnooffs c.week i.lockdown weeklockdown weekcovid c.housethousandscent c.housethousandscent#c.week c.housethousandscent#i.lockdown c.housethousandscent#c.weeklockdown c.housethousandscent#c.weekcovid, family(poisson) link(log) corr(exch)vce(robust) eform
lincom c.housethousandscent#c.weeklockdown + c.housethousandscent#c.week, eform

/** Does deprivation cause difference in effect of crime **/
summarize imdaveragescore
gen imdcent = imdaveragescore - r(mean)
xtgee tnooffs c.week i.lockdown weeklockdown weekcovid c.imdcent c.imdcent#c.week c.imdcent#i.lockdown c.imdcent#c.weeklockdown c.imdcent#c.weekcovid, family(poisson) link(log) corr(exch)vce(robust) eform
lincom c.imdcent#c.weeklockdown + c.imdcent#c.week, eform

/** Does prop young people cause difference in effect of crime **/
replace percentageunder30 = "" if percentageunder30 == "N/A"
destring percentageunder30, replace
summarize percentageunder30
gen youngcent = (percentageunder30 - r(mean)) * 100
xtgee tnooffs c.week i.lockdown weeklockdown weekcovid c.youngcent c.youngcent#c.week c.youngcent#i.lockdown c.youngcent#c.weeklockdown c.youngcent#c.weekcovid, family(poisson) link(log) corr(exch)vce(robust) eform
lincom c.youngcent#c.weeklockdown + c.youngcent#c.week, eform

/** Methodological issues **/
// Overdispersion is not an issue as we use robust stadard errors.
// Other things you could do would be to include logpopulation as an offset. This would allow the exponentiated coefficients to be interpreted as a rate.
// We could also use a longer time-series including a fourier term to adjust for seasonality.


/** Finish up **/
log close
translate gee.smcl gee.log, replace
