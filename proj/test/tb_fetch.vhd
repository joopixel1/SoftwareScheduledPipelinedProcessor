-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_fetch.vhd
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


entity tb_fetch is
  generic(gCLK_HPER   : time := 50 ns);
end tb_fetch;

architecture behavior of tb_fetch is
  
    -- Calculate the clock period as twice the half-period
    constant cCLK_PER   : time      := gCLK_HPER * 2;
    constant L          : integer   := ADDR_WIDTH;
    constant M          : integer   := SELECT_WIDTH;
    constant N          : integer   := DATA_WIDTH;

    component fetch
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

    -- Temporary signals to connect to the dff component.
    signal s_CLK, s_RST, s_InLd               : std_logic;
    signal s_InstAddr, s_JumpReg, s_NextInstAddr: std_logic_vector(N-1 downto 0);
    signal s_PCSel                              : std_logic_vector(1 downto 0);
    signal s_Inst, s_PCInc, s_IMemAddr          : std_logic_vector(N-1 downto 0);

begin

    DUT: fetch 
    port map(
        iCLK            => s_CLK, 
        iRST            => s_RST,
        iInstLd         => s_InLd,
        iInstAddr       => s_InstAddr,
        jumpReg         => s_JumpReg,
        PCSel           => s_PCSel,
        inst            => s_Inst,
        PCInc           => s_PCInc,
        iNextInstAddr   => s_NextInstAddr,
        iIMemAddr       => s_IMemAddr
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
    s_InLd      <= '1';
    s_InstAddr  <= x"00000000";
    wait for cCLK_PER; 

    -- Get Instruction 0 and Increment
    s_RST       <= '0';
    s_InLd    <= '0';
    s_PCSel     <= "00";
    s_JumpReg   <= x"00000000";
    s_Inst      <= x"00000000";
    wait for cCLK_PER;

    -- Moves to Next Instruction at 4 from regular Incrementing
    s_PCSel     <= "00";
    s_JumpReg   <= x"00000000";
    s_Inst      <= x"00000000";
    wait for cCLK_PER;

    -- Test jump to 256  after reading instruction 8
    s_PCSel <= "01";
    s_JumpReg   <= x"00000000";
    s_Inst      <= x"00000040";
    wait for cCLK_PER;  

    -- Test branch to -128  after reading instruction 256
    s_PCSel <= "10";
    s_JumpReg   <= x"00000000";
    s_Inst      <= x"0000ffe0";
    wait for cCLK_PER;  

    -- Test JR to  afte r reading instruction 128 which moves it instruction 0.
    s_PCSel <= "11";
    s_JumpReg   <= x"00000000";
    s_Inst      <= x"00000000";
    wait for cCLK_PER;  

    -- Test CI 
    s_PCSel <= "00";
    wait for cCLK_PER;  

    wait;
  end process;
  
end behavior;
