-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_barrel_shifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- barrel shifter for the ALU.
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;


entity tb_barrel_shifter is
  generic(gCLK_HPER   : time := 50 ns);
end tb_barrel_shifter;

architecture behavior of tb_barrel_shifter is
  
    -- Calculate the clock period as twice the half-period
    constant cCLK_PER   : time      := gCLK_HPER * 2;

    component barrel_shifter
        port(
	    	i_data		    : in std_logic_vector(31 downto 0);
	        i_shamt  	  	: in std_logic_vector(4 downto 0);
	        i_shift_dir	  	: in std_logic;
	        i_shift_type	: in std_logic;
	        o_data       	: out std_logic_vector(31 downto 0) 
        ); 
    end component;

    -- Temporary signals to connect to the barre shifter.
    signal s_data            : std_logic_vector(31 downto 0);
    signal s_shamt           : std_logic_vector(4 downto 0);
    signal s_shift_dir       : std_logic;
    signal s_shift_type      : std_logic;
    signal s_o_data          : std_logic_vector(31 downto 0);

begin

    DUT: barrel_shifter
    port map(
        i_data           => s_data, 
        i_shamt          => s_shamt,
	    i_shift_dir      => s_shift_dir,
        i_shift_type     => s_shift_type,
        o_data           => s_o_data
    );

  -- Testbench process
  P_TB: process
  begin

    -- Reset
    s_data        <= x"00000000";
    s_shamt       <= "00000";
    s_shift_dir   <= '0';
    s_shift_type  <= '0';
    wait for cCLK_PER; 

---------------------SLL----------------------
    -- sll $t0, $t0, 1 when $t0 = 0x0111FFFF
    s_data        <= x"0111FFFF";
    s_shamt       <= "00001";
    s_shift_dir   <= '1';    -- left 
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x0223FFFE

    -- sll $t0, $t0, 2 when $t0 = 0x0111FFFF
    s_data        <= x"0111FFFF";
    s_shamt       <= "00010";
    s_shift_dir   <= '1';    -- left 
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x0447FFFC

    -- sll $t0, $t0, 3 when $t0 = 0x0111FFFF
    s_data        <= x"0111FFFF";
    s_shamt       <= "00011";
    s_shift_dir   <= '1';    -- left 
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x088FFFF8

    -- sll $t0, $t0, 4 when $t0 = 0x0111FFFF
    s_data        <= x"0111FFFF";
    s_shamt       <= "00100";
    s_shift_dir   <= '1';    -- left 
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x111FFFF0

    -- sll $t0, $t0, 31 when $t0 = 0x0111FFFF
    s_data        <= x"0111FFFF";
    s_shamt       <= "11111";
    s_shift_dir   <= '1';    -- left 
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x80000000

---------------------SRL----------------------
    -- srl $t0, $t0, 1 when $t0 = 0x234F67A0
    s_data        <= x"234F67A0";
    s_shamt       <= "00001";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x11A7B3D0

    -- srl $t0, $t0, 2 when $t0 = 0x234F67A0
    s_data        <= x"234F67A0";
    s_shamt       <= "00010";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x08D3D9E8

    -- srl $t0, $t0, 3 when $t0 = 0x234F67A0
    s_data        <= x"234F67A0";
    s_shamt       <= "00011";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x0469ECF4

    -- srl $t0, $t0, 4 when $t0 = 0x234F67A0
    s_data        <= x"234F67A0";
    s_shamt       <= "00100";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x0234F67A

    -- srl $t0, $t0, 31 when $t0 = 0x234F67A0
    s_data        <= x"234F67A0";
    s_shamt       <= "11111";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '0';    -- logical
    wait for cCLK_PER; 
    -- Expected 0x00000000

---------------------SRA----------------------
    -- sra $t0, $t0, 1 when $t0 = 0x0F687FF0
    s_data        <= x"0F687FF0";
    s_shamt       <= "00001";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0x07B43FF8

    -- sra $t0, $t0, 2 when $t0 = 0x0F687FF0
    s_data        <= x"0F687FF0";
    s_shamt       <= "00010";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0x03DA1FFC

    -- sra $t0, $t0, 3 when $t0 = 0x0F687FF0
    s_data        <= x"0F687FF0";
    s_shamt       <= "00011";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0x01ED0FFE

    -- sra $t0, $t0, 4 when $t0 = 0x0F687FF0
    s_data        <= x"0F687FF0";
    s_shamt       <= "00100";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0x00F687FF

    -- sra $t0, $t0, 31 when $t0 = 0x0F687FF0
    s_data        <= x"0F687FF0";
    s_shamt       <= "11111";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0x00000000

    -- sra $t0, $t0, 1 when $t0 = 0x8F687FF0
    s_data        <= x"8F687FF0";
    s_shamt       <= "00001";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0xC7B43FF8

    -- srl $t0, $t0, 2 when $t0 = 0x8F687FF0
    s_data        <= x"8F687FF0";
    s_shamt       <= "00010";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0xE3DA1FFC

    -- srl $t0, $t0, 3 when $t0 = 0x8F687FF0
    s_data        <= x"8F687FF0";
    s_shamt       <= "00011";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0xF1ED0FFE

    -- srl $t0, $t0, 4 when $t0 = 0x8F687FF0
    s_data        <= x"8F687FF0";
    s_shamt       <= "00100";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0xF8F687FF

    -- srl $t0, $t0, 31 when $t0 = 0x8F687FF0
    s_data        <= x"8F687FF0";
    s_shamt       <= "11111";
    s_shift_dir   <= '0';    -- right
    s_shift_type  <= '1';    -- arithmetic
    wait for cCLK_PER; 
    -- Expected 0xFFFFFFFF

    wait;
  end process;
  
end behavior;
