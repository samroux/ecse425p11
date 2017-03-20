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
    EXE_result: out std_logic_vector(31 downto 0) := (others => '0');
    MemRead : out std_logic;
    MemWrite : out std_logic;
    branchTaken_EX : out std_logic;
    B_EX : out std_logic_vector(31 downto 0);
    IR_EX : out std_logic_vector(31 downto 0)
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
signal ALUOp: std_logic_vector(1 downto 0) := "00";
signal ALU_operation: std_logic_vector(3 downto 0);
signal zero: std_logic;
signal branch_select: std_logic := '0';
signal ALU_result: std_logic_vector(31 downto 0);
signal ALU_result_temp: std_logic_vector(31 downto 0);

component ALU
    port(
        ALU_operation: in std_logic_vector(3 downto 0);
        funct: in std_logic_vector(5 downto 0);
        shamt: in std_logic_vector(4 downto 0);
        imm: in std_logic_vector(31 downto 0);
        read_data_1: in std_logic_vector(31 downto 0);
        read_data_2: in std_logic_vector(31 downto 0);
        ALU_result: out std_logic_vector(31 downto 0) := (others => '0');
        zero: out std_logic
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
variable Jump: std_logic := '0';
variable Branch: std_logic := '0';
variable BorJ: std_logic;
begin
if rising_edge(clock) then
    shift_j_addr <= std_logic_vector(shift_left(unsigned(jump_addr), 2));
    
    branch_addr <= std_logic_vector(to_signed(to_integer(signed(PC_plus_4)) + to_integer(signed(shifted_imm)), 32));
     
    if (opcode = "001000") then
        ALUOp <= "11"; --addi
    elsif (opcode = "001010") then
        ALUOp <= "11"; --slti
    elsif (opcode = "001100") then
        ALUOp <= "11"; --andi
    elsif (opcode = "001101") then
        ALUOp <= "11"; --ori
    elsif (opcode = "001110") then
        ALUOp <= "11"; --xori
    elsif (opcode = "001111") then
        ALUOp <= "11"; --lui
    elsif (opcode = "100011") then
        ALUOp <= "00"; --lw
    elsif (opcode = "101011") then
        ALUOp <= "00"; --sw
    elsif (opcode = "000101") then
        ALUOp <= "01";  --bne
    elsif (opcode = "000100") then
        ALUOp <= "01"; --beq
    elsif (opcode = "000000") then
        ALUOp <= "10"; --R
    else
        ALUOp <= "00";
    end if;

    report "-> zero: "&std_logic'image(zero);
    --	 beq					bne
    if ((opcode = "000100") or (opcode = "000101")) and (zero = '1')  then
        Branch := '1';
    else
        Branch := '0';
    end if;

    -- jumps
    if (opcode = "000010") or (opcode = "000011") then 
    	Jump := '1';
    else 
    	Jump := '0';
    end if;
        
    if(Branch = '1') then
        branch_mux <= branch_addr;
    elsif (Branch = '0') then
        branch_mux <= std_logic_vector(resize(unsigned(PC_plus_4), 32));
    else
        branch_mux <= (others => '0');
    end if;
    
    if (Jump = '1') then
        ALU_result_temp <= std_logic_vector(resize(unsigned(shift_j_addr), 32));
    elsif (Jump = '0') then
        ALU_result_temp <= branch_mux;
    else
        ALU_result_temp <= (others => '0');
    end if;
    
    BorJ := Branch or Jump;
    report "-> bra: "&std_logic'image(Branch);
    report "-> jmp: "&std_logic'image(Jump);
    report "-> bork: "&std_logic'image(BorJ);
    shifted_imm <= std_logic_vector(shift_left(unsigned(imm), 2));
    
    if (BorJ = '1') then
        EXE_result <= ALU_result_temp;
    elsif (BorJ = '0') then
        EXE_result <= ALU_result;
    else
        EXE_result <= (others => '0');
    end if;
    
    -- mem operations for data memory
    if (opcode = "100011") then -- lw
        MemRead <= '1';
    else
        MemRead <= '0';
    end if;
    
    if (opcode = "101011") then -- sw
        MemWrite <= '1';
    else
        MemWrite <= '0';
    end if;

    --signals are only following through at rising edge.
    NEXT_PC <= PC_plus_4;
    B_EX <= read_data_2;
    IR_EX <= instruction;
    
    branchTaken_EX <= BorJ;
     
end if;
end process;
end arch;