-- @filename:	data_memory.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Data memory in the MEM stage of the pipeline. Used when a 
--              load/store instruction has been through the ALU and the 
--              EX stage.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATA_MEMORY is
generic(
		mem_size : integer := 8192;
		mem_delay : time := 1 ns;
		clock_period : time := 1 ns
	);
port (
	clock : in std_logic;
	ALUOutput : in std_logic_vector(31 downto 0);
	B: in std_logic_vector(31 downto 0);
	MemRead : in std_logic;		-- comes from ALU control unit
	MemWrite : in std_logic;	-- same as above

	LMD : out std_logic_vector(31 downto 0)
	);
end DATA_MEMORY;

architecture behavior of DATA_MEMORY is

	-- size needs to be 32768 bytes (spec): 8192*32/8 = 32768 bytes
	-- equivalent to 8192 registers, whereas CPU has 32 registers.
	type DATA_MEM is array(mem_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal data_mem_inst : DATA_MEM := ((others => (others => '0')));

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
			data_mem_inst(to_integer(unsigned(ALUOutput(12 downto 0)))) <= B;
            LMD <= (others => '0');
       	else
       		LMD <= (others => '0');
		end if;
	end process;

end behavior;
