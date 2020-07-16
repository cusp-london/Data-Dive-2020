regression <- read.csv("regression.csv",header = TRUE)
attach(regression)

plot(regression$knife.crime.number,regression$Search.Volume)
cor(regression$knife.crime.number,regression$Search.Volume)

model<-lm(1/regression$Search.Volume~regression$knife.crime.number,regression)
summary(model)
