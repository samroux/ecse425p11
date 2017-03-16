-- @filename processor.vhd
-- @author Samuel Roux
-- @timestamp 2017-03-13 2:08 PM
-- @brief vhdl entity defining the whole processor

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY processor is
	PORT (
		clock : in std_logic;
		reset : in std_logic
	);
END processor;

ARCHITECTURE behaviour OF processor IS
SIGNAL s_reset : std_logic := '0';


-- instruction fetch stage --
signal s_branch_taken_EX_MEM : std_logic := '0';
signal s_branch_address_EX_MEM : std_logic_vector(11 downto 0):= (others => '0');
signal s_IR_Fetch : std_logic_vector(31 downto 0):= (others => '0');
signal s_PC_Fetch : std_logic_vector(11 downto 0) := (others => '0');

component instruction_fetch
	PORT (
		clock : in std_logic;
		reset : in std_logic;
		
		branch_taken : in std_logic;		-- will be set to 1 when Branch is Taken
		branch_address : in std_logic_vector (11 downto 0);	-- address to jump to when Branch is Taken
		
		IR : out std_logic_vector (31 downto 0);	-- Instruction Read -> Size of 32 bits defined by compiler 
		PC : out std_logic_vector (11 downto 0)	-- Program Counter -> Assuming instruction memory of size 4096 (128 instructions of 32 bits)

	);
end component;


-- IF/ID register --
signal s_PC_IF_ID : std_logic_vector(11 downto 0) := (others => '0');
signal s_IR_IF_ID : std_logic_vector(31 downto 0)	:= (others => '0');

component if_id_reg				
	PORT (
		clock : in std_logic;
		
		NPC_IF: in std_logic_vector(11 downto 0);
		IR_IF: in std_logic_vector(31 downto 0);
		
		NPC_ID : out std_logic_vector(11 downto 0);
		IR_ID : out std_logic_vector(31 downto 0)
	);
end component;


--instruction decode stage --

signal s_WB_addr : std_logic_vector(4 downto 0);
signal s_WB_return : std_logic_vector(31 downto 0); 
signal s_IR_decode : std_logic_vector(31 downto 0);
signal s_A_decode : std_logic_vector(31 downto 0);
signal s_B_decode : std_logic_vector(31 downto 0);
signal s_imm_decode : std_logic_vector(31 downto 0);
signal s_branch_taken_decode : std_logic;
signal s_PC_decode : std_logic_vector(11 downto 0);

component register_controller
	port (
		clock : in std_logic;
		PC_IF : in std_logic_vector (11 downto 0);
		IR_IF : in std_logic_vector(31 downto 0);
		WB_addr : in std_logic_vector(4 downto 0); 		-- address to write to (rs or rt)
		WB_return : in std_logic_vector(31 downto 0); 	-- either a loaded register from memory 
														-- or the ALU output (mux decided)

		IR_ID : out std_logic_vector(31 downto 0);	--TODO modify file itself
		A : out std_logic_vector(31 downto 0);
		B : out std_logic_vector(31 downto 0);
		Imm : out std_logic_vector(31 downto 0);
		branchTaken : out std_logic;	-- returns 1 if rs == rt and instruction is beq
									-- or if rs /= rt and instruction is bne.
									-- to be used in EX stage
		PC_ID : out std_logic_vector(11 downto 0) --TODO modify file itself
		);
end component;

-- ID/EX register
signal s_A_ID_EX : std_logic_vector(31 downto 0);
signal s_B_ID_EX : std_logic_vector(31 downto 0);
signal s_IMM_ID_EX : std_logic_vector(31 downto 0);
signal s_PC_ID_EX : std_logic_vector(11 downto 0);
signal s_IR_ID_EX : std_logic_vector(31 downto 0);

component id_ex_reg				
	PORT (
		clock : in std_logic;
		
		A_ID : in std_logic_vector(31 downto 0); 	-- regs have length 8
		B_ID : in std_logic_vector(31 downto 0); 	
		IMM_ID : in std_logic_vector(31 downto 0); 	-- last 16 bits of instruction (sign-extended)
		NPC_ID : in std_logic_vector(11 downto 0);-- should come from if/id directly
		IR_ID : in std_logic_vector(31 downto 0);	-- same as above

		A_EX : out std_logic_vector(31 downto 0);
		B_EX : out std_logic_vector(31 downto 0);
		IMM_EX : out std_logic_vector(31 downto 0);
		NPC_EX : out std_logic_vector(11 downto 0);
		IR_EX : out std_logic_vector(31 downto 0)
	);
end component;

-- execute stage --
signal s_cond_EX : std_logic;
signal s_ALUOutput_EX : std_logic_vector(31 downto 0);
signal s_B_EX : std_logic_vector(31 downto 0);
signal s_IR_EX : std_logic_vector(31 downto 0);
signal s_MemRead_EX : std_logic;
signal s_MemWrite_EX : std_logic;

component execute
--TODO
end component;

-- EX/MEM register --
signal s_cond_EX_MEM : std_logic;
signal s_ALUOutput_EX_MEM : std_logic_vector(31 downto 0);
signal s_B_EX_MEM : std_logic_vector(31 downto 0);
signal s_IR_EX_MEM : std_logic_vector(31 downto 0);
signal s_MemRead_EX_MEM : std_logic;
signal s_MemWrite_EX_MEM : std_logic;

component ex_mem_reg
	PORT (
		clock : in std_logic;
		Cond_EX : in std_logic; -- whether branch should be taken (BEQZ)
		ALUOutput_EX : in std_logic_vector(31 downto 0); -- need to make sure that only 12 bits
														 -- are used when this is used as index
		B_EX : in std_logic_vector(31 downto 0);	-- rt, used for reg-reg store
												-- should come from id/ex directly
		IR_EX : in std_logic_vector(31 downto 0);	-- same as above
		
		MemRead_EX : in std_logic;		-- comes from ALU control unit
		MemWrite_EX : in std_logic;
		
		Cond_MEM : out std_logic;
		ALUOutput_MEM : out std_logic_vector(31 downto 0);
		B_MEM : out std_logic_vector(31 downto 0);
		IR_MEM : out std_logic_vector(31 downto 0);
		MemRead_MEM : out std_logic;
		MemWrite_MEM : out std_logic
	);
end component;

-- memory stage --
signal s_LMD_MEM : std_logic_vector(31 downto 0);
signal s_IR_MEM : std_logic_vector(31 downto 0);

component data_memory 
	port (
		clock : in std_logic;
		ALUOutput : in std_logic_vector(31 downto 0);
		B: in std_logic_vector(31 downto 0);
		MemRead : in std_logic;		-- comes from ALU control unit
		MemWrite : in std_logic;	-- same as above
		IR_i : in std_logic_vector(31 downto 0);

		LMD : out std_logic_vector(31 downto 0);
		IR_o : out std_logic_vector(31 downto 0)
	);
end component;


-- MEM/WB register --

component mem_wb_reg			
    PORT (
		clock : in std_logic;
		
		LMD_MEM : in std_logic_vector(7 downto 0);-- load memory data
		ALUOutput_MEM : in std_logic_vector(15 downto 0);-- comes from ex/mem (see notes there)
		IR_MEM : in std_logic_vector(31 downto 0); -- comes from ex/mem

		LMD_WB : out std_logic_vector(7 downto 0);
		ALUOutput_WB : out std_logic_vector(15 downto 0);
		IR_WB : out std_logic_vector(31 downto 0)
	);
end component;

--write back stage --

component write_back
   port (
   		clock : in std_logic;
		
		IR_reg : in std_logic_vector(31 downto 0);		--instruction following thru from IF and out of MEM/WB register
		LMD : in std_logic_vector(31 downto 0);			-- Load Memory Data	
		ALUOutput : in std_logic_vector(31 downto 0);	-- ALU Output
		
		IR_dest_reg : out std_logic_vector(4 downto 0);
		WB_output : out std_logic_vector(31 downto 0)
   );
end component;

BEGIN

	I_F: instruction_fetch
	port map (
			--in
			clock,
			s_reset,
			s_branch_taken_EX_MEM,
			s_branch_address_EX_MEM,
			--out
			s_IR_Fetch,
			s_PC_Fetch
		);
		
	IF_ID: if_id_reg
	port map (
			--in
			clock,
			s_PC_Fetch,
			s_IR_Fetch,
			--out
			s_PC_IF_ID,
			s_IR_IF_ID
		);
		
	I_D: register_controller
	port map (
			--in
			clock,
			s_PC_IF_ID,
			s_IR_IF_ID,
			s_WB_addr,
			s_WB_return,
			--out
			s_IR_decode,
			s_A_decode,
			s_B_decode,
			s_imm_decode,
			s_branch_taken_decode,
			s_PC_decode
		);
		
	ID_EX: id_ex_reg
	port map (
			--in
			clock,
			s_A_decode,
			s_B_decode,
			s_imm_decode,
			s_PC_decode,
			s_IR_decode,
			--out
			s_A_ID_EX,
			s_B_ID_EX,
			s_IMM_ID_EX,
			s_PC_ID_EX,
			s_IR_ID_EX
		);
		
--	EX: execute
--TODO
--	port map (
--			clock,
--			s_reset
--		);
	
	EX_MEM: ex_mem_reg
	port map (
			--in
			clock,
			s_cond_EX,
			s_ALUOutput_EX,
			s_B_EX,
			s_IR_EX,
			s_MemRead_EX,
			s_MemWrite_EX,
			--out
			s_cond_EX_MEM,
			s_ALUOutput_EX_MEM,
			s_B_EX_MEM,
			s_IR_EX_MEM,
			s_MemRead_EX_MEM,
			s_MemWrite_EX_MEM
		);
		
--	MEM: data_memory
--	port map (
--			clock,
--			s_reset
--		);
		
--	MEM_WB: mem_wb_reg
--	port map (
--			clock,
--			s_reset
--		);
		
--	WB: write_back
--	port map (
--		clock,
--		s_reset
--		);

	process (clock, reset)
		begin
			
		end process;

END behaviour;