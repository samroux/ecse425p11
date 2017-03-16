-- @filename instruction_memory.vhd

-- @author Samuel Roux and Po-Shiang - Adapted from memory.vdh provided for PD3

-- @timestamp 2017-03-08

-- @brief vhdl entity defining the instruction memory register and function to fill it



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

		reset: IN STD_LOGIC;

		address: in std_logic_vector(1023 downto 0);

		instruction: out std_logic_vector(31 downto 0)

	);

END instruction_memory;



ARCHITECTURE behaviour OF instruction_memory IS

	-- Memory is a two dimensional array of size 4096 * 8 bits, and each memory

	-- address points to a single byte. Need to read the 32-bit instruction in

	-- four parts to store it into 4 successive bytes. Despite this, a 32-bit

	-- vector should be fed to the IF/ID register for decoding.

	-- Memory can store 4096/4 = 1024 instructions.

	-- The PC will keep track of inst locations by increasing by 4.

	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL ram_block: MEM;

	

		

BEGIN



	read_file:	process (reset)

		--fucntion strongly inspired from : http://www.ics.uci.edu/~jmoorkan/vhdlref/filedec.html

		variable VEC_LINE : line;

		variable VEC_VAR : bit_vector(0 to 31);

		variable mem_address: integer := 0;

		file VEC_FILE : text is in "C:\Users\Sam\Documents\_ecse425\ecse425p11\PD4_pp\Assembler\program.txt"; -- Path of any output of assembler. (Correct relative path in actual config)



		begin

			if reset = '1' then

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

					--wait for 10 ns; Probably need a way to wait in process...?

				end loop;

			end if;

	end process read_file;



	process(clock, address)

		begin

		--Goal of this process is to output instruction from address

			if (rising_edge(clock)) then

				instruction(31 downto 24) <= ram_block(to_integer(unsigned(address)));

				instruction(23 downto 16) <= ram_block(to_integer(unsigned(address)) + 1);

				instruction(15 downto 8) <= ram_block(to_integer(unsigned(address)) + 2);

				instruction(7 downto 0) <= ram_block(to_integer(unsigned(address)) + 3);

			end if;

	end process;



END behaviour;