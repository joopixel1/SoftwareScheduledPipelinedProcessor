-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- IF_ID.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the memory to writeback
-- register for the pipelined processor.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MEM_WB is

    generic(N : integer := 32 );
    port(
        i_CLK              : in std_logic;
        i_RST              : in std_logic;
        i_Addr             : in std_logic_vector(N-1 downto 0);
        i_Q                : in std_logic_vector(N-1 downto 0);
        i_Partial_mem      : in std_logic_vector(N-1 downto 0);
        o_Addr             : out std_logic_vector(N-1 downto 0);
        o_Q                : out std_logic_vector(N-1 downto 0);
        o_Partial_mem      : out std_logic_vector(N-1 downto 0)
    ); 

end MEM_WB;

architecture structure of MEM_WB is

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

    Addr_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_Addr,
            o_Q         => o_Addr
        );

    Q_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_Q,
            o_Q         => o_Q
        );

    Partial_mem_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_Partial_mem,
            o_Q         => o_Partial_mem
        );



end structure;
