-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "03/13/2017 05:10:54"
                                                            
-- Vhdl Test Bench template for design  :  alu
-- 
-- Simulation tool : ModelSim (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY alu_vhd_tst IS
END alu_vhd_tst;
ARCHITECTURE alu_arch OF alu_vhd_tst IS
-- constants                                                 
-- signals
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;                                                   
SIGNAL ALU_operation : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ALU_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL funct : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL read_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL zero : STD_LOGIC;
COMPONENT alu
	PORT (
	ALU_operation : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	ALU_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
	read_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	read_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	zero : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : alu
	PORT MAP (
-- list connections between master ports and signals
	ALU_operation => ALU_operation,
	ALU_result => ALU_result,
	funct => funct,
	read_data_1 => read_data_1,
	read_data_2 => read_data_2,
	zero => zero
	);

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
begin

	ALU_operation <= "0010"; --add
	funct <= "100000"; --add
	read_data_1 <= x"00000001";
	read_data_2 <= x"00000002";
	WAIT FOR 1 * clk_period;
	
	ALU_operation <= "0110"; --sub
	funct <= "100010"; --sub
	read_data_1 <= x"00000003";
	read_data_2 <= x"00000002";
	WAIT FOR 1 * clk_period;
	
	ALU_operation <= "0010"; --sll
	funct <= "000000"; --sll
	read_data_1 <= x"00000001";
	read_data_2 <= x"00000002";	
	WAIT FOR 1 * clk_period;
	
	ALU_operation <= "0110"; --srl
	funct <= "000010"; --srl
	read_data_1 <= x"00000010";
	read_data_2 <= x"00000002";
	WAIT FOR 1 * clk_period;
	
	ALU_operation <= "0000"; --and
	funct <= "100100"; --and
	read_data_1 <= x"01010101";
	read_data_2 <= x"02020202";
	WAIT FOR 1 * clk_period;
	
	ALU_operation <= "0001"; --or
	funct <= "100101"; --or
	read_data_1 <= x"01010101";
	read_data_2 <= x"02020202";
	WAIT FOR 1 * clk_period;
	
	ALU_operation <= "0111"; --sll
	funct <= "001010"; --sll
	read_data_1 <= x"00000001";
	read_data_2 <= x"00000002";
	WAIT FOR 1 * clk_period;
	
	ALU_operation <= "1111"; --others
	funct <= "100000"; --add
	read_data_1 <= x"00000001";
	read_data_2 <= x"00000002";
	WAIT FOR 1 * clk_period;

WAIT;
	
end process;                                      
END alu_arch;
