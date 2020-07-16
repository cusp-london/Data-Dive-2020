data1 = read.csv('/Users/evelyn/Desktop/crime_poor.csv')
data2 = read.csv('/Users/evelyn/Desktop/crime_price.csv')

crime1 = data1$X2017
crime2 = data2$X2018
price = data2$house_price
poor = data1$poor.households....

mod_simp_reg<-lm(cri~poor) 
summary(mod_simp_reg) 


mod_simp_reg<-lm(price~crime1) 
summary(mod_simp_reg)