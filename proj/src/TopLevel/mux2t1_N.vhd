-------------------------------------------------------------------------
-- Jesutofunmi Obimakinde
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2:1 mux using structural VHDL
--
--
-- NOTES:
-- 1/14/19 by H3::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity mux2t1_N is

    generic(
        n           :positive
    );

	port(
		i_D0        : in std_logic_vector(n-1 downto 0);
		i_D1        : in std_logic_vector(n-1 downto 0);
		i_S         : in std_logic;
		o_O         : out std_logic_vector(n-1 downto 0)
    ); 

end mux2t1_N;

architecture structure of mux2t1_N is

    -- Describe the component entities as defined in invg.vhdl,
 	-- andg2.vhdl, org2.vhdl (not strictly necessary).
    component mux2t1
        port(
            i_D0        : in std_logic;
            i_D1        : in std_logic;
            i_S         : in std_logic;
            o_O         : out std_logic
        ); 
    end component;

begin
  
    mux2t1_instances: for i in n-1 downto 0 generate
        mux2t1_instance : mux2t1
        port MAP(
            i_D0        => i_D0(i),
            i_D1        => i_D1(i),
            i_S         => i_S,
            o_O         => o_O(i)
        );
    end generate;

end structure;