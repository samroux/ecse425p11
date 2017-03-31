-- @filename:	register_controller.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Wrapper for the register file (ID stage).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGISTER_CONTROLLER is

port (
	clock : in std_logic;

	PC_IF : in std_logic_vector (11 downto 0);
	IR_IF : in std_logic_vector(31 downto 0);
	WB_addr : in std_logic_vector(4 downto 0); 		-- address to write to (rs or rt)
	WB_return : in std_logic_vector(31 downto 0); 	-- either a loaded register from memory 
												  	-- or the ALU output (mux decided)
	write_to_file : in std_logic;

	PC_ID : out std_logic_vector (11 downto 0);
	IR_ID : out std_logic_vector(31 downto 0);
	A : out std_logic_vector(31 downto 0);
	B : out std_logic_vector(31 downto 0);
	Imm : out std_logic_vector(31 downto 0)
	--branch_taken : out std_logic	-- returns 1 if rs == rt and instruction is beq
								-- or if rs /= rt and instruction is bne.
								-- to be used in EX stage 
								
	);
end REGISTER_CONTROLLER;

architecture behavior of REGISTER_CONTROLLER is

	-- register file signals
	signal reg_address_A : std_logic_vector(4 downto 0);
	signal reg_address_B : std_logic_vector(4 downto 0);
	signal reg_write_input : std_logic_vector(31 downto 0);
	signal reg_write_addr : std_logic_vector (4 downto 0);
	signal Mem_R_W : std_logic := '0'; -- 0 for read, 1 for write
	--signal MemRead : std_logic := '0';
	signal reg_output_A : std_logic_vector(31 downto 0);
	signal reg_output_B : std_logic_vector(31 downto 0);

	component REGISTER_FILE
		port (
			clock : in std_logic;
			reg_address_A : in std_logic_vector(4 downto 0);
			reg_address_B : in std_logic_vector(4 downto 0);
			reg_write_input : in std_logic_vector(31 downto 0);
			reg_write_addr : in std_logic_vector (4 downto 0);
			Mem_R_W : in std_logic;
			--MemRead : in std_logic;
			write_to_file : in std_logic;
			reg_output_A : out std_logic_vector(31 downto 0);
			reg_output_B : out std_logic_vector(31 downto 0)
		);
	end component;

	begin

	rf : REGISTER_FILE
	port map (
		clock => clock,
		reg_address_A => reg_address_A,
		reg_address_B => reg_address_B,
		reg_write_addr => reg_write_addr,
		reg_write_input => reg_write_input,
		Mem_R_W => Mem_R_W,
		--MemRead => MemRead,
		write_to_file => write_to_file,
		reg_output_A => reg_output_A,
		reg_output_B => reg_output_B
		);	

	process(clock)

	variable Imm_temp : std_logic_vector(31 downto 0);
	begin

	-- read in 2nd half of cycle, write in 1st half
	if falling_edge(clock) then
		-- Read registers
		Mem_R_W <= '0';

		reg_address_A <= IR_IF(25 downto 21);
		reg_address_B <= IR_IF(20 downto 16);

		-- Sign extend immediate 16->32 for signed instructions (general case)
		-- Zero extend immediate 16->32 for unsigned instructions (andi, ori)
		if (IR_IF(31 downto 26) = "001100") OR (IR_IF(31 downto 26) = "001101") then
			Imm_temp := std_logic_vector(resize(signed(IR_IF(15 downto 0)), Imm'length));
		else
			Imm_temp := std_logic_vector(resize(unsigned(IR_IF(15 downto 0)), Imm'length));
		end if;

	-- WB process runs concurrently but works on a previous instruction.
	-- It only writes to reg file, which supports read/write in a single cycle.
	elsif rising_edge(clock) then
		-- Write to appropriate register
		Mem_R_W <= '1';
		reg_write_addr <= WB_addr;
		reg_write_input <= WB_return;

		-- Move PC_IF to PC_ID and IR_IF to IR_ID after a cycle
		PC_ID <= PC_IF;
		IR_ID <= IR_IF;

		-- Ensure that Imm is written to on a rising edge
		Imm <= Imm_temp;
	end if;
	end process;

	-- needs to be outside the process block to avoid excess delay
	A <= reg_output_A;
	B <= reg_output_B;

end behavior;