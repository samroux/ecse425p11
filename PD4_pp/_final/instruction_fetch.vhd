-- @filename instruction_fetch.vhd
-- @author Samuel Date
-- @timestamp 2017-03-10 8:55 PM
-- @brief vhdl entity defining the instruction fetch stage of the pipelined processor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch is
	port (
		clock : in std_logic;
		reset : in std_logic;
		
		branch_taken : in std_logic;		-- will be set to 1 when Branch is Taken
		branch_address : in std_logic_vector (11 downto 0);
		hazard_detected : in std_logic;

		IR : out std_logic_vector (31 downto 0);	-- Instruction Read -> Size of 32 bits defined by compiler 
		PC : out std_logic_vector (11 downto 0);	-- Program Counter -> Assuming instruction memory of size 4096 (128 instructions of 32 bits)
		write_to_files : out std_logic
	);
end instruction_fetch;

architecture behaviour of instruction_fetch is

signal s_PC: std_logic_vector (11 downto 0) := (others => '0'); --initialize PC to 0
signal s_IR : std_logic_vector (31 downto 0);
signal get_bubble : std_logic := '0';

component instruction_memory
  port (
		clock: in STD_LOGIC;
		reset : in STD_LOGIC;
		get_bubble : in std_logic;
		address: in std_logic_vector(11 downto 0);
		instruction: out std_logic_vector(31 downto 0)
		--is_stalled : out std_logic
	);
end component;

begin

	IM: instruction_memory
	port map (
			clock,
			reset,
			get_bubble,
			s_PC,
			s_IR
			--is_stalled
		);

-- performing instruction fetch
fetch :	process (clock, reset)
variable should_write : std_logic;
variable branch_stall : integer := 0;
variable self_loop_counter : integer := 0;
begin
	if reset = '1' then
		-- This should begin to fill Instruction Memory Register -- done only on reset
		-- since reset signal is hardwired between two devices, this will run the read_file process of instruction_memory
		s_PC <= (others => '0');
		should_write := '0';
	elsif (rising_edge(clock)) then
		-- fetch instruction from instruction memory on rising edge
		-- Here, s_IR will contain instruction when inst mem is done
		if ( hazard_detected = '1' ) then
			--get_bubble <= '1'; -- next inst should be a bubble
			branch_stall := 0;
			s_PC <= s_PC;
		
		-- if branch, stall for 2 cycles (until branch_taken is known, i.e. after EX)
		elsif (s_IR(31 downto 26) = "000100" OR s_IR(31 downto 26) = "000101") then
	
			get_bubble <= '1'; -- next inst should be a bubble
			branch_stall := 1;
		elsif (0 < branch_stall AND branch_stall <= 1) then
			get_bubble <= '1'; -- stall for a second bubble
			branch_stall := branch_stall + 1;

		-- if branch taken, change PC to branch address
		elsif(branch_taken = '1') then
			-- check for infinite loop as a trigger to write reg_file and data_mem
			-- an infinite loop is a taken branch that changes the PC to its own PC
			if (s_PC = branch_address) and (should_write = '0') then
				self_loop_counter := self_loop_counter + 1;
				if ( self_loop_counter >= 2)then
					should_write := '1';
				end if;
			end if;

			get_bubble <= '0';
			branch_stall := 0;
			s_PC <= branch_address;	

		-- normal case: move to next instruction, PC + 4
		else
			get_bubble <= '0';	
			branch_stall := 0;
			s_PC <= std_logic_vector(unsigned(s_PC) + "000000000100");
		end if;

		write_to_files <= should_write;
	end if;
end process;
	
--set output to signal value
PC <= s_PC;
IR <= s_IR;

END behaviour;