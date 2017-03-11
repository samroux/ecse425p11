-- @filename instruction_fetch.vhd
-- @author Samuel Date
-- @timestamp 2017-03-10 8:55 PM
-- @brief vhdl entity defining the instruction fetch stage of the pipelined processor

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instruction_fetch is
	PORT (
		clock : in std_logic;
		reset : in std_logic;
		
		branch_taken : in std_logic;		-- will be set to 1 when Branch is Taken
		branch_address : in std_logic_vector (1023 downto 0);	-- address to jump to when Branch is Taken
		
		IR : out std_logic_vector (31 downto 0);	-- Instruction Read -> Size of 32 bits defined by compiler 
		PC : out std_logic_vector (1023 downto 0)	-- Program Counter -> Assuming instruction memory of size 4096 (128 instructions of 32 bits)

	);
END instruction_fetch;

ARCHITECTURE behaviour OF instruction_fetch IS
SIGNAL sPC: std_logic_vector (1023 downto 0);

component instruction_memory
  PORT (
		clock: IN STD_LOGIC;
		address: in std_logic_vector(31 downto 0);
		instruction: out std_logic_vector(31 downto 0)
	);
end component;

BEGIN

fetch :	process (clock, reset)
			-- performing instruction fetch
			begin
				if reset = '1' then
					-- TODO
					-- This should bring to fill Instruction Memory Register
				elsif (rising_edge(clock)) then
					-- can fetch instruction on rising edge
					
					-- Get instruction from instruction memory
					-- Perform add = PC + 4
					
					-- Check MUX and output
					
					
				end if;
			end process;

	PC <= sPC;	--set output to signal value

END behaviour;