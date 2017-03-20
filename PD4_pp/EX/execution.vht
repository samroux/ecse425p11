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
-- Generated on "03/19/2017 15:04:54"
                                                            
-- Vhdl Test Bench template for design  :  execution
-- 
-- Simulation tool : ModelSim (VHDL)
-- 
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
ENTITY execution_vhd_tst IS
END execution_vhd_tst;
ARCHITECTURE execution_arch OF execution_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clock : STD_LOGIC;
constant clk_period : time := 1 ns; 
SIGNAL imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL PC_plus_4 : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL read_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL EXE_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL NEXT_PC : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal MemRead : std_logic;
signal MemWrite : std_logic;
signal branchTaken_EX : std_logic;
signal B_EX : std_logic_vector(31 downto 0);
signal IR_EX : std_logic_vector(31 downto 0);
--signal test_b_addr: std_logic_vector(31 downto 0);
COMPONENT execution
    PORT (
    clock : IN STD_LOGIC;
    imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    PC_plus_4 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    read_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    read_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    EXE_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    NEXT_PC : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    MemRead : out std_logic;
    MemWrite : out std_logic;
    branchTaken_EX : out std_logic;
    B_EX : out std_logic_vector(31 downto 0);
    IR_EX : out std_logic_vector(31 downto 0)
    --test_b_addr: out std_logic_vector(31 downto 0)
    );
END COMPONENT;
BEGIN
    i1 : execution
    PORT MAP (
-- list connections between master ports and signals
    clock => clock,
    imm => imm,
    instruction => instruction,
    PC_plus_4 => PC_plus_4,
    read_data_1 => read_data_1,
    read_data_2 => read_data_2,
    EXE_result => EXE_result,
    NEXT_PC => NEXT_PC,
    MemRead => MemRead,
    MemWrite => MemWrite,
    branchTaken_EX => branchTaken_EX,
    B_EX => B_EX,
    IR_EX => IR_EX
    --test_b_addr => test_b_addr
    );
clk_process : process
begin
  clock <= '0';
  wait for clk_period/2;
  clock <= '1';
  wait for clk_period/2;
end process;
test_process : process
begin
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000000000000100";
    instruction <= "00100000000010100000000000000100"; --addi $10,  $0, 4
    pc_plus_4 <= "000000000000";
    read_data_1 <= x"00000000";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000000000000001";
    instruction <= "00100000000000010000000000000001"; --addi $1,  $0, 1
    pc_plus_4 <= "000000000100";
    read_data_1 <= x"00000000";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000000000000001";
    instruction <= "00100000000000100000000000000001"; --addi $2,  $0, 1
    pc_plus_4 <= "000000001000";
    read_data_1 <= x"00000000";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000011111010000";
    instruction <= "00100000000010110000011111010000"; --addi $11,  $0, 2000
    pc_plus_4 <= "000000001100";
    read_data_1 <= x"00000000";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000000000000100";
    instruction <= "00100000000011110000000000000100"; --addi $15,  $0, 4
    pc_plus_4 <= "000000010000";
    read_data_1 <= x"00000000";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000000000000000";
    instruction <= "00100000010000110000000000000000"; --addi $3,  $2, 0
    pc_plus_4 <= "000000010100";
    read_data_1 <= x"00000000";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000001000000100000";
    instruction <= "00000000010000010001000000100000"; --add $2,  $2, 1
    pc_plus_4 <= "000000011000";
    read_data_1 <= x"00000000";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000001000000100000";
    instruction <= "00000001010011110000000000011000"; --mult $10,  $15
    pc_plus_4 <= "000000011100";
    read_data_1 <= x"00000003";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000001000000100000";
    instruction <= "00000000000000000110000000010010"; --mflo $12
    pc_plus_4 <= "000000100000";
    read_data_1 <= x"00000003";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000000000000000";
    instruction <= "10101101101000100000000000000000"; --sw $2, 0($13)
    pc_plus_4 <= "000000100100";
    read_data_1 <= x"00000003";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000001111111111111111";
    instruction <= "00100001010010101111111111111111"; --addi $10, $10, -1
    pc_plus_4 <= "000000101000";
    read_data_1 <= x"00000003";
    read_data_2 <= x"00000002";
    WAIT FOR 1 * clk_period;
    
    imm <= "00000000000000000000000000000101";
    instruction <= "00010101010000000000000000000101"; --bne $10, $0, loop
    pc_plus_4 <= "000000101100";
    read_data_1 <= x"00000002";
    read_data_2 <= x"00000000";
    WAIT FOR 1 * clk_period;
    
WAIT;
    
end process;            
END execution_arch;