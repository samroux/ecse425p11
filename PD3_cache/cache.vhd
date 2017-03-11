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
--------------------------------------------------------------------------------
-- TODO:    figure out waitrequest (use diagram in instructions)
--          make sure all outputs are set in all states
--------------------------------------------------------------------------------
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

    -- separate input address into tokens
    signal i_addr : std_logic_vector (31 downto 0);
    signal i_byteOffset : std_logic_vector(1 downto 0);
    signal i_blockOffset : std_logic_vector(1 downto 0);
    signal i_index : std_logic_vector(4 downto 0);
    signal i_tag : std_logic_vector(5 downto 0);

    -- block to be read from or written to
    signal targetBlock : cache_block;
    alias t_validBit is targetBlock(135);
    alias t_dirtyBit is targetBlock(134);
    alias t_tag is targetBlock(133 downto 128);
    alias t_data is targetBlock(127 downto 0);
    alias t_word1 is targetBlock(127 downto 96);
    alias t_word2 is targetBlock(95 downto 64);
    alias t_word3 is targetBlock(63 downto 32);
    alias t_word4 is targetBlock(31 downto 0);

    signal tagEqual : std_logic;
    signal temp : std_logic_vector (127 downto 0);

    signal temp_allocate : std_logic_vector (31 downto 0);
function compareTags( tag1 : std_logic_vector(5 downto 0);
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
    variable bytesToWrite, bytesToRead: integer range 0 to 16;
    variable  pos1, pos2: integer range 0 to 127;
    begin
    -- only want to deal with the values given when s_read or s_write were changed
    -- in order to be independent from s_addr changes
    cache_instance <=(others=>(others=>'0'));
    i_addr <= s_addr;
    i_byteOffset <= i_addr(1 downto 0);
    i_blockOffset <= i_addr(3 downto 2);
    i_index <= i_addr(8 downto 4);
    i_tag <= i_addr(14 downto 9);
    targetBlock <= cache_instance(to_integer(unsigned(i_index)));
    case STATE is
    
    --idle state
    when sIDLE  => 
        Report "In sIDLE state";
            if (s_read xor s_write) = '1' then
                NEXT_STATE <= sCOMPARE_TAG;
            else
                NEXT_STATE <= sIDLE;
            end if;

    --compare tab state
    when sCOMPARE_TAG  =>
        Report "In sCOMPARE_TAG state";
            tagEqual <= compareTags(t_tag, i_tag);
            if ((t_validBit AND tagEqual) = '1') then    -- hit
                if (s_write = '1') then
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
                elsif(t_dirtyBit = '1') then
                    NEXT_STATE <= sWRITE_BACK;
                else
                    NEXT_STATE <= sIDLE;
                end if;
            end if;

    --write back state
    when sWRITE_BACK  =>
        Report "In sWRITE_BACK state";
            -- write to memory
            -- avalon writes one byte at a time, so need to ensure it has a counter
            -- to write 4x4 = 16 bytes
        bytesToWrite := 16; 
        pos1 := 0;
        pos2 :=0;
        temp <= t_data;  
            while (bytesToWrite > 0) loop
                -- ignore trailing offsets
                nextm_addr <= to_integer(unsigned(i_addr(31 downto 4)));
                nextm_write <= '1';
                -- move from pos1 = 127 and pos2 = 120 to pos1 = 7 and pos2 = 0
                --pos1:=0;
                Report "pos1_after0: " & integer'image(pos1);
                pos1 := bytesToWrite * 8 - 1;
                pos2 := pos1 - 7;
                --Report "ByteWritten: " & integer'image(bytesToWrite);
                --Report "pos1_afterCalc: " & integer'image(pos1);
                --Report "pos2: " & integer'image(pos2);
                --nextm_writedata <= t_data(pos1 downto pos2);

                nextm_writedata <= temp (127 downto 120);
                temp <= temp (119 downto 0) & temp (127 downto 120);

                bytesToWrite := bytesToWrite - 1;
                NEXT_STATE <= sWRITE_BACK;
            end loop;
            
            -- in case of tag mismatch, this will ensure that the new tag
            -- can take ownership of a block after the prev one has been written
            t_tag <= i_tag;
            bytesToWrite := 16;
            NEXT_STATE <= sALLOCATE;

        --Allocate state
        when sALLOCATE  =>
            Report "In sALLOCATE state";
            -- read from memory
            bytesToRead := 4;
            pos1 := 0;
            pos2 :=0;
        
            while (bytesToRead > 0) loop
                nextm_addr <= to_integer(unsigned(i_addr(31 downto 4)));
                nextm_read <= '1';
                
                pos1 := bytesToRead * 8 - 1;
                pos2 := pos1 - 7;
        
                -- here the main issue we are having is that we don't know how to get back the address that has been allocated into memory...
                --if we have this, we would then be able to set the tag and valid bit, as well as the data into the cache..
        
                temp_allocate(31 downto 24) <= m_readdata;
                temp_allocate <= temp_allocate(23 downto 0) & temp_allocate(31 downto 24);
                bytesToRead := bytesToRead - 1;
                NEXT_STATE <= sALLOCATE;
            end loop;

            nexts_readdata <= temp_allocate;
            bytesToRead := 4;
            NEXT_STATE <= sCOMPARE_TAG;   
        end case;
end process;

end arch;