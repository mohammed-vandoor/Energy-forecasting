library(RMySQL)
library(dplyr)
library(lubridate)
## Create a database connection 
con <- dbConnect(MySQL(), user='deepAnalytics', password='Sqltask1234!', dbname='dataanalytics2018', host='data-analytics-2018.cbrosir2cswx.us-east-1.rds.amazonaws.com')
## List the tables contained in the database 
dbListTables(con)


yr_2006<-dbGetQuery(con,'select * from yr_2006')
yr_2007<-dbGetQuery(con,'select * from yr_2007')
yr_2008<-dbGetQuery(con,'select * from yr_2008')
yr_2009<-dbGetQuery(con,'select * from yr_2009')
yr_2010<-dbGetQuery(con,'select * from yr_2010')

# Combine tables into one dataframe using dplyr

energy_consumption <- bind_rows(yr_2006,yr_2007,yr_2008,yr_2009,yr_2010)


## Combine Date and Time attribute values in a new attribute column


energy_consumption <-cbind(energy_consumption,paste(energy_consumption$Date,energy_consumption$Time), stringsAsFactors=FALSE)


## Give the new attribute in the 11th column a header name 

colnames(energy_consumption)[11] <-"DateTime"

## Move the DateTime attribute within the dataset

energy_consumption <- energy_consumption[,c(ncol(energy_consumption), 1:(ncol(energy_consumption)-1))]

# remove unwanted colomns from the data set

power_cal=energy_consumption %>% 
  select(DateTime,Global_active_power,Global_reactive_power,Sub_metering_1,Sub_metering_2,Sub_metering_3) %>% 
  mutate(remaing_power=Global_active_power*(1000/60)-Sub_metering_1-Sub_metering_2-Sub_metering_3) %>% 
  mutate(Global_active_power=Global_active_power*1000/60) %>% 
  mutate(Global_reactive_power=Global_reactive_power*1000/60)


## Convert DateTime from POSIXlt to POSIXct

power_cal$DateTime <- as.POSIXct(power_cal$DateTime,"%Y-%m-%d %H:%M:%S",tz="Europe/Paris")

## Add the time zone

str(power_cal$DateTime)

tz(power_cal$DateTime)

## Create "year" attribute with lubridate

power_cal$year <- year(power_cal$DateTime)

ggplot(yr_2007,aes(Time,Global_active_power))+geom_line()
ggplot(yr_2008,aes(Time,Global_active_power))+geom_line()
ggplot(yr_2009,aes(Time,Global_active_power))+geom_line()         
ggplot(yr_2010,aes(Time,Global_active_power))+geom_line()         
