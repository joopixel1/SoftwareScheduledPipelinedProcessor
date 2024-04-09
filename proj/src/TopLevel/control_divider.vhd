-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- control_divider.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the control unit.
--
-- 2/29/24
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;

entity control_divider is
    port(
        i_ctrl          : in control_t;
        o_EXControl     : out ex_control_t;
        o_MEMControl    : out mem_control_t;
        o_WBControl     : out wb_control_t 
    );
end control_divider;

architecture behavior of control_divider is
begin
    -- Execution stage control signals
    o_EXControl.alu_control.allow_ovfl  <= i_ctrl.alu_control.allow_ovfl;
    o_EXControl.alu_control.alu_select  <= i_ctrl.alu_control.alu_select;
    o_EXControl.alu_input1_sel          <= i_ctrl.alu_input1_sel;
    o_EXControl.alu_input2_sel          <= i_ctrl.alu_input2_sel;

    -- Memory stage control signals
    o_MEMControl.mem_wr                 <= i_ctrl.mem_wr;
    o_MEMControl.partial_mem_sel        <= i_ctrl.partial_mem_sel;

    -- Write-back stage control signals
    o_WBControl.reg_wr                  <= i_ctrl.reg_wr;
    o_WBControl.reg_wr_sel              <= i_ctrl.reg_wr_sel;
    o_WBControl.halt                    <= i_ctrl.halt;
end behavior;
