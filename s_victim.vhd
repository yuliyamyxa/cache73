library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity victim is
    generic (
        AINDEX_WIDTH : integer := 6;
        MODE         : integer := 1  -- 0 - always same index output; 1 - sequential output; 2 - prng, not awaliable now
    );
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           index : out  STD_LOGIC_VECTOR (AINDEX_WIDTH-1 downto 0)
        );
end victim;

architecture victim_arch of victim is
    signal Qt : std_logic_vector(AINDEX_WIDTH-1 downto 0) := "000001";
    signal prng : std_logic_vector(15 downto 0) := conv_std_logic_vector(1, 16);
begin


    prng_p : process(clk, rst_n)
        variable tmp : STD_LOGIC := '0';
        function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
            begin
                return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
        end function;
    begin
        if clk'event and clk = '1' then
            if rst_n = '0' then
                Qt <=  (others => '0')--"000001"; 
            else
				if MODE = 0 then
					Qt <=  "000010";
                elsif MODE = 1 then -- shft mode
                    Qt <= conv_std_logic_vector(unsigned(Qt) + 1, AINDEX_WIDTH);
                else --if MODE = 2 then -- not avaliable now
                    Qt <=  lfsr32(Qt);--"000000";
				
                end if;
               -- Qt <= tmp & Qt(AINDEX_WIDTH-1 downto 1);
            end if;
        end if;
    end process;
                
    index <= Qt;

end victim_arch;

