library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port(
	ALU_operation: in std_logic_vector(3 downto 0);
	func: in std_logic_vector(5 downto 0);
	read_data_1: in std_logic_vector(31 downto 0);
	read_data_2: in std_logic_vector(31 downto 0);
	ALU_result: out std_logic_vector(31 downto 0) := (others => '0');
	zero: out std_logic := '0'
  );
end alu;

architecture arch of alu is

signal Hi: std_logic_vector(31 downto 0);
signal Lo: std_logic_vector(31 downto 0);

begin

alu: process(ALU_operation, func, read_data_1, read_data_2)

	variable HiLo: std_logic_vector(63 downto 0);
	variable div_a : integer;
	variable div_b : integer;
	variable div_temp : integer;

begin
		case(ALU_operation) is
			when "0010" => --add
				ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));
				if func = "010000" then --mfhi
					ALU_result <= Hi;
				end if;
			when "0110" => --substract
				ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) - to_integer(signed(read_data_2)), 32));
				if unsigned(ALU_result) = to_unsigned(0, 32) then --branch
					zero <= '1';
				end if;
				if func = "010010" then --mflo
					ALU_result <= Lo;
				end if
			when "0000" => --AND
				ALU_result <= read_data_1 and read_data_2;
			when "0001" => --OR
				ALU_result <= read_data_1 or read_data_2;
			when "0111" => --set on less than
				if func = "011010" then --div
					Lo <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) / to_integer(signed(read_data_2)), 32));
					Hi <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) rem to_integer(signed(read_data_2)), 32));
				elsif to_integer(signed(read_data_1)) < to_integer(signed(read_data_2)) then
					ALU_result <= std_logic_vector(to_unsigned(1, 32));
				else
					ALU_result <= std_logic_vector(to_unsigned(0, 32));
				end if;
			when "0011" =>	--NOR
				ALU_result <= read_data_1 nor read_data_2;
			when "0100" => --XOR
				ALU_result <= read_data_1 xor read_data_2;
			when "0101" => --mult
				HiLo <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) * to_integer(signed(read_data_2)), 64));
				Hi <= HiLo(63 downto 32);
				Lo <= HiLo(31 downto 0);
		end case;
end process;

end arch;