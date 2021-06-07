library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tegmem is
    generic (
        -- parameters
          ATEG_WIDTH    : integer := 12;
          LINE_WIDTH    : integer := 32
          AINDEX_WIDTH  : integer := 6	
        );
        port (
            clk     : in  std_logic;
            rst_n : in  std_logic; 	

            addr    : in  std_logic_vector(ATEG_WIDTH - 1 downto 0); -- teg only
            wr      : in  std_logic;
            rand    : in  std_logic;
            md      : in  std_logic;
            
            tegOut  : out std_logic_vector(ATEG_WIDTH + 2 - 1 downto 0); -- VAL & MOD & adr[ATEG_WIDTH-1:0]
            index   : out std_logic_vector(CHANNEL_WIDTH - 1 downto 0);
            hit	    : out std_logic
        );
end tegmem;

architecture tegMem_arch of tegmem is

    
    сomponent victim is
		generic (
			AINDEX_WIDTH : integer;
			MODE	     : integer
		);
		port (
			lfuCntIn	:	in  std_logic_vector(2**CHANNEL_WIDTH * (LFU_WIDTH+1) - 1 downto 0);
			lfuMin	    :  out std_logic_vector (CHANNEL_WIDTH - 1 downto 0)
		);
	end component;

    constant MODE       : ingeger := 0;
    constant MEM_SIZE	: integer := 64; -- 64
    constant VAL_BIT	: integer := 13; 
    constant MD_BIT     : integer := 12; 
	constant MEM_WIDTH  : integer := ATEG_WIDTH + 2; -- 14

    -- memory for itself
    type tegMem_t is array (natural range <>) of std_logic_vector (LINE_WIDTH*8 - 1 downto 0);
	signal tegMem 		: tegMem_t (MEM_SIZE - 1 downto 0) := (others => (others => 'U'));

    signal index :  std_logic_vector(2**CHANNEL_WIDTH * (LFU_WIDTH+1) - 1 downto 0);



    signal tegMemOut    : std_logic_vector (MEM_WIDTH - 1 downto 0);
		alias moTeg		: std_logic_vector (ATEG_WIDTH - 1 downto 0) is tegMemOut(MEM_WIDTH - 1 downto VAL_BIT + 1);
		alias moVal		: std_logic 												is tegMemOut(VAL_BIT);
		alias moMod		: std_logic 												is tegMemOut(MOD_BIT);

	signal tegMemIn     : std_logic_vector (MEM_WIDTH - 1 downto 0);
		alias miTeg		: std_logic_vector (ATEG_WIDTH - 1 downto 0) is tegMemIn(MEM_WIDTH - 1 downto VAL_BIT + 1);
		alias miVal		: std_logic is tegMemIn(VAL_BIT);
		alias miMod		: std_logic is tegMemIn(MOD_BIT);

    signal hit_index    : std_logic_vector (AINDEX_WIDTH - 1 downto 0);
    signal hitBuf       : std_logic;
    signal victim_index : std_logic_vector (AINDEX_WIDTH - 1 downto 0);





    -- function to cmp all stored tags with input one and look for hit
    function hit_teg (signal mem : tegMem_t(), signal teg : std_logic_vector()) return std_logic_vector (AINDEX_WIDTH - 1 downto 0) is
    begin    
      for i in a'low to a'high loop -- if hit
        if mem(i)(AINDEX_WIDTH - 1 downto 0) = teg and mem(i)(VAL_BIT) = '1' then
          return conv_std_logic_vector(i, AINDEX_WIDTH);
        end if;
      end loop;    
      -- if not hit
      return (others => 'U');
    end function;

begin


    LFU_KS : lfuCompKs 
		generic map (
			AINDEX_WIDTH => AINDEX_WIDTH,
			MODE	     => MODE)
			port map (
            clk      => clk,
            rst_n    => rst_n,
			index	 => victim_index
			);

    -- hit_search_p: process(clk, rst)
    --     variable ind : integer;
    -- begin

    --     for i in 2**AINDEX_WIDTH 
    --         if moTeg = addr and moVal = '1'
    --     end if;
    -- end process hit_search_p;

    -- index_g : for i in 0 to AINDEX_WIDTH - 1 generate
    --     hit_index <= conv_std_logic_vector(i, AINDEX_WIDTH) when moTeg = addr and moVal = '1' else 
    -- end generate;

    hit_index <= hit_teg(tegMem, addr);
    hitBuf <= '1' when hit_index /= (others => 'U') else
              '0';
    -- input for memory
    miTeg <= aTeg when wr = '1' else 
             moTeg;
    miVal <= '1'  when wr = '1' else 
             moVal;
    miMod <= '1'  when md = '1' else 
     		 '0'  when wr = '1' else 
             moMod;
            
    --ce	<= '1' when hitBuf = '1' or lfu_ce = '1' or lfu_s = '1' else '0';
    tegMem_p : process(clk)
	begin
		rstVal := (others => 'U');
		rstVal(VAL_BIT) := '0';
        rstVal(MD_BIT)  := '0';
		if clk'event and clk = '1' then
			if rst_n = '0' then
				tegMem <= (others => rstVal);
			elsif hitBuf = '1' or wr = '1' then
				tegMem(conv_integer(aIndex)) <= tegMemIn;
			end if;
		end if;
	end process tegMem_p;



    tegOut <= tegmem(conv_integer(hit_index));

end tegMem_arch;

