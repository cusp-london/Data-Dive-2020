*data dive
* 2018
clear
*1
import delimited "/Users/feramaros/Downloads/2018/2018-01/2018-01-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met181.csv"
*2
clear
import delimited "/Users/feramaros/Downloads/2018/2018-02/2018-02-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met182.csv"
*3
clear
import delimited "/Users/feramaros/Downloads/2018/2018-03/2018-03-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met183.csv"
*4
clear
import delimited "/Users/feramaros/Downloads/2018/2018-04/2018-04-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met184.csv"
*5
clear
import delimited "/Users/feramaros/Downloads/2018/2018-05/2018-05-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met185.csv"
*6
clear
import delimited "/Users/feramaros/Downloads/2018/2018-06/2018-06-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met186.csv"
*7
clear
import delimited "/Users/feramaros/Downloads/2018/2018-07/2018-07-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met187.csv"
*8
clear
import delimited "/Users/feramaros/Downloads/2018/2018-08/2018-08-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met188.csv"
*9
clear
import delimited "/Users/feramaros/Downloads/2018/2018-09/2018-09-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met189.csv"
*10
clear
import delimited "/Users/feramaros/Downloads/2018/2018-10/2018-10-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met1810.csv"
*11
clear
import delimited "/Users/feramaros/Downloads/2018/2018-11/2018-11-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met1811.csv"
clear
import delimited "/Users/feramaros/Downloads/2018/2018-12/2018-12-metropolitan-street", encoding(UTF-8)
save "/Users/feramaros/Downloads/2018/met1812.csv"



**Append
clear
use "/Users/feramaros/Downloads/2018/met181.csv" 
forvalues x=1/12 {
append using "/Users/feramaros/Downloads/2018/met18`x'.csv"
save "/Users/feramaros/Downloads/2018/mettotal18.xlsx", replace
} 
clear
use "/Users/feramaros/Downloads/2018/mettotal18.dta"
keep  if crimetype=="Violence and sexual offences" 
save "/Users/feramaros/Downloads/2018/metsexcrimes18.csv", replace
save "/Users/feramaros/Downloads/2018/metsexcrimes18.xlsx", replace






