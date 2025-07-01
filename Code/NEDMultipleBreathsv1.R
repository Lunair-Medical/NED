## the purpose of this script is to be able to look through waveform data that has insp starts and ends marked and have the program integrate between the insp markings it finds
#originally created by Grace Burkholder 01 July 2025

#read in the CSV file with selected columns
allNEDbreaths<-read.csv("data/NEDPractice5Breaths.csv", header=FALSE)

data_step<-0.0005

#make the header and remove automatic header rows
colnames(allNEDbreaths)<-as.character(unlist(allNEDbreaths[4, ]))

#allNEDbreaths<-allNEDbreaths[-(1:8), ]

##keep only the columns we want
#allNEDbreaths <- subset(allNEDbreaths, select = c(ChannelTitle=, Flow Sensor Nose, Flow Sensor Mouth, Flow Sensor Total, Tidal Volume Total, Comments))
#cols_to_keep <- c("ChannelTitle=", "Flow Sensor Nose", "Flow Sensor Mouth", "Flow Sensor Total", "Tidal Volume Total", "Comments")
#allNEDbreaths <- allNEDbreaths[, cols_to_keep]

#NEDbreathsColsWeWant <- select(allNEDbreaths, , N2, N3, REM)




## comment as of July 01 afternoon: So I had the first part of the code working and it was naming the columns correctly and removing the headers, but I tried to filter columns and now the first part of the script is being weird so pick up here tomorrow.