-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an extender from 16 bit to 32 bit which could be signeed or zero extended.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;

entity extender is

    port(
        i_S         : in std_logic;                            -- Write enable input
        i_D          : in std_logic_vector((DATA_WIDTH/2)-1 downto 0);       -- Data value input
        o_Q          : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Data value output
    );

end extender;

architecture dataflow of extender is
begin
  
    o_Q <= (16 to 31 => '0') & i_D when i_S = '0' else
        (16 to 31 => i_D(15)) & i_D;
    
end dataflow;
