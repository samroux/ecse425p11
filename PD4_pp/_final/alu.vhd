library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.MATH_REAL.ALL;

entity alu is
  port(
	ALU_operation: in std_logic_vector(3 downto 0);
	funct: in std_logic_vector(5 downto 0);
	shamt: in std_logic_vector(4 downto 0);
	imm: in std_logic_vector(31 downto 0);
	read_data_1: in std_logic_vector(31 downto 0);
	read_data_2: in std_logic_vector(31 downto 0);
	ALU_result: out std_logic_vector(31 downto 0) := (others => '0');
	zero: out std_logic := '0'
  );
end alu;

architecture arch of alu is

signal ALU_result_temp: std_logic_vector(31 downto 0);
signal Hi: std_logic_vector(31 downto 0);
signal Lo: std_logic_vector(31 downto 0);
--signal power: real := 0.0;

begin

alu: process(ALU_operation, funct, read_data_1, read_data_2)

	variable HiLo: std_logic_vector(63 downto 0);

begin
zero <= '0';
		case(ALU_operation) is
			when "0010" => --add
				if funct = "000000" then --sll
					ALU_result <= std_logic_vector(shift_left(unsigned(read_data_1), to_integer(unsigned(shamt))));
					--SHAMT signed or unsigned?
-- MAKE SURE read_data_1 is rt register
				elsif funct = "010000" then --mfhi
					ALU_result <= Hi;
				else
					ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(read_data_2)), 32));
				end if;
			when "1101" => --addi
				ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) + to_integer(signed(imm)), 32));
			when "0110" => --substract
				if funct ="000010" then --srl
					ALU_result <= std_logic_vector(to_signed(to_integer(unsigned(read_data_1)) / 2**to_integer(unsigned(shamt)), 32));
				elsif funct = "010010" then --mflo
					ALU_result <= Lo;
				else
					ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) - to_integer(signed(read_data_2)), 32));
					ALU_result_temp <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) - to_integer(signed(read_data_2)), 32));
				end if;

				if funct = "000100" then -- beq
					if read_data_1 = read_data_2 then zero <= '1';
					end if;
				elsif funct = "000101" then -- bne
					if read_data_1 /= read_data_2 then zero <= '1';
					end if;
				end if;
			when "0000" => --AND
				ALU_result <= read_data_1 and read_data_2;
			when "1000" => --ANDi
				ALU_result <= read_data_1 and imm;
			when "0001" => --OR
				ALU_result <= read_data_1 or read_data_2;
			when "1100" => --ORi
				ALU_result <= read_data_1 or imm;
			when "0111" => --set on less than
				if funct = "011010" then --div
					Lo <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) / to_integer(signed(read_data_2)), 32));
					Hi <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) rem to_integer(signed(read_data_2)), 32));
				elsif to_integer(signed(read_data_1)) < to_integer(signed(read_data_2)) then
					ALU_result <= std_logic_vector(to_unsigned(1, 32));
				else
					ALU_result <= std_logic_vector(to_unsigned(0, 32));
				end if;
			when "1110" => --slti
				if to_integer(signed(read_data_1)) < to_integer(signed(imm)) then
					ALU_result <= std_logic_vector(to_unsigned(1, 32));
				else
					ALU_result <= std_logic_vector(to_unsigned(0, 32));
				end if;
			when "0011" =>	--NOR
				ALU_result <= read_data_1 nor read_data_2;
			when "0100" => --XOR
				ALU_result <= read_data_1 xor read_data_2;
			when "1001" => --XORi
				ALU_result <= read_data_1 xor imm;
			when "0101" => --mult
				HiLo := std_logic_vector(to_signed(to_integer(signed(read_data_1)) * to_integer(signed(read_data_2)), 64));
				Hi <= HiLo(63 downto 32);
				Lo <= HiLo(31 downto 0);
			when "1010" => --lui
				ALU_result <= imm(31 downto 16) & std_logic_vector(to_unsigned(0, 16));
			when "1011" => --sra
				--power <= 2**to_integer(signed(read_data_2))
				ALU_result <= std_logic_vector(to_signed(to_integer(signed(read_data_1)) / 2**to_integer(signed(shamt)), 32));
			when others =>
				ALU_result <= (others => '0');
		end case;

end process;

end arch;