-- @filename	write_back_tb.vht
-- @author		Samuel Roux
-- @timestamp	2017-03-15 7:05 PM
-- @brief		Testbench for write_back.vhd


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY write_back_tb IS
END write_back_tb;

ARCHITECTURE behaviour OF write_back_tb IS


    --all the input signals with initial values
    signal clock : std_logic;
	signal s_reset : std_logic := '0';
    constant clock_period : time := 1 ns;
	
	signal s_IR_reg : std_logic_vector(31 downto 0) := (others => '0');
	signal s_LMD : std_logic_vector(7 downto 0) := (others => '0');
	signal s_ALUOutput : std_logic_vector(15 downto 0) := (others => '0');
	
	signal s_IR_dest_reg : std_logic_vector(4 downto 0) := (others => '0');
	signal s_WB_output : std_logic_vector(15 downto 0) := (others => '0');
	
	component write_back
		PORT (
			clock : in std_logic;
			reset : in std_logic;
			
			IR_reg : in std_logic_vector(31 downto 0);		--instruction following thru from IF and out of MEM/WB register
			LMD : in std_logic_vector(7 downto 0);			-- Load Memory Data	
			ALUOutput : in std_logic_vector(15 downto 0);	-- ALU Output
			
			IR_dest_reg : out std_logic_vector(4 downto 0);
			WB_output : out std_logic_vector(15 downto 0)
		);
	end component;

BEGIN
	
	dut : write_back
	port map (
			clock,
			s_reset,
			s_IR_reg,
			s_LMD,
			s_ALUOutput,
			s_IR_dest_reg,
			s_WB_output
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
	
		REPORT "-------SIMULATION START-------";
		
		wait for clock_period/2;
		
		--------Start of Test---------
		
		--addi (Testing immediate operation)
		
		s_IR_reg <= "00100000000010110000011111010000"; --addi $10,  $0, 4
		s_LMD <= "11110000";
		s_ALUOutput <= "0000111100001111";
		
		REPORT "Values are set";
		
		wait for clock_period;
		--wait for clock_period/4;
		
		ASSERT(s_WB_output = "0000111100001111") REPORT "NOT Taking ALUOutput" SEVERITY ERROR;
		
		ASSERT(s_IR_dest_reg = "01011") REPORT "NOT Taking rt register for destination" SEVERITY ERROR;
		
		
		

		--add (Testing regular add operation)
		
		--lw (Testing load operation)
		
		------------------------
		
		
		REPORT "Simulation Done";
		wait;            
		--------END of Test---------                                   
	end process generate_test;  
END;