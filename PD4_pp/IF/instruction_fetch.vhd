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
		branch_address : in std_logic_vector (11 downto 0);

		IR : out std_logic_vector (31 downto 0);	-- Instruction Read -> Size of 32 bits defined by compiler 
		PC : out std_logic_vector (11 downto 0);	-- Program Counter -> Assuming instruction memory of size 4096 (128 instructions of 32 bits)
		write_to_files : out std_logic
	);
END instruction_fetch;

ARCHITECTURE behaviour OF instruction_fetch IS
--SIGNAL s_reset : std_logic := '0';
SIGNAL s_PC: std_logic_vector (11 downto 0) := (others => '0'); --initialize PC to 0
SIGNAL s_IR : std_logic_vector (31 downto 0);
SIGNAL s_FOUR: std_logic_vector (11 downto 0) := (2=>'1', others=>'0'); --signal hard wired to 4

SIGNAL s_PC_int : integer;

component instruction_memory
  PORT (
		clock: IN STD_LOGIC;
		reset : IN STD_LOGIC;
		address: IN std_logic_vector(11 downto 0);
		instruction: OUT std_logic_vector(31 downto 0)
	);
end component;

BEGIN

	IM: instruction_memory
	port map (
			clock,
			reset,
			s_PC,
			s_IR
		);

-- performing instruction fetch
fetch :	process (clock, reset)
variable should_write : std_logic;
begin
	if reset = '1' then
		-- This should bring to fill Instruction Memory Register
		-- since reset signal is hardwired between two devices, this will run the read_file process of instruction_memory
		--s_reset <= reset;
		s_PC <= (others => '0');
		should_write := '0';
	elsif (rising_edge(clock)) then
		-- can fetch instruction on rising edge
		-- Get instruction from instruction memory
		-- Here, s_IR should contain instruction
					
		-- Check MUX and output
		if(branch_taken = '1') then
			-- check for infinite loop as a trigger to write reg_file and data_mem
			-- an infinite loop is a taken branch that changes the PC to its own PC
			if (s_PC = branch_address) and (should_write = '0') then
				should_write := '1';
			end if;

			-- move to instruction pointed to by branch address
			s_PC <= branch_address;
		else
			-- normal case: move to next instruction			
			s_PC <= std_logic_vector(unsigned(s_PC) + unsigned(s_FOUR));
		end if;
		write_to_files <= should_write;
	end if;
end process;
	
PC <= s_PC;	--set output to signal value
IR <= s_IR;

END behaviour;