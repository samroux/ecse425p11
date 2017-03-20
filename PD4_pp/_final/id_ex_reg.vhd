-- @filename:	id_ex_reg.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-10
-- @brief:		ID/EX register which contains the intermediate values used
--				in pipelining

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_EX_REG is
port (
	clock : in std_logic;
	A_ID : in std_logic_vector(31 downto 0); 	-- regs have length 32
	B_ID : in std_logic_vector(31 downto 0); 	
	IMM_ID : in std_logic_vector(31 downto 0); 	-- last 16 bits of instruction (sign-extended)
	NPC_ID : in std_logic_vector(11 downto 0);-- should come from if/id directly
	IR_ID : in std_logic_vector(31 downto 0);	-- same as above

	A_EX : out std_logic_vector(31 downto 0) := (others=>'0');
	B_EX : out std_logic_vector(31 downto 0) := (others=>'0');
	IMM_EX : out std_logic_vector(31 downto 0) := (others=>'0');
	NPC_EX : out std_logic_vector(11 downto 0);
	IR_EX : out std_logic_vector(31 downto 0)
	);
end ID_EX_REG;

architecture behavior of ID_EX_REG is

	--signal A_ID_STORED : std_logic_vector(31 downto 0) := (others=>'0');
	--signal B_ID_STORED : std_logic_vector(31 downto 0) := (others=>'0');
	--signal IMM_ID_STORED : std_logic_vector(31 downto 0) := (others=>'0');
	--signal NPC_ID_STORED : std_logic_vector(11 downto 0) := (others=>'0');
	--signal IR_ID_STORED : std_logic_vector(31 downto 0) := (others=>'0');


	begin

	-- If register_in is the current value, register_out should be 
	-- the last value stored (1 clock cycle before the current value).
	-- Values should be fed on rising_edge to be returned on the next 
	-- rising_edge (i.e a full cycle after).

	process (clock)
	begin
		if rising_edge(clock) then
			A_EX <= A_ID;
			B_EX <= B_ID;
			IMM_EX <= IMM_ID;
			NPC_EX <= NPC_ID;
			IR_EX <= IR_ID;
			--if (A_ID_STORED /= A_ID) then
			--	A_EX <= A_ID_STORED;
			--	A_ID_STORED <= A_ID;
			--end if;

			--if (B_ID_STORED /= B_ID) then
			--	B_EX <= B_ID_STORED;
			--	B_ID_STORED <= B_ID;
			--end if;

			--if (IMM_ID_STORED /= IMM_ID) then
			--	IMM_EX <= IMM_ID_STORED;
			--	IMM_ID_STORED <= IMM_ID;
			--end if;

			--if (NPC_ID_STORED /= NPC_ID) then
			--	NPC_EX <= NPC_ID_STORED;
			--	NPC_ID_STORED <= NPC_ID;
			--end if;

			--if (IR_ID_STORED /= IR_ID) then
			--	IR_EX <= IR_ID_STORED;
			--	IR_ID_STORED <= IR_ID;
			--end if;
		end if;
	end process;

end behavior;
