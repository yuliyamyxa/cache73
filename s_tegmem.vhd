library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tegmem is
    generic (
        -- parameters
          ATEG_WIDTH : integer := 12;
          LINE_WIDTH : integer := 32
          --MEM_WIDTH  : integer := 6	
        );
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic; 	

            addr    : in  std_logic_vector(ATEG_WIDTH - 1 downto 0);
            wr      : in  std_logic;
            rand    : in  std_logic;
            md      : in  std_logic;
            
            tegOut  : out std_logic_vector(ATEG_WIDTH + 1 - 1 downto 0); -- MOD & adr[ATEG_WIDTH-1:0]
            index   : out std_logic_vector(CHANNEL_WIDTH - 1 downto 0);
            hit	    : out std_logic
        );
end tegmem;

architecture tegMem_arch of tegmem is
    constant MEM_SIZE	: integer := 64; -- 64
    constant VAL_BIT	: integer := 13; 
    constant MD_BIT     : integer := 12; 
	constant MEM_WIDTH  : integer := ATEG_WIDTH + 2; -- 14

    -- memory for itself
    type tegMem_t is array (natural range <>) of std_logic_vector (LINE_WIDTH*8 - 1 downto 0);
	signal tegMem 		: tegMem_t (MEM_SIZE - 1 downto 0) := (others => (others => 'U'));

begin

    








end tegMem_arch;

