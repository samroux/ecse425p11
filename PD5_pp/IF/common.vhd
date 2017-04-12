-- @filename common.vhd
-- @author Samuel Roux and William Bouchard
-- @timestamp 2017-04-10
-- @brief vhdl entity defining common types used between blocks

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use STD.textio.all;

package common IS

	TYPE MEM IS ARRAY(4096-1 downto 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE BUF IS ARRAY(1024-1 downto 0) OF INTEGER;
	TYPE MEM_SQUARE IS ARRAY(1024-1 downto 0) OF BUF;
	
END common;

