## the purpose of this script is to be able to look through waveform data that has insp starts and ends marked and have the program integrate between the insp markings it finds
#originally created by Grace Burkholder 01 July 2025

rm(list=ls())

library(tidyverse)
library(janitor)

#read in the CSV file with selected columns
allNEDbreaths<-read.csv("data/NEDPractice5Breaths.csv", header=FALSE)

#make the header and remove automatic header rows and convert to numeric
colnames(allNEDbreaths)<-as.character(unlist(allNEDbreaths[5, ]))
allNEDbreaths<-allNEDbreaths[-(1:9), ]
clean_names(allNEDbreaths)

data_step<-0.0005


##keep only the columns we want
cols_to_keep <- c("ChannelTitle=", "Flow Sensor Nose", "Flow Sensor Mouth", "Flow Sensor Total", "Tidal Volume Total", "Comments")
allNEDbreaths <- allNEDbreaths[, cols_to_keep]

allNEDbreaths %>% 
  mutate(across(c(1:5),as.numeric))->allNEDbreaths

#find all the inspstart and inspend indices
inspstartindices<-which(grepl("InspStart", allNEDbreaths$Comments))
inspendindices<-which(grepl("InspEnd", allNEDbreaths$Comments))

data_step<-0.0005

#making an array to hold the area of each of the breaths
allbreathareas<-vector(mode="numeric",length=length(inspendindices))

#a for loop that will integrate from inspstart to inspend for the number of breaths selected
for(i in 1:length(inspstartindices)){
  #finding the breath that we are working on - we find the start and end index of this breath and then the times for those
  start<-inspstartindices[i]
  end<-inspendindices[i]
  
  #defining the breath 
  breath=allNEDbreaths$`Flow Sensor Total`[start:end]
  
  #finding the two local maximums and their indices
  vmax1=max(breath[1:floor(length(breath)/2)])
  vmax1index = which(breath[1:floor(length(breath)/2)]==vmax1)
  vmax2=max(breath[floor(length(breath)/2):floor(length(breath))])
  vmax2index = which(breath[floor(length(breath)/2):floor(length(breath))]==vmax2)
  
  #making empty arrays to hold the areas
  midptNEDareas<-vector(mode="numeric",length=(end-start))
  leftareas<-vector(mode="numeric", length=vmax1index)
  rightareas<-vector(mode="numeric", length=(length(breath)-vmax2index)
  
  #looping over the individual breath i to find midpt NED area
   for(j in 1:length(breath)-1){
     #get the two values of y 
     base1=breath[j]
     base2=breath[j+1]
    
     #calculate the area:
     midpt = (base2+base1)/2
     midptNEDarea = midpt * data_step #midpt area formula
     
     #store it in the array
     midptNEDarea->midptNEDareas[j]
   }
 
   #store the sum of the NED midpoint areas in another vector
  sum(midptNEDareas)->allbreathareas[i]
  
  #looping over the individual breath i to find rectangle non-NED area
  #integrating the first segment with a midpt sum
  for(k in 1:vmax1index-1){
    #get the two values of y 
    base1=breath[k]
    base2=breath[k+1]
   
    #calculate the area:
    midptL = (base2+base1)/2
    leftrect = midptL * data_step #midpt area formula
    
    #store it in the array
    leftrect->leftareas[k]
  }
  leftsum<-sum(leftareas)
  
  #multiplying the middle rectangle
    middlearea = (vmax2index-vmax1index)*data_step*vmax1
  
  #integrating the last segment with a trap sum
  for (m in vmax2index:length(breath)-1){
    #get the two values of y 
    base1=breath[m]
    base2=breath[m+1]
    
    #calculate the area:
    midptR = (base2+base1)/2
    rightrect = midptR * data_step #midpt area formula
    
    #store it in the array
    rightrect->rightareas[m]
  }
    rightsum<-sum(rightareas)
    
    TVnonNED<-leftsum+middlearea+rightsum
    
    TVNED <-sum(allbreathareas)
}