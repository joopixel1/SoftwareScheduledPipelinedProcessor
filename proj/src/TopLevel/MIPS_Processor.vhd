-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
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


entity MIPS_Processor is
  
    generic(
        L : integer := ADDR_WIDTH;
        N : integer := DATA_WIDTH;
        M : integer := SELECT_WIDTH
    );
  
    port(
        iCLK            : in std_logic;
        iRST            : in std_logic;
        iInstLd         : in std_logic;
        iInstAddr       : in std_logic_vector(N-1 downto 0);
        iInstExt        : in std_logic_vector(N-1 downto 0);
        oALUOut         : out std_logic_vector(N-1 downto 0)
    ); 

end  MIPS_Processor;


architecture structure of MIPS_Processor is

    -- Required halt signal -- for simulation
    signal s_Halt           : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

    -- Required overflow signal -- for overflow exception detection
    signal s_Ovfl           : std_logic;  -- : this signal indicates an overflow exception would have been initiated

    -- Required data memory signals
    signal s_DMemWr         : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
    signal s_DMemAddr       : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
    signal s_DMemData       : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
    signal s_DMemOut        : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
    
    -- Required register file signals 
    signal s_RegWr          : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
    signal s_RegWrAddr      : std_logic_vector(M-1 downto 0); -- TODO: use this signal as the final destination register address input
    signal s_RegWrData      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

    -- Required instruction memory signals
    signal s_IMemAddr       : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
    signal s_NextInstAddr   : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
    signal s_Inst           : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

    -- instruction Fetch and Decode Signals
    signal s_PCNext             : std_logic;
    signal s_PCJumpNext         : std_logic_vector(N-1 downto 0); 
    signal s_PCBranchNext       : std_logic_vector(N-1 downto 0); 
    signal s_PCBranchAdderInput : std_logic_vector(N-1 downto 0);
        
    -- instruction Decode Signals
    signal s_Zero               : std_logic;
    signal s_Control            : control_t; 
    
    -- Execute Signals
    signal s_ALUInput1      : std_logic_vector(N-1 downto 0);
    signal s_ALUInput2      : std_logic_vector(N-1 downto 0);


    -- Temp signals for if stage
    -- out
    signal if_Inst          : std_logic_vector(N-1 downto 0);
    signal if_PCInc         : std_logic_vector(N-1 downto 0);

    -- Temp signals for id stage
    -- in
    signal id_Inst          : std_logic_vector(N-1 downto 0);
    signal id_PCInc         : std_logic_vector(N-1 downto 0);
    -- out
    signal id_EXControl     : ex_control_t;
    signal id_MEMControl    : ex_control_t;
    signal id_WBControl     : wb_control_t;
    signal id_Reg1Out       : std_logic_vector(N-1 downto 0);
    signal id_Reg2Out       : std_logic_vector(N-1 downto 0);
    signal id_Shamt         : std_logic_vector(N-1 downto 0);
    signal id_SignExt       : std_logic_vector(N-1 downto 0);
    signal id_ZeroExt       : std_logic_vector(N-1 downto 0);
    
    -- Temp signals for ex stage
    -- in
    signal ex_EXControl     : ex_control_t;
    signal ex_Reg1Out       : std_logic_vector(N-1 downto 0);
    signal ex_Reg2Out       : std_logic_vector(N-1 downto 0);
    signal ex_Shamt         : std_logic_vector(N-1 downto 0);
    signal ex_SignExt       : std_logic_vector(N-1 downto 0);
    signal ex_ZeroExt       : std_logic_vector(N-1 downto 0);
    -- out
    signal ex_ALUOut        : std_logic_vector(N-1 downto 0);
    -- both
    signal ex_MEMControl    : ex_control_t;
    signal ex_WBControl     : wb_control_t;
    signal ex_PCInc         : std_logic_vector(N-1 downto 0);
    signal ex_RegWrAddr     : std_logic_vector(N-1 downto 0);
    
    -- Temp signals for mem stage
    -- in
    signal mem_MEMControl   : mem_control_t;
    signal mem_Reg2Out      : std_logic_vector(N-1 downto 0);
    -- out
    signal mem_DMEMOut      : std_logic_vector(N-1 downto 0);
    signal mem_PartialMemOut: std_logic_vector(N-1 downto 0);
    -- both
    signal mem_WBControl    : wb_control_t;
    signal mem_ALUOut       : std_logic_vector(N-1 downto 0);
    signal mem_PCInc        : std_logic_vector(N-1 downto 0);
    signal mem_RegWrAddr    : std_logic_vector(N-1 downto 0);
    
    -- Temp signals for wb stage
    -- in
    signal wb_WBControl     : wb_control_t;
    signal wb_DMEMOut       : std_logic_vector(N-1 downto 0);
    signal wb_ALUOut        : std_logic_vector(N-1 downto 0);
    signal wb_PCInc         : std_logic_vector(N-1 downto 0);
    signal wb_RegWrAddr     : std_logic_vector(N-1 downto 0);
    signal wb_PartialMemOut : std_logic_vector(N-1 downto 0);


    component pc_dffg
        generic(
            N           :positive       := N     
        );
        port(
          i_CLK         : in std_logic;                            -- Clock input
          i_RST         : in std_logic;                            -- Reset input
          i_WE          : in std_logic;                            -- Write enable input
          i_D           : in std_logic_vector(N-1 downto 0);       -- Data value input
          o_Q           : out std_logic_vector(N-1 downto 0)       -- Data value output
      );
    end component;

    component mem
        generic(
            ADDR_WIDTH  : integer    := L;
            DATA_WIDTH  : integer    := N
        );

        port(
            clk         : in std_logic;
            addr        : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data        : in std_logic_vector((DATA_WIDTH-1) downto 0);
            we          : in std_logic := '1';
            q           : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;
        
    component control_unit
        port(
            i_Opc          : in std_logic_vector(5 downto 0); 
            i_Funct        : in std_logic_vector(5 downto 0);   
            i_Zero         : in std_logic;
            o_ctrl_Q       : out control_t;
            o_alu_Q        : out alu_control_t   
       ); 
    end component;

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

    component partial_mem
        port(
            i_X         : in std_logic_vector(N-1 downto 0);
            i_A         : in std_logic_vector(1 downto 0);
            i_S         : in std_logic_vector(1 downto 0);
            o_Y         : out std_logic_vector(N-1 downto 0)
        ); 
    end component;

    
    component IF_ID 
        port(
            i_CLK             : in std_logic;
            i_RST             : in std_logic;
            i_PCIncIn         : in std_logic_vector(N-1 downto 0);
            i_InstIn          : in std_logic_vector(N-1 downto 0);
            o_PCIncOut        : out std_logic_vector(N-1 downto 0);
            o_InstOut         : out std_logic_vector(N-1 downto 0)
        ); 
    component IF_ID;

    component ID_EX 
        port(
            i_CLK           : in std_logic;
            i_RST           : in std_logic;
            i_Reg1Out       : in std_logic_vector(N-1 downto 0);
            i_Reg2Out       : in std_logic_vector(N-1 downto 0);
            i_Shamt         : in std_logic_vector(N-1 downto 0);
            i_ZeroExt       : in std_logic_vector(N-1 downto 0);
            i_SignExt       : in std_logic_vector(N-1 downto 0);
            i_PCInc         : in std_logic_vector(N-1 downto 0);
            i_RegWrAddr     : in std_logic_vector(N-1 downto 0);
            i_EXControl     : in ex_control_t;
            i_MEMControl    : in mem_control_t;
            i_WBControl     : in wb_control_t;
            o_Reg1Out       : out std_logic_vector(N-1 downto 0);
            o_Reg2Out       : out std_logic_vector(N-1 downto 0);
            o_Shamt         : out std_logic_vector(N-1 downto 0);
            o_ZeroExt       : out std_logic_vector(N-1 downto 0);
            o_SignExt       : out std_logic_vector(N-1 downto 0);
            o_PCInc         : out std_logic_vector(N-1 downto 0);
            o_RegWrAddr     : out std_logic_vector(N-1 downto 0);
            o_EXControl     : out ex_control_t;
            o_MEMControl    : out mem_control_t;
            o_WBControl     : out wb_control_t
        ); 
    end component;

    component EX_MEM 
        port(
            i_CLK           : in std_logic;
            i_RST           : in std_logic;
            i_ALUOut        : in std_logic_vector(N-1 downto 0);
            i_PCInc         : in std_logic_vector(N-1 downto 0);
            i_DMemAddr      : in std_logic_vector(N-1 downto 0);
            i_MEMControl    : in mem_control_t;
            i_WBControl     : in wb_control_t;
            o_ALUOut        : out std_logic_vector(N-1 downto 0);
            o_PCInc         : out std_logic_vector(N-1 downto 0);
            o_DMemAddr      : out std_logic_vector(N-1 downto 0);
            o_MEMControl    : out mem_control_t;
            o_WBControl     : out wb_control_t
        ); 
    end component;

    component MEM_WB 
        port(
            i_CLK           : in std_logic;
            i_RST           : in std_logic;
            i_ALUOut        : in std_logic_vector(N-1 downto 0);
            i_DMEMOut       : in std_logic_vector(N-1 downto 0);
            i_PartialMemOut : in std_logic_vector(N-1 downto 0);
            i_RegWrAddr     : in std_logic_vector(N-1 downto 0);
            i_PCInc         : in std_logic_vector(N-1 downto 0);
            i_WBControl     : in wb_control_t;
            o_ALUOut        : out std_logic_vector(N-1 downto 0);
            o_DmemOut       : out std_logic_vector(N-1 downto 0);
            o_PartialMemOut : out std_logic_vector(N-1 downto 0);
            o_RegWrAddr     : out std_logic_vector(N-1 downto 0);
            o_PCInc         : out std_logic_vector(N-1 downto 0);
            o_WBControl     : out wb_control_t
        ); 
    end component;

begin

    -------------- IF STAGE -------------------------
     
    with s_Control.PCSel select
        s_PCNext <= id_Reg1Out when "11",
        s_PCJumpNext when "01",
        s_PCBranchNext when "10",
        if_PCInc when others;

    PC : pc_dffg
    port map(
        i_CLK       => iCLK,
        i_RST       => iRST,
        i_WE        => '1',
        i_D         => s_PCNext,
        o_Q         => s_NextInstAddr
    );
    
    with iInstLd select
        s_IMemAddr <= s_NextInstAddr when '0',
        iInstAddr when others;

    i_adder_n: adder_n
	port map(
        i_D0        => std_logic_vector(to_unsigned(4, N)),
       	i_D1        => s_NextInstAddr,
        i_C         => '0',
        o_S         => if_PCInc,
       	o_C         => open
    );

    IMem: mem
    port map(
        clk     => iCLK,
        addr    => s_IMemAddr(11 downto 2),
        data    => iInstExt,
        we      => iInstLd,
        q       => if_Inst
    );

    s_Inst <= if_Inst

    -------------- IF/ID STAGE -----------------------------

    IIF_ID: IF_ID
    port map(
        i_CLK           => iCLK,
        i_RST           => iRST,
        i_PCInc         => if_PCInc,
        i_Inst          => if_Inst,
        o_PCInc         => id_PCInc,
        o_Inst          => id_Inst
    ); 

    --------------- ID STAGE ---------------------------

    s_PCBranchAdderInput <= (18 to 31 => id_Inst(15)) & (id_Inst(15 downto 0) & "00");

    i2_adder_n: adder_n
	port map(
        i_D0        => s_PCInc,
       	i_D1        => s_PCBranchAdderInput,
        i_C         => '0',
        o_S         => s_PCBranchNext,
       	o_C         => open
    );

    s_PCJumpNext <= PCInc(31 downto 28) & inst(25 downto 0) & "00";

    ControlUnit: control_unit
    port map(
        i_Opc          => id_Inst(31 downto 26),
        i_Funct        => id_Inst(5 downto 0),
        i_Zero         => s_Zero,
        o_ctrl_Q       => s_Control
    );

    ControlDivider: contol_divider
    port map(
        i_ctrl          => s_Control,
        o_EXControl     => id_EXControl,
        o_MEMControl    => id_MEMControl,
        o_WBControl     => id_WBControl 
    );

    with s_Control.reg_dst_sel select
        id_RegWrAddr <= id_Inst(20 downto 16) when "00",
        id_Inst(15 downto 11) when "01",
        std_logic_vector(to_unsigned(31, M)) when "10",
        (others => '-') when others;

    RegFile: reg_file 
    port map(
        i_CLK   => iCLK, 
        i_WEN   => s_RegWr,
        i_RST   => iRST,
        i_W     => s_RegWrData,
        i_WS    => s_RegWrAddr,
        i_R1S   => inst(25 downto 21),
        i_R2S   => inst(20 downto 16),
        o_R1    => id_Reg1Out,
        o_R2    => id_Reg2Out
    );

    s_Zero <= '1' when (id_Reg1Out = id_Reg2Out) else '0';

    --------------- ID/EX STAGE --------------------------

    IID_EX: ID_EX
    port map(
        i_CLK           => iCLK,
        i_RST           => iRST,
        i_Reg1Out       => id_Reg1Out,
        i_Reg2Out       => id_Reg2Out,
        i_Shamt         => id_Shamt,
        i_SignExt       => id_SignExt,
        i_ZeroExt       => id_ZeroExt,
        i_PCInc         => id_PCInc, 
        i_RegWrAddr     => id_RegWrAddr,      
        i_EXControl     => id_EXControl,     
        i_MEMControl    => id_MEMControl,
        i_WBControl     => id_WBControl,
        o_Reg1Out       => ex_Reg1Out,
        o_Reg2Out       => ex_Reg2Out,
        o_Shamt         => ex_Shamt,
        o_SignExt       => ex_SignExt,
        o_ZeroExt       => ex_ZeroExt,
        o_PCInc         => ex_PCInc, 
        o_RegWrAddr     => ex_RegWrAddr,      
        o_EXControl     => ex_EXControl,     
        o_MEMControl    => ex_MEMControl,
        o_WBControl     => ex_WBControl
    ); 

    --------------- EX STAGE -----------------------------

    with ex_EXControl.alu_input1_sel select
        s_ALUInput1 <= ex_Reg1Out when '0',
        ex_Shamt when others;
    
    with ex_EXControl.alu_input2_sel select
        s_ALUInput2 <= s_Reg2Out when "00",
        ex_SignExt when "10",
        ex_ZeroExt when "11",
        (others => '-') when others;

    ALUObject: alu
    port map(
        i_D0        => s_ALUInput1,
        i_D1        => s_ALUInput2,
        i_C         => ex_EXControl.alu_control,
        o_OVFL      => s_Ovfl,
        o_Q         => ex_ALUOut
    );

    o_ALUOut    <= ex_ALUOut;

    ------------------ EX/MEM STAGE -----------------------

    IEX_MEM: EX_MEM
    port map(
        i_CLK           => iCLK,
        i_RST           => iRST,
        i_ALUOut        => ex_ALUOut,
        i_Reg2Out       => ex_Reg2Out,  
        i_PCInc         => ex_PCInc,
        i_RegWrAddr     => ex_RegWrAddr      
        i_MEMControl    => ex_MEMControl,
        i_WBControl     => ex_WBControl,
        o_ALUOut        => mem_ALUOut,
        o_Reg2Out       => mem_Reg2Out,
        o_PCInc         => mem_PCInc, 
        o_RegWrAddr     => mem_RegWrAddr,      
        o_MEMControl    => mem_MEMControl,
        o_WBControl     => mem_WBControl
    ); 

    ------------------ MEM STAGE --------------------------
    
    DMem: mem
    port map(
        clk  => iCLK,
        addr => mem_ALUOut(11 downto 2),
        data => mem_Reg2Out,
        we   => mem_MEMControl.mem_wr,
        q    => mem_DMEMOut
    );

    PartialMem: partial_mem
    port map(
        i_X         => mem_DMemOut,
        i_A         => mem_ALUOut(1 downto 0),
        i_S         => mem_MEMControl.partial_mem_sel,
        o_Y         => mem_PartialMemOut
    );

    s_DMemWr    <= mem_MEMControl.mem_wr;
    s_DMemAddr  <= mem_DMEMAddr;
    s_DMemData  <= mem_ALUOut;
    s_DMemOut   <= mem_DMEMOut;


    ---------------- MEM/WB STAGE -------------------------

    IMEM_WB: MEM_WB
    port map(
        i_CLK           => iCLK,
        i_RST           => iRST,
        i_ALUOut        => mem_ALUOut,
        i_DMEMOut       => mem_DMEMOut,
        i_PartialMemOut => mem_PartialMemOut,
        i_RegWrAddr     => mem_RegWrAddr,
        i_PCInc         => mem_PCInc,
        i_WBControl     => mem_WBControl,
        o_ALUOut        => wb_ALUOut,
        o_DmemOut       => wb_DmemOut,
        o_PartialMemOut => wb_PartialMemOut,
        o_RegWrAddr     => wb_RegWrAddr,
        o_PCInc         => wb_PCInc,
        o_WBControl     => wb_WBControl
    ); 

    ----------------- WB STAGE ----------------------------

    with wb_WBControl.reg_wr_sel select
        s_RegWrData <= wb_ALUOut when "00",
        wb_DMemOut when "01",
        wb_PCInc when "10",
        wb_PartialMemOut when others; 

    s_RegWr <= wb_control_t.reg_wr;
    s_RegWrAddr <= wb_RegWrAddr;

    ------------------ HALT -------------------------------

    with s_Inst(31 downto 26) select 
        s_Halt <= '1' when "010100",
        '0' when others;
    
end structure;

