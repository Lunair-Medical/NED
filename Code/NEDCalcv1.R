#The purpose of this script is to calculate the NED tidal volume and compare it to the flow limited TV
#Originally created by Grace Burkholder, 01 July 2025

library(janitor)
library(tidyverse)

##uploading the CSV
#LabChartRaw<-read.csv("Data/LabChartSnippetNED.csv")
#LabChartRaw[0,1]<-LabChartRaw[1,1]
#LabChartRaw[0,2]<-LabChartRaw[1,2]


##clean the column names
#clean_names(LabChartRaw)->LabChartRaw

#read in the Lab Chart csv that has one breath from insp start to insp end
LabChartRaw<-read.csv("Data/NEDPracticeBreath1.csv", header=FALSE)

##implement the trap sum on that one breath

#define the x and y values
data_step=0.0005
y<-LabChartRaw$V1

#making an empty array to hold the area of each trapezoid
areas<-vector(mode="numeric",length=length(LabChartRaw$V1)-1)

#finding the area of each trapezoid
for (i in 2:(length(LabChartRaw$V1))){
  
  #get the two values of y 
  base1=y[i-1]
  base2=y[i]
  
  #value of x is always the same, step_x
  
  #calculate the area:
  area = 1/2 * (base1 + base2) * data_step #trapezoidal area formula
  
  #store it in the array
  area->areas[i-1]
  
}

sum(areas)
