library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlU is
    Port ( clk   : in STD_LOGIC;
		   rst_n : in STD_LOGIC;
		   -- CPU
		   wrCPU  : in STD_LOGIC;
		   rdCPU  : in STD_LOGIC;
		   ackCPU : out STD_LOGIC;
		   
		   -- TEG 
		    hit  : in STD_LOGIC;
			slru : out STD_LOGIC;
			wrt  : out STD_LOGIC;
			md   : out STD_LOGIC;
			lm   : in STD_LOGIC;
			
		   -- DATA
		    wr : out STD_LOGIC;
			
		   -- SELECTION
		   wsel : out STD_LOGIC;
		   tsel : out STD_LOGIC;
		   
		   -- RAM IF
		   ramwr  : out STD_LOGIC;
		   ramrd  : out STD_LOGIC;
		   ramack : in STD_LOGIC
          );
end ControlU;

architecture cu_arch of ControlU is

 type states is ( S_IDLE,
				  S_RDHIT, 
				  S_WRHIT,
				  S_RAMWR,
				  S_RAMRD
 				);
 signal state : states := S_IDLE;
 
 signal next_state : states;

 begin
    
 state_p : process(clk)
	 begin
		 if (clk'event and clk = '1') then
			 if rst_n = '0' then
				state <= S_IDLE;
			 else
				state <= next_state;
		 end if;
	 end if;
 end process state_p;
 
 next_state_p : process(state, hit, lm, wrCPU, rdCPU, ramack)
 begin
	case state is 
		when S_IDLE =>
			if hit = '1' and wrCPU = '1' then 
				next_state <= S_WRHIT;
			elsif hit = '1' and rdCPU = '1' then 
				next_state <= S_RDHIT;
			elsif hit = '0' and lm = '1' then 
				next_state <= S_RAMWR;
			elsif hit = '0' and lm = '0' and (rdCPU = '1' or wrCPU = '1') then 
				next_state <= S_RAMRD;
			else 
				next_state <= S_IDLE;
			end if; 
		when S_WRHIT => next_state <= S_IDLE;
		when S_RDHIT => next_state <= S_IDLE;
		when S_RAMWR => 
			if ramack = '1' then 
				next_state <= S_RAMRD;
			else 
				next_state <= S_RAMWR;
			end if;
		when S_RAMRD => 
			if ramack = '1' and rdCPU = '1' then 
				next_state <= S_RDHIT;
			elsif ramack = '1' and wrCPU = '1' then 
				next_state <= S_WRHIT;
			-- if ramack = '1'  then 
			-- 	next_state <= S_IDLE;
			else
				next_state <= S_RAMRD;
			end if;
	end case;
 end process next_state_p;


 wsel <= '1' when state = S_RAMRD else '0'; 
 tsel <= '1' when state = S_RAMWR else '0';


 ackCPU <= '1' when state = S_RDHIT else 
		   '1' when state = S_WRHIT else
		   '0';
		   
 --slru <= '1' when state = S_RDHIT else '0';
 md   <= '1' when state = S_WRHIT else '0';
 wrt  <= '1' when state = S_RAMRD and ramack = '1' else '0';
 wr   <= '1' when state = S_RAMRD or state = S_WRHIT else '0';
 
 ramwr <= '1' when state = S_RAMWR else '0';
 ramrd <= '1' when state = S_RAMRD else '0';
 

 

end cu_arch;