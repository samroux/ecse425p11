--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use STD.textio.all;

ENTITY instruction_memory IS
	GENERIC(
		ram_size : INTEGER := 4096;--1024 instructions
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		address: in std_logic_vector(31 downto 0);
		instruction: out std_logic_vector(31 downto 0)
	);
END instruction_memory;

ARCHITECTURE rtl OF instruction_memory IS
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ram_block: MEM;
BEGIN

READ_FILE: process(clock)
  variable VEC_LINE : line;
  variable VEC_VAR : bit_vector(0 to 31);
  variable mem_address: integer := 0;
  file VEC_FILE : text is in "program.txt";
  
begin
  while not endfile(VEC_FILE) loop
    readline (VEC_FILE, VEC_LINE);
    read (VEC_LINE, VEC_VAR);
    ram_block(mem_address) <= to_stdlogicvector(VEC_VAR(0 to 7));
	 mem_address := mem_address + 1;
	 ram_block(mem_address) <= to_stdlogicvector(VEC_VAR(8 to 15));
	 mem_address := mem_address + 1;
	 ram_block(mem_address) <= to_stdlogicvector(VEC_VAR(16 to 23));
	 mem_address := mem_address + 1;
	 ram_block(mem_address) <= to_stdlogicvector(VEC_VAR(24 to 31));
	 mem_address := mem_address + 1;
    wait for 10 ns;
  end loop;
  instruction(31 downto 24) <= ram_block(to_integer(unsigned(address)));
  instruction(23 downto 16) <= ram_block(to_integer(unsigned(address)) + 1);
  instruction(15 downto 8) <= ram_block(to_integer(unsigned(address)) + 2);
  instruction(7 downto 0) <= ram_block(to_integer(unsigned(address)) + 3);
  wait;
end process READ_FILE;

END rtl;
