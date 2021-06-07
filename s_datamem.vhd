library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity datamem is
    generic (
            -- parameters
            LINE_WIDTH  : integer := 32; -- in bytes
            MEM_WIDTH   : integer := 6
        );
        port (
            clk   : in  std_logic;
            index : in  std_logic_vector(MEM_WIDTH - 1 downto 0);
            wr    : in  std_logic;
            
            wData : in std_logic_vector(LINE_WIDTH*8 - 1 downto 0);
            Data  : out std_logic_vector(LINE_WIDTH*8 - 1 downto 0)
        );
end datamem;

architecture datamem_arch of datamem is
    constant MEM_SIZE : integer := 5; --64; --2048/32 - from task
    type dataMem_t is array (natural range <>) of std_logic_vector (LINE_WIDTH*8 - 1 downto 0);
	signal dataMem : dataMem_t (MEM_SIZE - 1 downto 0) := (others => (others => 'U'));

begin
    datamem_p : process(clk, wr)
	begin
		if clk'event and clk = '1' then
			Data <= dataMem(conv_integer(index));
			if wr = '1' then
                dataMem(conv_integer(index)) <= wData;
			end if;
		end if;
	end process datamem_p;

end datamem_arch;

