-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- IF_ID.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the execute to memory
-- register for the pipelined processor.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity EX_MEM is

    generic(N : integer := 32 );
    port(
        i_CLK              : in std_logic;
        i_RST              : in std_logic;
        i_ALUOut           : in std_logic_vector(N-1 downto 0);
        i_RT               : in std_logic_vector(N-1 downto 0);
        o_ALUOut           : out std_logic_vector(N-1 downto 0);
        o_RT               : out std_logic_vector(N-1 downto 0)
    ); 

end EX_MEM;

architecture structure of EX_MEM is

    component n_dffg
        generic(N  : positive  := 32);
        port(
            i_CLK        : in std_logic;                          
            i_RST        : in std_logic;                         
            i_WE         : in std_logic;                         
            i_D          : in std_logic_vector(N-1 downto 0);   
            o_Q          : out std_logic_vector(N-1 downto 0)      
        );
    end component;

begin

    ALU_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_ALUOut,
            o_Q         => o_ALUOut
        );

    RT_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_RT,
            o_Q         => o_RT
        );

end structure;
