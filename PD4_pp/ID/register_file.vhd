-- @filename:	register_file.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Register file of the CPU. Contains 32 non-persistent registers
--				that can be addressed directly by instructions, using $0 to $31.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGISTER_FILE is

generic(
	number_of_registers : integer := 32
	);
port (
	clock : in std_logic;
	reg_address : in std_logic_vector(4 downto 0); -- 32 = 2^5 addressing bits
	reg_write_input : in std_logic_vector(31 downto 0);
	MemWrite : in std_logic;
	MemRead : in std_logic;
	reg_output : out std_logic_vector(31 downto 0)
	);
end REGISTER_FILE;

architecture behavior of REGISTER_FILE is

	type REGISTERS is array(number_of_registers-1 downto 0) of std_logic_vector(31 downto 0);
	signal registers_inst : REGISTERS := ((others => (others => '0')));

	begin

	-- need to ensure that writes are done on rising edge, and
	-- reads are done on falling edge, to allow for ID/WB overlap
	process(clock)
	variable addr_int : integer;
	begin
		addr_int := to_integer(unsigned(reg_address));

		if falling_edge(clock) then		-- 1st half of cycle: read
			if (MemWrite = '0') and (MemRead = '1') then
				if (addr_int /= 0) then 
					reg_output <= registers_inst(addr_int);
				else reg_output <= (31=>'1', others => '0'); -- $0 hardwired to 0
				end if;
			else reg_output <= (30=>'1', others => '0');
			end if;
		elsif rising_edge(clock) then	-- 2nd half of cycle: write
			if (MemWrite = '1') and (MemRead = '0') then
				if (addr_int /= 0) then 
					registers_inst(addr_int) <= reg_write_input;
				end if;
				reg_output <= (29=>'1', others => '0');
			else reg_output <= (28=>'1', others => '0');
			end if;
		end if;
	end process;

end behavior;