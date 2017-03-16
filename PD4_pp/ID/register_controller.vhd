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
	--PC_IF : in std_logic_vector (11 downto 0);
	IR_IF : in std_logic_vector(31 downto 0);
	WB_addr : in std_logic_vector(4 downto 0); 		-- address to write to (rs or rt)
	WB_return : in std_logic_vector(31 downto 0); 	-- either a loaded register from memory 
												  	-- or the ALU output (mux decided)

	opcode : out std_logic_vector(5 downto 0);
	A : out std_logic_vector(31 downto 0);
	B : out std_logic_vector(31 downto 0);
	Imm : out std_logic_vector(31 downto 0);
	branchTaken : out std_logic	-- returns 1 if rs == rt and instruction is beq
								-- or if rs /= rt and instruction is bne.
								-- to be used in EX stage 

	);
end REGISTER_CONTROLLER;

architecture behavior of REGISTER_CONTROLLER is

	-- Separate instruction into tokens
	--signal opcode_read : std_logic_vector(5 downto 0);
	--signal A_addr : std_logic_vector(4 downto 0);
	--signal B_addr : std_logic_vector(4 downto 0);
	--signal Imm_to_extend : std_logic_vector(15 downto 0);

	-- register file signals
	signal reg_address : std_logic_vector(4 downto 0);
	signal reg_write_input : std_logic_vector(31 downto 0);
	signal MemWrite : std_logic;
	signal MemRead : std_logic;
	signal reg_output : std_logic_vector(31 downto 0);

	-- temporary register contents used for beq/bne comparison
	signal A_temp : std_logic_vector(31 downto 0);
	signal B_temp : std_logic_vector(31 downto 0);

	component REGISTER_FILE
		port (
			clock : in std_logic;
			reg_address : in std_logic_vector(4 downto 0);
			reg_write_input : in std_logic_vector(31 downto 0);
			MemWrite : in std_logic;
			MemRead : in std_logic;
			reg_output : out std_logic_vector(31 downto 0)
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

	process(clock)
	begin

	-- ID process's only interaction with reg file should be reads.
	if falling_edge(clock) then
		--opcode_read <= IR_IF(31 downto 26);
		--A_addr <= IR_IF(25 downto 21);
		--B_addr <= IR_IF(20 downto 16);
		--Imm_to_extend <= IR_IF(15 downto 0);

		-- Return opcode. Needs to match the following:
		-- http://www-inst.eecs.berkeley.edu/~cs61c/resources/MIPS_Green_Sheet.pdf
		-- TODO: ensure ALU compatibility and fallback case (invalid inst)
		--opcode <= opcode_read;
		opcode <= IR_IF(31 downto 26);

		-- Read registers
		MemRead <= '1';
		MemWrite <= '0';
		--reg_address <= A_addr;
		reg_address <= IR_IF(25 downto 21);
		A <= reg_output;
		A_temp <= reg_output;

		--reg_address <= B_addr;
		reg_address <= IR_IF(20 downto 16);
		B <= reg_output;
		B_temp <= reg_output;

		-- Preemptive steps	
		-- Sign extend immediate 16->32 for signed instructions (general case)
		-- Zero extend immediate 16->32 for unsigned instructions (andi, ori)
		--if (opcode_read = "001100") OR (opcode_read = "001101") then
		if (IR_IF(31 downto 26) = "001100") OR (IR_IF(31 downto 26) = "001101") then
			--Imm <= std_logic_vector(resize(unsigned(Imm_to_extend), Imm'length));
			Imm <= std_logic_vector(resize(unsigned(IR_IF(15 downto 0)), Imm'length));
		else
			--Imm <= std_logic_vector(resize(signed(Imm_to_extend), Imm'length));
			Imm <= std_logic_vector(resize(unsigned(IR_IF(15 downto 0)), Imm'length));
		end if;

		-- Do equality test on registers -> branch
		-- TODO: Compute branch target address PC+4+Imm
		-- 		 why is this not done in EX?
		if (IR_IF(31 downto 26) = "000100") then	-- beq
			if (A_temp = B_temp) then 	branchTaken <= '1';
			else 						branchTaken <= '0';
			end if;
		elsif (IR_IF(31 downto 26) = "000101") then	-- bne
			if (A_temp /= B_temp) then 	branchTaken <= '1';
			else 						branchTaken <= '0';
			end if;
		else
			branchTaken <= '0';
		end if;

	-- WB process runs concurrently but works on a previous instruction.
	-- It only writes to reg file, which supports read/write in a single cycle.
	elsif rising_edge(clock) then
		-- Write to appropriate register
		MemRead <= '0';
		MemWrite <= '1';
		reg_address <= WB_addr;
		reg_write_input <= WB_return;
	end if;
	end process;

	-- WB process runs concurrently but works on a previous instruction.
	-- It only writes to reg file, which supports read/write in a single cycle.
	--WB: process(clock)
	--begin
	--if rising_edge(clock) then
		-- Write to appropriate register
	--	MemRead <= '0';
	--	MemWrite <= '1';
	--	reg_address <= WB_addr;
	--	reg_write_input <= WB_return;
	--end if;
	--end process;

end behavior;