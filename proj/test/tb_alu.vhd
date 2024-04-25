-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- tb_alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the adder subtractor unit.
--              
-- 01/03/2020 by H3::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_alu is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_alu;

architecture mixed of tb_alu is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component alu is
    generic(
        L : integer := ADDR_WIDTH;
        N : integer := DATA_WIDTH;
        M : integer := SELECT_WIDTH
    );
    port(
        i_D0        : in std_logic_vector(N-1 downto 0);
        i_D1        : in std_logic_vector(N-1 downto 0);
        i_C         : in alu_control_t;         -- Data value input
        o_OVFL      : out std_logic;
        o_Z         : out std_logic;         -- Data value input
        o_Q         : out std_logic_vector(N-1 downto 0)       -- Data value output
    ); 
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_iD0    : std_logic_vector(DATA_WIDTH-1 downto 0)  := x"00000000";
signal s_iD1    : std_logic_vector(DATA_WIDTH-1 downto 0)  := x"00000000";
signal s_iC     : alu_control_t;
signal s_oQ     : std_logic_vector(DATA_WIDTH-1 downto 0);
signal s_oZ     : std_logic;
signal s_oOVFL     : std_logic;

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: alu
  port map(
    i_D0        => s_iD0,
    i_D1        => s_iD1,
    i_C         => s_iC,
    o_OVFL      => s_oOVFL,
    o_Z         => s_oZ,
    o_Q         => s_OQ
  );
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  
  --This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  -- This process resets the sequential components of the design.
  -- It is held to be 1 across both the negative and positive edges of the clock
  -- so it works regardless of whether the design uses synchronous (pos or neg edge)
  -- or asynchronous resets.
  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  
  
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- TODO: add test cases as needed (at least 3 more for this lab)

      -- Test case for addition
  s_iD0 <= x"00000001";  -- Input 1 (e.g., 1)
  s_iD1 <= x"00000002";  -- Input 2 (e.g., 2)
  s_iC.alu_select <= "0000";  -- Addition operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for addition operation

  -- Test case for subtraction
  s_iD0 <= x"00000005";  -- Input 1 (e.g., 5)
  s_iD1 <= x"00000002";  -- Input 2 (e.g., 2)
  s_iC.alu_select <= "0001";  -- Subtraction operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for subtraction operation

  -- Test case for AND operation
  s_iD0 <= x"00000F0F";  -- Input 1 (e.g., 1111 0000 1111 0000)
  s_iD1 <= x"00000FF0";  -- Input 2 (e.g., 1111 1111 0000 0000)
  s_iC.alu_select <= "0010";  -- AND operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for AND operation

  -- Test case for OR operation
  s_iD0 <= x"00000F0F";  -- Input 1 (e.g., 1111 0000 1111 0000)
  s_iD1 <= x"00000FF0";  -- Input 2 (e.g., 1111 1111 0000 0000)
  s_iC.alu_select <= "0011";  -- OR operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for OR operation

  -- Test case for XOR operation
  s_iD0 <= x"00000F0F";  -- Input 1 (e.g., 1111 0000 1111 0000)
  s_iD1 <= x"00000FF0";  -- Input 2 (e.g., 1111 1111 0000 0000)
  s_iC.alu_select <= "0100";  -- XOR operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for XOR operation

  -- Test case for NOR operation
  s_iD0 <= x"00000F0F";  -- Input 1 (e.g., 1111 0000 1111 0000)
  s_iD1 <= x"00000FF0";  -- Input 2 (e.g., 1111 1111 0000 0000)
  s_iC.alu_select <= "0101";  -- NOR operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for NOR operation

  -- Test case for lower extend operation
  s_iD0 <= x"00001234";  -- Input 1 (e.g., 0001 0010 0011 0100)
  s_iD1 <= x"00005678";  -- Input 2 (e.g., 0101 0110 0111 1000)
  s_iC.alu_select <= "0110";  -- Lower extend operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for lower extend operation

  -- Test case for SLT operation
  s_iD0 <= x"00000001";  -- Input 1 (e.g., 1)
  s_iD1 <= x"00000002";  -- Input 2 (e.g., 2)
  s_iC.alu_select <= "0111";  -- SLT operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for SLT operation

  -- Test case for shift left operation
  s_iD0 <= x"00000002";  -- Input 1 (e.g., 2)
  s_iD1 <= x"00000003";  -- Input 2 (e.g., 3)
  s_iC.alu_select <= "1000";  -- Shift left operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for shift left operation

  -- Test case for shift right logical operation
  s_iD0 <= x"00000008";  -- Input 1 (e.g., 8)
  s_iD1 <= x"00000002";  -- Input 2 (e.g., 2)
  s_iC.alu_select <= "1001";  -- Shift right logical operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for shift right logical operation

  -- Test case for shift right arithmetic operation
  s_iD0 <= x"00000002";  -- Input 1 (e.g., -256)
  s_iD1 <= x"0000FF00";  -- Input 2 (e.g., 2)
  s_iC.alu_select <= "1010";  -- Shift right arithmetic operation
  wait for gCLK_HPER * 2;
  -- Check outputs here for shift right arithmetic operation



    wait;
  end process;

end mixed;