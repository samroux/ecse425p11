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
	signal ALUOutput : std_logic_vector(15 downto 0);
	signal B: std_logic_vector(7 downto 0);
	signal MemRead : std_logic;
	signal MemWrite : std_logic;

	signal LMD : std_logic_vector(7 downto 0);

	constant clock_period : time := 1 ns;

	-- component to be tested
	component data_memory
		port (
			clock : in std_logic;
			ALUOutput : in std_logic_vector(15 downto 0);
			B: in std_logic_vector(7 downto 0);
			MemRead : in std_logic;
			MemWrite : in std_logic;

			LMD : out std_logic_vector(7 downto 0)
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
			-- read/write process is entered only when ALUOutput changes
			B <= "01010101"; -- test rt register
			ALUOutput <= "1100110011001100";

			report "Initial state; no read/write";
			MemRead <= '0';
			MemWrite <= '0';
			wait for clock_period;
			assert (LMD = "00000000") severity ERROR;
			report "______";

			report "Writing to address 1100110011001100";
			MemWrite <= '1';
			wait for clock_period;
			assert (LMD = "00000000") severity ERROR;
			report "______";

			report "Reading from address 1100110011001100";
			MemWrite <= '0';
			MemRead <= '1';
			wait for clock_period;
			assert (LMD = "01010101") severity ERROR;
			report "______";

			report "Moving back to no read/write";
			MemRead <= '0';
			wait for clock_period;
			assert (LMD = "00000000") severity ERROR;
			report "______";
		wait;                                                        
	end process generate_test;                                     
end data_memory_arch;