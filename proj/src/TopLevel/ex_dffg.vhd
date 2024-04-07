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
library work;
use work.MIPS_types.all;

entity ex_dffg is

    port(
        i_CLK        : in std_logic;                            -- Clock input
        i_RST        : in std_logic;                            -- Reset input
        i_WE         : in std_logic;                            -- Write enable input
        i_D          : in ex_control_t;       -- Data value input
        o_Q          : out ex_control_t      -- Data value output
    );

end ex_dffg;

architecture mixed of ex_dffg is
    signal s_D    : ex_control_t;    -- Multiplexed input to the FF
    signal s_Q    : ex_control_t;    -- Output of the FF
  
  begin
  
    -- The output of the FF is fixed to s_Q
    o_Q <= s_Q;
    
    -- Create a multiplexed input to the FF based on i_WE
    with i_WE select
      s_D <= i_D when '1',
             s_Q when others;
    
    -- This process handles the asyncrhonous reset and
    -- synchronous write. We want to be able to reset 
    -- our processor's registers so that we minimize
    -- glitchy behavior on startup.
    process (i_CLK, i_RST)
    begin
      if (i_RST = '1') then
        s_Q.alu_input1_sel <= '0'; -- Use "(others => '0')" for N-bit values
        s_Q.alu_input2_sel <= "00";
        s_Q.alu_control.allow_ovfl <= '0';
        s_Q.alu_control.alu_select <= "0000";
      elsif (rising_edge(i_CLK)) then
        s_Q <= s_D;
      end if;
  
    end process;
    
  end mixed;
