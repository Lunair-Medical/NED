## the purpose of this script is to be able to look through waveform data that has insp starts and ends marked and have the program integrate between the insp markings it finds
#originally created by Grace Burkholder 01 July 2025

rm(list=ls())

library(tidyverse)
library(janitor)
library(gridExtra)


#graphic settings
lunair_palette=c(
  "#6bdbdb","#143464", "#697e9c", "#ccd9e2", "#397b96")

#extrafont::loadfonts()

theme_lunair <- function(textsize=14){
  theme_minimal() %+replace% 
    theme(text = element_text(#family = "Arial", 
      size = textsize), 
      axis.ticks.length=unit(-0.05, "in"), 
      axis.text.y.right = element_blank(), 
      axis.text.x.top = element_blank(), 
      axis.title.y.right = element_blank(),
      axis.title.x.top = element_blank(),
      #panel.border = element_rect(fill = NA),
      plot.title = element_text(size = textsize,# face = "bold", 
                                hjust = 0),
      strip.background = element_rect(fill=NA))
}


#read in the CSV file with selected columns
allNEDbreaths<-read.csv("data/NEDPracticePx62Bailey.csv", header=FALSE)

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
allNEDbreathareas<-vector(mode="numeric",length=length(inspendindices))
allregbreathareas<-vector(mode="numeric",length=length(inspendindices))

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
  rightareas<-vector(mode="numeric", length=(length(breath)-first(vmax2index))) #one of the vmaxes has two back to back indices that have the same value
  
  #looping over the individual breath i to find midpt NED area
   for(j in 1:(length(breath)-1)){
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
  sum(midptNEDareas)->allNEDbreathareas[i]
  
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
  for(m in 1:(length(breath)-vmax2index-1)){
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
    
    #summing the left, middle, and right and storing that value in the array for each i
    TVnonNED<-leftsum+middlearea+rightsum
    sum(TVnonNED)->allregbreathareas[i]
    
}

##comparing NED and nonNED breaths

percentNEDoverIdeal<-(allNEDbreathareas/allregbreathareas)*100
breaths<-1:20


#plot the waveform to see the breaths

time=allNEDbreaths$`ChannelTitle=`
flow=allNEDbreaths$`Flow Sensor Total`
NEDPlot<-ggplot(data = allNEDbreaths, aes(x=time, y=flow))+
  geom_line(color=lunair_palette[2], linewidth=0.25)+
  theme_lunair()
NEDPlot

#create a table
finalarray<-rbind(breaths,percentNEDoverIdeal)
finaltable<-as.data.frame(finalarray)
print(finaltable)
table_plot <- tableGrob(finaltable)
ggsave("finaltable.png", table_plot, width = 35, height = 4)
