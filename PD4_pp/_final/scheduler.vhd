-- @filename scheduler.vhd
-- @author Samuel Roux and William Bouchard
-- @timestamp 2017-04-10
-- @brief vhdl entity defining the instruction scheduler. Which reads from I_M and return to I_F

LIBRARY ieee;
USE ieee.std_logic_1164.all;
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
		inst_sch: out std_logic_vector(31 downto 0)
	);
END scheduler;

ARCHITECTURE behaviour OF scheduler IS

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
	begin
		if(s_ready = '1') then
			--fill raw_inst from I_M
			for I in 0 to s_inst_count-1 loop
				inst_base(31 downto 24) <= raw_inst(to_integer(unsigned(loop_PC)));
				inst_base(23 downto 16) <= raw_inst(to_integer(unsigned(loop_PC)) + 1);
				inst_base(15 downto 8) <= raw_inst(to_integer(unsigned(loop_PC)) + 2);
				inst_base(7 downto 0) <= raw_inst(to_integer(unsigned(loop_PC)) + 3);
				
				for J in I to s_inst_count-1 loop
					loop_j_PC := std_logic_vector(unsigned(loop_i_PC) + "000000000100");
					inst_comp(31 downto 24) <= raw_inst(to_integer(unsigned(loop_PC)));
					inst_comp(23 downto 16) <= raw_inst(to_integer(unsigned(loop_PC)) + 1);
					inst_comp(15 downto 8) <= raw_inst(to_integer(unsigned(loop_PC)) + 2);
					inst_comp(7 downto 0) <= raw_inst(to_integer(unsigned(loop_PC)) + 3);
					
					
				end loop;
				loop_i_PC := std_logic_vector(unsigned(loop_i_PC) + "000000000100");
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

END behaviour;
