library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity s_prng is
    generic (
        AINDEX_WIDTH : integer := 6;
        MODE         : integer := 1  -- 0 - always same index output; 1 - sequential output; 3 - prng, not awaliable now
    );
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           index : out  STD_LOGIC_VECTOR (AINDEX_WIDTH-1 downto 0)
        );
end s_prng;

architecture Behavioral of s_prng is
    signal Qt : std_logic_vector(AINDEX_WIDTH-1 downto 0) := "000001";
begin

    prng_p : process(clk, rst_n)
        variable tmp : STD_LOGIC := '0';
    begin
        if clk'event and clk = '1' then
            if rst_n = '0' then
                Qt <=  "000001"; 
            else
                if EN = 1 then
                    Qt <= conv_std_logic_vector(unsigned(Qt) + 1, AINDEX_WIDTH);
                else 
                    Qt <=  "000010";
                end if;
               -- Qt <= tmp & Qt(AINDEX_WIDTH-1 downto 1);
            end if;
        end if;
    end process;
                
    index <= Qt;

end Behavioral;

