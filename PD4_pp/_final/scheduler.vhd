-- @filename scheduler.vhd
-- @author Samuel Roux and William Bouchard
-- @timestamp 2017-04-10
-- @brief vhdl entity defining the instruction scheduler. Which reads from I_M and return to I_F

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_textio.all;
USE ieee.numeric_std.all;
use STD.textio.all;
use work.common.all;	-- this is our common package

ENTITY scheduler IS
	GENERIC(
		ram_size : INTEGER := 1024;--1024 instructions
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		reset: IN STD_LOGIC;
		
		start_sch : IN std_logic;
		
		get_bubble_sch : in std_logic;
		
		address: in std_logic_vector(11 downto 0);
		inst_sch: out std_logic_vector(31 downto 0);
		done_sch: out std_logic
	);
END scheduler;

ARCHITECTURE behaviour OF scheduler IS

	SIGNAL s_raw_inst: MEM := ((others => (others => '0')));
	SIGNAL s_scheduled_inst: MEM := ((others => (others => '0')));
	
	--signal inst_is_in_a_dep_list : BUF := (others => -1);
	--SIGNAL candidate_list: BUF := (others => 0);
	--SIGNAL dib: BUF := (others => 0);	-- dependency_index_buffer: stores length of each dependency list
	--									-- used for more efficient loops
	--SIGNAL dependency_lists : MEM_SQUARE := ((others => (others => 0))); 	-- for each inst, store a list of all
	--																		-- instructions that depend on it
	signal s_inst_count: integer;
	signal s_ready: std_logic;
	signal get_bubble: std_logic;
	signal s_PC: std_logic_vector (11 downto 0) := (others => '0'); --initialize PC to 0
	signal s_IR : std_logic_vector (31 downto 0);
	
	file sch_file : text;

	
	component instruction_memory
	port (
		clock: in STD_LOGIC;
		reset : in STD_LOGIC;
		get_bubble : in std_logic;
		address: in std_logic_vector(11 downto 0);
		
		instruction: out std_logic_vector(31 downto 0);
		raw_inst: out MEM;
		ready : out std_logic;
		inst_count : out integer
	);
	end component;
	
	function check_dependency (IR_base:std_logic_vector(31 downto 0); IR_comp:std_logic_vector(31 downto 0) ) 
		return std_logic is
	
		--var for base instruction
		variable opcode_base : std_logic_vector(5 downto 0);
		variable rs_base : std_logic_vector(4 downto 0);
		variable rt_base : std_logic_vector(4 downto 0);
		variable rd_base : std_logic_vector(4 downto 0);
		variable inst_type_base : integer; -- 0=R, 1=I
		
		--var for compared instruction
		variable opcode_comp : std_logic_vector(5 downto 0);
		variable rs_comp : std_logic_vector(4 downto 0);
		variable rt_comp : std_logic_vector(4 downto 0);
		variable rd_comp : std_logic_vector(4 downto 0);
		variable inst_type_comp : integer; -- 0=R, 1=I;
		
		variable isDependent : std_logic := 'U';

		begin
			opcode_base := IR_base (31 downto 26);
			opcode_comp := IR_comp (31 downto 26);
			
			--decoding instruction base
			if (opcode_base = "UUUUUU") then 
				inst_type_base := -1;
			elsif ( opcode_base = "000000") then -- R-type
				inst_type_base := 0;
				rs_base := IR_base (25 downto 21);
				rt_base := IR_base (20 downto 16);
				rd_base := IR_base (15 downto 11);
			else -- I-type
				inst_type_base := 1;
				rs_base := IR_base (25 downto 21);
				rt_base := IR_base (20 downto 16);
			end if;
			
			--decoding compared instruction 
			if (opcode_base = "UUUUUU") then 
				inst_type_comp := -1;
			elsif ( opcode_comp = "000000") then -- R-type
				inst_type_comp := 0;
				rs_comp := IR_comp (25 downto 21);
				rt_comp := IR_comp (20 downto 16);
				rd_comp := IR_comp (15 downto 11);
			else -- I-type
				inst_type_comp := 1;
				rs_comp := IR_comp (25 downto 21);
				rt_comp := IR_comp (20 downto 16);
			end if;
			
			-- compare register destinations of both insts to find RAW, WAR, WAW
			if (inst_type_base < 0 OR inst_type_comp < 0) then -- one or both inst undefined
				isDependent := 'U';
			else	
				if 	(rs_base = rs_comp AND rs_base /= "00000") OR 
					(rs_base = rt_comp AND rs_base /= "00000") OR
					(rt_base = rs_comp AND rt_base /= "00000") OR
					(rt_base = rt_comp AND rt_base /= "00000") then
					isDependent := '1';
				end if;

				if (inst_type_base = 0) then -- base is an R-type; has rd
					if 	(rd_base = rs_comp AND rd_base /= "00000") OR
						(rd_base = rt_comp AND rd_base /= "00000") then
						isDependent := '1';
					end if;
				end if;

				if (inst_type_comp = 0) then -- comp is an R-type; has rd
					if 	(rs_base = rd_comp AND rs_base /= "00000") OR 
						(rt_base = rd_comp AND rt_base /= "00000") then
						isDependent := '1';
					end if;
				end if;

				if (inst_type_base = 0 and inst_type_comp = 0) then -- both have rd
					if (rd_base = rd_comp AND rd_base /= "00000") then
						isDependent := '1';
					end if;
				end if;

				if (isDependent = 'U') then -- no dependency has been found
					isDependent := '0';
				end if;
			end if;
			
		return isDependent;
	end check_dependency;

BEGIN

	IM: instruction_memory
	port map (
			clock,
			reset,
			get_bubble,
			s_PC,
			s_IR,
			s_raw_inst,
			s_ready,
			s_inst_count
		);

	scheduling : process (start_sch)
	
		variable loop_i_PC : STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
		--variable loop_j_PC : STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
		variable inst_base : STD_LOGIC_VECTOR (31 downto 0);
		variable inst_comp : STD_LOGIC_VECTOR (31 downto 0);
		variable isDependent : std_logic;
		
		variable v_PC_sch : STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
		variable v_scheduled_inst: MEM := ((others => (others => '0')));
		variable inst_number_raw: integer := 0;
		
		variable inst_write : std_logic_vector (31 downto 0);
		variable inst_number_sch : integer := 0;
		variable line_to_write : line;
		
		variable inst_is_in_a_dep_list : BUF := (others => 0);
		variable candidate_list: BUF := (others => 0);  -- queue that contains the candidate insts to be placed in the
														-- rescheduled inst file, in order. FIFO. the queue grows as dependencies diminish

		variable dib: BUF := (others => 0);				-- dependency_index_buffer: stores length of each dependency list
														-- used for more efficient loops

		variable dependency_lists : MEM_SQUARE := ((others => (others => 0))); 	-- for each inst, store a list of all
																				-- instructions that depend on it

		variable candidate_list_counter : integer := 0;
	begin
		if(start_sch = '1' ) then
		
			report "\/\/\/                           \/\/\/";
			report "\/\/\/     START DEP FINDING     \/\/\/";
			report "\/\/\/                           \/\/\/";

			-- build Dependency lists (Stored into Dependency memory) & store each list's length in DIB for each instruction
			for I in 0 to s_inst_count-1 loop
				inst_base(31 downto 24) := s_raw_inst(to_integer(unsigned(loop_i_PC)));
				inst_base(23 downto 16) := s_raw_inst(to_integer(unsigned(loop_i_PC)) + 1);
				inst_base(15 downto 8)  := s_raw_inst(to_integer(unsigned(loop_i_PC)) + 2);
				inst_base(7 downto 0)   := s_raw_inst(to_integer(unsigned(loop_i_PC)) + 3);
				
				for J in I+1 to s_inst_count-1 loop -- through all insts after I 
					inst_comp(31 downto 24) := s_raw_inst(J * 4);		-- PC of an inst = (inst #) times (4 bytes)
					inst_comp(23 downto 16) := s_raw_inst((J * 4) + 1);
					inst_comp(15 downto 8)  := s_raw_inst((J * 4) + 2);
					inst_comp(7 downto 0)   := s_raw_inst((J * 4) + 3);
					
					isDependent := check_dependency (inst_base, inst_comp);
					report "\/\/\/ for I = "&integer'image(I)&" and J = "&integer'image(J)&" isDependent = "&std_logic'image(isDependent)&"    \/\/\/";
					if (isDependent = '1') then
						dependency_lists(I)(dib(I)) := J;
						report "\/\/\/ dep_list(I)(dib(I)) @["&integer'image(I)&", "&integer'image(dib(I))&"] is set to "&integer'image(dependency_lists(I)(dib(I)))&"    \/\/\/";
						dib(I) := dib(I) + 1;
					end if;
	
				end loop;
				loop_i_PC := std_logic_vector(unsigned(loop_i_PC) + "000000000100");
			end loop;
			
			-- count the number of instructions that depend on each instruction
			for K in 0 to s_inst_count-1 loop 	--where K is instruction number
				for L in 0 to dib(K)-1 loop 	--where L is the index in dependency list
					-- increase dependency counter of the inst at L, which is in the list of inst K
					report "\/\/\/ dep_list(K)(L) @["&integer'image(K)&", "&integer'image(L)&"] = "&integer'image(dependency_lists(K)(L))&"    \/\/\/";
					
					inst_is_in_a_dep_list(dependency_lists(K)(L)) := (inst_is_in_a_dep_list(dependency_lists(K)(L)) + 1);
				end loop;		
			end loop;
			
			--initialize candidate list
			for M in 0 to s_inst_count-1 loop
				report "\/\/\/ "&integer'image(inst_is_in_a_dep_list(M))&" instruction(s) depend on instruction #"&integer'image(M)&"    \/\/\/";
				if (inst_is_in_a_dep_list(M) = 0) then
					candidate_list(candidate_list_counter) := M;

					report "\/\/\/ candidate_list["&integer'image(candidate_list_counter)&"] is set to "&integer'image(M)&" -- no insts depend on this"&"    \/\/\/";
					candidate_list_counter := candidate_list_counter + 1;

					-- made it to candidate list -- set to -1 to avoid  dealing with this inst again
					inst_is_in_a_dep_list(M) := -1;
				end if;
			end loop;
			
			report "\/\/\/                           \/\/\/";
			report "\/\/\/    START INST SCHEDULE    \/\/\/";
			report "\/\/\/                           \/\/\/";
			v_PC_sch := (others=>'0');
			
			-- report initial candidate list
			for X in 0 to candidate_list_counter-1 loop
				report "\/\/\/ initial candidate_list["&integer'image(X)&"] = "&integer'image(candidate_list(X))&"    \/\/\/";
			end loop;

			while (candidate_list_counter /= 0) loop
				--get first element in candidate_list and store as next instruction in scheduled inst
				inst_number_raw := candidate_list(0);
				
				--store in scheduled inst
				v_scheduled_inst(to_integer(unsigned(v_PC_sch))) := s_raw_inst (inst_number_raw * 4);
				v_scheduled_inst(to_integer(unsigned(v_PC_sch)) + 1) := s_raw_inst ((inst_number_raw * 4) +1);
				v_scheduled_inst(to_integer(unsigned(v_PC_sch)) + 2) := s_raw_inst ((inst_number_raw * 4) +2);
				v_scheduled_inst(to_integer(unsigned(v_PC_sch)) + 3) := s_raw_inst ((inst_number_raw * 4) +3);
				
				-- shift candidate list left
				for N in 1 to s_inst_count-1 loop
					candidate_list(N-1) := candidate_list(N); 
				end loop;
				candidate_list (candidate_list_counter) := -1; 
				candidate_list_counter := candidate_list_counter - 1;
				
				---- report shifted candidate list
				--for Y in 0 to candidate_list_counter-1 loop
				--	report "\/\/\/ shifted candidate_list["&integer'image(Y)&"] = "&integer'image(candidate_list(Y))&"    \/\/\/";
				--end loop;
				
				-- instructions that dependended on inst_raw are now free to be candidates, as inst_raw has been scheduled
				for P in 0 to dib(inst_number_raw)-1 loop
					--where P is the element's position in inst_raw's dependency list
					inst_is_in_a_dep_list(dependency_lists(inst_number_raw)(P)) := inst_is_in_a_dep_list(dependency_lists(inst_number_raw)(P)) - 1;
				end loop;
				
				-- check for new candidates
				for Q in 0 to s_inst_count-1 loop
					-- if element from dependency list is no longer in any other dependency list
					if(inst_is_in_a_dep_list(Q) = 0) then
						--add into candidate_list
						candidate_list(candidate_list_counter) := Q;
						candidate_list_counter := candidate_list_counter + 1;

						-- made it to candidate list -- set to -1 to avoid  dealing with this inst again
						inst_is_in_a_dep_list(Q) := -1;
					end if;
				end loop;

				-- report new candidate list
				for Z in 0 to candidate_list_counter-1 loop
					report "\/\/\/ new candidate_list["&integer'image(Z)&"] = "&integer'image(candidate_list(Z))&"    \/\/\/";
				end loop;

				v_PC_sch := std_logic_vector(unsigned(v_PC_sch) + "000000000100"); 
			end loop;

			-- assign signal at the end to avoid hiccups
			s_scheduled_inst <= v_scheduled_inst;
			done_sch <= '1';
			
			-- write rescheduled program to a text file for comparison with original
			file_open(sch_file, "scheduled_program.txt", write_mode);
			while (inst_number_sch /= s_inst_count) loop
				inst_write(31 downto 24) := v_scheduled_inst(inst_number_sch * 4);
				inst_write(23 downto 16) := v_scheduled_inst((inst_number_sch * 4) + 1);
				inst_write(15 downto 8)  := v_scheduled_inst((inst_number_sch * 4) + 2);
				inst_write(7 downto 0)   := v_scheduled_inst((inst_number_sch * 4) + 3);

				write(line_to_write, inst_write, right, 32);
				writeline(sch_file, line_to_write);
				inst_number_sch := inst_number_sch + 1;
			end loop;
		
			report "\/\/\/                           \/\/\/";
			report "\/\/\/     DONE ! CHECK .TXT     \/\/\/";
			report "\/\/\/                           \/\/\/";

		end if;
	end process;	


	-- return instruction at PC to the caller
	-- does not need to be edge-triggered, as it is called in an edge-triggered process 
	return_IR : process(address, get_bubble_sch)
		begin
		if (get_bubble_sch = '1') then
			inst_sch <= "00000000000000000000000000000000";
		else
			inst_sch(31 downto 24) <= s_scheduled_inst(to_integer(unsigned(address)));
			inst_sch(23 downto 16) <= s_scheduled_inst(to_integer(unsigned(address)) + 1);
			inst_sch(15 downto 8) <= s_scheduled_inst(to_integer(unsigned(address)) + 2);
			inst_sch(7 downto 0) <= s_scheduled_inst(to_integer(unsigned(address)) + 3);
		end if;
	end process;

END behaviour;
