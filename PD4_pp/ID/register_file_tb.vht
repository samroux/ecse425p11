-- @filename:	register_file_tb.vht
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Test bench for the register file in the ID stage.

library ieee;                                               
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;                               

entity register_file_tb is
end register_file_tb;

architecture register_file_arch of register_file_tb is
           
    -- test signals                                     
	signal clock : std_logic;
	signal reg_address : std_logic_vector(4 downto 0);
	signal reg_write_input : std_logic_vector(31 downto 0);
	signal MemWrite : std_logic;
	signal MemRead : std_logic;
	signal reg_output : std_logic_vector(31 downto 0);

	constant clock_period : time := 1 ns;

	-- component to be tested
	component register_file
		port (
			clock : in std_logic;
			reg_address : in std_logic_vector(4 downto 0);
			reg_write_input : in std_logic_vector(31 downto 0);
			MemWrite : in std_logic;
			MemRead : in std_logic;
			reg_output : out std_logic_vector(31 downto 0)
		);
	end component;

	begin
		-- map test signals to component in/out
		i : register_file
		port map (
			clock => clock,
			reg_address => reg_address,
			reg_write_input => reg_write_input,
			MemWrite => MemWrite,
			MemRead => MemRead,
			reg_output => reg_output
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
			reg_write_input <= "01010101000000000000000000000000";
			reg_address <= "00001";

			report "Initial state; no read/write";
			MemRead <= '0';
			MemWrite <= '0';
			wait for clock_period;
			assert (reg_output = "00000000000000000000000000000000") severity ERROR;
			report "______";

			report "Writing to register $1";
			MemWrite <= '1';
			wait for clock_period;
			assert (reg_output = "00000000000000000000000000000000") severity ERROR;
			report "______";

			report "Reading from address $1";
			MemWrite <= '0';
			MemRead <= '1';
			wait for clock_period/2;
			assert (reg_output = "01010101000000000000000000000000") severity ERROR;
			report "______";
			wait for clock_period/2;

			report "Moving back to no read/write";
			MemRead <= '0';
			wait for clock_period;
			assert (reg_output = "00000000000000000000000000000000") severity ERROR;
			report "______";

			report "Writing to a new register $2";
			reg_write_input <= "10000001000000000000000000000000";
			reg_address <= "00010";
			MemWrite <= '1';
			wait for clock_period;
			assert (reg_output = "00000000000000000000000000000000") severity ERROR;

			report "Test persistency; read both written registers successively";
			reg_address <= "00001";
			MemWrite <= '0';
			MemRead <= '1';
			wait for clock_period/2;
			assert (reg_output = "01010101000000000000000000000000") severity ERROR;
			wait for clock_period/2;
			
			reg_address <= "00010";
			wait for clock_period/2;
			assert (reg_output = "10000001000000000000000000000000") severity ERROR;
			wait for clock_period/2;
			report "______";

			report "Test simultaneous read/write on half cycle";
			MemRead <= '1';
			MemWrite <= '0';
			wait for clock_period/2;
			assert (reg_output = "10000001000000000000000000000000") severity ERROR;
			reg_address <= "00001";
			reg_write_input <= "10000000000000000000000000000000";
			MemRead <= '0';
			MemWrite <= '1';
			wait for clock_period/2;
			assert (reg_output = "00000000000000000000000000000000") severity ERROR;
			MemRead <= '1';
			MemWrite <= '0';
			wait for clock_period/2;
			assert (reg_output = "10000000000000000000000000000000") severity ERROR;
			
			wait for clock_period/2;
			wait for clock_period;

			report "Test read/writing from $0 register";
			reg_address <= "00000";
			reg_write_input <= "10101010000000000000000000000000";
			MemRead <= '0';
			MemWrite <= '1';
			wait for clock_period;
			assert (reg_output = "00000000000000000000000000000000") severity ERROR;
			MemRead <= '1';
			MemWrite <= '0';
			wait for clock_period;
			assert (reg_output = "00000000000000000000000000000000") severity ERROR;

		wait;                                                        
	end process generate_test;                                     
end register_file_arch;