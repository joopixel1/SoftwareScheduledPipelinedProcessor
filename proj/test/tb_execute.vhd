-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_execute.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- n-bit decoder.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;


entity tb_execute is
  generic(gCLK_HPER   : time := 50 ns);
end tb_execute;

architecture behavior of tb_execute is
  
    -- Calculate the clock period as twice the half-period
    constant cCLK_PER   : time      := gCLK_HPER * 2;
    constant L          : integer   := ADDR_WIDTH;
    constant M          : integer   := SELECT_WIDTH;
    constant N          : integer   := DATA_WIDTH;

    component execute
        port(
            PCInc           : in std_logic_vector(N-1 downto 0);
            inst            : in std_logic_vector(N-1 downto 0);
            iCLK            : in std_logic;
            iRST            : in std_logic;
            reg_wr          : in std_logic;
            mem_wr          : in std_logic;
            alu_input1_sel  : in std_logic;
            partial_mem_sel : in std_logic_vector(1 downto 0);
            reg_dst_sel     : in std_logic_vector(1 downto 0);
            reg_wr_sel      : in std_logic_vector(1 downto 0);
            alu_input2_sel  : in std_logic_vector(1 downto 0);
            alu_control     : in alu_control_t;
            reg1_val        : out std_logic_vector(N-1 downto 0);
            oALUOut         : out std_logic_vector(N-1 downto 0);
            oOVFL           : out std_logic;
            oZero           : out std_logic
        ); 
    end component;

    -- Temporary signals to connect to the dff component.
    signal s_CLK, s_RST, s_RegWr, s_MemWr, s_Ovfl, s_Zero, s_ALUInput1Sel : std_logic;
    signal s_Reg1Val, s_ALUOut                                            : std_logic_vector(N-1 downto 0);
    signal s_RegDstSel, s_RegWrSel, s_ALUInput2Sel, s_PartialMemSel       : std_logic_vector(1 downto 0);
    signal s_ALUControl                                                   : alu_control_t;
    signal s_Inst, s_PCInc                                                : std_logic_vector(N-1 downto 0);

begin

    DUT: execute 
    port map(
        PCInc           => s_PCInc,
        inst            => s_Inst,
        iCLK            => s_CLK, 
        iRST            => s_RST,
        reg_wr          => s_RegWr,
        mem_wr          => s_MemWr,
        partial_mem_sel => s_PartialMemSel,
        alu_input1_sel  => s_ALUInput1Sel,
        reg_dst_sel     => s_RegDstSel,
        reg_wr_sel      => s_RegWrSel,
        alu_input2_sel  => s_ALUInput2Sel,
        alu_control     => s_ALUControl,
        reg1_val        => s_Reg1Val,
        oALUOut         => s_ALUOut,
        oOVFL           => s_Ovfl,
        oZero           => s_Zero
    );

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
    -- Reset
    s_RST       <= '1';
    wait for cCLK_PER; 

    -- lui $1, 0x7fff # $1 - 0x7fff0000
    s_RST                   <= '0';
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0110";
    s_Inst                  <= x"3c017fff";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;

    -- addi $2, $1, 0x7fff # $2 - 0x7fff7fff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"20227fff";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;
    -- addi $2, $2, 0x7fff # $2 - 0x7ffffffe
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"20427fff";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;
    -- addi $3, $2, 0x7fff # $3 - 0x80007ffd
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"20437fff";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;

    -- addiu $4, $1, 0x7fff # $4 - 0x7fff7fff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"24247fff";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- addiu $5, $2, 0x7fff # $5 - 0x8007fffd
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"24457fff";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- add $6, $1, $2 # $6 - 0xfffefffe
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"00223020";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- add $7, $1, $3 # $7 - 0xffff7ffd
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"00233820";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- addu $8, $1, $2 # $8 - 0xfffefffe
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"00224021";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- addu $9, $1, $3 # $9 - 0xffff7ffd
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"00234821";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- subu $10, $2, $3 # $10 - 0x00000000
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0001";
    s_Inst                  <= x"00435023";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- sub $11, $2, $3 # $11 - 0x00000000
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0001";
    s_Inst                  <= x"00435822";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- and $12, $1, $2 # $12 - 0x7fff000 
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0010";
    s_Inst                  <= x"00226024";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- andi $13, $1, 0x0f0f # $13 - 0x00000000
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "11";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0010";
    s_Inst                  <= x"302d0f0f";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- andi $14, $1, 0xf0f0 # $14 - 0x00000000
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "11";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0010";
    s_Inst                  <= x"302ef0f0";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    
    -- xor $15, $1, $2   # $15 - 0x0000fffe
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0100";
    s_Inst                  <= x"00227826";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- xori $16, $1, 0x0f0f # $16 - 0x7fff0f0f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "11";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0100";
    s_Inst                  <= x"38300f0f";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- xori $17, $1, 0xf0f0 # $17 - 0x7ffff0f0
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "11";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0100";
    s_Inst                  <= x"3831f0f0";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- or $18, $1, $2 # $18 - 0x7ffffffe 
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0011";
    s_Inst                  <= x"00229025";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- ori $19, $1, 0x0f0f # $19 - 0x7fff0f0f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "11";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0011";
    s_Inst                  <= x"34330f0f";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- ori $20, $1, 0xf0f0 # $20 - 0x7ffff0f0
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "11";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0011";
    s_Inst                  <= x"3434f0f0";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- nor $21, $1, $2 #$21 = 0x80000001
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0101";
    s_Inst                  <= x"0022a827";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- sw $19 0($0) 
    s_RegWr                 <= '0';
    s_MemWr                 <= '1';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"ac130000";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- sw $20 4($0) 
    s_RegWr                 <= '0';
    s_MemWr                 <= '1';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"ac140004";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- sw $21 8($0) 
    s_RegWr                 <= '0';
    s_MemWr                 <= '1';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"ac150008";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- lw $22 0($0) # $22 - 0x7fff0f0f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "01";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"8c160000";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lw $23 4($0) # $23 - 0x7ffff0f0
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "01";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"8c170004";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lw $24 8($0) #$24 = 0x80000001
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "01";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"8c180008";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER; 
    
    -- lb $25 0($0)  # $25 - 0x0000000f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"80190000";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lb $26 1($0) # $26 - 0x0000000f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"801a0001";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lb $27 2($0) # $27 - 0xffffffff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"801b0002";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- lh $28 0($0) # $28 - 0x00000f0f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "01";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"841c0000";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lh $29 2($0) # $29 - 0x00007fff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "01";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"841d0002";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lh $30 4($0) # $30 - 0xfffff0f0
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "01";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"841e0004";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    
    -- lbu $25 0($0)  # $25 - 0x0000000f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "10";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"90190000";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lbu $26 1($0) # $26 - 0x0000000f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "10";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"901a0001";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lbu $27 2($0) # $27 - 0x000000ff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "10";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"901b0002";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- lhu $28 0($0) # $28 - 0x00000f0f
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "11";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"841c0000";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lhu $29 2($0) # $29 - 0x00007fff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "11";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"841d0002";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- lhu $30 4($0) # $30 - 0x0000f0f0
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "11";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "11";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"841e0004";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- sll $2, $2, 0x0001 # $2 - 0xfffffffc
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '1';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1000";
    s_Inst                  <= x"00021040";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- sll $3, $3, 0x0004 # $3 - 0x0007ffd0
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '1';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1000";
    s_Inst                  <= x"00031900";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- sra $2, $2, 0x0001 # $2 - 0xfffffffe
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '1';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1010";
    s_Inst                  <= x"00021043";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- sra $3, $3, 0x0004 # $3 - 0x00007ffd 
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '1';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1010";
    s_Inst                  <= x"00031903";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- srl $2, $2, 0x0001 # $2 - 0x7fffffff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '1';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1001";
    s_Inst                  <= x"00021042";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- srl $3, $3, 0x0004 # $3 - 0x000007ff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '1';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1001";
    s_Inst                  <= x"00031902";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- addiu $10, $0, 8 # $10 - 0x00000008
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"240a0008";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- addiu $11, $0, 16 # $11 - 0x00000010
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '1';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"240b0010";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER; 

    -- sllv $4, $4, $10 # $4 - 0xff7fff00
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1000";
    s_Inst                  <= x"01442004";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- sllv $5, $5, $11 # $5 - 0x7ffd0000
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1000";
    s_Inst                  <= x"01652804";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- srav $4, $4, $10 # $4 - 0xffff7fff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1010";
    s_Inst                  <= x"01442007";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- srav $5, $5, $11 # $5 - 0x00007ffd 
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1010";
    s_Inst                  <= x"01652807";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- srlv $4, $4, $10 # $4 - 0x00ff7fff
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1001";
    s_Inst                  <= x"01442006";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- srlv $5, $5, $11 # $5 - 0x00000000
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "1001";
    s_Inst                  <= x"01652806";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- beq $16, $19, 0x0100
    s_RegWr                 <= '0';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0001";
    s_Inst                  <= x"12130100";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- beq $16, $17, 0xff00
    s_RegWr                 <= '0';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0001";
    s_Inst                  <= x"1211ff00";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- bne $16, $19, 0x0100
    s_RegWr                 <= '0';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0001";
    s_Inst                  <= x"16130100";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- bne $16, $17, 0xff00
    s_RegWr                 <= '0';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0001";
    s_Inst                  <= x"1611ff00";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- slti $6, $0, 0x00ff # $6 - 0x00000001
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0111";
    s_Inst                  <= x"280600ff";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- slti $7, $0, 0xff00 # $7 - 0x00000000
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "10";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0111";
    s_Inst                  <= x"2807ff00";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- slt $8, $0, $20 # $8 - 0x00000001
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0111";
    s_Inst                  <= x"0014402a";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  
    -- slt $9, $0, $21 # $9 - 0x00000000 
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "01";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0111";
    s_Inst                  <= x"0015482a";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;  

    -- jal 0x00194348
    s_RegWr                 <= '1';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "10";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "10";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"0c194348";
    s_PCInc                 <= x"00004444";
    wait for cCLK_PER;  
    
    -- j 0x00000000
    s_RegWr                 <= '0';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"08000000";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;     

    -- jr $31
    s_RegWr                 <= '0';
    s_MemWr                 <= '0';
    s_ALUInput1Sel          <= '0';
    s_PartialMemSel         <= "00";
    s_RegDstSel             <= "00";
    s_ALUInput2Sel          <= "00";
    s_RegWrSel              <= "00";
    s_ALUControl.allow_ovfl <= '0';
    s_ALUControl.alu_select <= "0000";
    s_Inst                  <= x"03e00008";
    s_PCInc                 <= x"00000000";
    wait for cCLK_PER;   

    wait;
  end process;
  
end behavior;
