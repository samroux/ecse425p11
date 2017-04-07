-- @filename hazard_detection.vhd
-- @author Samuel Roux
-- @timestamp 2017-04-5 3:33 PM
-- @brief vhdl entity defining the hazard detection block

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity hazard_detection is
   port (
		clock : in std_logic;
		
		IR_IF_ID : in std_logic_vector(31 downto 0);
		IR_ID_EX : in std_logic_vector(31 downto 0);
		
		hazard_detected : out std_logic
   );
end entity hazard_detection;

architecture behaviour of hazard_detection is

begin


	process (clock)
	
	variable opcode_if_id : std_logic_vector(5 downto 0);
	variable rs_if_id : std_logic_vector(4 downto 0);
	variable rt_if_id : std_logic_vector(4 downto 0);
	variable rd_if_id : std_logic_vector(4 downto 0);
	variable inst_type_if_id : integer; -- 0=R, 1=I
	
	variable opcode_id_ex : std_logic_vector(5 downto 0);
	variable rs_id_ex : std_logic_vector(4 downto 0);
	variable rt_id_ex : std_logic_vector(4 downto 0);
	variable rd_id_ex : std_logic_vector(4 downto 0);
	variable inst_type_id_ex : integer; -- 0=R, 1=I;
	variable v_hazard_detected : std_logic;
	
	begin
		if rising_edge (clock) then
			--hazard detection--
			opcode_if_id := IR_IF_ID (31 downto 26);
			opcode_id_ex := IR_ID_EX (31 downto 26);
			
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
				-- use the sign-extended immediate
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
				-- use the sign-extended immediate
			end if;
			
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
		end if;
		hazard_detected <= v_hazard_detected;
	end process;

end architecture behaviour;