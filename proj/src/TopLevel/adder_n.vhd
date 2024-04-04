-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


--adder_n.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a N-bit ones complementor using structural VHDL
--
--
-- NOTES:
-- 1/14/19 by H3::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity adder_n is

    generic(
        N           :positive
    );

    port(
		i_D0        : in std_logic_vector(N-1 downto 0);
		i_D1        : in std_logic_vector(N-1 downto 0);
		i_C        : in std_logic;
		o_S         : out std_logic_vector(N-1 downto 0);
		o_C         : out std_logic
    ); 

end adder_n;

architecture structure of adder_n is

    -- Describe the component entities as defined in invg.vhdl,
 	-- andg2.vhdl, org2.vhdl (not strictly necessary).
    component adder
        port(
            i_D0        : in std_logic;
            i_D1        : in std_logic;
            i_C        : in std_logic;
            o_S         : out std_logic;
            o_C         : out std_logic
        ); 
    end component;

    -- TODO: change input and output signals as needed.
    signal s_C   : std_logic_vector(N-2 downto 0);

begin
    
    i0_adder_1 : adder
    port MAP(
        i_D0        => i_D0(0),
        i_D1        => i_D1(0),
        i_C         => i_C,
        o_S         => o_S(0),
        o_C         => s_C(0)
    ); 

    s0_adder_1: for i in N-2 downto 1 generate
        i1_adder_1 : adder
        port MAP(
            i_D0        => i_D0(i),
            i_D1        => i_D1(i),
            i_C         => s_C(i-1),
            o_S         => o_S(i),
            o_C         => s_C(i)
        ); 
    end generate;

    i2_adder_1 : adder
    port MAP(
        i_D0        => i_D0(N-1),
        i_D1        => i_D1(N-1),
        i_C         => s_C(N-2),
        o_S         => o_S(N-1),
        o_C         => o_C
    ); 

end structure;