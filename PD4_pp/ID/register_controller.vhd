-- @filename:	register_controller.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Wrapper for the register file.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGISTER_CONTROLLER is

port (
	clock : in std_logic;
	PC_IF : in std_logic_vector (11 downto 0);
	IR_IF : in std_logic_vector(31 downto 0);

	IR_MEM_WB : in std_logic_vector(31 downto 0);
	WB_return : in std_logic_vector(7 downto 0); -- either a loaded register from memory 
												 -- or the ALU output (mux decided)
	isRegReg: in std_logic;	-- WB should have a mux to determine this flag (not in diagram!)
							-- it is used to know whether to write to rs (1) or rt (0)

	A : out std_logic_vector(7 downto 0);
	B : out std_logic_vector(7 downto 0);
	Imm : out std_logic_vector(31 downto 0);
	opcode : out std_logic_vector(5 downto 0);
	branchTaken : out std_logic	-- returns 1 if rs == rt and instruction is beq
								-- or if rs /= rt and instruction is bne.
								-- to be used in EX stage 

	);
end REGISTER_CONTROLLER;

architecture behavior of REGISTER_CONTROLLER is

	-- temporary tokens for IR
	signal instruction : std_logic_vector(5 downto 0);
	signal A_addr : std_logic_vector(4 downto 0);
	signal B_addr : std_logic_vector(4 downto 0);
	signal Imm_to_extend : std_logic_vector(15 downto 0);

	-- register file signals
	signal reg_address : std_logic_vector(4 downto 0);
	signal reg_write_input : std_logic_vector(7 downto 0);
	signal MemWrite : std_logic;
	signal MemRead : std_logic;
	signal reg_output : std_logic_vector(7 downto 0);

	-- temporary register contents used for beq/bne comparison
	signal A_temp : std_logic_vector(7 downto 0);
	signal B_temp : std_logic_vector(7 downto 0);

	component REGISTER_FILE
		port (
			clock : in std_logic;
			reg_address : in std_logic_vector(4 downto 0);
			reg_write_input : in std_logic_vector(7 downto 0);
			MemWrite : in std_logic;
			MemRead : in std_logic;
			reg_output : out std_logic_vector(7 downto 0)
		);
	end component;

	begin

	rf : REGISTER_FILE
	port map (
		clock => clock,
		reg_address => reg_address,
		reg_write_input => reg_write_input,
		MemWrite => MemWrite,
		MemRead => MemRead,
		reg_output => reg_output
		);	

	-- ID should only read from reg file
	ID: process(clock)
	begin
	if falling_edge(clock) then
		-- Separate instruction in tokens
		instruction <= IR_IF(5 downto 0);
		A_addr <= IR_IF(10 downto 6);
		B_addr <= IR_IF(15 downto 11);
		Imm_to_extend <= IR_IF(31 downto 16);

		-- Return opcode. Needs to match the following:
		-- http://www-inst.eecs.berkeley.edu/~cs61c/resources/MIPS_Green_Sheet.pdf
		-- TODO: ensure ALU compatibility and fallback case (invalid inst)
		opcode <= instruction;

		-- Read registers
		MemRead <= '1';
		MemWrite <= '0';
		reg_address <= A_addr;
		A <= reg_output;
		A_temp <= reg_output;
		reg_address <= B_addr;
		B <= reg_output;
		B_temp <= reg_output;

		-- Preemptive steps	
		-- Sign extend immediate 16->32
		Imm <= std_logic_vector(resize(signed(Imm_to_extend), Imm'length));

		-- Do equality test on registers -> branch
		if (instruction = "000100") then	-- beq
			if (A_temp = B_temp) then 	branchTaken <= '1';
			else 						branchTaken <= '0';
			end if;
		elsif (instruction = "000101") then	-- bne
			if (A_temp /= B_temp) then 	branchTaken <= '1';
			else 						branchTaken <= '0';
			end if;
		else
			branchTaken <= '0';
		end if;

		-- TODO: why is this not done in EX?
		-- Compute branch target address PC+4+Imm
	end if;
	end process;

	-- WB process runs concurrently but works on a previous instruction.
	-- It only writes to reg file, which supports read/write in a single cycle.
	WB: process(clock)
	begin
	if rising_edge(clock) then
		-- Separate instruction in tokens
		instruction <= IR_MEM_WB(5 downto 0);
		A_addr <= IR_MEM_WB(10 downto 6);
		B_addr <= IR_MEM_WB(15 downto 11);
		Imm_to_extend <= IR_MEM_WB(31 downto 16);

		-- Write to appropriate register
		MemRead <= '0';
		MemWrite <= '1';
		if (isRegReg = '1') then
			reg_address <= A_addr;
		else
			reg_address <= B_addr;
		end if;
		reg_write_input <= WB_return;
	end if;
	end process;

end behavior;