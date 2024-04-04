-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ones_comp.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a n-bit ones complementor using structural VHDL
--
--
-- NOTES:
-- 1/14/19 by H3::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity adder is

	port(
		i_D0        : in std_logic;
		i_D1        : in std_logic;
		i_C        : in std_logic;
		o_S         : out std_logic;
		o_C         : out std_logic
    ); 

end adder;

architecture dataflow of adder is

begin

    o_C <= (i_D0 and i_D1) or (i_D0 and i_C) or (i_D1 and i_C);
    o_S <= i_D0 xor i_D1 xor i_C;

end dataflow;