-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- decoder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit decoder.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder is

    generic(
        N           :positive
    );

    port(
        i_WE         : in std_logic;                            -- Write enable input
        i_S          : in std_logic_vector(N-1 downto 0);       -- Data value input
        o_Q          : out std_logic_vector((2**N)-1 downto 0)  -- Data value output
    );

end decoder;

architecture dataflow of decoder is
    
    constant a  : integer := 1;
    
    signal s_T      : std_logic_vector((2**N)-1 downto 0)     := ((2**N)-1 downto 1 => '0') & '1';
  
begin
  
    o_Q <= (others => '0') when i_WE = '0' else
        std_logic_vector( (unsigned(s_T) sll to_integer(unsigned(i_S))) );
    
end dataflow;
