*data dive
* 2019
clear
*1
import delimited "/Users/feramaros/Downloads/2019/2019-01/2019-01-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met191.csv"
*2
clear
import delimited "/Users/feramaros/Downloads/2019/2019-02/2019-02-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met192.csv"
*3
clear
import delimited "/Users/feramaros/Downloads/2019/2019-03/2019-03-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met193.csv"
*4
clear
import delimited "/Users/feramaros/Downloads/2019/2019-04/2019-04-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met194.csv"
*5
clear
import delimited "/Users/feramaros/Downloads/2019/2019-05/2019-05-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met195.csv"
*6
clear
import delimited "/Users/feramaros/Downloads/2019/2019-06/2019-06-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met196.csv"
*7
clear
import delimited "/Users/feramaros/Downloads/2019/2019-07/2019-07-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met197.csv"
*8
clear
import delimited "/Users/feramaros/Downloads/2019/2019-08/2019-08-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met198.csv"
*9
clear
import delimited "/Users/feramaros/Downloads/2019/2019-09/2019-09-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met199.csv"
*10
clear
import delimited "/Users/feramaros/Downloads/2019/2019-10/2019-10-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met1910.csv"
*11
clear
import delimited "/Users/feramaros/Downloads/2019/2019-11/2019-11-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met1911.csv"
clear
import delimited "/Users/feramaros/Downloads/2019/2019-12/2019-12-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2019/met1912.csv"



**Append
clear
use "/Users/feramaros/Downloads/2019/met191.csv" 
forvalues x=1/12 {
append using "/Users/feramaros/Downloads/2019/met19`x'.csv"
save "/Users/feramaros/Downloads/2019/mettotal19.dta", replace
} 
clear
use "/Users/feramaros/Downloads/2019/mettotal19.dta"
keep  if crimetype=="Violence and sexual offences" 
save "/Users/feramaros/Downloads/2019/metsexcrimes19.csv", replace
save "/Users/feramaros/Downloads/2019/metsexcrimes19.xlsx", replace
save "/Users/feramaros/Downloads/2019/metsexcrimes19.dta", replace
**** may 2020
clear
import delimited "/Users/feramaros/Downloads/2020-05-metropolitan-street.csv", clear 
keep  if crimetype=="Violence and sexual offences" 

