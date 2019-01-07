## Signal-test

# Description
Simple circuit simulator written in Ruby. The program was made with the intention of designing circuits and combining them to eventually simulate complex machines like adders, CPUs and perhaps entire computers. 
The project began the 4'th January 2019.  

Update #1 07 Jan 2019:
After doing some testing I've realised the program runs very slowly after adding a lot of noddes and repeaters. This is likely due to the poor optimisation in my code and I'm working on it currently. First I have to figure out exactly what is using so much CPU performance.

Update #2 07 Jan 2019
I optimised the signal transfering and afterwards ran the program with Ruby Profiler to pinpoint the cause of lag. The lag is primarily caused by the drawing of nodes and links. With about 800 nodes and 800 links I get about 40 FPS. However this should be easily handled even by my laptop. The reason why the drawing causes lag I'm guessing is partly due to the many calculations done to compensate for the camera movement and zoom. I'll be looking into that. Worst-case scenario I may have to remove the camera zoom entirely.

# Screenshots
![screenshot _8bit_memory](https://user-images.githubusercontent.com/8478043/50781436-ab0a6600-12a5-11e9-815c-046782816b4e.PNG)

# Launch
There is no .exe file attached yet.
The program is launched by opening "Main.rb" with ruby.

# Requirements
- Ruby v1.9.3 installed (only tested with v1.9.3 so far, but should work with all versions)
- Gosu v0.7.50 installed for Ruby (only tested with 0.7.50, but should work with all versions)

# User Manual
in progres...

# Credits
in progres
