library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		opcode: in std_logic_vector(5 downto 0);
	   RegDst: out std_logic := '0';
		Jump: out std_logic := '0';
		Branch: out std_logic := '0';
		MemRead: out std_logic := '0';
		MemtoReg: out std_logic := '0';
		ALUOp: out std_logic_vector(1 downto 0) := "00";
		MemWrite: out std_logic := '0';
		ALUSrc: out std_logic := '0';
		RegWrite: out std_logic := '0'
	);
end entity;

architecture arch of control_unit is
begin

process(opcode)
begin
    case(opcode) is
        when "000000" => --R type
				RegDst <= '1';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "10";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '1';
        when "000010" => --j
            RegDst <= '0';
            Jump <= '1';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "00";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '0';
		  when "000011" => --jal
				RegDst <= '0';
            Jump <= '1';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "00";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '0';		  
        when "000100" => --beq
            --RegDst <= '0'; don't care
            Jump <= '0';
				Branch <= '1';
				MemRead <= '0';
				--MemtoReg <= '0'; don't care
				ALUOp <= "01";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '0';
        when "000101" => --bne
				--RegDst <= '0'; don't care
            Jump <= '0';
				Branch <= '1';
				MemRead <= '0';
				--MemtoReg <= '0'; don't care
				ALUOp <= "01";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '0';
        when "001000" => --addi
				RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "11";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '1';
        when "001010" => --slti
				RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "11";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '1';
        when "001100" => --andi
				RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "11";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '1';
        when "001101" => --ori
				RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "11";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '1';
        when "001110" => --xori
				RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "11";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '1';
		  when "001111" => --lui
				RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "11";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '1';
        when "100011" => --lw
            RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '1';
				MemtoReg <= '1';
				ALUOp <= "00";
				MemWrite <= '0';
				ALUSrc <= '1';
				RegWrite <= '1';
        when "101011" => --sw
            --RegDst <= '0'; don't care
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				--MemtoReg <= '0'; don't care
				ALUOp <= "00";
				MemWrite <= '1';
				ALUSrc <= '1';
				RegWrite <= '0';
        when others =>
            RegDst <= '0';
            Jump <= '0';
				Branch <= '0';
				MemRead <= '0';
				MemtoReg <= '0';
				ALUOp <= "00";
				MemWrite <= '0';
				ALUSrc <= '0';
				RegWrite <= '0';
    end case;
end process;

end architecture;