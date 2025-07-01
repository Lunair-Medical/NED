#trapezoidal sum coding setup

#raw data 
samp_rate<-1000
data_step<-1/samp_rate #how big a timestep you have in the data
x<-seq(0,2*pi-0.01,data_step)
y<-sin(x)

plot(x,y)

fake_data<-data.frame(x,y)

## calculate trap sum:

#define the step value:
# range_x <- last(fake_data$x)- first(fake_data$x)
# n=100  #number of trapezoids

#multiplier:
multiplier<-5
step_x <- multiplier * data_step #must be a multiple of the data step rate

#make an array of all of the x values 
all_x<-fake_data$x[seq(multiplier,length(fake_data$x),multiplier)]
all_y<-fake_data$y[seq(multiplier,length(fake_data$y),multiplier)]

#calc all areas :

#empty array for the areas: 
areas<-vector(mode="numeric",length=length(all_x)-1)

for (i in 2:(length(all_x))){
  
  #get the two values of y 
  base1=all_y[i-1]
  base2=all_y[i]
  
  #value of x is always the same, step_x
  
  #calculate the area:
  area = 1/2 * (base1 + base2) * step_x #trapezoidal area formula
  
  #store it in the array
  area->areas[i-1]
  
}

sum(areas)
