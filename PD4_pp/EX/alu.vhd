library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port(
	ALU_operation: in std_logic_vector(3 downto 0);
	func: in std_logic_vector(5 downto 0);
	read_data_1: in std_logic_vector(31 downto 0);
	read_data_2: in std_logic_vector(31 downto 0);
	ALU_result: out std_logic_vector(31 downto 0) := x"00000000"
	zero: out std_logic := '0'
	shamt : in std_logic_vector(4 downto 0);
  );
end alu;

architecture arch of alu is

signal Hi: std_logic_vector(31 downto 0);
signal Lo: std_logic_vector(31 downto 0);

begin

alu: process(ALU_operation, funct, read_data_1, read_data_2)

	variable HiLo: std_logic_vector(63 downto 0);
	variable div_a : integer;
	variable div_b : integer;
	variable div_temp : integer;
	variable mult_temp : integer;

begin
		case( ALU_operation ) is

			when "000000" =>

				case( func ) is
					
					when "100000" => --add 0/20hex

						ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));
						
					when "100010" => --sub 0/22hex

						ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) - to_integer(signed(read_data_2)), 32));
						
					when "101010" => --slt 0/2a hex

						if to_integer(signed(read_data_1)) < to_integer(signed(read_data_2)) then

							ALU_result <= x"00000001";

						else

							ALU_result <= x"00000000";

						end if ;
						
					when "100100" => --and 0/24hex

						ALU_result <= read_data_1 and read_data_2;
						
					when "100101" => --or 0/25hex

						ALU_result <= read_data_1 or read_data_2;
						
					when "100111" => --nor 0/27hex

						ALU_result <= read_data_1 nor read_data_2;
					
					

					when "000000" => --sll 0/00hex

						ALU_result <= std_logic_vector(shift_left(unsigned(read_data_2), to_integer(unsigned(shamt))));

					when "000010" => --srl 0/02hex

						ALU_result <= std_logic_vector(shift_right(unsigned(read_data_2), to_integer(unsigned(shamt))));

					when "001000" => --jr 0/08hex

						-- PC = rs thus no operation

					when "010000" => --mfhi 0x10 associate with mult

						ALU_result <= Hi;

					when "010010" => --mflo 0x12

						ALU_result <= Lo;

					when "011000" => --mult 0x18

						mult_temp := std_logic_vector(to_signed(to_integer(signed(read_data_1)) * to_integer(signed(read_data_2)), 64));

						Hi <= mult_temp(63 downto 32);

						Lo <= mult_temp(31 downto 0);

					when "011010" => --div 0/1a hex

						div_a := to_integer(signed(read_data_1));

						div_b := to_integer(signed(read_data_2));

						if div_b /= 0 then

							div_temp := div_a / div_b;

							Lo <= std_logic_vector(to_signed(div_temp, 32));

							Hi <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) rem to_integer(signed(read_data_2)), 32));

						end if;

					

					

					

					

					--xor missing from MIPS green sheet

						--ALU_result <= read_data_1 xor read_data_2;

					

					

					when others =>

						ALU_result <= (others => 'X');

				end case;	

				

			when "001000" => --addi 08hex

				ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));

			when "001100" => --andi c hex

				ALU_result <= read_data_1 and read_data_2;

			when "001101" => --ori d hex

				ALU_result <= read_data_1 or read_data_2;

			when "001110" => --xori e hex

				ALU_result <= read_data_1 xor read_data_2;

			when "001010" => --slti a hex

				if to_integer(signed(read_data_1)) < to_integer(signed(read_data_2)) then

					ALU_result <= x"00000001";

				else

					ALU_result <= x"00000000";

				end if ;

            when "100000" => -- load byte

                ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));

            when "100011" => -- load word

                ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));

            when "101000" => -- store byte

                ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));

            when "101011" => -- store word

                ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));

            when "001111" => -- lui

                ALU_result <= read_data_2; 

           

            when "100100" => -- halt

                ALU_result <= (others => '0');

            when others => -- should not happen

                ALU_result <= (others => '0');

		end case ;
end process;

end arch;