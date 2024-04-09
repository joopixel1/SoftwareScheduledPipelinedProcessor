-------------------------------------------------------------------------
-- Author: Braedon Giblin
-- Date: 2022.02.1
-- Files: MIPS_types.vhd
-------------------------------------------------------------------------
-- Description: This file contains a skeleton for some types that 381 students
-- may want to use. This file is guarenteed to compile first, so if any types,
-- constants, functions, etc., etc., are wanted, students should declare them
-- here.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package MIPS_types is

  type std_logic_vector_vector is array (integer range<>) of std_logic_vector;

  -- Example Constants. Declare more as needed
  constant DATA_WIDTH : integer := 32;
  constant SELECT_WIDTH : integer := 5;
  constant ADDR_WIDTH : integer := 10;

  -- Example record type. Declare whatever types you need here
  type alu_control_t is record
    allow_ovfl    : std_logic;
    alu_select    : std_logic_vector(3 downto 0);
  end record alu_control_t;

  type control_t is record
    alu_control     : alu_control_t;
    halt            : std_logic;
    reg_wr          : std_logic;
    mem_wr          : std_logic;
    alu_input1_sel  : std_logic;
    partial_mem_sel : std_logic_vector(1 downto 0);
    reg_dst_sel     : std_logic_vector(1 downto 0);
    alu_input2_sel  : std_logic_vector(1 downto 0);
    reg_wr_sel      : std_logic_vector(1 downto 0);
    pc_sel          : std_logic_vector(1 downto 0);
  end record control_t;

  type wb_control_t is record
    halt            : std_logic;
    reg_wr          : std_logic;
    reg_wr_sel      : std_logic_vector(1 downto 0);
  end record wb_control_t;

  type mem_control_t is record
    mem_wr          : std_logic;
    partial_mem_sel : std_logic_vector(1 downto 0);
  end record mem_control_t;

  type ex_control_t is record
    alu_control     : alu_control_t;
    alu_input1_sel  : std_logic;
    alu_input2_sel  : std_logic_vector(1 downto 0);
  end record ex_control_t;

end package MIPS_types;

package body MIPS_types is
  -- Probably won't need anything here... function bodies, etc.
end package body MIPS_types;
