-- @filename:   mem_wb_reg.vhd

-- @author:     William Bouchard

-- @timestamp:  2017-03-10

-- @brief:      MEM/WB register which contains the intermediate values used

--              in pipelining



library ieee;

use ieee.std_logic_1164.all;

use ieee.numeric_std.all;



entity MEM_WB_REG is

    port (

    clock : in std_logic;

    LMD_MEM : in std_logic_vector(7 downto 0);-- load memory data

    ALUOutput_MEM : in std_logic_vector(15 downto 0);-- comes from ex/mem (see notes there)

    IR_MEM : in std_logic_vector(31 downto 0); -- comes from ex/mem



    LMD_WB : out std_logic_vector(7 downto 0);

    ALUOutput_WB : out std_logic_vector(15 downto 0);

    IR_WB : out std_logic_vector(31 downto 0)

);

end MEM_WB_REG;



architecture behavior of MEM_WB_REG is



    signal LMD_MEM_STORED : std_logic_vector(7 downto 0) := (others=>'0');

    signal ALUOutput_MEM_STORED : std_logic_vector(15 downto 0) := (others=>'0');

    signal IR_MEM_STORED : std_logic_vector(31 downto 0) := (others=>'0');



begin



    -- If register_in is the current value, register_out should be 

    -- the last value stored (1 clock cycle before the current value).

    -- Values should be fed on rising_edge to be returned on the next 

    -- rising_edge (i.e a full cycle after).



    process (clock)

    begin

        if rising_edge(clock) then

            if (LMD_MEM_STORED /= LMD_MEM) then

                LMD_WB <= LMD_MEM_STORED;

                LMD_MEM_STORED <= LMD_MEM;

            end if;



            if (ALUOutput_MEM_STORED /= ALUOutput_MEM) then

                ALUOutput_WB <= ALUOutput_MEM_STORED;

                ALUOutput_MEM_STORED <= ALUOutput_MEM;

            end if;



            if (IR_MEM_STORED /= IR_MEM) then

                IR_WB <= IR_MEM_STORED;

                IR_MEM_STORED <= IR_MEM;

            end if;

        end if;

    end process;



end behavior;