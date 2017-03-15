-- @filename:	data_memory_tb.vht
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Test bench for the data memory in the MEM stage.

library ieee;                                               
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;                               

entity data_memory_tb is
end data_memory_tb;

-- need to ensure that the register is properly edge-triggered

architecture data_memory_arch of data_memory_tb is
           
    -- test signals                                     
	signal clock : std_logic;
	signal ALUOutput : std_logic_vector(31 downto 0);
	signal B: std_logic_vector(31 downto 0);
	signal MemRead : std_logic;
	signal MemWrite : std_logic;

	signal LMD : std_logic_vector(31 downto 0);

	constant clock_period : time := 1 ns;

	-- component to be tested
	component data_memory
		port (
			clock : in std_logic;
			ALUOutput : in std_logic_vector(31 downto 0);
			B: in std_logic_vector(31 downto 0);
			MemRead : in std_logic;
			MemWrite : in std_logic;

			LMD : out std_logic_vector(31 downto 0)
		);
	end component;

	begin
		-- map test signals to component in/out
		i : data_memory
		port map (
			clock => clock,
			ALUOutput => ALUOutput,
			B => B,
			MemRead => MemRead,
			MemWrite => MemWrite,
			LMD => LMD
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
			B <= (31=>'1', 30=>'1', 29=>'1', 28=>'1', others=>'0'); -- rt register used for testing
			ALUOutput <= (31=>'0', 30=>'0', 29=>'0', 28=>'1', others=>'0'); -- address used for testing

			report "Initial state; no read/write";
			MemRead <= '0';
			MemWrite <= '0';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;
			report "______";

			report "Writing 1111 to address 0001";
			MemWrite <= '1';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;
			report "______";

			report "Reading from address 0001";
			MemWrite <= '0';
			MemRead <= '1';
			wait for clock_period;
			assert (LMD = "11110000000000000000000000000000") severity ERROR;
			report "______";

			report "Moving back to no read/write";
			MemRead <= '0';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;
			report "______";

			report "Writing 1001 to a new address 1000";
			B <= (31=>'1', 30=>'0', 29=>'0', 28=>'1', others=>'0');
			ALUOutput <= (31=>'1', 30=>'0', 29=>'0', 28=>'0', others=>'0');
			MemWrite <= '1';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;

			report "Test persistency; read both written addresses successively";
			ALUOutput <= (31=>'0', 30=>'0', 29=>'0', 28=>'1', others=>'0');
			MemWrite <= '0';
			MemRead <= '1';
			wait for clock_period;
			assert (LMD = "11110000000000000000000000000000") severity ERROR;
			
			ALUOutput <= (31=>'1', 30=>'0', 29=>'0', 28=>'0', others=>'0');
			wait for clock_period;
			assert (LMD = "10010000000000000000000000000000") severity ERROR;
			report "______";

			report "Test simultaneous read/write";
			MemRead <= '1';
			MemWrite <= '1';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;

		wait;                                                        
	end process generate_test;                                     
end data_memory_arch;
