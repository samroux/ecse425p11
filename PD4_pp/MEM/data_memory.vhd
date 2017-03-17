-- @filename:	data_memory.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Data memory in the MEM stage of the pipeline. Used when a 
--              load/store instruction has been through the ALU and the 
--              EX stage.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity DATA_MEMORY is
generic(
		mem_size : integer := 8192;
		mem_delay : time := 1 ns;
		clock_period : time := 1 ns
	);
port (
	clock : in std_logic;
	ALUOutput : in std_logic_vector(31 downto 0);
	B_i: in std_logic_vector(31 downto 0);
	MemRead : in std_logic;		-- comes from ALU control unit
	MemWrite : in std_logic;	-- same as above
	IR_i : in std_logic_vector(31 downto 0);
	write_to_file : in std_logic;

	LMD : out std_logic_vector(31 downto 0);
	IR_o : out std_logic_vector(31 downto 0);
	B_o: out std_logic_vector(31 downto 0)
	);
end DATA_MEMORY;

architecture behavior of DATA_MEMORY is

	-- size needs to be 32768 bytes (spec): 8192*32/8 = 32768 bytes
	-- equivalent to 8192 registers, whereas CPU has 32 registers.
	type DATA_MEM is array(mem_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal data_mem_inst : DATA_MEM := ((others => (others => '0')));
	file data_file : text;

	begin

	-- TODO:	where does memdelay come in?
	--			should this be edge triggered?
	process(clock)
	begin
		if (MemWrite = '0') and (MemRead = '1') then
			-- ALUOutput is a 32-bit vector, so it has a range of 2^32 - 1
			-- Memory only has a range of 8192 = 2^13, so we take as address
			-- the bottom 13 bits of the ALUOutput.
			
			-- TODO: Ensure that the other bits returned by the EX stage
			--		 are not significant (i.e. sign/zero extended)	 
			LMD <= data_mem_inst(to_integer(unsigned(ALUOutput(12 downto 0))));
		elsif (MemWrite = '1') and (MemRead = '0') then
			data_mem_inst(to_integer(unsigned(ALUOutput(12 downto 0)))) <= B_i;
            LMD <= (others => '0');
       	else
       		LMD <= (others => '0');
		end if;

		-- delay signals by one clock cycle
		if (rising_edge(clock)) then
			B_o <= B_i;
			IR_o <= IR_i;
		end if;
	end process;

	final_write : process(write_to_file)
	variable memory_address : integer := 0;
	variable line_to_write : line;
	variable bit_vector : bit_vector(0 to 31);
	begin
		if(write_to_file = '1') then
			file_open(data_file, "memory.txt", write_mode);
			while (memory_address /= mem_size) loop
				write(line_to_write, data_mem_inst(memory_address), right, 32);
				writeline(data_file, line_to_write);
				memory_address := memory_address + 1;
			end loop;
		end if;
	end process final_write;

end behavior;
