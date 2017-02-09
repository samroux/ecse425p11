library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is
	
	--subtype addr_int is integer range 0 to 65535;

	SUBTYPE cache_block is std_logic_vector(135 downto 0);
	TYPE CACHE IS ARRAY(31 downto 0) OF cache_block;
	SIGNAL CACHE_INSTANCE : CACHE;

	--CACHE ()
		-- 32 CACHE BLOCK (136-BIT)
			 -- 1 VALID BIT (1 BIT)
			 -- 1 DIRTY BIT (1 BIT)
			 -- 1 TAG (6 BITS)
			 -- 1 DATA (128 BITS)
				-- 4 WORD (32 BITS)

	type state_type is (sIDLE, sCOMPARE_TAG, sWRITE_BACK, sALLOCATE);
	signal STATE : state_type;
	signal NEXT_STATE : state_type;
	signal nexts_readdata : std_logic_vector (31 downto 0);
	signal nexts_waitrequest : std_logic; 
	signal nextm_addr : integer range 0 to ram_size-1;
	signal nextm_read : std_logic;
	signal nextm_write : std_logic;
	signal nextm_writedata : std_logic_vector (7 downto 0);

	-- signal i_addr : std_logic_vector (31 downto 0);

    -- separate input address into tokens
    alias i_byteOffset is s_addr(1 downto 0); -- ignore?
    alias i_blockOffset is s_addr(3 downto 2);
    alias i_index is s_addr(8 downto 4);
    alias i_tag is s_addr(14 downto 9);

    -- block to be read from or written to
    signal targetBlock : cache_block;
    alias t_validBit is targetBlock(135);
    alias t_dirtyBit is targetBlock(134);
    alias t_tag is targetBlock(133 downto 128);
    alias t_word1 is targetBlock(127 downto 96);
    alias t_word2 is targetBlock(95 downto 64);
    alias t_word3 is targetBlock(63 downto 32);
    alias t_word4 is targetBlock(31 downto 0);

    signal tagEqual : std_logic;

-- compareTag:  compare two tags
impure function compareTags( tag1 : std_logic_vector(5 downto 0);
                             tag2 : std_logic_vector(5 downto 0))
            return std_logic is
    begin
        if (tag1 AND tag2) = "000000" then
            return '1';
        else
            return '0';
        end if;
end compareTags;

begin

process (clock, reset)
    begin
    if reset = '1' then 
        STATE <= sIDLE;
    elsif (rising_edge(clock)) then
        STATE <= NEXT_STATE;
        s_readdata <= nexts_readdata;
        s_waitrequest <= nexts_waitrequest;
        m_addr <= nextm_addr;
        m_read <= nextm_read;
        m_write <= nextm_write; 
        m_writedata <= nextm_writedata;
    end if;
end process;

process (s_read, s_write, STATE)
    begin
    case STATE is
        when sIDLE  =>
            if (s_read = '1') and (s_write = '1') then
                NEXT_STATE <= sIDLE;
                nexts_readdata <= "00000000000000000000000000000000";
                nexts_waitrequest <= '0';
                nextm_addr <= 0;
                nextm_read <= '0';
                nextm_write <= '0';
                nextm_writedata <= "00000000";
            elsif (s_read = '0') and (s_read = '0') then
                NEXT_STATE <= sIDLE;
            else
                NEXT_STATE <= sCOMPARE_TAG;
            end if;
        when sCOMPARE_TAG  =>
            targetBlock <= cache_instance(to_integer(unsigned(i_index)));

            tagEqual <= compareTags(t_tag, i_tag);
            if ((t_validBit AND tagEqual) = '1') then    -- hit
                if (s_write = '1') then
                    if (t_dirtyBit = '0') then
                        -- write to block
                        case i_blockOffset is
                            when "00" => t_word1 <= s_writedata;
                            when "01" => t_word2 <= s_writedata;
                            when "10" => t_word3 <= s_writedata;
                            when "11" => t_word4 <= s_writedata;
                            when others => null;
                        end case;

                        -- setDirty
                        t_dirtyBit <= '1';
                        NEXT_STATE <= sIDLE;
                    else
                        NEXT_STATE <= sWRITE_BACK;
                    end if;
                else
                    -- read from block
                    case i_blockOffset is
                        when "00" => nexts_readdata <= t_word1;
                        when "01" => nexts_readdata <= t_word2;
                        when "10" => nexts_readdata <= t_word3;
                        when "11" => nexts_readdata <= t_word4;
                        when others => null;
                    end case;
                    NEXT_STATE <= sIDLE;
                end if;
            else    -- miss
                if (t_dirtyBit = '0') then
                    NEXT_STATE <= sALLOCATE;
                else
                    NEXT_STATE <= sWRITE_BACK;
                end if;
            end if;
        when sWRITE_BACK  =>
            -- only one byte written to MM at a time, need to write 16
            -- while memory is not ready (byteWritten < 16)
                NEXT_STATE <= sWRITE_BACK;
            -- if byteWritten = 16
                -- set byteWritten = 0
                NEXT_STATE <= sALLOCATE;
        when sALLOCATE  =>
            -- while memory is not ready (byteRead < 16)
                NEXT_STATE <= sALLOCATE;
            -- if byteRead = 16
                -- set byteRead = 0
                NEXT_STATE <= sCOMPARE_TAG;
            
        end case;
end process;

end arch;
