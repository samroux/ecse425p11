library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_control is
  port(
	funct: in std_logic_vector(5 downto 0);
	ALUOp: in std_logic_vector(1 downto 0);
	operation: out std_logic_vector(3 downto 0):= "0000"
  );
end alu_control;

architecture arch of alu_control is

begin

alu_control: process(funct, ALUOp)

begin
		case (ALUOp) is
			when "00" =>
				operation <= "0010"; --add
			when "01" =>
				operation <= "0110"; --substract
			when "10" =>
				case (funct(3 downto 0)) is
					when "0000" =>
						operation <= "0010"; --add
					when "0010" =>
						operation <= "0110"; --substract
					when "0100" =>
						operation <= "0000"; --AND
					when "0101" =>
						operation <= "0001"; --OR
					when "1010" =>
						operation <= "0111"; --set on less than/div
					when "0111" =>
						operation <= "0011"; --NOR
					when "0110" =>
						operation <= "0100"; --XOR
					when "1000" =>
						operation <= "0101"; --mult
					when "0011" =>
						operation <= "1011"; --sra
					when others =>
						operation <= "1111";
				end case;
			when "11" =>
				case (funct(3 downto 0)) is
					when "1000" =>
						operation <= "0010"; --addi
					when "0010" =>
						operation <= "0110"; --substract
					when "1010" =>
						operation <= "0111"; --slti
					when "1100" =>
						operation <= "1000"; --andi
					when "1110" =>
						operation <= "1001"; --xori
					when "1111" =>
						operation <= "1010"; --lui
					when "1101" =>
						operation <= "1100"; --ori
					when others =>
						operation <= "1111";
				end case;
			when others =>
				operation <= "1111";
		end case;
end process;

end arch;