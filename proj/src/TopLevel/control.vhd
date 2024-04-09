-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- control_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the control unit.
--
-- 2/29/24
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;

entity control is


	port(
		i_Opc          : in std_logic_vector(5 downto 0); 
     	i_Funct        : in std_logic_vector(5 downto 0);
      i_Zero         : in std_logic;   
     	o_ctrl_Q       : out control_t
   ); 

end control;

architecture mixed of control is

begin
   o_ctrl_Q.alu_control.allow_ovfl <= '1'    when ((i_Opc = "000000" and (i_Funct = "100000" or i_Funct = "100010")) or (i_Opc = "001000")) else   -- add, sub, addi
                          '0';  

   o_ctrl_Q.alu_control.alu_select <= "0000" when ((i_Opc = "000000" and (i_Funct = "100000" or i_Funct =  "100001"))          -- add, addu
                       or (i_Opc = "001000" or i_Opc = "001001")                                             -- addi, addiu
                       or (i_Opc = "101011" or i_Opc = "100011" or i_Opc = "100000" or i_Opc = "100001" or i_Opc = "100100" or i_Opc = "100101")) else -- sw, lw, lb, lh, lbu, lhu

                          "0001" when ((i_Opc = "000000" and (i_Funct = "100010" or i_Funct = "100011")) -- sub, subu
                       or (i_Opc = "000100" or i_Opc = "000101")) else                                     -- bne, beq

                          "0010" when ((i_Opc = "000000" and i_Funct = "100100")             -- and
                       or (i_Opc = "001100")) else                                                -- andi

                          "0011" when ((i_Opc = "000000" and i_Funct = "100101")             -- or 
                       or (i_Opc = "001101")) else                                               -- ori

                          "0100" when ((i_Opc = "000000" and i_Funct = "100110")             -- xor
                       or (i_Opc = "001110")) else                                               -- xori

                          "0101" when ((i_Opc = "000000" and i_Funct = "100111")) else            -- nor

                          "0110" when ((i_Opc = "001111")) else                                    -- lui

                          "0111" when ((i_Opc = "000000" and i_Funct = "101010")             -- slt
                       or (i_Opc = "001010")) else                                                -- slti

                          "1000" when ((i_Opc = "000000" and i_Funct = "000000") or (i_Opc = "000000" and i_Funct = "000100")) else             -- sll, sllv

                          "1001" when ((i_Opc = "000000" and i_Funct = "000010") or (i_Opc = "000000" and i_Funct = "000110")) else             -- srl, srlv

                          "1010" when ((i_Opc = "000000" and i_Funct = "000011") or (i_Opc = "000000" and i_Funct = "000111"));               -- sra, srav

    ---------------------------------------------------------------------------------------------------------------------------------

    o_ctrl_Q.halt <= '1' when i_Opc = "010100" else '0';

    o_ctrl_Q.reg_wr    <= '0'   when (i_Opc = "101011" or i_Opc = "000010" or i_Opc = "000101" or i_Opc = "000100" or (i_Opc = "000000" and i_Funct = "001000")) else -- sw, j,beq, bne, jr
                          '1'; 


    o_ctrl_Q.mem_wr    <= '1'   when (i_Opc = "101011") else       -- sw
		          '0';

    o_ctrl_Q.alu_input1_sel  <= '1' when ((i_Opc = "000000" and i_Funct = "000000") or (i_Opc = "000000" and i_Funct = "000010") or (i_Opc = "000000" and i_Funct = "000011")) else -- sll, srl, sra
                                '0';


    o_ctrl_Q.reg_dst_sel <= "01" when ( i_Opc = "000000" and (i_Funct = "100000" or i_Funct = "100010" or i_Funct = "100100" or i_Funct = "100001" or i_Funct = "100111" or i_Funct = "100101" or i_Funct = "100110" or i_Funct = "100011" or i_Funct = "101010"  -- add, sub, and, addu, nor, or, xor, subu, slt,
                  or i_Funct="000000" or i_Funct="000010" or i_Funct="000011" or i_Funct="000100" or i_Funct="000110" or i_Funct="000111") ) else  -- sll, srl, sra, sllv, srlv, srav                                                                     
		            "10" when (i_Opc = "000011") else    -- jal 
		            "00";

    o_ctrl_Q.reg_wr_sel <= "11" when (i_Opc = "100000" or i_Opc = "100001" or i_Opc = "100100" or i_Opc = "100101") else -- lb, lh, lbu, lhu
                  "10" when (i_Opc = "000011") else     -- jal
		            "01" when (i_Opc = "100011") else  -- lw
		            "00";

    o_ctrl_Q.alu_input2_sel <= "10" when (i_Opc = "001000" or i_Opc = "001001" or i_Opc = "001111" or i_Opc = "001010" or i_Opc = "101011" or i_Opc = "100011" or i_Opc = "100000" or i_Opc = "100001" or i_Opc = "100100" or i_Opc = "100101") else -- addi, addiu, lui, slti, sw, lw, lb, lh, lbu, lhu
	                       "11" when (i_Opc = "001100" or i_Opc = "001101" or i_Opc = "001110") else    -- andi, ori, xori
		               "00";

    o_ctrl_Q.pc_sel <= "01" when (i_Opc = "000010" or i_Opc = "000011") else            -- j, jal
                       "10" when ((i_Opc = "000101" and i_Zero = '0') or (i_Opc = "000100" and i_Zero = '1')) else -- bne, beq
                       "11" when (i_Opc = "000000" and i_Funct = "001000") else         -- jr
                       "00";

    o_ctrl_Q.partial_mem_sel <= "00" when (i_Opc = "100000") else       -- lb
                              "01" when (i_Opc = "100001") else       -- lh
                              "10" when (i_Opc = "100100") else       -- lbu
                              "11" when (i_Opc = "100101");           -- lbhu
    

 
end mixed;