
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

	-- read_file:	process (s_reset)
		
		-- variable VEC_LINE : line;
		-- variable VEC_VAR : bit_vector(0 to 31);
		-- variable reg_address: integer := 0;
		-- file VEC_FILE : text is in "register_file.txt"; -- Path of register. 

		-- begin
			-- if s_reset = '1' then
				-- while not endfile(VEC_FILE) loop
					-- readline (VEC_FILE, VEC_LINE);
					-- read (VEC_LINE, VEC_VAR);
					-- reg_block(reg_address) <= to_stdlogicvector(VEC_VAR(0 to 31));
					 -- reg_address := reg_address + 1;
					 
					-- --wait for 10 ns; Probably need a way to wait in process...?
				-- end loop;
			-- end if;
	-- end process read_file;

	
	generate_test : process
		
	begin
		--s_reset <= '0'; 
        --wait for clock_period;
        
        s_reset <= '1';     
        wait for clock_period;
        
        s_reset <= '0';    
        wait for clock_period;
        
        REPORT "System has been reset";
        wait for 10 * clock_period;
        wait;
		
		--------Start of Test---------
		
		--------Read File in order--------





		-- assert (reg_block(0) = "00000000000000000000000000000110") report"add failed" severity ERROR;

		-- assert (reg_block(1) = "00000000000000000000000000000010") report"sub failed" severity ERROR;

		-- assert (reg_block(2) = "00000000000000000000000000000011") report"addi failed" severity ERROR;

		-- assert (reg_block(3) = "00000000000000000000000000000100") report"mult failed" severity ERROR;

		-- assert (reg_block(4) = "00000000000000000000000000000101") report"div failed" severity ERROR;

		-- assert (reg_block(5) = "00000000000000000000000000000001") report"slt failed" severity ERROR;

		-- assert (reg_block(6) = "00000000000000000000000000000001") report"slti failed" severity ERROR;

		-- assert (reg_block(7) = "00000000000000000000000000000010") report"and failed" severity ERROR;

		-- assert (reg_block(8) = "00000000000000000000000000000110") report"or failed" severity ERROR;

		-- assert (reg_block(9) = "11111111111111111111111111111111") report"nor failed" severity ERROR;

		-- assert (reg_block(10) = "00000000000000000000000000000100") report"xor failed" severity ERROR; 

		-- assert (reg_block(11) = "00000000000000000000000000000001") report"andi failed" severity ERROR;

		-- assert (reg_block(12) = "00000000000000000000000000000111") report"ori failed" severity ERROR;

		-- assert (reg_block(13) = "00000000000000000000000000000011") report"xori failed" severity ERROR;

		-- assert (reg_block(14) = "00000000000000000000000000000001") report"mfhi failed" severity ERROR;

		-- assert (reg_block(15) = "00000000000000000000000000000001") report"mflo failed" severity ERROR;

		-- assert (reg_block(16) = "00010000000000010000000000000000") report"lui failed" severity ERROR;

		-- assert (reg_block(17) = "00000000000000000000000011010100") report"sll failed" severity ERROR;

		-- assert (reg_block(18) = "00000000000000000000000000001101") report"srl failed" severity ERROR;

		-- assert (reg_block(19) = "00000000000000000000000000001101") report"sra failed" severity ERROR;


		
		------------------------
		
		--------END of Test---------                                   
	end process generate_test;

	

  
END behaviour;