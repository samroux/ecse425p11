library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execution is
  port(
   instruction: in std_logic_vector(31 downto 0);
	PC_plus_4: in std_logic_vector(11 downto 0);
	read_data_1: in std_logic_vector(31 downto 0);
	read_data_2: in std_logic_vector(31 downto 0);
	imm: in std_logic_vector(31 downto 0);
	
	NEXT_PC: out std_logic_vector(11 downto 0);
	ALU_result: out std_logic_vector(31 downto 0) := (others => '0')
  );
end execution;

architecture arch of execution is

signal opcode: std_logic_vector(5 downto 0);
signal funct: std_logic_vector(5 downto 0);
signal jump_addr: std_logic_vector(25 downto 0);
signal shift_j_addr: std_logic_vector(25 downto 0);
signal branch_addr: std_logic_vector(31 downto 0);
signal branch_mux: std_logic_vector(31 downto 0);
signal shifted_imm: std_logic_vector(31 downto 0);

signal Jump: std_logic := '0';
signal Branch: std_logic := '0';
signal ALUOp: std_logic_vector(1 downto 0) := "00";

signal ALU_operation: std_logic_vector(3 downto 0);
signal zero: std_logic;

signal branch_select: std_logic := '0';

component ALU
	port(
		ALU_operation: in std_logic_vector(3 downto 0);
		funct: in std_logic_vector(5 downto 0);
		read_data_1: in std_logic_vector(31 downto 0);
		read_data_2: in std_logic_vector(31 downto 0);
		ALU_result: out std_logic_vector(31 downto 0) := (others => '0');
		zero: out std_logic := '0'
	);
end component;

component alu_control
	port(
		funct: in std_logic_vector(5 downto 0);
		ALUOp: in std_logic_vector(1 downto 0);
		operation: out std_logic_vector(3 downto 0):= "0000"
	);
end component;

begin

opcode <= instruction(31 downto 26);
funct <= instruction(5 downto 0);
jump_addr <= instruction(25 downto 0);

a: ALU
	port map(
		ALU_operation => ALU_operation,
		funct => funct,
		read_data_1 => read_data_1,
		read_data_2 => read_data_2,
		ALU_result => ALU_result,
		zero => zero
	);
	
ac: alu_control
	port map(
		funct => funct,
		ALUOp => ALUOp,
		operation => ALU_operation
	);

process(opcode)
begin
    case(opcode) is
        when "000000" => --R type
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "10";
        when "000010" => --j
            Jump <= '1';
				Branch <= '0';
				ALUOp <= "00";
		  when "000011" => --jal
            Jump <= '1';
				Branch <= '0';
				ALUOp <= "00";
        when "000100" => --beq
            Jump <= '0';
				if zero = '1' then
					Branch <= '1';
				else
					Branch <= '0';
				end if;
				ALUOp <= "01";
        when "000101" => --bne
            Jump <= '0';
				if zero = '0' then
					Branch <= '1';
				else
					Branch <= '0';
				end if;
				ALUOp <= "01";
        when "001000" => --addi
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "11";
        when "001010" => --slti
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "11";
        when "001100" => --andi
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "11";
        when "001101" => --ori
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "11";
        when "001110" => --xori
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "11";
		  when "001111" => --lui
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "11";
        when "100011" => --lw
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "00";
        when "101011" => --sw
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "00";
        when others =>
            Jump <= '0';
				Branch <= '0';
				ALUOp <= "00";
    end case;
end process;

shift_j_addr <= std_logic_vector(shift_left(unsigned(jump_addr), 2));

NEXT_PC <= shift_j_addr(11 downto 0) when Jump = '1' else
	branch_mux(11 downto 0) when Jump = '0' else
	(others => '0');

shifted_imm <= std_logic_vector(shift_left(unsigned(imm), 2));
branch_addr <= std_logic_vector(to_signed(to_integer(signed(PC_plus_4)) + to_integer(signed(shifted_imm)), 32));

branch_mux <= branch_addr when Branch = '1' else
	std_logic_vector(resize(unsigned(PC_plus_4), 32)) when Branch = '0' else
	(others => '0');

end arch;