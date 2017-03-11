-- @filename:	if_id_reg.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-10
-- @brief:		IF/ID register which contains the intermediate values used
--				in pipelining

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID_REG is
port (
	-- PC keeps track of the number of bytes in the instruction register.
	-- It should be increased by 4 bytes (32 bits, length of an inst)
	-- to move to next inst. Our memory has size 4096 * 8 bits, which
	-- means 4096/4 = 1024 instructions.
	clock : in std_logic;
	NPC_IF: in std_logic_vector(4095 downto 0);
	NPC_ID : out std_logic_vector(4095 downto 0);
	IR_IF: in std_logic_vector(31 downto 0);
	IR_ID : out std_logic_vector(31 downto 0)
	);
end IF_ID_REG;

architecture behavior of IF_ID_REG is

	signal NPC_IF_STORED : std_logic_vector(4095 downto 0) := (others=>'0');
	signal IR_IF_STORED : std_logic_vector(31 downto 0) := (others=>'0');

	begin

	-- If register_in is the current value, register_out should be 
	-- the last value stored (1 clock cycle before the current value).
	-- Values should be fed on rising_edge to be returned on the next 
	-- rising_edge (i.e a full cycle after).

	process (clock)
	begin
		if rising_edge(clock) then
			if (NPC_IF_STORED /= NPC_IF) then
				NPC_ID <= NPC_IF_STORED;
				NPC_IF_STORED <= NPC_IF;
			end if;

			if (IR_IF_STORED /= IR_IF) then
				IR_ID <= IR_IF_STORED;
				IR_IF_STORED <= IR_IF;
			end if;		
		end if;
	end process;

end behavior;