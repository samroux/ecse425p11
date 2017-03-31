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
		
		WB_dest_reg : out std_logic_vector(4 downto 0);
		WB_output : out std_logic_vector(31 downto 0)
		
   );
end entity write_back;

architecture behaviour of write_back is

--signal s_WB_dest_reg : std_logic_vector(4 downto 0) := (others=>'0');
--signal s_WB_output : std_logic_vector(31 downto 0);

--signal instruction_type : std_logic := '0';
--signal is_load : std_logic := '0';
--signal opcode_it : std_logic_vector (5 downto 0):= (others=>'0');
--signal opcode_o : std_logic_vector (5 downto 0):= (others=>'0');
--signal rt : std_logic_vector(4 downto 0):= (others=>'0');
--signal rd : std_logic_vector(4 downto 0):= (others=>'0');



-- Function to determine type of instruction. Either (load or immediate) or ALU with Reg-Reg operation
--function opcode_to_instruction_type(opcode : std_logic_vector(5 downto 0))
--              return std_logic is
--begin
--  if (	opcode = "001000" or	--addi
--		opcode = "001010" or 	--slti
--		opcode = "001100" or 	--andi
--		opcode = "001101" or 	--ori
--		opcode = "001110" or 	--xori
--		opcode = "001111" or	--lui
--		opcode = "100011"		--lw
--		)then
--    return '1'; --instruction of type ALU immediate or load
--  else
--    return '0';
--  end if;
--end opcode_to_instruction_type;

function is_load_instruction (opcode : std_logic_vector(5 downto 0))
              return std_logic is
begin
	if (opcode = "001111" or	-- lui
		opcode = "100011" or	-- lw
		opcode = "000011"		-- jal; not a load but a special case where LMD holds PC+8
		) then
  		return '1'; --instruction of type load
  	else
    	return '0';
	end if;
end is_load_instruction;			  

begin

	--Process Defining the MUX choosing the destination register
	MUX_instruction_type: process(clock)
	variable op : std_logic_vector(5 downto 0);
	variable rt : std_logic_vector(4 downto 0) := (others=>'0');
	variable rd : std_logic_vector(4 downto 0) := (others=>'0');
	variable v_WB_dest_reg : std_logic_vector(4 downto 0) := (others => '0');
	variable instruction_type : std_logic;

	begin
	if (rising_edge(clock)) then
		-- Separate instruction in tokens
		op := IR_reg(31 downto 26);
		rt := IR_reg(20 downto 16); --for immediate or load
		rd := IR_reg(15 downto 11);	--for ALU op type RegReg

		--report "IR_Reg: "&integer'image(to_integer(unsigned(IR_reg(31 downto 26))));	
		--report "op: "&integer'image(to_integer(unsigned(op)));
		--report "opcode_it: "&integer'image(to_integer(unsigned(opcode_it)));
		--instruction_type := opcode_to_instruction_type(op);	--get type of instruction to defin register

		--select register
		if (rd = "UUUUU") then
			v_WB_dest_reg := "00000"; 	-- write to $0 (null) as default
		elsif (op = "000011") then		
			v_WB_dest_reg := "11111"; 	-- jal writes back PC+8 in $31
		elsif (op = "000000") then
			v_WB_dest_reg := rd;		-- rd for ALU reg-reg operations; R-types have opcode = "000000"
		else
			v_WB_dest_reg := rt;		-- rt for immediate and load instrcutions	
		end if;

		WB_dest_reg <= v_WB_dest_reg;
	end if;
	end process;
   
   --Process defining the MUX choosing the main output of WB stage
	MUX_output: process(clock)
	variable op : std_logic_vector(5 downto 0);
	variable v_WB_output : std_logic_vector(31 downto 0) := (others => '0');
	variable is_load : std_logic := '0';

	begin
	if (rising_edge(clock)) then
		-- Separate instruction in tokens
		op := IR_reg(31 downto 26);
		
		is_load := is_load_instruction(op);	--test whether instruction is of type load
				
		--select output
		if (is_load = '1') then
			v_WB_output := LMD;
		else
			v_WB_output := ALUOutput;
		end if;

		WB_output <= v_WB_output;
	end if;
	end process;

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




