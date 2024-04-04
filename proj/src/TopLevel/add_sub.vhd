-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- add_sub_n.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a n-bit adder subtractor unit using structural VHDL
--
--
-- NOTES:
-- 1/14/19 by H3::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity add_sub is

    generic(
        N           :positive
    );

	port(
		i_A         : in std_logic_vector(N-1 downto 0);
		i_B         : in std_logic_vector(N-1 downto 0);
		i_S         : in std_logic;
        o_OVFL      : out std_logic;
		o_Y         : out std_logic_vector(N-1 downto 0);
        o_C         : out std_logic
    ); 

end add_sub;

architecture structure of add_sub is

    -- Describe the component entities as defined in ones_comp.vhd
 	-- mux2t1.vhdl, adder_n.vhdl (not strictly necessary).
    component mux2t1_N
        generic(
            N           :positive       := N
        );
        port(
            i_D0        : in std_logic_vector(N-1 downto 0);
            i_D1        : in std_logic_vector(N-1 downto 0);
            i_S         : in std_logic;
            o_O         : out std_logic_vector(N-1 downto 0)
        ); 
    end component;


    component ones_comp
        generic(
            N           :positive       := N
        );
        port(
            i_X        : in std_logic_vector(N-1 downto 0);
            o_Y         : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component adder_n
        generic(
            N           :positive       := N
        );    
        port(
            i_D0        : in std_logic_vector(N-1 downto 0);
            i_D1        : in std_logic_vector(N-1 downto 0);
            i_C        : in std_logic;
            o_S         : out std_logic_vector(N-1 downto 0);
            o_C         : out std_logic
        ); 
    end component;

    -- TODO: change input and output signals as needed.
    signal s_B   : std_logic_vector(N-1 downto 0);
    signal s_C   : std_logic_vector(N-1 downto 0);

begin
  
    i_ones_comp: ones_comp
    port MAP(
        i_X          => i_B,
       	o_Y          => s_B
    );

	i_mux2t1_N: mux2t1_N
    port MAP(
        i_D0        => i_B,
       	i_D1        => s_B,
        i_S         => i_S,
       	o_O         => s_C
    );
  
    i_adder_n: adder_n
	port MAP(
        i_D0        => i_A,
       	i_D1        => s_C,
        i_C         => i_S,
        o_S         => o_Y,
       	o_C         => o_C
    );

    o_OVFL <= '1' when (i_A(31) = s_C(31) and i_A(31) = not o_Y(31) ) else
        '0'; 

end structure;