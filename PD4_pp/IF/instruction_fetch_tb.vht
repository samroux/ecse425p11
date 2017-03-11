-- @filename	instruction_fetch_tb.vhd
-- @author		Samuel Roux
-- @timestamp	2017-03-11 12:20 AM
-- @brief		Testbench for instruction_fetch.vhd

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instruction_fetch_tb IS
END instruction_fetch_tb;

ARCHITECTURE behaviour OF instruction_fetch_tb IS

--Declare the component that you are testing:
    COMPONENT instruction_fetch IS
        GENERIC(
            clock_period : time := 1 ns
        );
        PORT (
            clock : in std_logic;
			reset : in std_logic;
			
			branch_taken : in std_logic;
			branch_address : in std_logic_vector (1023 downto 0);
			
			IR : out std_logic_vector (31 downto 0);
			PC : out std_logic_vector (1023 downto 0)
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
	
	signal reset : std_logic := '0';
	
	signal branch_taken : std_logic := '0';
	signal branch_address : std_logic_vector (1023 downto 0);
	
	signal IR : std_logic_vector (31 downto 0);
	signal PC : std_logic_vector (1023 downto 0);

BEGIN

    --dut => Device Under Test
    dut: instruction_fetch
                PORT MAP(
                    clk,
					reset,
                    branch_taken,
                    branch_address,
                    IR,
                    PC
                );

    clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN
        wait for clk_period;
        address <= 14; 
        writedata <= X"12";
        memwrite <= '1';
        
        --waits are NOT synthesizable and should not be used in a hardware design
        wait until rising_edge(waitrequest);
        memwrite <= '0';
        memread <= '1';
        wait until rising_edge(waitrequest);
        assert readdata = x"12" report "write unsuccessful" severity error;
        memread <= '0';
        wait for clk_period;
        address <= 12;memread <= '1';
        wait until rising_edge(waitrequest);
        assert readdata = x"0c" report "write unsuccessful" severity error;
        memread <= '0';
        wait;

    END PROCESS;
	
END;