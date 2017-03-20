# ecse425p11
## Group 11 - ECSE425

### How to test:

In order to test this file properly, you need to test the processor.vhd component.
This component is responsible for integrating all processor's components together.

There's only two inputs to this file:

`clock : std_logic`

`reset : std_logic`

The reset signal will load the content of a file into the "instruction memory"-register.

A .tcl file is provided to compile all required components of this project, along with the main processor.vhd and processor_tb.vht files. Sourcing this file should allow you to run the pipelined processor successfully.

The processor deals with several files: (For simplicity with Modelsim and the tcl script, all files have been copied to the _final directory. )
#### Input:
* `_final/program.txt` should contain the input program, compiled using a MIPS Assembler.

#### Outputs:
* `_final/register_file.txt` contains the contents of the registers once the program is done executing.
* `_final/memory.txt` contains the contents of data memory once the program is done executing.
