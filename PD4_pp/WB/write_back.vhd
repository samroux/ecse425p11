-- @filename write_back.vhd
-- @author Samuel Date
-- @timestamp 2017-03-15 12:15 PM
-- @brief vhdl entity defining the write back stage of pipelined processor

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity write_back is
   port (
   		clock : in std_logic;
		
		IR_reg : in std_logic_vector(31 downto 0);		--instruction following thru from IF and out of MEM/WB register
		LMD : in std_logic_vector(31 downto 0);			-- Load Memory Data	
		ALUOutput : in std_logic_vector(31 downto 0);	-- ALU Output
		
		IR_dest_reg : out std_logic_vector(4 downto 0);
		WB_output : out std_logic_vector(31 downto 0)
		
   );
end entity write_back;

architecture behaviour of write_back is

signal s_IR_dest_reg : std_logic_vector(4 downto 0) := (others=>'0');
signal s_WB_output : std_logic_vector(31 downto 0);

signal instruction_type : std_logic := '0';
signal is_load : std_logic := '0';
signal opcode_it : std_logic_vector (5 downto 0):= (others=>'0');
signal opcode_o : std_logic_vector (5 downto 0):= (others=>'0');
signal rt : std_logic_vector(4 downto 0):= (others=>'0');
signal rd : std_logic_vector(4 downto 0):= (others=>'0');



-- Function to determine type of instruction. Either (load or immediate) or ALU with Reg-Reg operation
function opcode_to_instruction_type(opcode : std_logic_vector(5 downto 0))
              return std_logic is
begin
  if (	opcode = "001000" or	--addi
		opcode = "001010" or 	--slti
		opcode = "001100" or 	--andi
		opcode = "001101" or 	--ori
		opcode = "001110" or 	--xori
		opcode = "001111" or	--lui
		opcode = "100011"		--lw
		)then
    return '1'; --instruction of type ALU immediate or load
  else
    return '0';
  end if;
end opcode_to_instruction_type;

function is_load_instruction (opcode : std_logic_vector(5 downto 0))
              return std_logic is
begin
  if (	opcode = "001111" or	--lui
		opcode = "100011"		--lw
		)then
    return '1'; --instruction of type load
  else
    return '0';
  end if;
end is_load_instruction;			  

begin

	MUX_instruction_type: process(clock)
	--Process Defining the MUX choosing the destination register
	variable op : std_logic_vector(5 downto 0);
	begin
      if (rising_edge(clock)) then
		
		-- Separate instruction in tokens
		op := IR_reg(31 downto 26);
		rt <= IR_reg(20 downto 16); --for immediate or load
		rd <= IR_reg(15 downto 11);	--for ALU op type RegReg
		
		--report "IR_Reg: "&integer'image(to_integer(unsigned(IR_reg(31 downto 26))));
		
		
		--report "op: "&integer'image(to_integer(unsigned(op)));
		--report "opcode_it: "&integer'image(to_integer(unsigned(opcode_it)));
		
		instruction_type <= opcode_to_instruction_type(op);	--get type of instruction to defin register
		
		-- if (op = "001000" or	--addi
			-- op = "001010" or 	--slti
			-- op = "001100" or 	--andi
			-- op = "001101" or 	--ori
			-- op = "001110" or 	--xori
			-- op = "001111" or	--lui
			-- op = "100011"		--lw
			-- )then
			-- instruction_type <= '1'; --instruction of type ALU immediate or load
			-- --REPORT "Instruction Type should be set now";
		-- else
			-- instruction_type <= '0';
			-- --REPORT "Instruction Type NOT set";
		-- end if;
		
		--select register
		if(instruction_type = '1') then
			s_IR_dest_reg <= rt;	-- rt for immediare and load instrcutions
		
		else
			s_IR_dest_reg <= rd;	-- rd for ALU reg-reg operations
			
		end if;
		
      end if;
	end process;
   
	MUX_output: process(clock)
	--Process defining the MUX choosing the main output of WB stage
	variable opcode : std_logic_vector(5 downto 0);
	begin
		if (rising_edge(clock)) then
		
			-- Separate instruction in tokens
			opcode := IR_reg(31 downto 26);
			
			is_load <= is_load_instruction(opcode);	--get if instrcution is of type load
			
			-- if (	opcode_o = "001111" or	--lui
					-- opcode_o = "100011"		--lw
				-- )then
				-- is_load <= '1';
			-- else
				-- is_load <= '0';
			-- end if;
				
			
			--select output
			if(is_load = '1') then
				s_WB_output <= LMD;
			
			else
				s_WB_output <= ALUOutput;
			end if;
		end if;
	end process;
	
	WB_output <= s_WB_output;
	IR_dest_reg <= s_IR_dest_reg;


end architecture behaviour;


-- ALUoutput for opcode:
--add
--sub
--mult
-- ....

--LDM for opcode:
--lw
--lui


--Destination register field:
---- rt (imediate operation)----
--addi	(0x0008) -> 00 1000
--slti	(0x000A) -> 00 1010
--andi	(0x000C) ->	00 1100
--ori	(0x000D) ->	00 1101
--xori	(0x000E) -> 00 1110
--lui	(0x000F) -> 00 1111
	
--rd




