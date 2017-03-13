-- @filename	instruction_fetch_tb.vht
-- @author		Samuel Roux
-- @timestamp	2017-03-11 12:10 AM
-- @brief		Testbench for instruction_fetch.vhd


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instruction_fetch_tb IS
END instruction_fetch_tb;

ARCHITECTURE behaviour OF instruction_fetch_tb IS


    --all the input signals with initial values
    signal clock : std_logic;
	signal s_reset : std_logic;
    constant clock_period : time := 1 ns;
	
	signal s_branch_taken : std_logic := '0';	--initialy, assume no branch is taken
	signal s_branch_address : std_logic_vector(1023 downto 0):= (others => '0');  --set branch address to 0 for now, but won't be used
	
	signal s_PC : std_logic_vector(1023 downto 0) := (others => '0'); --initialize PC to 0
	signal s_IR : std_logic_vector(31 downto 0):= (others => '0');
	
	component instruction_fetch
		PORT (
			clock : in std_logic;
			reset : in std_logic;
			
			branch_taken : in std_logic;		-- will be set to 1 when Branch is Taken
			branch_address : in std_logic_vector (1023 downto 0);	-- address to jump to when Branch is Taken
			
			IR : out std_logic_vector (31 downto 0);	-- Instruction Read -> Size of 32 bits defined by compiler 
			PC : out std_logic_vector (1023 downto 0)	-- Program Counter -> Assuming instruction memory of size 4096 (128 instructions of 32 bits)
		);
	end component;

BEGIN
	
	dut : instruction_fetch
	port map (
			clock,
			s_reset,
			s_branch_taken,
			s_branch_address,
			s_IR,
			s_PC
		);


-- continuous clock process
	clock_process : process
	begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	end process;
	
	generate_test : process
		variable pc_temp : std_logic_vector (1023 downto 0);
	begin
	
		REPORT "-------SIMULATION START-------";
		
		s_reset <= '1';
		
		wait for clock_period/2;
		
		s_reset <= '0';
		
		REPORT "System has been resetted";
		
		--------Start of Test---------
		
		--------Read File in order--------
		
		------------------------
		pc_temp := (others=>'0');
		
		ASSERT (s_PC = pc_temp) REPORT "PC is not initialized to 0!" Severity ERROR; --PC = 0
		
		wait for clock_period;
		
		--Require 1 clock cycle to get instruction from memory
		
		ASSERT (s_IR = "00100000000010110000011111010000") REPORT "PC = 0 is wrong" SEVERITY ERROR;

		
		------------------------
		pc_temp := (2=>'1', others=>'0');
		
		ASSERT (s_PC = pc_temp ) REPORT "PC is not = 4" Severity ERROR; -- PC = 4
		
		wait for clock_period;
		
		--Require 1 clock cycle to get instruction from memory
		
		ASSERT (s_IR = "00100000000011110000000000000100") REPORT "PC = 4 is wrong" SEVERITY ERROR;
		
		--------Test Branching--------
		
		s_branch_taken <= '1';		--Branch taken is set 1 cycle before it takes effect.
		s_branch_address <= (2=>'1', 3=>'1', 4=> '1', others=>'0');	--addr 28
		
		pc_temp := (3=>'1', others=>'0');
		
		ASSERT (s_PC = pc_temp ) REPORT "PC is not = 8" Severity ERROR; -- PC = 8
		
		wait for clock_period;
		
		--Require 1 clock cycle to get instruction from memory
		
		ASSERT (s_IR = "00100000000000010000000000000011") REPORT "PC = 8 is wrong" SEVERITY ERROR;
	
		----
		
		ASSERT (s_PC = s_branch_address ) REPORT "PC is not equal to branch_address" Severity ERROR; -- PC = 28
		
		s_branch_taken <= '0';
		
		wait for clock_period;
		
		--Require 1 clock cycle to get instruction from memory
		
		ASSERT (s_IR = "00000000000000000110000000010010") REPORT "PC = Branching instr. is wrong" SEVERITY ERROR;
		
		------------------------
		
		pc_temp := (5=> '1', others=>'0');
		
		ASSERT (s_PC = pc_temp ) REPORT "PC is not = 32" Severity ERROR; -- PC = 32
		
		wait for clock_period;
		
		--Require 1 clock cycle to get instruction from memory
		
		ASSERT (s_IR = "00000001011011000110100000100000") REPORT "PC = 32 is wrong" SEVERITY ERROR;
		
		
		REPORT "Simulation Done";
		wait;            
		--------END of Test---------                                   
	end process generate_test;  
END;