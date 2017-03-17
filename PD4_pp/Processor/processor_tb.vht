
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use STD.textio.all;

ENTITY processor_tb IS
END processor_tb;

architecture behaviour of processor_tb is


    --all the input signals with initial values
	signal clock : std_logic;
	signal s_reset : std_logic;
	constant clock_period : time := 1 ns;
	TYPE REG IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL reg_block: REG;
		
	component processor
		PORT (
			clock : in std_logic;
			reset : in std_logic
			
		);
	
	end component;

	BEGIN
	
	dut : processor
	port map (
		clock => clock,
		reset => s_reset
			
	);


-- continuous clock process
	clock_process : process
	begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	end process clock_process;

	read_file:	process (s_reset)
		
		variable VEC_LINE : line;
		variable VEC_VAR : bit_vector(0 to 31);
		variable reg_address: integer := 0;
		file VEC_FILE : text is in "C:\Users\zhouy\Documents\GitHub\ecse425p11\PD4_pp\ID\register_file.txt"; -- Path of register. 

		begin
			if s_reset = '1' then
				while not endfile(VEC_FILE) loop
					readline (VEC_FILE, VEC_LINE);
					read (VEC_LINE, VEC_VAR);
					reg_block(reg_address) <= to_stdlogicvector(VEC_VAR(0 to 31));
					 reg_address := reg_address + 1;
					 
					--wait for 10 ns; Probably need a way to wait in process...?
				end loop;
			end if;
	end process read_file;

	
	generate_test : process
		
	begin
	
		REPORT "-------SIMULATION START-------";
		
		s_reset <= '1';
		
		wait for clock_period/2;
		
		s_reset <= '0';
		
		REPORT "System has been resetted";
		
		--------Start of Test---------
		
		--------Read File in order--------





		assert (reg_block(0) = "00000000000000000000000000000001") severity ERROR; 

		
		------------------------
		
		--------END of Test---------                                   
	end process generate_test;

	

  
END behaviour;