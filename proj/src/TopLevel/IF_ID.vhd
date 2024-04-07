-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- IF_ID.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the fetch to decode
-- register for the pipelined processor.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.MIPS_types.all;

entity IF_ID is

    generic(
        N           : positive;
        M           : positive
    );


    port(
        i_CLK           : in std_logic;
        i_RST           : in std_logic;
        i_PCInc         : in std_logic_vector(N-1 downto 0);
        i_Inst          : in std_logic_vector(N-1 downto 0);
        o_PCInc         : out std_logic_vector(N-1 downto 0);
        o_Inst          : out std_logic_vector(N-1 downto 0)
    ); 

end IF_ID;

architecture structure of IF_ID is

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

    pc_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_PCInc,
            o_Q         => o_PCInc
        );

    inst_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_Inst,
            o_Q         => o_Inst
        );



end structure;
