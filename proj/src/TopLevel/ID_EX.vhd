-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ID_EX.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the decode to execute
-- register for the pipelined processor.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ID_EX is

    generic(N : integer := 32 );
    port(
        i_CLK                : in std_logic;
        i_RST                : in std_logic;
        i_RS                 : in std_logic_vector(N-1 downto 0);
        i_RT                 : in std_logic_vector(N-1 downto 0);
        i_ZeroExtIn          : in std_logic_vector(N-1 downto 0);
        i_SignExtIn          : in std_logic_vector(N-1 downto 0);
        o_RS                 : out std_logic_vector(N-1 downto 0);
        o_RT                 : out std_logic_vector(N-1 downto 0);
        o_ZeroExtOut         : out std_logic_vector(N-1 downto 0);
        o_SignExtOut         : out std_logic_vector(N-1 downto 0)
    ); 

end ID_EX;

architecture structure of ID_EX is

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

    RS_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_RS,
            o_Q         => o_RS
        );

    RT_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_RT,
            o_Q         => o_RT
        );

    ZeroExtend_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_ZeroExtIn,
            o_Q         => o_ZeroExtOut
        );

    SignExtend_input : n_dffg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => '1',
            i_D         => i_SignExtIn,
            o_Q         => o_SignExtOut
        );

end structure;
