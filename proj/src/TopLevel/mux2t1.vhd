-------------------------------------------------------------------------
-- Jesutofunmi Obimakinde
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- 2_to_1_mux.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2:1 mux using structural VHDL
--
--
-- NOTES:
-- 1/14/19 by H3::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity mux2t1 is

	port(
		i_D0					: in std_logic;
		i_D1         : in std_logic;
		i_S          : in std_logic;
		o_O          : out std_logic); 

end mux2t1;

architecture dataflow of mux2t1 is
begin
  

  o_O <= i_D0 when (i_S = '0') else i_D1;


end dataflow;