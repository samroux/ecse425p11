-- @filename:	ex_mem_reg.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-10
-- @brief:		EX/MEM register which contains the intermediate values used
--				in pipelining

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_MEM_REG is
port (
	clock : in std_logic;
	branch_taken_EX : in std_logic; -- whether branch should be taken (BEQZ)
	PC_EX : in std_logic_vector(11 downto 0);
	ALUOutput_EX : in std_logic_vector(31 downto 0); -- need to make sure that only 12 bits
													 -- are used when this is used as index
	B_EX : in std_logic_vector(31 downto 0);	-- rt, used for reg-reg store
										    -- should come from id/ex directly
	IR_EX : in std_logic_vector(31 downto 0);	-- same as above
	MemRead_EX : in std_logic;
	MemWrite_EX : in std_logic;
	
	branch_taken_MEM : out std_logic;
	PC_MEM : out std_logic_vector(11 downto 0);
	ALUOutput_MEM : out std_logic_vector(31 downto 0);
	B_MEM : out std_logic_vector(31 downto 0);
	IR_MEM : out std_logic_vector(31 downto 0);
	MemRead_MEM : out std_logic;
	MemWrite_MEM : out std_logic
	);
end EX_MEM_REG;

architecture behavior of EX_MEM_REG is

	signal branch_taken_EX_STORED : std_logic;
	signal PC_EX_STORED : std_logic_vector(11 downto 0);
	signal ALUOutput_EX_STORED : std_logic_vector(31 downto 0) := (others=>'0');
	signal B_EX_STORED : std_logic_vector(31 downto 0) := (others=>'0');
	signal IR_EX_STORED : std_logic_vector(31 downto 0) := (others=>'0');
	signal MemRead_EX_STORED : std_logic;
	signal MemWrite_EX_STORED : std_logic;

	begin

	-- If register_in is the current value, register_out should be 
	-- the last value stored (1 clock cycle before the current value).
	-- Values should be fed on rising_edge to be returned on the next 
	-- rising_edge (i.e a full cycle after).

	process (clock)
	begin
		if rising_edge(clock) then
			if (branch_taken_EX_STORED /= branch_taken_EX) then
				branch_taken_MEM <= branch_taken_EX_STORED;
				branch_taken_EX_STORED <= branch_taken_EX;
			end if;

			if (PC_EX_STORED /= PC_EX) then
				PC_MEM <= PC_EX_STORED;
				PC_EX_STORED <= PX_EX;
			end if;

			if (ALUOutput_EX_STORED /= ALUOutput_EX) then
				ALUOutput_MEM <= ALUOutput_EX_STORED;
				ALUOutput_EX_STORED <= ALUOutput_EX;
			end if;

			if (B_EX_STORED /= B_EX) then
				B_MEM <= B_EX_STORED;
				B_EX_STORED <= B_EX;
			end if;

			if (IR_EX_STORED /= IR_EX) then
				IR_MEM <= IR_EX_STORED;
				IR_EX_STORED <= IR_EX;
			end if;
			
			if (MemRead_EX_STORED /= MemRead_EX) then
				MemRead_MEM <= MemRead_EX_STORED;
				MemRead_EX_STORED <= MemRead_EX;
			end if;
			
			if (MemWrite_EX_STORED /= MemWrite_EX) then
				MemWrite_MEM <= MemWrite_EX_STORED;
				MemWrite_EX_STORED <= MemWrite_EX;
			end if;
			
		end if;
	end process;

end behavior;
