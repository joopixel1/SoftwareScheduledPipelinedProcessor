-- Quartus Prime VHDL Template
-- Single-port RAM with single read/write address

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity partial_mem is

    generic(
        N : integer := 32
    );

    port(
        i_X         : in std_logic_vector(N-1 downto 0);
        i_A         : in std_logic_vector(1 downto 0);
        i_S         : in std_logic_vector(1 downto 0);
        o_Y         : out std_logic_vector(N-1 downto 0)
    ); 

end partial_mem;

architecture behavior of partial_mem is

    signal s_B  : std_logic_vector(N/4 - 1 downto 0); 
    signal s_H  : std_logic_vector(N/2 - 1 downto 0);
    
begin

    with i_A select
        s_B <= i_X(N/4 - 1 downto 0) when "00",
            i_X(N/2 - 1 downto N/4) when "01",
            i_X(3*N/4 - 1 downto N/2) when "10",
            i_X(N - 1 downto 3*N/4) when others;

    with i_A(1) select
        s_H <= i_X(N/2 - 1 downto 0) when '0',
        i_X(N - 1 downto N/2) when others;
           

    with i_S select
        o_Y <= (N-1 downto N/4 => s_B(N/4 - 1)) & s_B when "00",
            (N-1 downto N/2 => s_H(N/2 - 1)) & s_H when "01",
            (N-1 downto N/4 => '0') & s_B when "10",
            (N-1 downto N/2 => '0') & s_H when others;

end behavior;
