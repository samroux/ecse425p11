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
signal s_branch_taken : std_logic := '0';
signal s_branch_address : std_logic_vector(11 downto 0):= (others => '0');
signal s_IR : std_logic_vector(31 downto 0):= (others => '0');
signal s_PC : std_logic_vector(11 downto 0) := (others => '0');

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
signal s_NPC_ID : std_logic_vector(11 downto 0) := (others => '0');
signal s_IR_ID : std_logic_vector(31 downto 0)	:= (others => '0');

component if_id_reg				
	PORT (
		clock : in std_logic;
		NPC_IF: in std_logic_vector(11 downto 0);
		NPC_ID : out std_logic_vector(11 downto 0);
		IR_IF: in std_logic_vector(31 downto 0);
		IR_ID : out std_logic_vector(31 downto 0)
	);
end component;


--instruction decode stage --

component instruction_decode
--TODO
end component;

component id_ex_reg				-- ID/EX register
	PORT (
		clock : in std_logic;
		A_ID : in std_logic_vector(7 downto 0); 	-- regs have length 8
		B_ID : in std_logic_vector(7 downto 0); 	
		IMM_ID : in std_logic_vector(31 downto 0); 	-- last 16 bits of instruction (sign-extended)
		NPC_ID : in std_logic_vector(4095 downto 0);-- should come from if/id directly
		IR_ID : in std_logic_vector(31 downto 0);	-- same as above

		A_EX : out std_logic_vector(7 downto 0);
		B_EX : out std_logic_vector(7 downto 0);
		IMM_EX : out std_logic_vector(31 downto 0);
		NPC_EX : out std_logic_vector(4095 downto 0);
		IR_EX : out std_logic_vector(31 downto 0)
	);
end component;

-- execute stage --

component execute
--TODO
end component;

-- EX/MEM register --

component ex_mem_reg
	PORT (
		clock : in std_logic;
		Cond_EX : in std_logic; -- whether branch should be taken (BEQZ)
		ALUOutput_EX : in std_logic_vector(15 downto 0); -- need to make sure that only 12 bits
														 -- are used when this is used as index
		B_EX : in std_logic_vector(7 downto 0);	-- rt, used for reg-reg store
												-- should come from id/ex directly
		IR_EX : in std_logic_vector(31 downto 0);	-- same as above
		
		Cond_MEM : out std_logic;
		ALUOutput_MEM : out std_logic_vector(15 downto 0);
		B_MEM : out std_logic_vector(7 downto 0);
		IR_MEM : out std_logic_vector(31 downto 0)
	);
end component;

-- memory stage --

component data_memory			
--TODO
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
--TODO
end component;

BEGIN

	I_F: instruction_fetch
	port map (
			clock,
			s_reset,
			s_branch_taken,
			s_branch_address,
			s_IR,
			s_PC
		);
		
	IF_ID: if_id_reg
	port map (
			clock,
			s_PC,
			s_NPC_ID,
			s_IR,
			s_IR_ID
		);
		
--	I_D: instruction_decode
--	port map (
--			clock,
--			s_reset
--		);
		
--	ID_EX: id_ex_reg
--	port map (
--			clock,
--			s_reset
--		);
		
--	EX: execute
--	port map (
--			clock,
--			s_reset
--		);
	
--	EX_MEM: ex_mem_reg
--	port map (
--			clock,
--			s_reset
--		);
		
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