-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- fetch.vhd
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


entity fetch is
  
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
        jumpReg         : in std_logic_vector(N-1 downto 0);
        PCSel           : in std_logic_vector(1 downto 0);
        inst            : in std_logic_vector(N-1 downto 0);
        PCInc           : out std_logic_vector(N-1 downto 0);
        iNextInstAddr   : out std_logic_vector(N-1 downto 0);   -- for the two needed imem signals
        iIMemAddr       : out std_logic_vector(N-1 downto 0)    -- for the two needed imem signals
    ); 

end  fetch;


architecture mixed of fetch is

    -- Required instruction memory signals
    signal s_IMemAddr           : std_logic_vector(N-1 downto 0); -- 1
    signal s_NextInstAddr       : std_logic_vector(N-1 downto 0); -- 2
    
    -- Required PC signals
    signal s_PCNext             : std_logic_vector(N-1 downto 0); -- 3
    signal s_PCJumpNext         : std_logic_vector(N-1 downto 0); -- 4
    signal s_PCBranchNext       : std_logic_vector(N-1 downto 0); -- 5
    signal s_PCBranchAdderInput : std_logic_vector(N-1 downto 0); -- 6
    signal s_PCInc              : std_logic_vector(N-1 downto 0);

    component adder_n
        generic(
            N           :positive       := N
        );    
        port(
            i_D0        : in std_logic_vector(N-1 downto 0);
            i_D1        : in std_logic_vector(N-1 downto 0);
            i_C         : in std_logic;
            o_S         : out std_logic_vector(N-1 downto 0);
            o_C         : out std_logic
        ); 
    end component;
    
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

begin

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
        o_S         => s_PCInc,
       	o_C         => open
    );

    PCInc <= s_PCInc;

    s_PCBranchAdderInput <= (18 to 31 => inst(15)) & (inst(15 downto 0) & "00");

    i2_adder_n: adder_n
	port map(
        i_D0        => s_PCInc,
       	i_D1        => s_PCBranchAdderInput,
        i_C         => '0',
        o_S         => s_PCBranchNext,
       	o_C         => open
    );
    
    --  check again
    s_PCJumpNext <= PCInc(31 downto 28) & inst(25 downto 0) & "00";

    with PCSel select
        s_PCNext <= jumpReg when "11",
        s_PCJumpNext when "01",
        s_PCBranchNext when "10",
        PCInc when others;

    iIMemAddr       <= s_IMemAddr;
    iNextInstAddr   <= s_NextInstAddr;

end mixed;

