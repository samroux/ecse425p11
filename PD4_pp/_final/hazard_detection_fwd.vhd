-- @filename hazard_detection_fwd.vhd
-- @author Samuel Roux
-- @timestamp 2017-04-5 3:33 PM
-- @brief vhdl entity defining the hazard detection and forwarding block

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity hazard_detection_fwd is
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
end entity hazard_detection_fwd;

architecture behaviour of hazard_detection_fwd is

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


	process (clock)
	
	--var for IR_IF_ID
	variable opcode_if_id : std_logic_vector(5 downto 0);
	variable rs_if_id : std_logic_vector(4 downto 0);
	variable rt_if_id : std_logic_vector(4 downto 0);
	variable rd_if_id : std_logic_vector(4 downto 0);
	variable inst_type_if_id : integer; -- 0=R, 1=I
	
	--var for IR_ID_EX
	variable opcode_id_ex : std_logic_vector(5 downto 0);
	variable rs_id_ex : std_logic_vector(4 downto 0);
	variable rt_id_ex : std_logic_vector(4 downto 0);
	variable rd_id_ex : std_logic_vector(4 downto 0);
	variable inst_type_id_ex : integer; -- 0=R, 1=I;
	
	--var for IR_EX_MEM
	variable opcode_ex_mem : std_logic_vector(5 downto 0);
	variable rs_ex_mem : std_logic_vector(4 downto 0);
	variable rt_ex_mem : std_logic_vector(4 downto 0);
	variable rd_ex_mem : std_logic_vector(4 downto 0);
	variable inst_type_ex_mem : integer; -- 0=R, 1=I;
	
	--var for IR_MEM_WB
	variable opcode_mem_wb : std_logic_vector(5 downto 0);
	variable rs_mem_wb : std_logic_vector(4 downto 0);
	variable rt_mem_wb : std_logic_vector(4 downto 0);
	variable rd_mem_wb : std_logic_vector(4 downto 0);
	variable inst_type_mem_wb : integer; -- 0=R, 1=I;

	
	
	variable v_hazard_detected : std_logic;
	variable v_fwd_required : std_logic;
	
	--Value fwd
	variable v_fwd_aluoutput_ex_mem : std_logic;
	variable v_fwd_aluoutput_mem_wb : std_logic;
	variable v_fwd_lmd_mem_wb : std_logic;
	
	--ALU input fwd
	variable v_fwd_top : std_logic;
	variable v_fwd_bottom : std_logic;
	
	begin
		if falling_edge (clock) then
			--hazard detection--
			opcode_if_id := IR_IF_ID (31 downto 26);
			opcode_id_ex := IR_ID_EX (31 downto 26);
			opcode_ex_mem:= IR_EX_MEM (31 downto 26);
			opcode_mem_wb := IR_MEM_WB (31 downto 26);
			
			--decoding instruction in if_id
			if ( opcode_if_id = "000000") then -- R-type
				inst_type_if_id := 0;
				rs_if_id := IR_IF_ID (25 downto 21);
				rt_if_id := IR_IF_ID (20 downto 16);
				rd_if_id := IR_IF_ID (15 downto 11);
			else -- I-type
				inst_type_if_id := 1;
				rs_if_id := IR_IF_ID (25 downto 21);
				rt_if_id := IR_IF_ID (20 downto 16);
			end if;
			
			--decoding instruction in id_ex
			if ( opcode_id_ex = "000000") then -- R-type
				inst_type_id_ex := 0;
				rs_id_ex := IR_ID_EX (25 downto 21);
				rt_id_ex := IR_ID_EX (20 downto 16);
				rd_id_ex := IR_ID_EX (15 downto 11);
			else -- I-type
				inst_type_id_ex := 1;
				rs_id_ex := IR_ID_EX (25 downto 21);
				rt_id_ex := IR_ID_EX (20 downto 16);
			end if;
			
			--decoding instruction in ex_mem
			if ( opcode_ex_mem = "000000") then -- R-type
				inst_type_ex_mem := 0;
				rs_ex_mem := IR_EX_MEM (25 downto 21);
				rt_ex_mem := IR_EX_MEM (20 downto 16);
				rd_ex_mem := IR_EX_MEM (15 downto 11);
			else -- I-type
				inst_type_ex_mem := 1;
				rs_ex_mem := IR_EX_MEM (25 downto 21);
				rt_ex_mem := IR_EX_MEM (20 downto 16);
			end if;
			
			--decoding instruction in mem_wb
			if ( opcode_mem_wb = "000000") then -- R-type
				inst_type_mem_wb := 0;
				rs_mem_wb := IR_MEM_WB (25 downto 21);
				rt_mem_wb := IR_MEM_WB (20 downto 16);
				rd_mem_wb := IR_MEM_WB (15 downto 11);
			elsif ( is_load_instruction( opcode_mem_wb ) = '1' ) then
				inst_type_mem_wb := 1;
				rs_mem_wb := IR_MEM_WB (25 downto 21);
				rt_mem_wb := IR_MEM_WB (20 downto 16);
			else -- I-type
				if ( is_load_instruction( opcode_mem_wb ) = '1' ) then
					inst_type_mem_wb := 2; --this is a load
				else
					inst_type_mem_wb := 1;
				end if;
				rs_mem_wb := IR_MEM_WB (25 downto 21);
				rt_mem_wb := IR_MEM_WB (20 downto 16);
			end if;
			
		------------------------------------------------
		------------	  HAZARD DETECT     ------------
		------------------------------------------------
		
			--check if there's an hazard or not
			if (inst_type_id_ex = 0) then
				--r-type
				if (inst_type_if_id = 0) then
					--r-type
					if (rd_id_ex = "00000" or rd_id_ex = "UUUUU") then
						v_hazard_detected := '0';
					elsif ( rd_id_ex = rs_if_id ) then
						v_hazard_detected := '1';
					elsif ( rd_id_ex = rt_if_id ) then
						v_hazard_detected := '1';
					else
						v_hazard_detected := '0';
					end if;
				elsif (inst_type_if_id = 1 ) then
					--i-type
					if (rd_id_ex = "00000" or rd_id_ex = "UUUUU") then
						v_hazard_detected := '0';
					elsif ( rd_id_ex = rt_if_id ) then
						v_hazard_detected := '1';
					else
						v_hazard_detected := '0';
					end if;
				end if;
			elsif (inst_type_id_ex = 1) then
				--i-type
				if (inst_type_if_id = 0) then
					--r-type
					if (rt_id_ex = "00000" or rt_id_ex = "UUUUU") then
						v_hazard_detected := '0';
					elsif ( rt_id_ex = rs_if_id ) then
						v_hazard_detected := '1';
					elsif ( rt_id_ex = rt_if_id ) then
						v_hazard_detected := '1';
					else
						v_hazard_detected := '0';
					end if;
				elsif (inst_type_if_id = 1 ) then
					--i-type
					if (rt_id_ex = "00000" or rt_id_ex = "UUUUU") then
						v_hazard_detected := '0';
					elsif ( rt_id_ex = rs_if_id ) then
						v_hazard_detected := '1';
					else
						v_hazard_detected := '0';
					end if;
				end if;
			end if;
			
			hazard_detected <= v_hazard_detected;

			
		------------------------------------------------
		------------		FORWARDING		------------
		------------------------------------------------
		
			--check if forwarding is required or not
			if (inst_type_id_ex = 0) then
				--r-type
				
				--Source is EX/MEM
				if (inst_type_ex_mem = 0) then
					--r-type
					if (rd_ex_mem = "00000" or rd_ex_mem = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rd_ex_mem = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_ex_mem := '1';
						--fwd ALUOUTPUT EX/MEM to top
					elsif ( rd_ex_mem = rt_id_ex ) then
						v_fwd_required := '1';
						v_fwd_bottom := '1';
						v_fwd_aluoutput_ex_mem := '1';
						--fwd ALUOUTPUT EX/MEM to bottom
					else
						v_fwd_required := '0';
					end if;
				elsif (inst_type_ex_mem = 1 ) then
					--i-type
					if (rt_ex_mem = "00000" or rt_ex_mem = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rt_ex_mem = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_ex_mem := '1';
						--fwd ALUOUTPUT EX/MEM to top
					elsif ( rt_ex_mem = rt_id_ex ) then
						v_fwd_required := '1';
						v_fwd_bottom := '1';
						v_fwd_aluoutput_ex_mem := '1';
						--fwd ALUOUTPUT EX/MEM to bottom
					else
						v_fwd_required := '0';
					end if;
				end if;
				
				--Source is MEM/WB
				if (inst_type_mem_wb = 0) then
					--r-type
					if (rd_mem_wb = "00000" or rd_mem_wb = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rd_mem_wb = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to top
					elsif ( rd_mem_wb = rt_id_ex ) then
						v_fwd_required := '1';
						v_fwd_bottom := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to bottom
					else
						v_fwd_required := '0';
					end if;
				elsif (inst_type_mem_wb = 1 ) then
					--i-type
					if (rt_mem_wb = "00000" or rt_mem_wb = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rt_mem_wb = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to top
					elsif ( rt_mem_wb = rt_id_ex ) then
						v_fwd_required := '1';
						v_fwd_bottom := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to bottom
					else
						v_fwd_required := '0';
					end if;
				elsif (inst_type_mem_wb = 2 ) then
					--load
					if (rt_mem_wb = "00000" or rt_mem_wb = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rt_mem_wb = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_lmd_mem_wb := '1';
						--fwd LMD MEM/WB to top
					elsif ( rt_mem_wb = rt_id_ex ) then
						v_fwd_required := '1';
						v_fwd_bottom := '1';
						v_fwd_lmd_mem_wb := '1';
						--fwd LMD MEM/WB to bottom
					else
						v_fwd_required := '0';
					end if;	
				end if;
				
			elsif (inst_type_id_ex = 1) then
				--i-type
				
					--Source is EX/MEM
				if (inst_type_ex_mem = 0) then
					--r-type
					if (rd_ex_mem = "00000" or rd_ex_mem = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rd_ex_mem = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to top
					else
						v_fwd_required := '0';
					end if;
				elsif (inst_type_ex_mem = 1 ) then
					--i-type
					if (rt_ex_mem = "00000" or rt_ex_mem = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rt_ex_mem = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to top
					else
						v_fwd_required := '0';
					end if;
				end if;
				
				--Source is MEM/WB
				if (inst_type_mem_wb = 0) then
					--r-type
					if (rd_mem_wb = "00000" or rd_mem_wb = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rd_mem_wb = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to top
					else
						v_fwd_required := '0';
					end if;
				elsif (inst_type_mem_wb = 1 ) then
					--i-type
					if (rt_mem_wb = "00000" or rt_mem_wb = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rt_mem_wb = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_aluoutput_mem_wb := '1';
						--fwd ALUOUTPUT MEM/WB to top
					else
						v_fwd_required := '0';
					end if;
				elsif (inst_type_mem_wb = 2 ) then
					--load
					if (rt_mem_wb = "00000" or rt_mem_wb = "UUUUU") then
						v_fwd_required := '0';
					elsif ( rt_mem_wb = rs_id_ex ) then
						v_fwd_required := '1';
						v_fwd_top := '1';
						v_fwd_lmd_mem_wb := '1';
						--fwd LMD MEM/WB to top
					else
						v_fwd_required := '0';
					end if;
				end if;
				
				
			end if;
		fwd_required <= v_fwd_required;
		fwd_top <= v_fwd_top;
		fwd_bottom <= v_fwd_bottom;
		fwd_aluoutput_ex_mem <= v_fwd_aluoutput_ex_mem;
		fwd_aluoutput_mem_wb <= v_fwd_aluoutput_mem_wb;
		fwd_lmd_mem_wb <= v_fwd_lmd_mem_wb;
		end if;
	end process;

end architecture behaviour;