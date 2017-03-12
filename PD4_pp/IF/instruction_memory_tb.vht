-- @filename	instruction_memory_tb.vht
-- @author		Samuel Roux
-- @timestamp	2017-03-11 12:55 AM
-- @brief		Testbench for instruction_memory.vhd


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instruction_memory_tb IS
END instruction_memory_tb;

ARCHITECTURE behaviour OF instruction_memory_tb IS


    --all the input signals with initial values
    signal clock : std_logic;
	signal s_reset : std_logic;
    constant clock_period : time := 1 ns;
	
	signal s_address : std_logic_vector(1023 downto 0);
	signal s_instruction : std_logic_vector(31 downto 0);
	
	component instruction_memory
		port (
			clock : in std_logic;
			reset : in std_logic;
			address: in std_logic_vector(1023 downto 0);
			instruction : out std_logic_vector(31 downto 0)
		);
	end component;

BEGIN
	
	dut : instruction_memory
	port map (
			clock,
			s_reset,
			s_address,
			s_instruction
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
	begin
	
		REPORT "Starting Simulation. Will check if can get 10 first lines of file correctly";
		
		s_reset <= '0';
		
		wait for clock_period;
		
		s_reset <= '1';
		
		wait for clock_period;
		
		s_reset <= '0';
		
		wait for clock_period;
		
		REPORT "System has been resetted";
		
		-----------------
		s_address <= (others=>'0');	--addr 0
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00100000000010110000011111010000") REPORT "1 is wrong" SEVERITY ERROR;
		
		-----------------
		
		wait for clock_period;
		
		s_address <= (2=>'1', others=>'0');	--addr 4
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00100000000011110000000000000100") REPORT "2 is wrong" SEVERITY ERROR;
		
		-----------------
		
		wait for clock_period;
		
		s_address <= (3=>'1', others=>'0');	--addr 8
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00100000000000010000000000000011") REPORT "3 is wrong" SEVERITY ERROR;
	
		-----------------
		
		wait for clock_period;
		
		s_address <= (2=> '1',3=>'1', others=>'0');	--addr 12
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00100000000000100000000000000100") REPORT "4 is wrong" SEVERITY ERROR;
	
		-----------------
		wait for clock_period;
		
		s_address <= (4=> '1', others=>'0');	--addr 16
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00000000001000100001100000100100") REPORT "5 is wrong" SEVERITY ERROR;
	
		-----------------
		
		wait for clock_period;
		
		s_address <= (2=>'1', 4=> '1', others=>'0');	--addr 20
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00100000000010100000000000000000") REPORT "6 is wrong" SEVERITY ERROR;
		
		-----------------
		
		wait for clock_period;
		
		s_address <= (3=>'1', 4=> '1', others=>'0');	--addr 24
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00000001010011110000000000011000") REPORT "7 is wrong" SEVERITY ERROR;
		
		-----------------
		
		wait for clock_period;
		
		s_address <= (2=>'1', 3=>'1', 4=> '1', others=>'0');	--addr 28
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00000000000000000110000000010010") REPORT "8 is wrong" SEVERITY ERROR;
		
		-----------------
		
		wait for clock_period;
		
		s_address <= (5=> '1', others=>'0');	--addr 32
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00000001011011000110100000100000") REPORT "9 is wrong" SEVERITY ERROR;
		
		-----------------
		
		wait for clock_period;
		
		s_address <= (2=>'1', 5=> '1', others=>'0');	--addr 36
		
		wait for clock_period;
		
		ASSERT (s_instruction = "00000000000000110001000000100000") REPORT "10 is wrong" SEVERITY ERROR;
		
		REPORT "Simulation Done";
		wait;                                                        
	end process generate_test;  

	
END;