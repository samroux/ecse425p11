-- @filename:	register_controller.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Wrapper for the register file (ID stage).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGISTER_CONTROLLER is

port (
	clock : in std_logic;
	reset : in std_logic;

	PC_IF : in std_logic_vector (11 downto 0);
	IR_IF : in std_logic_vector(31 downto 0);
	WB_addr : in std_logic_vector(4 downto 0); 		-- address to write to (rs or rt)
	WB_return : in std_logic_vector(31 downto 0); 	-- either a loaded register from memory 
												  	-- or the ALU output (mux decided)
	write_to_file : in std_logic;
	hazard_detected : in std_logic;

	PC_ID : out std_logic_vector (11 downto 0);	--program counter
	IR_ID : out std_logic_vector(31 downto 0);	-- instruction
	A : out std_logic_vector(31 downto 0);		
	B : out std_logic_vector(31 downto 0);
	Imm : out std_logic_vector(31 downto 0)
	--branch_taken : out std_logic	-- returns 1 if rs == rt and instruction is beq
								-- or if rs /= rt and instruction is bne.
								-- to be used in EX stage
								
	);
end REGISTER_CONTROLLER;

architecture behavior of REGISTER_CONTROLLER is

	-- register file signals
	signal reg_address_A : std_logic_vector(4 downto 0);
	signal reg_address_B : std_logic_vector(4 downto 0);
	--signal reg_write_input : std_logic_vector(31 downto 0);
	--signal reg_write_addr : std_logic_vector (4 downto 0);
	signal Mem_R_W : std_logic := '0'; -- 0 for read, 1 for write
	signal reg_output_A : std_logic_vector(31 downto 0);
	signal reg_output_B : std_logic_vector(31 downto 0);

	signal A_temp : std_logic_vector(31 downto 0);
	signal B_temp : std_logic_vector(31 downto 0);
	
	signal s_hazard_detected : std_logic := '0';
	signal signed_imm : signed (15 downto 0);

	component REGISTER_FILE
		port (
			clock : in std_logic;
			reg_address_A : in std_logic_vector(4 downto 0);
			reg_address_B : in std_logic_vector(4 downto 0);
			reg_write_input : in std_logic_vector(31 downto 0);
			reg_write_addr : in std_logic_vector (4 downto 0);
			Mem_R_W : in std_logic;
			write_to_file : in std_logic;
			
			reg_output_A : out std_logic_vector(31 downto 0);
			reg_output_B : out std_logic_vector(31 downto 0)
		);
	end component;

	begin

	rf : REGISTER_FILE
	port map (
		clock => clock,
		reg_address_A => reg_address_A,
		reg_address_B => reg_address_B,
		reg_write_addr => WB_addr,
		reg_write_input => WB_return,

		Mem_R_W => Mem_R_W,
		--MemRead => MemRead,
		write_to_file => write_to_file,
		reg_output_A => reg_output_A,
		reg_output_B => reg_output_B
		);	

	process(clock)

	variable Imm_temp : std_logic_vector(31 downto 0);
	variable Imm_temp_16 : std_logic_vector(15 downto 0);
	variable Imm_temp_15 : std_logic_vector(14 downto 0);
	variable zero_16 : std_logic_vector (15 downto 0) := (others => '0');
	variable sign : integer;
	
	begin

	-- read in 2nd half of cycle, write in 1st half
	if falling_edge(clock) then
		-- Read registers
		Mem_R_W <= '0';

		reg_address_A <= IR_IF(25 downto 21);
		reg_address_B <= IR_IF(20 downto 16);

		-- Sign extend immediate 16->32 for signed instructions (general case)
		-- Zero extend immediate 16->32 for unsigned instructions (andi, ori)
		if (IR_IF(31 downto 26) = "001100") OR (IR_IF(31 downto 26) = "001101") then
			Imm_temp := std_logic_vector(resize(unsigned(IR_IF(15 downto 0)), Imm'length));
		else
			Imm_temp := std_logic_vector(resize(signed(IR_IF(15 downto 0)), Imm'length));
		end if;

	-- WB process runs concurrently but works on a previous instruction.
	-- It only writes to reg file, which supports read/write in a single cycle.
	elsif rising_edge(clock) then
		-- Write to appropriate register
		Mem_R_W <= '1';
		
		reg_address_A <= "00000";
		reg_address_B <= "00000";

		if (hazard_detected = '1' or reset = '1') then
		--push a bubble in pipeline
			--PC_ID <= PC_ID;
			PC_ID <= PC_IF;
			IR_ID <= (others => '0');
			-- Ensure that read results are returned on a rising edge
			Imm <= (others => '0');
			A <= (others => '0');
			B <= (others => '0');
		else
		--normal decode
			-- Move PC_IF to PC_ID and IR_IF to IR_ID after a cycle
			PC_ID <= PC_IF;
			IR_ID <= IR_IF;

			-- Ensure that read results are returned on a rising edge
			Imm <= Imm_temp;
			A <= A_temp;
			B <= B_temp;
		end if;
		
		s_hazard_detected <= hazard_detected;
		
	end if;
	end process;


	-- needs to be outside the process block to avoid excess delay
	A_temp <= reg_output_A;
	B_temp <= reg_output_B;

end behavior;