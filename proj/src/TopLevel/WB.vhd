-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- WB.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.MIPS_types.all;


entity WB is
  
    generic(
        L : integer := ADDR_WIDTH;
        N : integer := DATA_WIDTH;
        M : integer := SELECT_WIDTH
    );
  
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
        oZero           : out std_logic;
        iRegWr          : out std_logic;                        -- for the three needed reg signals
        iRegWrAddr      : out std_logic_vector(M-1 downto 0);   -- for the three needed reg signals
        iRegWrData      : out std_logic_vector(N-1 downto 0);   -- for the three needed reg signals
        iDMemWr         : out std_logic;                        -- for the four needed dmem signals
        iDMemAddr       : out std_logic_vector(N-1 downto 0);   -- for the four needed dmem signals
        iDMemData       : out std_logic_vector(N-1 downto 0);   -- for the four needed dmem signals
        iDMemOut        : in std_logic_vector(N-1 downto 0)    -- for the four needed dmem signals
    ); 

end WB;

architecture mixed of execute is

    -- Required RegFile signals
    signal s_WriteSel           : std_logic_vector(M-1 downto 0); -- 1
    signal s_WriteVal           : std_logic_vector(N-1 downto 0); -- 2
    signal s_Reg1Val            : std_logic_vector(N-1 downto 0); -- 3
    signal s_Reg2Val            : std_logic_vector(N-1 downto 0); -- 4
    
    -- Required alu signals
    signal s_ALUInput1          : std_logic_vector(N-1 downto 0); -- 5
    signal s_ALUInput2          : std_logic_vector(N-1 downto 0); -- 6

    -- Required data memory signals
    
    -- Required partial mem signals
    signal s_PartialMemOut       : std_logic_vector(N-1 downto 0); -- 8
    signal s_ALUOut              : std_logic_vector(N-1 downto 0);
 
    component reg_file
        port(
            i_CLK       : in std_logic;
            i_WEN       : in std_logic;
            i_RST       : in std_logic;
            i_W         : in std_logic_vector(N-1 downto 0); 
            i_WS        : in std_logic_vector(4 downto 0);   
            i_R1S       : in std_logic_vector(4 downto 0);  
            i_R2S       : in std_logic_vector(4 downto 0);
            o_R1        : out std_logic_vector(N-1 downto 0); 
            o_R2        : out std_logic_vector(N-1 downto 0)   
        );
    end component;

    component alu
        port(
            i_D0        : in std_logic_vector(N-1 downto 0);
            i_D1        : in std_logic_vector(N-1 downto 0);
            i_C         : in alu_control_t;         
            o_OVFL      : out std_logic;
            o_Z         : out std_logic;
            o_Q         : out std_logic_vector(N-1 downto 0)
        ); 
    end component;
    
    component mem
        port(
            clk         : in std_logic;
            addr        : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data        : in std_logic_vector((DATA_WIDTH-1) downto 0);
            we          : in std_logic := '1';
            q           : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

    component partial_mem
        port(
            i_X         : in std_logic_vector(N-1 downto 0);
            i_A         : in std_logic_vector(1 downto 0);
            i_S         : in std_logic_vector(1 downto 0);
            o_Y         : out std_logic_vector(N-1 downto 0)
        ); 
    end component;

begin

    with reg_dst_sel select
        s_WriteSel <= inst(20 downto 16) when "00",
        inst(15 downto 11) when "01",
        std_logic_vector(to_unsigned(31, M)) when "10",
        (others => '-') when others;

    RegFile: reg_file 
    port map(
        i_CLK   => iCLK, 
        i_WEN   => reg_wr,
        i_RST   => iRST,
        i_W     => s_WriteVal,
        i_WS    => s_WriteSel,
        i_R1S   => inst(25 downto 21),
        i_R2S   => inst(20 downto 16),
        o_R1    => s_Reg1Val,
        o_R2    => s_Reg2Val
    );

    reg1_val <= s_Reg1Val;

    with alu_input1_sel select
        s_ALUInput1 <= s_Reg1Val when '0',
        ((0 to 26 => '0') & inst(10 downto 6)) when others;
    
    with alu_input2_sel select
        s_ALUInput2 <= s_Reg2Val when "00",
        x"000000" & "000" & inst(10 downto 6) when "01",
        (0 to 15 => inst(15)) & inst(15 downto 0) when "10",
        x"0000" & inst(15 downto 0) when others;

    ALUObject: alu
    port map(
        i_D0        => s_ALUInput1,
        i_D1        => s_ALUInput2,
        i_C         => alu_control,
        o_OVFL      => oOVFL,
        o_Z         => oZero,
        o_Q         => s_ALUOut
    );

    oALUOut <= s_ALUOut;

    PartialMem: partial_mem
    port map(
        i_X         => iDMemOut,
        i_A         => s_ALUOut(1 downto 0),
        i_S         => partial_mem_sel,
        o_Y         => s_PartialMemOut
    );

    with reg_wr_sel select
        s_WriteVal <= oALUOut when "00",
        iDMemOut when "01",
        PCInc when "10",
        s_PartialMemOut when others;

    iRegWr      <= reg_wr;
    iRegWrAddr  <= s_WriteSel;
    iRegWrData  <= s_WriteVal;
    iDMemWr     <= mem_wr;
    iDMemAddr   <= oALUOut; 
    iDMemData   <= s_Reg2Val;

end mixed;

