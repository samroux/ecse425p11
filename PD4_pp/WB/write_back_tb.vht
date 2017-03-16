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
    constant clock_period : time := 1 ns;
	
	signal s_IR_reg : std_logic_vector(31 downto 0) := (others => '0');
	signal s_LMD : std_logic_vector(31 downto 0) := (others => '0');
	signal s_ALUOutput : std_logic_vector(31 downto 0) := (others => '0');
	
	signal s_IR_dest_reg : std_logic_vector(4 downto 0) := (others => '0');
	signal s_WB_output : std_logic_vector(31 downto 0) := (others => '0');
	
	component write_back
		PORT (
			clock : in std_logic;
			
			IR_reg : in std_logic_vector(31 downto 0);		--instruction following thru from IF and out of MEM/WB register
			LMD : in std_logic_vector(31 downto 0);			-- Load Memory Data	
			ALUOutput : in std_logic_vector(31 downto 0);	-- ALU Output
			
			IR_dest_reg : out std_logic_vector(4 downto 0);
			WB_output : out std_logic_vector(31 downto 0)
		);
	end component;

BEGIN
	
	dut : write_back
	port map (
			clock,
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
		
		s_IR_reg <= "00100000000010110000011111010000"; --addi $10,  $0, 4 (001000 00000 01011 0000011111010000)
		s_LMD <= "11111111111111111111111111111111";
		s_ALUOutput <= "00000000000000000000000000000000";
		
		wait for clock_period;
		wait for clock_period/10;
		
		ASSERT(s_WB_output = "00000000000000000000000000000000") REPORT "NOT Taking ALUOutput" SEVERITY ERROR;
		
		ASSERT(s_IR_dest_reg = "01011") REPORT "NOT Taking rt register for destination" SEVERITY ERROR;
		
		
		wait for 9*clock_period/10;
		-------------------------------------------------------------
		--add (Testing regular add operation)
		
		s_IR_reg <= "00000001011011000001000000100000"; --add     $2,  $11, $12 (000000 01011 01100 00010 00000100000)
		s_LMD <= "11111111111111111111111111111111";
		s_ALUOutput <= "00000000000000000000000000000000";
		
		wait for clock_period;
		wait for clock_period/10;
		
		ASSERT(s_WB_output = "00000000000000000000000000000000") REPORT "NOT Taking ALUOutput" SEVERITY ERROR;
		
		ASSERT(s_IR_dest_reg = "00010") REPORT "NOT Taking rd register for destination" SEVERITY ERROR;
		
		wait for 9*clock_period/10;
		
		-------------------------------------------------------------
		--lw (Testing load operation)
		
		s_IR_reg <= "10001100010000110000000000000000"; --lw $3,  0($2) (100011 00010 00011 0000000000000000)
		s_LMD <= "11111111111111111111111111111111";
		s_ALUOutput <= "00000000000000000000000000000000";
		
		wait for clock_period;
		wait for clock_period/10;
		
		ASSERT(s_WB_output = "11111111111111111111111111111111") REPORT "NOT Taking LMD" SEVERITY ERROR;
		
		ASSERT(s_IR_dest_reg = "00011") REPORT "NOT Taking rt register for destination" SEVERITY ERROR;
		
		wait for 9*clock_period/10;	
		
		------------------------
		
		
		REPORT "Simulation Done";
		wait;            
		--------END of Test---------                                   
	end process generate_test;  
END;