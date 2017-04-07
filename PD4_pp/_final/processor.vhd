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

-- instruction fetch stage --
signal s_IR_Fetch : std_logic_vector(31 downto 0):= (others => '0');
signal s_PC_Fetch : std_logic_vector(11 downto 0) := (others => '0');
signal s_write_to_files : std_logic;

component instruction_fetch
	PORT (
		clock : in std_logic;
		reset : in std_logic;
		
		branch_taken : in std_logic;		-- will be set to 1 when Branch is Taken
		branch_address : in std_logic_vector (11 downto 0);	-- address to jump to when Branch is Taken
		
		IR : out std_logic_vector (31 downto 0);	-- Instruction Read -> Size of 32 bits defined by compiler 
		PC : out std_logic_vector (11 downto 0);	-- Program Counter -> Assuming instruction memory of size 4096 (128 instructions of 32 bits)
		write_to_files : out std_logic
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


-- hazard detection component (hazard_detection.vhd)--
signal s_hazard_detected_HDF : std_logic := '0';
signal s_fwd_required_HDF : std_logic := '0';
signal s_fwd_top_HDF : std_logic := '0';
signal s_fwd_bottom_HDF : std_logic := '0';
signal s_fwd_aluoutput_ex_mem_HDF : std_logic := '0';
signal s_fwd_aluoutput_mem_wb_HDF : std_logic := '0';
signal s_fwd_lmd_mem_wb_HDF : std_logic := '0';

component hazard_detection_fwd
   port (
		clock : in std_logic;
		
		--Required for hazard detection only 
		IR_IF_ID : in std_logic_vector(31 downto 0);
		
		--required for hazard detection and fwd
		IR_ID_EX : in std_logic_vector(31 downto 0);
		
		--required for forwarding only
		IR_EX_MEM : in std_logic_vector(31 downto 0);
		IR_MEM_WB : in std_logic_vector(31 downto 0);
		
		HAZARD_DETECTED : out std_logic;
		FWD_REQUIRED : out std_logic;
	
		FWD_TOP : out std_logic;
		FWD_BOTTOM : out std_logic;
		
		FWD_ALUOUTPUT_EX_MEM : out std_logic;
		FWD_ALUOUTPUT_MEM_WB : out std_logic;
		FWD_LMD_MEM_WB : out std_logic
   );
end component;



--instruction decode stage (register_controller.vhd) --

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
	write_to_file : in std_logic;
	hazard_detected : in std_logic;

	PC_ID : out std_logic_vector (11 downto 0);
	IR_ID : out std_logic_vector(31 downto 0);
	A : out std_logic_vector(31 downto 0);
	B : out std_logic_vector(31 downto 0);
	Imm : out std_logic_vector(31 downto 0)								
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
		NPC_ID : in std_logic_vector(11 downto 0);  -- should come from if/id directly
		IR_ID : in std_logic_vector(31 downto 0);	-- same as above

		A_EX : out std_logic_vector(31 downto 0);
		B_EX : out std_logic_vector(31 downto 0);
		IMM_EX : out std_logic_vector(31 downto 0);
		NPC_EX : out std_logic_vector(11 downto 0);
		IR_EX : out std_logic_vector(31 downto 0)
	);
end component;

-- execute stage (execution.vhd)--
signal s_branch_taken_EX : std_logic;
signal s_PC_EX : std_logic_vector(11 downto 0);
signal s_ALUOutput_EX : std_logic_vector(31 downto 0);
signal s_B_EX : std_logic_vector(31 downto 0);
signal s_IR_EX : std_logic_vector(31 downto 0);
signal s_MemRead_EX : std_logic;
signal s_MemWrite_EX : std_logic;

component execution
	port(
		clock: in std_logic;
		inst: in std_logic_vector(31 downto 0);
		PC_ID_EX: in std_logic_vector(11 downto 0);
		rs_from_ID: in std_logic_vector(31 downto 0);
		rt_from_ID: in std_logic_vector(31 downto 0);
		imm_sign_ext: in std_logic_vector(31 downto 0);
		
		--Required for fwd
		ALUOutput_EX_MEM: in std_logic_vector(31 downto 0);
		ALUOutput_MEM_WB: in std_logic_vector(31 downto 0);
		LMD_MEM_WB : in std_logic_vector(31 downto 0);
		
		FWD_REQUIRED : in std_logic;
		FWD_TOP : in std_logic;
		FWD_BOTTOM : in std_logic;
		
		FWD_ALUOUTPUT_EX_MEM : in std_logic;
		FWD_ALUOUTPUT_MEM_WB : in std_logic;
		FWD_LMD_MEM_WB : in std_logic;
		
		PC_EX: out std_logic_vector(11 downto 0);
		ALUOutput: out std_logic_vector(31 downto 0) := (others => '0');
		MemRead : out std_logic;
		MemWrite : out std_logic;
		branch_taken_EX : out std_logic;
		B_EX : out std_logic_vector(31 downto 0);
		IR_EX : out std_logic_vector(31 downto 0)
	  );
end component;

-- EX/MEM register --
signal s_branch_taken_EX_MEM : std_logic;
signal s_PC_EX_MEM : std_logic_vector(11 downto 0);
signal s_ALUOutput_EX_MEM : std_logic_vector(31 downto 0);
signal s_B_EX_MEM : std_logic_vector(31 downto 0);
signal s_IR_EX_MEM : std_logic_vector(31 downto 0);
signal s_MemRead_EX_MEM : std_logic;
signal s_MemWrite_EX_MEM : std_logic;

component ex_mem_reg
	PORT (
		clock : in std_logic;
		branch_taken_EX : in std_logic; -- whether branch should be taken (BEQZ)
		PC_EX : in std_logic_vector(11 downto 0);
		ALUOutput_EX : in std_logic_vector(31 downto 0); -- need to make sure that only 12 bits
														 -- are used when this is used as index
		B_EX : in std_logic_vector(31 downto 0);	-- rt, used for reg-reg store
												-- should come from id/ex directly
		IR_EX : in std_logic_vector(31 downto 0);	-- same as above
		
		MemRead_EX : in std_logic;		-- comes from ALU control unit
		MemWrite_EX : in std_logic;
		
		branch_taken_MEM : out std_logic;		-- condition for branch taken or not.
		PC_MEM : out std_logic_vector(11 downto 0);
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
signal s_ALUOutput_MEM : std_logic_vector(31 downto 0);

component data_memory 
	port (
		clock : in std_logic;
		PC_in : in std_logic_vector(11 downto 0);
		ALUOutput : in std_logic_vector(31 downto 0);
		B_in: in std_logic_vector(31 downto 0);
		MemRead : in std_logic;		-- comes from ALU control unit
		MemWrite : in std_logic;	-- same as above
		IR_in : in std_logic_vector(31 downto 0);
		branch_taken_in : in std_logic;
		write_to_file : in std_logic;

		LMD : out std_logic_vector(31 downto 0);
		IR_out : out std_logic_vector(31 downto 0);
		ALUOutput_out: out std_logic_vector(31 downto 0)
	);
end component;

-- MEM/WB register --
signal s_LMD_MEM_WB : std_logic_vector(31 downto 0);
signal s_ALUOutput_MEM_WB : std_logic_vector(31 downto 0);
signal s_IR_MEM_WB : std_logic_vector(31 downto 0);

component mem_wb_reg			
    PORT (
		clock : in std_logic;
		
		LMD_MEM : in std_logic_vector(31 downto 0);-- load memory data
		ALUOutput_MEM : in std_logic_vector(31 downto 0);
		IR_MEM : in std_logic_vector(31 downto 0); -- comes from ex/mem

		LMD_WB : out std_logic_vector(31 downto 0);
		ALUOutput_WB : out std_logic_vector(31 downto 0);
		IR_WB : out std_logic_vector(31 downto 0)
	);
end component;

--write back stage --
signal s_WB_dest_reg : std_logic_vector(4 downto 0);
signal s_WB_output : std_logic_vector(31 downto 0);

component write_back
   port (
   		clock : in std_logic;
		
		IR_reg : in std_logic_vector(31 downto 0);		--instruction following thru from IF and out of MEM/WB register
		LMD : in std_logic_vector(31 downto 0);			-- Load Memory Data	
		ALUOutput : in std_logic_vector(31 downto 0);	-- ALU Output
		
		WB_dest_reg : out std_logic_vector(4 downto 0);
		WB_output : out std_logic_vector(31 downto 0)
   );
end component;

BEGIN

	I_F: instruction_fetch
	port map (
			--in
			clock,
			reset,
			s_branch_taken_EX_MEM, 			--> this comes from EX/MEM reg (not MEM)
			s_ALUOutput_EX_MEM(11 downto 0),--> this comes from EX/MEM reg (not MEM)
			--out
			s_IR_Fetch,
			s_PC_Fetch,
			s_write_to_files
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
	
	H_D_F: hazard_detection_fwd
	port map (
			--in
			clock,
			s_IR_IF_ID,
			s_IR_ID_EX,
			s_IR_EX_MEM,
			s_IR_MEM_WB,
			--out
			s_hazard_detected_HDF,
			s_fwd_required_HDF,
			s_fwd_top_HDF,
			s_fwd_bottom_HDF,
			s_fwd_aluoutput_ex_mem_HDF,
			s_fwd_aluoutput_mem_wb_HDF,
			s_fwd_lmd_mem_wb_HDF
		);
		
	I_D: register_controller
	port map (
			--in
			clock,
			s_PC_IF_ID,
			s_IR_IF_ID,
			s_WB_dest_reg,	--> this comes from output of WB
			s_WB_output,	--> this comes from output of WB
			s_write_to_files,
			s_hazard_detected_HDF,

			--out
			s_PC_decode,
			s_IR_decode,
			s_A_decode,
			s_B_decode,
			s_imm_decode
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
		
	EX: execution
	port map (
			--in
			clock,
			s_IR_ID_EX,
			s_PC_ID_EX,
			s_A_ID_EX,
			s_B_ID_EX,
			s_IMM_ID_EX,
			
			s_ALUOutput_EX_MEM,
			s_ALUOutput_MEM_WB,
			s_LMD_MEM_WB,
			
			s_fwd_required_HDF,
			s_fwd_top_HDF,
			s_fwd_bottom_HDF,
			s_fwd_aluoutput_ex_mem_HDF,
			s_fwd_aluoutput_mem_wb_HDF,
			s_fwd_lmd_mem_wb_HDF,
			--out
			s_PC_EX,
			s_ALUOutput_EX,
			s_MemRead_EX,
			s_MemWrite_EX,
			s_branch_taken_EX,
			s_B_EX,
			s_IR_EX
		);

	EX_MEM: ex_mem_reg
	port map (
			--in
			clock,
			s_branch_taken_EX,
			s_PC_EX,
			s_ALUOutput_EX,
			s_B_EX,
			s_IR_EX,
			s_MemRead_EX,
			s_MemWrite_EX,
			--out
			s_branch_taken_EX_MEM,	--> goes back to IF
			s_PC_EX_MEM,
			s_ALUOutput_EX_MEM, 	--> goes back to IF	(last 12 bits only)
			s_B_EX_MEM, 
			s_IR_EX_MEM,
			s_MemRead_EX_MEM,
			s_MemWrite_EX_MEM
		);
		
	MEM: data_memory
	port map (
			--in
			clock,
			s_PC_EX_MEM,
			s_ALUOutput_EX_MEM,
			s_B_EX_MEM,
			s_MemRead_EX_MEM,
			s_MemWrite_EX_MEM,
			s_IR_EX_MEM,
			s_branch_taken_EX_MEM,
			s_write_to_files,
			--out
			s_LMD_MEM,
			s_IR_MEM,
			s_ALUOutput_MEM
		);
		
	MEM_WB: mem_wb_reg
	port map (
			--in
			clock,
			s_LMD_MEM,
			s_ALUOutput_MEM,
			s_IR_MEM,
			--out
			s_LMD_MEM_WB,
			s_ALUOutput_MEM_WB,
			s_IR_MEM_WB
		);
		
	WB: write_back
	port map (
		--in
		clock,
		s_IR_MEM_WB,
		s_LMD_MEM_WB,
		s_ALUOutput_MEM_WB,
		--out
		s_WB_dest_reg, --> This goes back to ID
		s_WB_output --> This goes back to ID
		);


END behaviour;