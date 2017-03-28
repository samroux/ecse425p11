-- @filename:	execution.vhd
-- @author:		William Bouchard (adapted from previous version by Po-Shiang)
-- @timestamp:	2017-03-28
-- @brief:		Execution stage. Includes the ALU and other operations done in this stage.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execution is
  port(
  	clock: in std_logic;
   	inst: in std_logic_vector(31 downto 0);
    PC_ID_EX: in std_logic_vector(11 downto 0);
    rs_from_ID: in std_logic_vector(31 downto 0);
    rt_from_ID: in std_logic_vector(31 downto 0);
    imm_sign_ext: in std_logic_vector(31 downto 0);
    
    PC_EX: out std_logic_vector(11 downto 0);
    ALUOutput: out std_logic_vector(31 downto 0) := (others => '0');
    MemRead : out std_logic;
    MemWrite : out std_logic;
    branch_taken_EX : out std_logic;
    B_EX : out std_logic_vector(31 downto 0);
    IR_EX : out std_logic_vector(31 downto 0)
  );
end execution;

-- R-type							I-type							J-type
-- opcode 	31 downto 26	6		opcode	31 downto 26	 6		opcode	31 downto 26	 6
-- rs 		25 downto 21	5		rs 		25 downto 21	 5		address 25 downto  0	26
-- rt 		20 downto 16	5		rt 		20 downto 16	 5
-- rd 		15 downto 11	5		imm 	15 downto  0	16
-- shamt 	10 downto  6	5
-- funct	 5 downto  0	6

-- add, sub, mult, div, slt 		addi, slti, andi, ori, xori		j, jal	
-- and, or, nor, xor 				lui, lw, sw, beq, bne
-- mflo, mfhi
-- sll, srl, sra, jr

architecture arch of execution is
begin

process(clock)

-- instruction tokens
variable opcode : std_logic_vector(5 downto 0);
variable rs : std_logic_vector(4 downto 0);
variable rt : std_logic_vector(4 downto 0);
variable rd : std_logic_vector(4 downto 0);
variable shamt : std_logic_vector(4 downto 0);
variable funct : std_logic_vector(5 downto 0);
variable address : std_logic_vector(25 downto 0);
variable shifted_address : std_logic_vector(25 downto 0);
variable shifted_imm :std_logic_vector(31 downto 0);

-- temporary variables for easy signal handling
variable should_branch : std_logic := '0';
variable should_read  : std_logic := '0';
variable should_write : std_logic := '0';

-- multiplications store results in two variables HI and LO,
-- accessed by mfhi and mflo. These are implemented here as
-- variables, and not registers.
variable HI : std_logic_vector(31 downto 0) := (others => '0');
variable LO : std_logic_vector(31 downto 0) := (others => '0');
variable mult_result : std_logic_vector(63 downto 0); -- hi (63 downto 32), lo (31 downto 0)

variable inst_type : integer; -- 0=R, 1=I, 2=J

begin
	if rising_edge(clock) then
		opcode := inst(31 downto 26);
		should_branch := '0';
		should_read  := '0';
		should_write := '0';
		
		-- find the type of operation and allocate necessary variables
		if (opcode = "000000") then -- R-type
			inst_type := 0;
			rs := inst(25 downto 21);
			rt := inst(20 downto 16);
			rd := inst(15 downto 11);
			shamt := inst(10 downto 6);
			funct := inst(5 downto 0);
		elsif (opcode = "000010" OR opcode = "000011") then -- J-type
			inst_type := 2;
			address := inst(25 downto 0);
		else -- I-type
			inst_type := 1;
			rs := inst(25 downto 21);
			rt := inst(20 downto 16);
			-- use the sign-extended immediate
		end if;

		-- execute the instruction
		if (inst_type = 0) then -- R-type
			-- R-types all have opcode = 000000, switch on funct
			case (funct) is
			when "001000" => -- jr
				ALUOutput <= rs_from_ID;
				should_branch := '1';
			
			when "000000" => -- sll
				ALUOutput <=  std_logic_vector(shift_left(unsigned(rt_from_ID), to_integer(unsigned(shamt))));
			
			when "000010" => -- srl
				ALUOutput <= std_logic_vector(shift_right(unsigned(rt_from_ID), to_integer(unsigned(shamt))));
			
			when "000011" => -- sra
				ALUOutput <= std_logic_vector(shift_right(signed(rt_from_ID), to_integer(unsigned(shamt))));
			
			when "011000" => -- mult
				mult_result := std_logic_vector(unsigned(rs_from_ID) * unsigned(rt_from_ID));
				LO := mult_result(63 downto 32);
				HI := mult_result(31 downto 0);
				ALUOutput <= (others => '0'); -- result accessed through mfhi, mflo
			
			when "011010" => -- div
				LO := std_logic_vector(unsigned(rs_from_ID)  /  unsigned(rt_from_ID));
				HI := std_logic_vector(unsigned(rs_from_ID) rem unsigned(rt_from_ID));
				ALUOutput <= (others => '0');
			
			when "010000" => -- mfhi
				ALUOutput <= HI;
			when "010010" => -- mflo
				ALUOutput <= LO;
			
			when "100000" => -- add
				ALUOutput <= std_logic_vector(unsigned(rs_from_ID) + unsigned(rt_from_ID));
			when "100010" => -- sub
				ALUOutput <= std_logic_vector(unsigned(rs_from_ID) - unsigned(rt_from_ID));
			
			when "101010" => -- slt
				if (signed(rs_from_ID) < signed(rt_from_ID)) then
					ALUOutput <= (0 => '1', others => '0');
				else
					ALUOutput <= (others => '0');
				end if;
			
			when "100100" => -- and
				ALUOutput <= rs_from_ID AND rt_from_ID;
			when "100101" => -- or
				ALUOutput <= rs_from_ID OR  rt_from_ID;
			when "100110" => -- xor
				ALUOutput <= rs_from_ID XOR rt_from_ID;
			when "100111" => -- nor
				ALUOutput <= rs_from_ID NOR rt_from_ID;
			when others =>
				ALUOutput <= (others => '0');
			end case;

		elsif (inst_type = 1) then -- I-type
			case(opcode) is 
			when "001000" => -- addi
				ALUOutput <= std_logic_vector(to_signed(to_integer(signed(rs_from_ID)) + to_integer(signed(imm_sign_ext)), 32));

			when "000100" => -- beq
				if (rs_from_ID = rt_from_ID) then
					should_branch := '1';
					shifted_imm := std_logic_vector(shift_left(signed(imm_sign_ext), 2));
					ALUOutput(31 downto 12) <= (others => '0');
					ALUOutput(11 downto 0)  <= std_logic_vector(unsigned(PC_ID_EX) + unsigned(shifted_imm(11 downto 0)));
				else
					ALUOutput <= (others => '0');
				end if;
			when "000101" => -- bne
				if (rs_from_ID /= rt_from_ID) then
					should_branch := '1';
					shifted_imm := std_logic_vector(shift_left(signed(imm_sign_ext), 2));
					ALUOutput(31 downto 12) <= (others => '0');
					ALUOutput(11 downto 0)  <= std_logic_vector(unsigned(PC_ID_EX) + unsigned(shifted_imm(11 downto 0)));
				else
					ALUOutput <= (others => '0');
				end if;

			when "100011" => -- lw
				ALUOutput <= std_logic_vector(unsigned(rs_from_ID) + unsigned(imm_sign_ext));
				should_read  := '1';
				should_write := '0';
			when "101011" => -- sw
				ALUOutput <= std_logic_vector(unsigned(rs_from_ID) + unsigned(imm_sign_ext));
				should_read  := '0';
				should_write := '1';

			when "001111" => -- lui
				ALUOutput <= std_logic_vector(shift_left(signed(imm_sign_ext), 16));
			when "001010" => -- slti
				if (signed(rs_from_ID) < signed(imm_sign_ext)) then
					ALUOutput <= (0 => '1', others => '0');
				else
					ALUOutput <= (others => '0');
				end if;

			when "001100" => -- andi
				ALUOutput <= rs_from_ID AND imm_sign_ext;
			when "001101" => -- ori
				ALUOutput <= rs_from_ID OR  imm_sign_ext;
			when "001110" => -- xori
				ALUOutput <= rs_from_ID XOR imm_sign_ext;
			when others =>
				ALUOutput <= (others => '0');
			end case;

		elsif (inst_type = 2) then -- J-type
			-- j and jal (see WB stage for writing to $31)
			should_branch := '1';
			
			-- our pipeline supports 1024 insts, so we use a 12-bit PC
			-- assume the jump instruction does not try to jump beyond that
			shifted_address := std_logic_vector(shift_left(signed(address), 2));
			ALUOutput(31 downto 12) <= (others => '0');
			ALUOutput(11 downto 0)  <= PC_ID_EX(11 downto 8) & shifted_address(7 downto 0);
		end if;


		-- outputs (some are simply moved through from a cycle to the next)
		branch_taken_EX <= should_branch;
		MemRead <= should_read;
		MemWrite <= should_write;
		PC_EX <= PC_ID_EX;  -- if PC needs to be updated (i.e. in case of branch), 
							-- the ALUOutput contains that address. MEM contains that logic.
		B_EX <= rt_from_ID;
		IR_EX <= inst;
	end if;
end process;

end arch;