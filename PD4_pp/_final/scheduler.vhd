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
		
		get_bubble_sch : in std_logic;
		
		address: in std_logic_vector(11 downto 0);
		inst_sch: out std_logic_vector(31 downto 0);
		done: out std_logic
	);
END scheduler;

ARCHITECTURE behaviour OF scheduler IS

	signal inst_is_in_a_dep_list : BUF := (others => -1);

	SIGNAL s_raw_inst: MEM := ((others => (others => '0')));
	SIGNAL scheduled_inst: MEM := ((others => (others => '0')));
	
	SIGNAL candidate_list: BUF := (others => 0);
	SIGNAL dib: BUF := (others => 0);	--dependency_index_buff
	
	SIGNAL dependency_lists : MEM_SQUARE := ((others => (others => 0)));
	
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
		
		variable isDependent : std_logic := '0';

		
		begin
			opcode_base := IR_base (31 downto 26);
			opcode_comp := IR_comp (31 downto 26);
			
			--decoding instruction base
			if ( opcode_base = "000000") then -- R-type
				inst_type_base := 0;
				rs_base := IR_base (25 downto 21);
				rt_base := IR_base (20 downto 16);
				rd_base := IR_base (15 downto 11);
			else -- I-type
				inst_type_base := 1;
				rs_base := IR_base (25 downto 21);
				rt_base := IR_base (20 downto 16);
			end if;
			
			--decoding instruction compared
			if ( opcode_comp = "000000") then -- R-type
				inst_type_comp := 0;
				rs_comp := IR_comp (25 downto 21);
				rt_comp := IR_comp (20 downto 16);
				rd_comp := IR_comp (15 downto 11);
			else -- I-type
				inst_type_comp := 1;
				rs_comp := IR_comp (25 downto 21);
				rt_comp := IR_comp (20 downto 16);
			end if;
			
			
			--check if there's an hazard between inst_base & inst_comp
			if (inst_type_comp = 0) then
				--r-type
				if (inst_type_base = 0) then
					--r-type
					if (rd_comp = "00000" or rd_comp = "UUUUU") then
						isDependent := '0';
						
					elsif ( rd_comp = rs_base ) then
						isDependent := '1';
					elsif ( rd_comp = rt_base ) then
						isDependent := '1';
					elsif ( rd_comp = rd_base ) then
						isDependent := '1';
						
					elsif ( rs_comp = rs_base ) then
						isDependent := '1';
					elsif ( rs_comp = rt_base ) then
						isDependent := '1';
					elsif ( rs_comp = rd_base ) then
						isDependent := '1';
						
					elsif ( rt_comp = rs_base ) then
						isDependent := '1';
					elsif ( rt_comp = rt_base ) then
						isDependent := '1';
					elsif ( rt_comp = rd_base ) then
						isDependent := '1';
						
					else
						isDependent := '0';
					end if;
				elsif (inst_type_base = 1 ) then
					--i-type
					if (rd_comp = "00000" or rd_comp = "UUUUU") then
						isDependent := '0';
						
					elsif ( rd_comp = rs_base ) then
						isDependent := '1';
					elsif ( rd_comp = rt_base ) then
						isDependent := '1';
						
					elsif ( rs_comp = rs_base ) then
						isDependent := '1';
					elsif ( rs_comp = rt_base ) then
						isDependent := '1';
						
					elsif ( rt_comp = rs_base ) then
						isDependent := '1';
					elsif ( rt_comp = rt_base ) then
						isDependent := '1';
						
					else
						isDependent := '0';
					end if;
				end if;
			elsif (inst_type_comp = 1) then
				--i-type
				if (inst_type_base = 0) then
					--r-type
					if (rt_comp = "00000" or rt_comp = "UUUUU") then
						isDependent := '0';
						
					elsif ( rt_comp = rs_base ) then
						isDependent := '1';
					elsif ( rt_comp = rt_base ) then
						isDependent := '1';
					elsif ( rt_comp = rd_base ) then
						isDependent := '1';
						
						
					elsif ( rs_comp = rs_base ) then
						isDependent := '1';
					elsif ( rs_comp = rt_base ) then
						isDependent := '1';
					elsif ( rs_comp = rd_base ) then
						isDependent := '1';	
						
					else
						isDependent := '0';
					end if;
				elsif (inst_type_base = 1 ) then
					--i-type
					if (rt_comp = "00000" or rt_comp = "UUUUU") then
						isDependent := '0';
						
					elsif ( rt_comp = rs_base ) then
						isDependent := '1';
					elsif ( rt_comp = rt_base ) then
						isDependent := '1';
						
					elsif ( rs_comp = rs_base ) then
						isDependent := '1';
					elsif ( rs_comp = rt_base ) then
						isDependent := '1';
						
						
					else
						isDependent := '0';
					end if;
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

	scheduling : process (s_ready)
	
		variable loop_i_PC : STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
		variable loop_j_PC : STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
		variable inst_base : STD_LOGIC_VECTOR (31 downto 0);
		variable inst_comp : STD_LOGIC_VECTOR (31 downto 0);
		variable isDependent : std_logic;
		
		variable v_PC_sch : STD_LOGIC_VECTOR (11 downto 0):= (others => '0');
		variable inst_number_raw: integer := 0;
		
		variable instruction_number : integer := 0;
		variable line_to_write : line;
		
		variable candidate_list_counter : integer := 0;
	begin
		if(s_ready = '1') then
		
			-- fill raw_inst from I_M
			-- Build Dependency lists (Stored into Dependency memory) & fill (Dependency Index buffer)
			for I in 0 to s_inst_count-1 loop
				inst_base(31 downto 24) := s_raw_inst(to_integer(unsigned(loop_i_PC)));
				inst_base(23 downto 16) := s_raw_inst(to_integer(unsigned(loop_i_PC)) + 1);
				inst_base(15 downto 8) := s_raw_inst(to_integer(unsigned(loop_i_PC)) + 2);
				inst_base(7 downto 0) := s_raw_inst(to_integer(unsigned(loop_i_PC)) + 3);
				
				for J in I to s_inst_count-1 loop
					loop_j_PC := std_logic_vector(unsigned(loop_i_PC) + "000000000100");
					inst_comp(31 downto 24) := s_raw_inst(to_integer(unsigned(loop_j_PC)));
					inst_comp(23 downto 16) := s_raw_inst(to_integer(unsigned(loop_j_PC)) + 1);
					inst_comp(15 downto 8) := s_raw_inst(to_integer(unsigned(loop_j_PC)) + 2);
					inst_comp(7 downto 0) := s_raw_inst(to_integer(unsigned(loop_j_PC)) + 3);
					
					isDependent := check_dependency (inst_comp, inst_base);
					if (isDependent = '1') then
						dependency_lists(I)(dib(I)) <= J;
						dib(I) <= dib(I) + 1;
					end if;
				end loop;
				loop_i_PC := std_logic_vector(unsigned(loop_i_PC) + "000000000100");
				report "s_raw_inst: "&integer'image(to_integer(unsigned(s_raw_inst(0))));
				report "inst_base: "&integer'image(to_integer(unsigned(inst_base)));
			end loop;
			
			-- Fill Candidate List
			for K in 0 to s_inst_count-1 loop
				--where K is instruction number
				for L in 0 to dib(K)-1 loop
					--where L is the index in dependency list
					inst_is_in_a_dep_list(dependency_lists(K)(L)) <= (inst_is_in_a_dep_list(dependency_lists(K)(L)) + 1); --incresing dependency counter
					
				end loop;		
			end loop;
			
			--report "inst_is_in_a_dep_list: "&integer'image(to_integer(unsigned(inst_is_in_a_dep_list)));
			--initialize candidate list
			for M in 0 to s_inst_count-1 loop
				report "inst_is_in_a_dep_list(M): "&integer'image(inst_is_in_a_dep_list(M));
				if (inst_is_in_a_dep_list(M) = 0) then
					candidate_list(candidate_list_counter) <= M;
					candidate_list_counter := candidate_list_counter + 1;
				end if;
			end loop;
			
			
			v_PC_sch := (others=>'0');
			report "candidate_list_counter: "&integer'image(candidate_list_counter);
			while (candidate_list_counter /= 0) loop
				report "candidate_list_counter: "&integer'image(candidate_list_counter);
				--get first element in candidate_list and store as next instruction in scheduled inst
				inst_number_raw := candidate_list(0);
				
				--store in scheduled inst
				scheduled_inst(to_integer(unsigned(v_PC_sch))) <= s_raw_inst (inst_number_raw * 4);
				scheduled_inst(to_integer(unsigned(v_PC_sch)) + 1) <= s_raw_inst ((inst_number_raw * 4) +1);
				scheduled_inst(to_integer(unsigned(v_PC_sch)) + 2) <= s_raw_inst ((inst_number_raw * 4) +2);
				scheduled_inst(to_integer(unsigned(v_PC_sch)) + 3) <= s_raw_inst ((inst_number_raw * 4) +3);
				
				-- shift candidate list
				for N in 1 to s_inst_count-1 loop
					candidate_list (N-1) <= candidate_list (N); 
				end loop;
				candidate_list (candidate_list_counter) <= -1 ; 
				candidate_list_counter := (candidate_list_counter - 1);
				
				--remove element from any dependency list
				inst_is_in_a_dep_list(inst_number_raw) <= 0;
				
				--check if elements from dependency list of the element removed from candidate list are still in any dependency list
				for P in 0 to dib(inst_number_raw) loop
					--where P is the element position in dependency list
					--dependency_lists(inst_number_raw)(P) is a dependent for inst_number_raw
					
					inst_is_in_a_dep_list(dependency_lists(inst_number_raw)(P)) <= (inst_is_in_a_dep_list(dependency_lists(inst_number_raw)(P))-1); --decreasing dependency counter
					
					-- if element from dependency list is no longer in any other dependency list
					if(inst_is_in_a_dep_list(dependency_lists(inst_number_raw)(P)) = 0) then
						--add into candidate_list
						candidate_list_counter := candidate_list_counter + 1;
						candidate_list (candidate_list_counter) <= dependency_lists(inst_number_raw)(P);
					end if;
				end loop;
				
				v_PC_sch := std_logic_vector(unsigned(v_PC_sch) + "000000000100"); 
			end loop;
			done <= '1';
			
			
			file_open(sch_file, "scheduled_program.txt", write_mode);
			while (instruction_number /= s_inst_count) loop
				write(line_to_write, scheduled_inst(instruction_number), right, 32);
				writeline(sch_file, line_to_write);
				instruction_number := instruction_number + 1;
			end loop;
		
		end if;
	end process;	



	return_IR : process(address, get_bubble_sch)
		begin
		-- Goal of this process is to output instruction from address
		-- does not need to be edge-triggered, as it is called in an edge-triggered process 
		--if (rising_edge(clock)) then
			if (get_bubble_sch = '1') then
				inst_sch <= "00000000000000000000000000000000";
			else
				inst_sch(31 downto 24) <= scheduled_inst(to_integer(unsigned(address)));
				inst_sch(23 downto 16) <= scheduled_inst(to_integer(unsigned(address)) + 1);
				inst_sch(15 downto 8) <= scheduled_inst(to_integer(unsigned(address)) + 2);
				inst_sch(7 downto 0) <= scheduled_inst(to_integer(unsigned(address)) + 3);
			end if;
		--end if;
	end process;
	
	-- write_to_file : process(done)
	-- variable instruction_number : integer := 0;
	-- variable line_to_write : line;
	-- variable bit_vector : bit_vector(0 to 31);
	-- begin
		-- if(done = '1') then
			-- file_open(sch_file, "scheduled_program.txt", write_mode);
			-- while (instruction_number /= s_inst_count) loop
				-- write(line_to_write, scheduled_inst(instruction_number), right, 32);
				-- writeline(sch_file, line_to_write);
				-- instruction_number := instruction_number + 1;
			-- end loop;
		-- end if;
	-- end process final_write;


END behaviour;
