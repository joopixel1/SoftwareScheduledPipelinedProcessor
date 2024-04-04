-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- n_dffg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit edge-triggered
-- flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-- 11/25/19 by H3:Changed name to avoid name conflict with Quartus
--          primitives.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity n_dffg is

    generic(
        N           :positive
    );

    port(
        i_CLK        : in std_logic;                            -- Clock input
        i_RST        : in std_logic;                            -- Reset input
        i_WE         : in std_logic;                            -- Write enable input
        i_D          : in std_logic_vector(N-1 downto 0);       -- Data value input
        o_Q          : out std_logic_vector(N-1 downto 0)       -- Data value output
    );

end n_dffg;

architecture structure of n_dffg is

    component dffg
        port(
            i_CLK        : in std_logic;     -- Clock input
            i_RST        : in std_logic;     -- Reset input
            i_WE         : in std_logic;     -- Write enable input
            i_D          : in std_logic;     -- Data value input
            o_Q          : out std_logic     -- Data value output
        );
    end component;

begin

    dffg_instances: for i in N-1 downto 0 generate
        dffg_instance : dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => i_WE,
            i_D         => i_D(i),
            o_Q         => o_Q(i)
        );
    end generate;
  
end structure;
