# ecse425p11
## Group 11 - ECSE425

### How to test:

In order to test this file properly, you need to test the processor.vhd component.
This component is responsible for integrating all processor's components together.

There's only two inputs to this file:

`clock : std_logic`

`reset : std_logic`

The reset signal will load the content of a file into the "instruction memory"-register.

In order to have the program load the proper file, please modify line 43 of "instruction_memory.vhd". This file can be found at exce425p11/PD4_pp/IF/instruction_memory.vhd




