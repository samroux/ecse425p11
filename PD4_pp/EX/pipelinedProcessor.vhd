library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

ENTITY pipelinedProcessor IS

   PORT(
      clock: IN STD_LOGIC;
   );

END pipelinedProcessor;

ARCHITECTURE arch OF pipelinedProcessor IS
   --instruction fetch
      
   --instruction decode
	--signal PC_IF std_logic_vector (11 downto 0);
	signal IR_IF: std_logic_vector(31 downto 0);
	signal WB_addr: std_logic_vector(4 downto 0); 		-- address to write to (rs or rt)
	signal WB_return: std_logic_vector(31 downto 0); 	-- either a loaded register from memory 
										  	-- or the ALU output (mux decided)
	signal opcode: std_logic_vector(5 downto 0);
	signal A: std_logic_vector(31 downto 0);
	signal B: std_logic_vector(31 downto 0);
	signal Imm: std_logic_vector(31 downto 0);
	signal branchTaken: std_logic:
	
	--signal opcode: std_logic_vector(5 downto 0);
	signal RegDst: std_logic := '0';
	signal Jump: std_logic := '0';
	signal Branch: std_logic := '0';
	signal MemRead: std_logic := '0';
	signal MemtoReg: std_logic := '0';
	signal ALUOp: std_logic_vector(1 downto 0) := "00";
	signal MemWrite: std_logic := '0';
	signal ALUSrc: std_logic := '0';
	signal RegWrite: std_logic := '0';
	
	component register_controller
		port(
			clock : in std_logic;
			--PC_IF : in std_logic_vector (11 downto 0);
			IR_IF : in std_logic_vector(31 downto 0);
			WB_addr : in std_logic_vector(4 downto 0); 		-- address to write to (rs or rt)
			WB_return : in std_logic_vector(31 downto 0); 	-- either a loaded register from memory 
												  	-- or the ALU output (mux decided)
			opcode : out std_logic_vector(5 downto 0);
			A : out std_logic_vector(31 downto 0);
			B : out std_logic_vector(31 downto 0);
			Imm : out std_logic_vector(31 downto 0);
			branchTaken : out std_logic
		);
	component control_unit
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
		
		
   --execution
	signal funct: std_logic_vector(5 downto 0);
	signal ALU_operation: std_logic_vector(3 downto 0);
   signal read_data_1: std_logic_vector(31 downto 0);
   signal read_data_2: std_logic_vector(31 downto 0);
   signal reg_dest_EX: std_logic_vector(4 downto 0) := "00000";
   signal ALU_result: std_logic_vector (31 downto 0) := (others => '0');
   signal zero: std_logic;
	
	component ALU
		port(
			ALU_operation: in std_logic_vector(3 downto 0);
			funct: in std_logic_vector(5 downto 0);
			read_data_1: in std_logic_vector(31 downto 0);
			read_data_2: in std_logic_vector(31 downto 0);
			ALU_result: out std_logic_vector(31 downto 0) := (others => '0');
			zero: out std_logic := '0'
		);
	
	component alu_control
		port(
			funct: in std_logic_vector(5 downto 0);
			ALUOp: in std_logic_vector(1 downto 0);
			operation: out std_logic_vector(3 downto 0):= "0000"
		);
	
   --memory
    
   --write back

BEGIN
   --IF

	--ID
   rc: register_controller
      port map(
         clock => clock,
         IR_IF => IR_IF,
         WB_addr => WB_addr,
         WB_return => WB_return,
         opcode => opcode,
         A => A,
         B => B,
         Imm => Imm,
         branchTaken => branchTaken
      );

   cu: control_unit
      port map(
         opcode => opcode,
			RegDst => RegDst,
			Jump => Jump,
			Branch => Branch,
			MemRead => MemRead,
			MemtoReg => MemtoReg,
			ALUOp => ALUOp,
			MemWrite => MemWrite,
			ALUSrc => ALUSrc,
			RegWrite => RegWrite
      );

   --EXE
   alu: ALU
      port map(
         ALU_operation => ALU_operation,
			funct => funct,
			read_data_1 => read_data_1,
			read_data_2 => read_data_2,
			ALU_result => ALU_result,
			zero => zero,
		);
	
	ac: alu_control
		port map(
			funct => funct;
			ALUOp => ALUOp;
			operation => ALU_operation
		);

   --MEM
  
   --WB

   --IF_logic

   --ID_logic

   --EXE_logic
   read_data_1 <= A;
	
	read_data_2 <= Imm when opcode = "001000"
		else Imm when opcode = "001100"
		else Imm when opcode = "001101"
		else Imm when opcode = "001110"
		else Imm when opcode = "001010"
		else Imm when opcode = "001111"
		else B;

   --MEM_logic

   --WB_logic

END arch;