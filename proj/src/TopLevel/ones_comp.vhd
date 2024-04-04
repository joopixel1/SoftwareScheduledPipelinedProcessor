-------------------------------------------------------------------------
-- Jesutofunmi Obimakinde
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


entity ones_comp is

    generic(
        n           :positive
    );

	port(
		i_X        : in std_logic_vector(n-1 downto 0);
		o_Y         : out std_logic_vector(n-1 downto 0)
    ); 

end ones_comp;

architecture structure of ones_comp is

    -- Describe the component entities as defined in invg.vhdl,
 	-- andg2.vhdl, org2.vhdl (not strictly necessary).
    component invg
        port(
            i_A          : in std_logic;
            o_F          : out std_logic
        );
    end component;

begin
  
    invg_instances: for i in n-1 downto 0 generate
        invg_instance : invg
        port MAP(
            i_A        => i_X(i),
            o_F         => o_Y(i)
        );
    end generate;

end structure;