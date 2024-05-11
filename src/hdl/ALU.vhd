--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|
--|
--|
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
-- TODO
port(
             i_A : in std_logic_vector (7 downto 0);
             i_B : in std_logic_vector (7 downto 0);
             i_op : in std_logic_vector (3 downto 0);
             o_result : out std_logic_vector (7 downto 0);
             o_carryOut : out std_logic_vector (2 downto 0)
   --          o_zero : out std_logic_vector (7 downto 0)
          );    
end ALU;

architecture behavioral of ALU is 

component ALU_mux is
              port(
                 i_and : in std_logic_vector (7 downto 0);
                 i_or : in std_logic_vector (7 downto 0);--changed 7 from 6
                 i_shift : in std_logic_vector (7 downto 0);
                 i_sum : in std_logic_vector (7 downto 0);
                 i_opcode : in std_logic_vector (3 downto 0);
                 o_result : out std_logic_vector (7 downto 0)
             --    o_out : out std_logic_vector (2 downto 0)
              );    
            end component; 
component LR_mux is
              port(
                 i_left : in std_logic_vector (7 downto 0);
                 i_opLR : in std_logic_vector (3 downto 0);
                 i_right : in std_logic_vector (7 downto 0);--changed 7 from 6
                 o_shifts : out std_logic_vector (7 downto 0)
              );    
            end component; 
component AS_mux is 
              port(
                 i_add : in std_logic_vector (7 downto 0);
                 i_sub : in std_logic_vector (7 downto 0);
                 i_opAS : in std_logic_vector (3 downto 0);
                 o_shifts : out std_logic_vector (7 downto 0)
              );    
            end component; 
component halfAdder is
              port(
                 i_A : in std_logic_vector (7 downto 0);
                 i_B : in std_logic_vector (7 downto 0);--changed 7 from 6
                -- i_opAS : in std_logic_vector (2 downto 0);
                 o_Cout : out std_logic_vector (2 downto 0);
                 o_S : out std_logic_vector (7 downto 0)
              );    
            end component; 
  
-- CONSTANTS ------------------------------------------------------------------
  --  signal f_Q : std_logic_vector (3 downto 0) :="1000"; 
	--signal f_Q_next : std_logic_vector (3 downto 0) :="1000"; --to default state(all off)
--	signal sum : std_logic_vector (; 
	--signal sub : std_logic; 
	signal c_and : std_logic_vector (7 downto 0);
	signal c_or : std_logic_vector (7 downto 0);
	signal w_addMux : std_logic_vector (7 downto 0);
	signal w_shiftL : std_logic_vector (7 downto 0);
	signal w_shiftR : std_logic_vector (7 downto 0);
	signal w_shift : std_logic_vector (7 downto 0);
	signal w_sum : std_logic_vector (7 downto 0);
	signal w_cin : std_logic;
	signal w_result_final : std_logic_vector (7 downto 0);
	signal w_zero : std_logic_vector (2 downto 0);
	signal w_notB : std_logic_vector (7 downto 0);
begin

o_result <= w_result_final;
c_and <= i_A and i_B;
c_or <= i_A or i_B;

ALUmux_inst : ALU_mux port map (
                 i_and      => c_and,
                 i_or       => c_or,
                 i_shift    => w_shift,
                 i_sum      => w_sum,
                 i_opcode   => i_op,
                 o_result   => w_result_final
              --   o_out      => w_zero
              );    

ASmux_inst : AS_mux port map (--LR, AS, halfAdder
                 i_add       => i_B,
                 i_sub       => w_notB,
                 i_opAS      => i_op,
                 o_shifts    => w_addMux
                
              );     
              
LRmux_inst : LR_mux port map (--LR, AS, halfAdder
               i_left      => w_shiftL,
               i_opLR       => i_op,
               i_right    => w_shiftR,
               o_shifts      => w_shift
            );    
            
halfAdder_inst : halfAdder port map (--LR, AS, halfAdder
               i_A     => i_A,
               i_B       => w_addMux,
               o_Cout    => o_carryOut,
               o_S      => w_sum
            );              
                        

-- CONCURRENT STATEMENTS --------------------------------------------------------	
    w_shiftL <= std_logic_vector(shift_left(unsigned(i_A), to_integer(unsigned(i_B(2 downto 0)))));
    w_shiftR <= std_logic_vector(shift_right(unsigned(i_A), to_integer(unsigned(i_B(2 downto 0)))));
    w_notB   <= not i_B;
    --w_cin   <= i_opcode(0 downto 0);
 --   sum     <= unsigned(i_A) + unsigned(i_B); 
   -- sub     <= std_logic_vector(unsigned(i_A) + unsigned(i_B) + unsigned(w_cin)); 
    
---------------------------------------------------------------------------------

-- PROCESSES --------------------------------------------------------------------

-----------------------------------------------------	

end behavioral;
