-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- nm_mux.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit select mux for input of size M.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.MIPS_types.all;

entity nm_mux is

    generic(
        N           : positive;
        M           : positive
    );

    port(
        i_D         : in std_logic_vector_vector((2**N)-1 downto 0)(M-1 downto 0);       -- Data input
        i_S         : in std_logic_vector(N-1 downto 0);                                   -- Select value input
        o_Q         : out std_logic_vector(M-1 downto 0)                                   -- Data value output
    );

end nm_mux;

architecture dataflow of nm_mux is
  
begin

    o_Q <= i_D(to_integer(unsigned(i_S)));
    
end dataflow;
