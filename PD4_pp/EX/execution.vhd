library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execution is
  port(
   clock: in std_logic;
   instruction: in std_logic_vector(31 downto 0);
	PC_plus_4: in std_logic_vector(11 downto 0);
	read_data_1: in std_logic_vector(31 downto 0);
	read_data_2: in std_logic_vector(31 downto 0);
	imm: in std_logic_vector(31 downto 0);
	
	NEXT_PC: out std_logic_vector(11 downto 0);
	EXE_result: out std_logic_vector(31 downto 0) := (others => '0')
--	test_b_addr: out std_logic_vector(31 downto 0)
  );
end execution;

architecture arch of execution is

signal opcode: std_logic_vector(5 downto 0);
signal funct: std_logic_vector(5 downto 0);
signal shamt: std_logic_vector(4 downto 0);
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
signal ALU_result: std_logic_vector(31 downto 0);
signal ALU_result_temp: std_logic_vector(31 downto 0);
signal BorJ: std_logic;

component ALU
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
end component;

component alu_control
	port(
		opcode: in std_logic_vector(5 downto 0);
		funct: in std_logic_vector(5 downto 0);
		ALUOp: in std_logic_vector(1 downto 0);
		operation: out std_logic_vector(3 downto 0):= "0000"
	);
end component;

begin

opcode <= instruction(31 downto 26);
funct <= instruction(5 downto 0);
jump_addr <= instruction(25 downto 0);
shamt <= instruction(10 downto 6);
--test_operation <= ALU_operation;

a: ALU
	port map(
		ALU_operation => ALU_operation,
		funct => funct,
		shamt => shamt,
		imm => imm,
		read_data_1 => read_data_1,
		read_data_2 => read_data_2,
		ALU_result => ALU_result,
		zero => zero
	);
	
ac: alu_control
	port map(
		opcode => opcode,
		funct => funct,
		ALUOp => ALUOp,
		operation => ALU_operation
	);

process(clock)
begin

if falling_edge(clock) then
--    case(opcode) is
--        when "000000" => --R type
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "10";
--        when "000010" => --j
--            Jump <= '1';
--				Branch <= '0';
--				ALUOp <= "00";
--		  when "000011" => --jal
--            Jump <= '1';
--				Branch <= '0';
--				ALUOp <= "00";
--        when "000100" => --beq
--            Jump <= '0';
--				if zero = '1' then
--					Branch <= '1';
--				else
--					Branch <= '0';
--				end if;
--				ALUOp <= "01";
--        when "000101" => --bne
--            Jump <= '0';
--				if zero = '0' then
--					Branch <= '1';
--				else
--					Branch <= '0';
--				end if;
--				ALUOp <= "01";
--        when "001000" => --addi
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "11";
--        when "001010" => --slti
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "11";
--        when "001100" => --andi
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "11";
--        when "001101" => --ori
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "11";
--        when "001110" => --xori
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "11";
--		  when "001111" => --lui
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "11";
--        when "100011" => --lw
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "00";
--        when "101011" => --sw
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "00";
--        when others =>
--            Jump <= '0';
--				Branch <= '0';
--				ALUOp <= "00";
--    end case;
	 
--	 if Branch = '1' then
--		branch_mux <= branch_addr;
--	 elsif Branch = '0' then
--		branch_mux <= std_logic_vector(resize(unsigned(PC_plus_4), 32));
--	 end if;
--	 
--	 if Jump = '1' then
--		ALU_result_temp <= std_logic_vector(resize(unsigned(shift_j_addr), 32));
--	 elsif Jump = '0' then
--		ALU_result_temp <= branch_mux;
--	 end if;
	 
	 NEXT_PC <= PC_plus_4;
	 
end if;
end process;

shift_j_addr <= std_logic_vector(shift_left(unsigned(jump_addr), 2));

ALU_result_temp <= std_logic_vector(resize(unsigned(shift_j_addr), 32)) when Jump = '1' else
	branch_mux when Jump = '0' else
	(others => '0');

shifted_imm <= std_logic_vector(shift_left(unsigned(imm), 2));
branch_addr <= std_logic_vector(to_signed(to_integer(signed(PC_plus_4)) + to_integer(signed(shifted_imm)), 32));
--test_b_addr <= branch_addr;

branch_mux <= branch_addr when Branch = '1' else
	std_logic_vector(resize(unsigned(PC_plus_4), 32)) when Branch = '0' else
	(others => '0');

BorJ <= Branch or Jump;
EXE_result <= ALU_result_temp when BorJ = '1' else
	ALU_result when BorJ = '0' else
	(others => '0');

ALUOp <= "11" when opcode = "001000" else --addi
			"11" when opcode = "001010" else --slti
			"11" when opcode = "001100" else --andi
			"11" when opcode = "001101" else --ori
			"11" when opcode = "001110" else --xori
			"11" when opcode = "001111" else --lui
			"00" when opcode = "100011" else --lw
			"00" when opcode = "101011" else --sw
			"01" when opcode = "000101" else --bne
			"01" when opcode = "000100" else --beq
			"10" when opcode = "000000" else --R
			"00";

Branch <= '1' when (opcode = "000100") and (zero = '1') else --beq
	'1' when (opcode = "000101") and (zero = '0') else --bne
	'0';

Jump <= '1' when (opcode = "000010") or (opcode = "000011") else
	'0';
end arch;