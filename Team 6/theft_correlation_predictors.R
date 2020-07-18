packages <- c("survival","ggplot2","dplyr","ggfortify","survminer","lme4","tidyr","splines","dlnm","tsModel","nlme","mgcv")

library(survival); library(ggplot2); library(dplyr); library(ggfortify); library(survminer)
library(lme4); library(tidyr); library(splines); library(dlnm); library(tsModel)
library(nlme); library(mgcv)
library(psych)
library(openair)


mydata<-read.csv("/Users/admin/Desktop/dive/house.csv")


summary(mydata$Theft18)
sd(mydata$Theft18)
# house price
p1 <- ggplot(data = mydata, mapping = aes(x = mydata$Theft18,
                                        y = mydata$AverageHousePrices2018)) + 
  geom_point(colour = "#426671", size = 2) +  geom_smooth(method = lm,colour='#764C29',fill='#E7E1D7')

p1= p1 + xlab("The Number Of Theft Offs")+ylab("Average House Prices")
p1

r <- cor(mydata$Theft18,mydata$AverageHousePrices2018)
r
T <- cor.test(mydata$Theft18,mydata$AverageHousePrices2018)
T
r <- cor(mydata$Theft18,mydata$AverageHousePrices2018)
r

# Average of Proportion of Households Fuel Poor
r <- cor(mydata$Theft17,mydata$FuelPoor)
r
T <- cor.test(mydata$Theft18,mydata$FuelPoor)
T

plot(mydata$Theft17,mydata$FuelPoor,xlab="Time",ylab="Daily number of deaths")


r <- cor(mydata$Theft17,mydata$Hectares)
r
T <- cor.test(mydata$Theft18,mydata$Hectares)
T



imd<-read.csv("/Users/admin/Desktop/dive/imd.csv")


pairs.panels(imd[4:7])
cor(imd[4:7])


imd<-read.csv("/Users/admin/Desktop/dive/zong12.csv")
pairs.panels(imd[4:15])


imd<-read.csv("/Users/admin/Desktop/dive/zong1.csv")

cor(imd[4:31])


imd<-read.csv("/Users/admin/Desktop/dive/zong33.csv")
T <- cor.test(imd$Theft16,imd$AvPTAI2015)
T

imd<-read.csv("/Users/admin/Desktop/dive/zong2.csv")

cor(imd[4:23])

library(corrplot)
newimd<- cor(imd[4:23])
corrplot(newimd, type = "upper", order = "hclust", tl.col = "black", tl.srt = 45)

T <- cor.test(imd$average,imd$AverageHousePrices)
T
library(PerformanceAnalytics)
chart.Correlation(imd[4:23], histogram=TRUE, pch=19)

p1 <- ggplot(data = imd, mapping = aes(x =imd$average ,
                                          y = imd$AverageHousePrices) )+ 
  geom_point(colour = "#426671", size = 2) +  geom_smooth(method = lm,colour='#764C29',fill='#E7E1D7')
p1


fit<-lm(imd$average~imd$AvPTAI+imd$AverageHousePrices+imd$Percentage.Under.18)
fit
summary(fit)

T <- cor.test(imd$average,imd$AvPTAI)
T

T <- cor.test(imd$average,imd$PercentageUnder18)
T



