-- @filename:	register_controller.vhd
-- @author:		William Bouchard
-- @timestamp:	2017-03-13
-- @brief:		Wrapper for the register file.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGISTER_CONTROLLER is

port (
	clock : in std_logic;
	ALUOutput : in std_logic_vector(15 downto 0);
	IR_IF : in std_logic_vector(31 downto 0);
	IR_MEM_WB : in std_logic_vector(31 downto 0);
	WB_return : in std_logic_vector(15 downto 0) -- either a loaded register from
												 -- memory or the ALU output

	A : out std_logic_vector(7 downto 0);
	B : out std_logic_vector(7 downto 0);
	Imm : out std_logic_vector(31 downto 0)
	);
end REGISTER_CONTROLLER;

architecture behavior of REGISTER_CONTROLLER is

	begin

	process(clock)
	begin

	end process;

end behavior;