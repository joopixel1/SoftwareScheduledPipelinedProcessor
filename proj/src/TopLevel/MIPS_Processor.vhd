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

    -- Required fetch signals
    -- signal s_Inst           : std_logic_vector(N-1 downto 0); -- 1
    signal s_PCInc          : std_logic_vector(N-1 downto 0); -- 2

    -- Required Control Signals
    signal s_ControlUnit    : control_t; -- 3
    signal s_ALUControlUnit : alu_control_t; -- 4

    -- Required execute signals
    signal s_Zero         : std_logic; -- 5
    signal s_Reg1Val      : std_logic_vector(N-1 downto 0); -- 6

    -- Required halt signal -- for simulation
    signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

    -- Required overflow signal -- for overflow exception detection
    signal s_Ovfl         : std_logic;  -- : this signal indicates an overflow exception would have been initiated

    -- Required data memory signals
    signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
    signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
    signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
    signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
    
    -- Required register file signals 
    signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
    signal s_RegWrAddr    : std_logic_vector(M-1 downto 0); -- TODO: use this signal as the final destination register address input
    signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

    -- Required instruction memory signals
    signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
    signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
    signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

    component fetch is
        port(
            iCLK            : in std_logic;
            iRST            : in std_logic;
            iInstLd         : in std_logic;
            iInstAddr       : in std_logic_vector(N-1 downto 0);
            jumpReg         : in std_logic_vector(N-1 downto 0);
            PCSel           : in std_logic_vector(1 downto 0);
            inst            : in std_logic_vector(N-1 downto 0);
            PCInc           : out std_logic_vector(N-1 downto 0);
            iNextInstAddr   : out std_logic_vector(N-1 downto 0);   -- for the two needed imem signals
            iIMemAddr       : out std_logic_vector(N-1 downto 0)    -- for the two needed imem signals
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
            oZero           : out std_logic;
            iRegWr          : out std_logic;                        -- for the three needed reg signals
            iRegWrAddr      : out std_logic_vector(M-1 downto 0);   -- for the three needed reg signals
            iRegWrData      : out std_logic_vector(N-1 downto 0);   -- for the three needed reg signals
            iDMemWr         : out std_logic;                        -- for the three needed dmem signals
            iDMemAddr       : out std_logic_vector(N-1 downto 0);   -- for the three needed dmem signals
            iDMemData       : out std_logic_vector(N-1 downto 0);   -- for the three needed dmem signals
            iDMemOut        : in std_logic_vector(N-1 downto 0)    -- for the three needed dmem signals
        ); 
    end component;

begin

    IFetch: fetch
    port map(
        iCLK            => iCLK, 
        iRST            => iRST,
        iInstLd         => iInstLd,
        iInstAddr       => iInstAddr,
        jumpReg         => s_Reg1Val,
        PCSel           => s_ControlUnit.pc_sel,
        inst            => s_Inst,
        PCInc           => s_PCInc,
        iNextInstAddr   => s_NextInstAddr,
        iIMemAddr        => s_IMemAddr
    );

    IMem: mem
    port map(
        clk     => iCLK,
        addr    => s_IMemAddr(11 downto 2),
        data    => iInstExt,
        we      => iInstLd,
        q       => s_Inst
    );

    ControlUnit: control_unit
    port map(
        i_Opc          => s_Inst(31 downto 26),
        i_Funct        => s_Inst(5 downto 0),
        i_Zero         => s_Zero,
        o_ctrl_Q       => s_ControlUnit,
        o_alu_Q        => s_ALUControlUnit
    );
    
    DMem: mem
    port map(
        clk  => iCLK,
        addr => s_DMemAddr(11 downto 2),
        data => s_DMemData,
        we   => s_ControlUnit.mem_wr,
        q    => s_DMemOut
    );

    IExecute: execute
    port map(
        PCInc           => s_PCInc,
        inst            => s_Inst,
        iCLK            => iCLK, 
        iRST            => iRST,
        reg_wr          => s_ControlUnit.reg_wr,
        mem_wr          => s_ControlUnit.mem_wr,
        alu_input1_sel  => s_ControlUnit.alu_input1_sel,
        partial_mem_sel => s_ControlUnit.partial_mem_sel,
        reg_dst_sel     => s_ControlUnit.reg_dst_sel,
        reg_wr_sel      => s_ControlUnit.reg_wr_sel,
        alu_input2_sel  => s_ControlUnit.alu_input2_sel,
        alu_control     => s_ALUControlUnit,
        reg1_val        => s_Reg1Val,
        oALUOut         => oALUOut,
        oOVFL           => s_Ovfl,
        oZero           => s_Zero,
        iRegWr          => s_RegWr,
        iRegWrAddr      => s_RegWrAddr,
        iRegWrData      => s_RegWrData,  
        iDMemWr         => s_DMemWr,
        iDMemAddr       => s_DMemAddr,
        iDMemData       => s_DMemData,    
        iDMemOut        => s_DMemOut
    );

    with s_Inst(31 downto 26) select 
        s_Halt <= '1' when "010100",
        '0' when others;
    
end structure;

