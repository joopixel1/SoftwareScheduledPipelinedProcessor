-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_control_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- control unit of the processor.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;


entity tb_control_unit is
  generic(gCLK_HPER   : time := 50 ns);
end tb_control_unit;

architecture behavior of tb_control_unit is
  
    -- Calculate the clock period as twice the half-period
    constant cCLK_PER   : time      := gCLK_HPER * 2;

    component control_unit
        port(
	    	    i_Opc          : in std_logic_vector(5 downto 0); 
            i_Funct        : in std_logic_vector(5 downto 0);   
            o_ctrl_Q       : out control_t;    
            o_alu_Q        : out alu_control_t  
        ); 
    end component;

    -- Temporary signals to connect to the control unit.
    signal s_OPc, s_Funct  : std_logic_vector(5 downto 0);
    signal s_ctrl_Q        : control_t;
    signal s_alu_Q         : alu_control_t;

begin

    DUT: control_unit 
    port map(
        i_Opc         => s_OPc, 
        i_Funct       => s_Funct,
	o_ctrl_Q      => s_ctrl_Q,
        o_alu_Q       => s_alu_Q
    );

  -- Testbench process
  P_TB: process
  begin
---------R-type instructions-------
    s_Opc   <= "000000";

    -- (add) instruction
    s_Funct <= "100000";
    wait for cCLK_PER; 

    -- (addu) instruction
    s_Funct   <= "100001";
    wait for cCLK_PER; 

    -- (sub) instruction
    s_Funct <= "100010";
    wait for cCLK_PER; 

    -- (subu) instruction
    s_Funct <= "100011";
    wait for cCLK_PER; 

    -- (and) instruction
    s_Funct   <= "100100";
    wait for cCLK_PER; 

    -- (nor) instruction
    s_Funct   <= "100111";
    wait for cCLK_PER; 

    -- (xor) instruction
    s_Funct <= "100110";
    wait for cCLK_PER;
 
    -- (or) instruction
    s_Funct <= "100101";
    wait for cCLK_PER; 

    -- (slt) instruction
    s_Funct <= "101010";
    wait for cCLK_PER; 

    -- (sll) instruction
    s_Funct <= "000000";
    wait for cCLK_PER; 

    -- (srl) instruction
    s_Funct <= "000010";
    wait for cCLK_PER; 

    -- (sra) instruction
    s_Funct <= "000011";
    wait for cCLK_PER;

    -- (sllv) instruction
    s_Funct <= "000100";
    wait for cCLK_PER; 

    -- (srlv) instruction
    s_Funct <= "000110";
    wait for cCLK_PER; 

    -- (srav) instruction
    s_Funct <= "000111";
    wait for cCLK_PER; 

    -- (jr) instruction
    s_Funct <= "001000";
    wait for cCLK_PER; 

--------------I-type instructions------------------
    s_Funct <= "000000";

    -- (addi) instruction
    s_Opc   <= "001000";
    wait for cCLK_PER; 

    -- (addiu) instruction
    s_Opc   <= "001001";
    wait for cCLK_PER; 

    -- (andi) instruction
    s_Opc   <= "001100";
    wait for cCLK_PER; 

    -- (xori) instruction
    s_Opc   <= "001110";
    wait for cCLK_PER; 

    -- (ori) instruction
    s_Opc   <= "001101";
    wait for cCLK_PER; 

    -- (slti) instruction
    s_Opc   <= "001010";
    wait for cCLK_PER; 

    -- (lui) instruction
    s_Opc   <= "001111";
    wait for cCLK_PER; 

    -- (beq) instruction
    s_Opc   <= "000100";
    wait for cCLK_PER; 

    -- (bne) instruction
    s_Opc   <= "000101";
    wait for cCLK_PER; 

    -- (lw) instruction
    s_Opc   <= "100011";
    wait for cCLK_PER; 

    -- (sw) instruction
    s_Opc   <= "101011";
    wait for cCLK_PER; 

    -- (lb) instruction
    s_Opc   <= "100000";
    wait for cCLK_PER;
 
    -- (lh) instruction
    s_Opc   <= "100001";
    wait for cCLK_PER; 

    -- (lbu) instruction
    s_Opc   <= "100100";
    wait for cCLK_PER; 

    -- (lhu) instruction
    s_Opc   <= "100101";
    wait for cCLK_PER; 

-------------J-type instructions----------
    -- (j) instruction
    s_Opc   <= "000010";
    wait for cCLK_PER; 

    -- (jal) instruction
    s_Opc   <= "000011";
    wait for cCLK_PER; 


    wait;
  end process;
  
end behavior;
