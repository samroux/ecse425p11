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
	signal PC_in : std_logic_vector(11 downto 0);
	signal ALUOutput : std_logic_vector(31 downto 0);
	signal B_in: std_logic_vector(31 downto 0);
	signal MemRead : std_logic;
	signal MemWrite : std_logic;
	signal IR_in : std_logic_vector(31 downto 0);
	signal write_to_file : std_logic;
	signal branch_taken_in : std_logic;

	signal LMD : std_logic_vector(31 downto 0);
	signal PC_out : std_logic_vector(11 downto 0);
	signal IR_out : std_logic_vector(31 downto 0);
	signal B_out: std_logic_vector(31 downto 0);
	signal branch_taken_out : std_logic;

	constant clock_period : time := 1 ns;

	-- component to be tested
	component data_memory
		port (
			clock : in std_logic;
			PC_in : in std_logic_vector(11 downto 0);
			ALUOutput : in std_logic_vector(31 downto 0);
			B_in: in std_logic_vector(31 downto 0);
			MemRead : in std_logic;
			MemWrite : in std_logic;
			IR_in : in std_logic_vector(31 downto 0);
			write_to_file : in std_logic;
			branch_taken_in : in std_logic;

			LMD : out std_logic_vector(31 downto 0);
			PC_out : out std_logic_vector(11 downto 0);
			IR_out : out std_logic_vector(31 downto 0);
			B_out: out std_logic_vector(31 downto 0);
			branch_taken_out : out std_logic
		);
	end component;

	begin
		-- map test signals to component in/out
		dm : data_memory
		port map (
			clock => clock,
			PC_in => PC_in,
			ALUOutput => ALUOutput,
			B_in => B_in,
			MemRead => MemRead,
			MemWrite => MemWrite,
			IR_in => IR_in,
			write_to_file => write_to_file,
			branch_taken_in => branch_taken_in,

			LMD => LMD,
			PC_out => PC_out,
			IR_out => IR_out,
			B_out => B_out,
			branch_taken_out => branch_taken_out
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
			write_to_file <= '0';
			branch_taken_in <= '0';
			IR_in <= "00000000000000000000000000000000"; 
			PC_in <= "000000000100"; -- artificial constant PC of 4
			B_in <= "00000000000000000000000000001111"; -- rt register used for testing
			ALUOutput <= "00000000000000000000000000001000"; -- address used for testing

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
			assert (LMD = "00000000000000000000000000001111") severity ERROR;
			report "______";

			report "Moving back to no read/write";
			MemRead <= '0';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;
			report "______";

			report "Writing 1001 to a new address 1000";
			B_in <= "00000000000000000000000000001001";
			ALUOutput <= "00000000000000000000000000000001";
			MemWrite <= '1';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;

			report "Test persistency; read both written addresses successively";
			ALUOutput <= "00000000000000000000000000001000";
			MemWrite <= '0';
			MemRead <= '1';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000001111") severity ERROR;
			
			ALUOutput <= "00000000000000000000000000000001";
			wait for clock_period;
			assert (LMD = "00000000000000000000000000001001") severity ERROR;
			report "______";

			report "Test simultaneous read/write";
			MemRead <= '1';
			MemWrite <= '1';
			wait for clock_period;
			assert (LMD = "00000000000000000000000000000000") severity ERROR;

			report "Test whether PC is updated properly after branch";
			branch_taken_in <= '1';
			ALUOutput <= "00000000000000000000100000011000"; -- jump to PC = 2072
			MemRead <= '0';
			MemWrite <= '0';
			wait for clock_period;
			assert (PC_out = "100000011000") report "Did not branch properly" severity ERROR;
			assert (branch_taken_out = '1') severity ERROR;

			wait for clock_period;
			write_to_file <= '1';
		wait;                                                        
	end process generate_test;                                     
end data_memory_arch;
