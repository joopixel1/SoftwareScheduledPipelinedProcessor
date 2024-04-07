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

entity wb_dffg is
    port(
        i_CLK        : in std_logic;                      -- Clock input
        i_RST        : in std_logic;                      -- Reset input
        i_WE         : in std_logic;                      -- Write enable input
        i_D          : in wb_control_t;                  -- Data value input
        o_Q          : out wb_control_t                  -- Data value output
    );
end wb_dffg;

architecture mixed of wb_dffg is
    signal s_D    : wb_control_t;     -- Multiplexed input to the FF
    signal s_Q    : wb_control_t;     -- Output of the FF
begin
    -- The output of the FF is fixed to s_Q
    o_Q <= s_Q;

    -- Create a multiplexed input to the FF based on i_WE
    with i_WE select
        s_D <= i_D when '1',
               s_Q when others;

    -- This process handles the asynchronous reset and
    -- synchronous write.
    process (i_CLK, i_RST)
    begin
        if (i_RST = '1') then
            s_Q.reg_wr <= '0';  -- Reset the output to all zeros
            s_Q.reg_wr_sel <= "00";
        elsif (rising_edge(i_CLK)) then
            s_Q <= s_D;
        end if;
    end process;
end mixed;
