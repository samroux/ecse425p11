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
	reg_address_A : in std_logic_vector(4 downto 0); -- 32 = 2^5 addressing bits
	reg_address_B : in std_logic_vector(4 downto 0);
	reg_write_input : in std_logic_vector(31 downto 0);
	reg_write_addr : in std_logic_vector(4 downto 0);
	MemWrite : in std_logic;
	MemRead : in std_logic;
	reg_output_A : out std_logic_vector(31 downto 0);
	reg_output_B : out std_logic_vector(31 downto 0)
	);
end REGISTER_FILE;

architecture behavior of REGISTER_FILE is

	type REGISTERS is array(number_of_registers-1 downto 0) of std_logic_vector(31 downto 0);
	signal registers_inst : REGISTERS := ((others => (others => '0')));

	begin

	-- need to ensure that writes are done on rising edge, and
	-- reads are done on falling edge, to allow for ID/WB overlap
	process(clock)
	variable addr_int_A : integer;
	variable addr_int_B : integer;
	variable addr_int_w : integer;
	begin
		addr_int_A := to_integer(unsigned(reg_address_A));
		addr_int_B := to_integer(unsigned(reg_address_B));
		addr_int_w := to_integer(unsigned(reg_write_addr));

		-- may read an unneeded register
		if (MemRead = '1') then
			reg_output_A <= registers_inst(addr_int_A);	
			reg_output_B <= registers_inst(addr_int_B); 

		-- only need a single input, other one can be gibberish
		elsif (MemWrite = '1') then
			if (addr_int_w /= 0) then -- $0 hardwired to 0
				registers_inst(addr_int_w) <= reg_write_input;
			end if;
			reg_output_A <= (others => '0');
			reg_output_B <= (others => '0');
		else
			reg_output_A <= (others => '0');
			reg_output_B <= (others => '0');
		end if;
	end process;

end behavior;