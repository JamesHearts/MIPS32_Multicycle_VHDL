# MIPS 32-bit 

Version 1.0, I will be implementing a new version soon.
------------------------------------------------------------------------------------------------------------------------

Introduction
------------------------------------------------------------------------------------------------------------------------
This project aims to synthesize a 32-bit MIPS processor using VHDL.
I've provided a test bench and a .mif file that simulates basic instructions. Not all mips instructions are implemented but could easily be added to the controller. I will add instructions as time allows me. The MIPS architecture is a RISC architecture.

This particular project implements the multi-cycled version. The processor is not ready to be programmed to an FPGA but the code could easily be added.

How to Simulate:
------------------------------------------------------------------------------------------------------------------------

Download Modelsim or simulator of choice. Download all the files provided and place in a new directory. Create a new project in the same directory that the source files were downloaded to. Add all the files (Add existing) to the project. Top_level_tb is the top level and should be the last to compile. You can generate an auto compile order or just order them entities -> datapath -> controller -> top_level -> top_level_tb. When you compile the project you can go start the simulation and use the top_level_tb as the file to simulate. 

The simulation will start the clock and processor should compute whatever was in your RAM. In order to edit the RAM contents you must edit the .mif file. 

The instructions you can use are:
------------------------------------------------------------------------------------------------------------------------

lw  
sw  
r-type  
branch  
jump  

These instructions are sufficient for small simple programs.

How to add Instructions:
------------------------------------------------------------------------------------------------------------------------

The hardware exists to add more instructions especially I-type (immediate) instructions. Look through the data path and decide which singles need to be asserted in order to implement an instruction. Add the states to the datapath enabling the right signals.

I recommend building your own version as it is easier to understand when you build it from scratch, using my code as a reference.
