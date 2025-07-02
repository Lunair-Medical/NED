## the purpose of this script is to be able to look through waveform data that has insp starts and ends marked and have the program integrate between the insp markings it finds
#originally created by Grace Burkholder 01 July 2025

#read in the CSV file with selected columns
allNEDbreaths<-read.csv("data/NEDPractice5Breaths.csv", header=FALSE)

data_step<-0.0005

#make the header and remove automatic header rows
colnames(allNEDbreaths)<-as.character(unlist(allNEDbreaths[5, ]))

allNEDbreaths<-allNEDbreaths[-(1:9), ]


##keep only the columns we want
cols_to_keep <- c("ChannelTitle=", "Flow Sensor Nose", "Flow Sensor Mouth", "Flow Sensor Total", "Tidal Volume Total", "Comments")
allNEDbreaths <- allNEDbreaths[, cols_to_keep]

#find all the inspstart and inspend indices
inspstartindices<-which(grepl("InspStart", allNEDbreaths$Comments))
inspendindices<-which(grepl("InspEnd", allNEDbreaths$Comments))

data_step<-0.0005

#a for loop that will integrate from inspstart to inspend for the number of breaths selected
for(i in 1:length(inspstartindices)){
  inspstarti<-inspstartindices[i]
  inspendi<-inspendindices[i]
  starttime<-allNEDbreaths$`ChannelTitle=`[inspstarti]
  endtime<-allNEDbreaths$`ChannelTitle=`[inspendi]
  areas<-vector(mode="numeric",length=length(inspendi-inspstarti)-1)
  
   for(j in inspstarti+1:inspendi){
     #get the two values of y 
     base1=allNEDbreaths$`Flow Sensor Total`[j-1]
     base2=allNEDbreaths$`Flow Sensor Total`[j]
     
     #value of x is always the same, step_x
     
     #calculate the area:
     area = 1/2 * (base1 + base2) * data_step #trapezoidal area formula
     
     #store it in the array
     area->areas[i-1]
  }
}
