* We need to implement a power module which calculates power draw
* It needs to be able to calculate power draw based on hamming distances 
* The power trace needs to have some kind of sample rate which makes sense since we try to emulate Analog-to-Digital converter
* We need to implement a way to have some kind of negativ-positive spread around the 0 mean


# Current Ideas

Implement a decorator which can be used to send info from the execution unit and the cpu to the power module to signal  diffent events. 
We should set the sampling rate to one cycle which locks the sampling rate to the clock rate of our emulated cpu. This should more closly
resemble real hardware. We also need a way to get the hamming distance and swings from the actual calculations done. This is an open todo requires
some more changes to the way instructions are handled currently. 


# Instruction States 

Instructions inside slots have multiple different states: executing, executed, retiring, retired, done 
