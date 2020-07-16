library("sp")
library("rgdal")
library("rgeos")
library("GISTools")
library("scales")
library("spdep")
library("GWmodel")
library("scales")
library('maptools')
library('lattice')
library(dplyr)
library(plyr)


ldn <- readOGR("London-wards-2018/London-wards-2018_ESRI/London_Ward.shp", stringsAsFactors = FALSE) # via https://data.london.gov.uk/dataset/statistical-gis-boundary-files-london
names(ldn@data)[names(ldn@data)=="GSS_CODE"]<-"Code"

ward_imd <- read.csv("IMD 2019.csv", stringsAsFactors = FALSE)
names(ward_imd)[names(ward_imd)=="ï..Ward.Code"]<-"Code"
ldn@data <- merge(ldn@data, ward_imd, by="Code", all=F)


ward_crime <-read.csv("Crime/MPS/Ward Data.csv", stringsAsFactors = FALSE)
names(ward_crime)[names(ward_crime)=="Ward.Ward.Code"]<-"Code"


april_2019 <- ward_crime[ward_crime$Month.Year=="Apr 2019",]
names(april_2019)[names(april_2019)=="TNO.Offs"]<-"TNO.Offs.2019"
april_2020 <- ward_crime[ward_crime$Month.Year=="Apr 2020",]
names(april_2020)[names(april_2020)=="TNO.Offs"]<-"TNO.Offs.2020"
ldn@data <- merge(ldn@data, april_2019, by="Code", all=F)
ldn@data <- merge(ldn@data, april_2020, by="Code", all=F)


ldn@data$TNO_YOY <- (ldn@data$TNO.Offs.2020-ldn@data$TNO.Offs.2019)/ldn@data$TNO.Offs.2019


ward_bame18 <- read.csv("ward_profile2018.csv", stringsAsFactors = F)
names(ward_bame18)[names(ward_bame18)=="GSS_CODE_left"]<-"Code"
ldn@data <- merge(ldn@data, ward_bame18, by="Code", all=T)

#removing empty rows
ldn <- ldn[!is.na(ldn@data$TNO.Offs.2019),]

# plot TNO_YOY
library(leaflet)
spd <- spTransform(ldn, CRS("+proj=longlat +datum=WGS84 +no_defs"))
cols_tno <- colorNumeric("Blues", ldn@data$TNO_YOY,n=5)
tno_crimes_map <- leaflet(options = leafletOptions(attributionControl=T))%>% addPolygons(data=spd, weight=1, color = "grey", group="London")%>% 
  addPolygons(data=spd, weight=1, color = ~cols_tno(ldn@data$TNO_YOY), group="TNO" )%>%
  addLegend("topleft", pal=cols_tno, values = ldn@data$TNO_YOY, title="TNO Change", group = "TNO")
tno_crimes_map




# lm with all interaction terms added
crime_lm <- lm(ldn@data$TNO_YOY ~ ldn@data$Income.score+ldn@data$Employment.score+ldn@data$IDACI.score+ldn@data$IDAOPI.score+
                 ldn@data$Income.score*ldn@data$Employment.score+ldn@data$Income.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score+
                 ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$Employment.score*ldn@data$IDAOPI.score+
                 ldn@data$IDACI.score*ldn@data$IDAOPI.score+
                 ldn@data$Income.score*ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$Employment.score*ldn@data$IDAOPI.score+
                 ldn@data$Employment.score*ldn@data$IDAOPI.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score*ldn@data$IDACI.score+
                 ldn@data$Income.score*ldn@data$Employment.score*ldn@data$IDACI.score*ldn@data$IDAOPI.score)
summary(crime_lm)
plot(crime_lm)


#refining model using the parameters from COVID19 Crime Impact GWR.ipynb
simple_crime_lm <- lm(ldn@data$TNO_YOY ~ ldn@data$Income.score+ldn@data$Employment.score+ldn@data$IDACI.score+ldn@data$IDAOPI.score+
                        ldn@data$Income.score*ldn@data$Employment.score+ldn@data$Income.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score+
                        ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$IDACI.score*ldn@data$IDAOPI.score+
                        ldn@data$Income.score*ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score*ldn@data$IDACI.score)
summary(simple_crime_lm)


#calculating the GWR
bandwidth <- bw.gwr(ldn@data$TNO_YOY ~ ldn@data$Income.score+ldn@data$Employment.score+ldn@data$IDACI.score+ldn@data$IDAOPI.score+
                      ldn@data$Income.score*ldn@data$Employment.score+ldn@data$Income.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score+
                      ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$IDACI.score*ldn@data$IDAOPI.score+
                      ldn@data$Income.score*ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score*ldn@data$IDACI.score,
                    data = ldn,
                    approach = "CV",
                    kernel = "gaussian")

gwr <-
  gwr.basic(
    ldn@data$TNO_YOY ~ ldn@data$Income.score+ldn@data$Employment.score+ldn@data$IDACI.score+ldn@data$IDAOPI.score+
      ldn@data$Income.score*ldn@data$Employment.score+ldn@data$Income.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score+
      ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$IDACI.score*ldn@data$IDAOPI.score+
      ldn@data$Income.score*ldn@data$Employment.score*ldn@data$IDACI.score+ldn@data$Income.score*ldn@data$IDAOPI.score*ldn@data$IDACI.score,
    data = ldn,
    bw = bandwidth,
    kernel = "gaussian"
  ) 
gwr



#Interactive plot of GWR Variables
leaflet_ldn <-gwr$SDF@data
cols_intercept<- colorNumeric("Blues", leaflet_ldn$Intercept, n=5)
cols_inc <- colorNumeric("Blues", leaflet_ldn$`ldn@data$Income.score`, n=5)
cols_empl <- colorNumeric("Blues", leaflet_ldn$`ldn@data$Employment.score`, n=5)
cols_idac <- colorNumeric("Blues", leaflet_ldn$`ldn@data$IDACI.score`, n=5)
cols_idao <- colorNumeric("Blues", leaflet_ldn$`ldn@data$IDAOPI.score`, n=5)
cols_inc_emp <- colorNumeric("Blues", leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score`, n=5)
cols_inc_idaci<- colorNumeric("Blues", leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score`, n=5)
cols_inc_idaopi<- colorNumeric("Blues", leaflet_ldn$`ldn@data$Income.score:ldn@data$IDAOPI.score`, n=5)
cols_emp_idaci<- colorNumeric("Blues", leaflet_ldn$`ldn@data$Employment.score:ldn@data$IDACI.score`, n=5)
cols_idaci_idaopi<- colorNumeric("Blues", leaflet_ldn$`ldn@data$IDACI.score:ldn@data$IDAOPI.score`, n=5)
cols_inc_emp_idaci<- colorNumeric("Blues", leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score:ldn@data$IDACI.score`, n=5)
cols_inc_idaci_idaopi<- colorNumeric("Blues", leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score:ldn@data$IDAOPI.score`, n=5)



map<-leaflet()%>% addPolygons(data=spd, weight=1, color = "grey", group="London", popup =  paste(ldn@data$NAME,",",ldn@data$Borough))%>% 
  addPolygons(data=spd, weight=1, color = ~cols_intercept(leaflet_ldn$Intercept), group="Intercept" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Intercept:", round(leaflet_ldn$Intercept,4)))%>%
  addLegend("bottomright", pal=cols_intercept, values = leaflet_ldn$Intercept, title="Intercept", group = "Intercept")%>%

  addPolygons(data=spd, weight=1, color = ~cols_inc(leaflet_ldn$`ldn@data$Income.score`), group="Income Score" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Income Score:", round(leaflet_ldn$`ldn@data$Income.score`,4)))%>%
  addLegend("bottomright", pal=cols_inc, values = leaflet_ldn$`ldn@data$Income.score`, title="Income Score", group = "Income Score")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_empl(leaflet_ldn$`ldn@data$Employment.score`), group="Employment Score" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Employment Score:", round(leaflet_ldn$`ldn@data$Employment.score`,4)))%>%
  addLegend("bottomright", pal=cols_empl, values = leaflet_ldn$`ldn@data$Employment.score`, title="Employment Score", group = "Employment Score")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_idac(leaflet_ldn$`ldn@data$IDACI.score`), group="IDACI Score" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","IDACI Score:", round(leaflet_ldn$`ldn@data$IDACI.score`,4)))%>%
  addLegend("bottomright", pal=cols_idac, values = leaflet_ldn$`ldn@data$IDACI.score`, title="IDACI Score", group = "IDACI Score")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_idao(leaflet_ldn$`ldn@data$IDAOPI.score`), group="IDAOPI Score" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","IDAOPI Score:", round(leaflet_ldn$`ldn@data$IDAOPI.score`,4)))%>%
  addLegend("bottomright", pal=cols_idao, values = leaflet_ldn$`ldn@data$IDAOPI.score`, title="IDAOPI Score", group = "IDAOPI Score")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_inc_emp(leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score`), group="Income & Employment", popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Income & Employment:", round(leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score`,4)) )%>%
  addLegend("bottomright", pal=cols_inc_emp, values = leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score`, title="Income & Employment", group = "Income & Employment")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_inc_idaci(leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score`), group="Income & IDACI", popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Income & IDACI:", round(leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score`,4)) )%>%
  addLegend("bottomright", pal=cols_inc_idaci, values = leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score`, title="Income & IDACI", group = "Income & IDACI")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_inc_idaopi(leaflet_ldn$`ldn@data$Income.score:ldn@data$IDAOPI.score`), group="Income & IDAOPI", popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Income & IDAOPI:", round(leaflet_ldn$`ldn@data$Income.score:ldn@data$IDAOPI.score`,4)) )%>%
  addLegend("bottomright", pal=cols_inc_idaopi, values = leaflet_ldn$`ldn@data$Income.score:ldn@data$IDAOPI.score`, title="Income & IDAOPI", group = "Income & IDAOPI")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_emp_idaci(leaflet_ldn$`ldn@data$Employment.score:ldn@data$IDACI.score`), group="Employment & IDACI" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Employment & IDACI:", round(leaflet_ldn$`ldn@data$Employment.score:ldn@data$IDACI.score`,4)))%>%
  addLegend("bottomright", pal=cols_emp_idaci, values = leaflet_ldn$`ldn@data$Employment.score:ldn@data$IDACI.score`, title="Employment & IDACI", group = "Employment & IDACI")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_idaci_idaopi(leaflet_ldn$`ldn@data$IDACI.score:ldn@data$IDAOPI.score`), group="IDACI & IDAOPI", popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","IDACI & IDAOPI:", round(leaflet_ldn$`ldn@data$IDACI.score:ldn@data$IDAOPI.score`,4)))%>%
  addLegend("bottomright", pal=cols_idaci_idaopi, values = leaflet_ldn$`ldn@data$IDACI.score:ldn@data$IDAOPI.score`, title="IDACI & IDAOPI", group = "IDACI & IDAOPI")%>%
  
  addPolygons(data=spd, weight=1, color = ~cols_inc_emp_idaci(leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score:ldn@data$IDACI.score`), group="Income & Employment & IDACI" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Income & Employment & IDACI:", round(leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score:ldn@data$IDACI.score`,4)))%>%
  addLegend("bottomright", pal=cols_inc_emp_idaci, values = leaflet_ldn$`ldn@data$Income.score:ldn@data$Employment.score:ldn@data$IDACI.score`, title="Income & Employment & IDACI", group = "Income & Employment & IDACI")%>%

  addPolygons(data=spd, weight=1, color = ~cols_inc_idaci_idaopi(leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score:ldn@data$IDAOPI.score`), group="Income & IDACI & IDAOPI" , popup =  paste(ldn@data$NAME,",",ldn@data$Borough, "<br>","Income & IDACI & IDAOPI:", round(leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score:ldn@data$IDAOPI.score`,4)))%>%
  addLegend("bottomright", pal=cols_inc_idaci_idaopi, values = leaflet_ldn$`ldn@data$Income.score:ldn@data$IDACI.score:ldn@data$IDAOPI.score`, title="Income & IDACI & IDAOPI", group = "Income & IDACI & IDAOPI")%>%
  
  addLayersControl(baseGroups = c("London"),
                   overlayGroups = c("Intercept", "Employment Score","Income Score", "IDAOPI Score", "IDACI Score", "Income & Employment", "Income & IDACI", "Income & IDAOPI",
                                     "Employment & IDACI", "IDACI & IDAOPI", "Income & Employment & IDACI", "Income & IDACI & IDAOPI"),
                   options = layersControlOptions(collapsed = F))%>% 
  hideGroup(c("Employment Score","Income Score", "IDAOPI Score", "IDACI Score", "Income & Employment", "Income & IDACI", "Income & IDAOPI",
             "Employment & IDACI", "IDACI & IDAOPI", "Income & Employment & IDACI", "Income & IDACI & IDAOPI"))
map


library(htmlwidgets)
saveWidget(map,file="GWR_map.html")

