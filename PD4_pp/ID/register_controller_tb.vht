-- @filename:	register_controller_tb.vht
-- @author:		William Bouchard
-- @timestamp:	2017-03-15
-- @brief:		Test bench for the register controller, which wraps the register
--				file and is responsible for both ID and WB interactions.
--				Used with test_decode.asm and its compiled program.txt

library ieee;                                               
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;                               

entity register_controller_tb is
end register_controller_tb;

architecture register_controller_arch of register_controller_tb is
           
    -- test signals                                     
	signal clock : std_logic;
	signal IR_IF : std_logic_vector(31 downto 0);
	signal WB_addr : std_logic_vector(4 downto 0);
	signal WB_return : std_logic_vector(31 downto 0);

	signal opcode : std_logic_vector(5 downto 0);
	signal A : std_logic_vector(31 downto 0);
	signal B : std_logic_vector(31 downto 0);
	signal Imm : std_logic_vector(31 downto 0);
	signal branchTaken : std_logic;

	constant clock_period : time := 1 ns;

	-- component to be tested
	component register_controller
		port (
			clock : in std_logic;
			IR_IF : in std_logic_vector(31 downto 0);
			WB_addr : in std_logic_vector(4 downto 0);
			WB_return : in std_logic_vector(31 downto 0);

			opcode : out std_logic_vector(5 downto 0);
			A : out std_logic_vector(31 downto 0);
			B : out std_logic_vector(31 downto 0);
			Imm : out std_logic_vector(31 downto 0);
			branchTaken : out std_logic
		);
	end component;

	begin
		-- map test signals to component in/out
		rc : register_controller
		port map (
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

		-- continuous clock process
		clock_process : process
		begin
  			clock <= '0';
  			wait for clock_period/2;
  			clock <= '1';
  			wait for clock_period/2;
		end process;

		generate_test : process                                           
		begin
			report "Initial state";
			IR_IF <= "00000000000000000000000000000000";
			WB_addr <= "00000";
			WB_return <= "00000000000000000000000000000000";
			wait for clock_period - clock_period/10;

			report "--- Instruction 1: addi $11, $0, 5 ---";
			report "Testing ID stage of inst 1";
			report "______";
			IR_IF <= "00100000000010110000000000000101";
			wait for clock_period/10;
			wait for clock_period/2; -- 1/2 cycle
			assert (opcode = "001000") severity ERROR;
			assert (A = "00000000000000000000000000000000") severity ERROR; 	-- $11
			assert (B = "00000000000000000000000000000000") severity ERROR; 	-- $0
			assert (Imm = "00000000000000000000000000000101") severity ERROR; 	-- 5
			assert (branchTaken = '0') severity ERROR;
			wait for clock_period/2; -- end of cycle

			report "--- Instruction 2: addi $12, $0, 6 ---";
			report "Testing ID stage of inst 2";
			IR_IF <= "00100000000011000000000000000110";
			wait for clock_period/2; -- 1/2 cycle
			assert (opcode = "001000") severity ERROR;
			assert (A = "00000000000000000000000000000000") severity ERROR; 	-- $12
			assert (B = "00000000000000000000000000000000") severity ERROR; 	-- $0
			assert (Imm = "00000000000000000000000000000110") severity ERROR; 	-- 6
			assert (branchTaken = '0') severity ERROR;

			report "Testing WB stage of inst 1 (same cycle as inst 2 ID)";
			WB_addr <= "01011"; --11 
			WB_return <= "00000000000000000000000000000101"; -- 5
			wait for clock_period/2; -- end of cycle
			-- cannot assert; check value of reg_address and reg_write_input signals
			-- since register_file is known to work.

			report "Testing WB stage of inst 2 (different cycle)";
			WB_addr <= "01100";
			WB_return <= "00000000000000000000000000000110"; -- 6
			wait for clock_period;

			report "--- Instruction 3: add $2, $11, $12";
			report "Testing ID stage of inst 3";
			IR_IF <= "00000001011011000001000000100000";
			wait for clock_period/2; -- 1/2 cycle
			assert (opcode = "000000") severity ERROR;
			assert (A = "00000000000000000000000000000101") severity ERROR; 	-- $11
			assert (B = "00000000000000000000000000000110") severity ERROR; 	-- $12
			-- don't care about Imm here
			assert (branchTaken = '0') severity ERROR;

			-- TODO: move WB of inst 2 here to test for data hazard


		wait;                                                        
	end process generate_test;                                     
end register_controller_arch;