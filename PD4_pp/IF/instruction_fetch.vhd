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
		full_ALUOutput_bAddr : in std_logic_vector (31 downto 0); -- full address received by ALU in case of branch. Needs to be truncated later

		IR : out std_logic_vector (31 downto 0);	-- Instruction Read -> Size of 32 bits defined by compiler 
		PC : out std_logic_vector (11 downto 0)	-- Program Counter -> Assuming instruction memory of size 4096 (128 instructions of 32 bits)

	);
END instruction_fetch;

ARCHITECTURE behaviour OF instruction_fetch IS
SIGNAL s_reset : std_logic := '0';
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
			s_reset,
			s_PC,
			s_IR
		);

fetch :	process (clock, reset)
			variable branch_address : std_logic_vector(11 downto 0) := "000000000000";
			-- performing instruction fetch
			begin
				if reset = '1' then
					-- This should bring to fill Instruction Memory Register
					--since reset signal is hardwired between two devices, this will run the read_file process of instruction_memory
					s_reset <= reset;
					s_PC <= (others => '0');
				elsif (rising_edge(clock)) then
					-- can fetch instruction on rising edge
					-- Get instruction from instruction memory
					-- Here, s_IR should contain instruction

					-- Perform add = PC + 4
					
					s_PC <= std_logic_vector(unsigned(s_PC) + unsigned(s_FOUR));
					
					-- address to jump to when Branch is Taken
					branch_address := full_ALUOutput_bAddr(11 downto 0);
					report "b addr: "&integer'image(to_integer(unsigned(branch_address)));
					-- Check MUX and output
					if(branch_taken = '1') then
						s_PC <= branch_address; --set PC to branch_address
					else
						-- do nothing, keep the added PC
					end if;
				end if;
	end process;
	
PC <= s_PC;	--set output to signal value
IR <= s_IR;

END behaviour;