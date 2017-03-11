-- @filename:	if_id_reg.vht
-- @author:		William Bouchard
-- @timestamp:	2017-03-10
-- @brief:		Test bench for the IF/ID register

library ieee;                                               
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;                               

entity if_id_reg_tst is
end if_id_reg_tst;

-- need to ensure that the register is properly edge-triggered

architecture if_id_reg_arch of if_id_reg_tst is
           
    -- test signals
    signal clock : std_logic;                                      
	signal NPC_IF : std_logic_vector(1023 downto 0);
	signal NPC_ID : std_logic_vector(1023 downto 0);
	signal IR_IF : std_logic_vector(31 downto 0);
	signal IR_ID : std_logic_vector(31 downto 0);

	constant clock_period : time := 1 ns;

	-- register component
	component if_id_reg
		port (
			clock : in std_logic;
			NPC_IF: in std_logic_vector(1023 downto 0);
			NPC_ID : out std_logic_vector(1023 downto 0);
			IR_IF: in std_logic_vector(31 downto 0);
			IR_ID : out std_logic_vector(31 downto 0)
		);
	end component;

	begin
		-- map test signals to component in/out
		i : if_id_reg
		port map (
			clock => clock,
			NPC_IF => NPC_IF,
			NPC_ID => NPC_ID,
			IR_IF => IR_IF,
			IR_ID => IR_ID
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
			NPC_IF <= (others=>'0');
			IR_IF  <= (others=>'0');                       
			wait for clock_period;    
			wait for clock_period/2; -- start at rising edge                  
        	NPC_IF <= (1023=>'1', 1022=>'1', 1021=>'0', 1020=>'1', others=>'0');
        	IR_IF  <= (31=>'0', 30=>'0', 29=>'1', 28=>'0', others=>'0');
        	wait for clock_period;
        	NPC_IF <= (others=>'0');
        	IR_IF  <= (others=>'0');
        	wait for clock_period;                         
        	NPC_IF <= (1023=>'1', 1022=>'1', 1021=>'0', 1020=>'1', others=>'0');
        	IR_IF  <= (31=>'0', 30=>'0', 29=>'1', 28=>'0', others=>'0');
        	wait for clock_period;
        	NPC_IF <= (others=>'0');
        	IR_IF  <= (others=>'0');
		wait;                                                        
	end process generate_test;                                     
end if_id_reg_arch;