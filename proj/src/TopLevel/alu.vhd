-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an ALU unit using structural VHDL
--
--
-- NOTES:
-- 1/14/19 by H3::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.MIPS_types.all;



entity alu is
  
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
        o_Q         : out std_logic_vector(N-1 downto 0)       -- Data value output
    ); 

end alu;

architecture structure of alu is

    -- Describe the component entities as defined in ones_comp.vhd
 	-- mux2t1.vhdl, adder_n.vhdl (not strictly necessary).
    component add_sub
        generic(
            N           :positive   := N
        );

        port(
            i_A         : in std_logic_vector(N-1 downto 0);
            i_B         : in std_logic_vector(N-1 downto 0);
            i_S         : in std_logic;
            o_OVFL      : out std_logic;
            o_Y         : out std_logic_vector(N-1 downto 0);
            o_C         : out std_logic
        ); 
    end component;

    component barrel_shifter
        
        port(
            i_data		    : in std_logic_vector(31 downto 0);
	        i_shamt  	    : in std_logic_vector(4 downto 0);
	        i_shift_dir    	: in std_logic; -- 1 left, 0 right
	        i_shift_type	: in std_logic; -- 0 logical, 1 arithmetic
	        o_data     	    : out std_logic_vector(31 downto 0)
         );
    end component;

    -- TODO: change input and output signals as needed.
    signal s_Add_Sub, s_And, s_Or, s_Xor, s_Nor, s_LowExt, s_SLT, s_Shift   : std_logic_vector(N-1 downto 0);
    signal s_0VFL_Add_Sub                                                   : std_logic;
    signal s_shift_dir : std_logic;
    signal s_shift_type : std_logic;

begin

    o_OVFL <= s_0VFL_Add_Sub when (i_C.allow_ovfl = '1') else 
        '0';
    
    with i_C.alu_select select
        o_Q <= s_Add_Sub when "0000",
        s_Add_Sub when "0001",
        s_And when "0010",
        s_Or when "0011",
        s_Xor when "0100",
        s_Nor when "0101",
        s_LowExt when "0110",
        s_SLT when "0111",
        s_Shift when "1000" | "1001" | "1010",
        (others => '-') when others;
    
    i_add_sub_n: add_sub
	port MAP(
        i_A         => i_D0,
       	i_B         => i_D1,
        i_S         => i_C.alu_select(0),
        o_OVFL      => s_0VFL_Add_Sub,
        o_Y         => s_Add_Sub,
       	o_C         => open
    );

    s_shift_dir <= '1' when i_C.alu_select = "1000" else -- sll
                   '0';  -- sra and srl
   
    s_shift_type <= '1' when i_C.alu_select = "1010" else -- sra
                    '0';  -- srl and sll


    i_barrel_shifter: barrel_shifter
	port MAP(
        i_data          => i_D1,
       	i_shamt         => i_D0(4 downto 0),
        i_shift_dir     => s_shift_dir,
        i_shift_type    => s_shift_type,
       	o_data          => s_Shift
    );
    
    s_And <= i_D0 and i_D1;
    s_Or <= i_D0 or i_D1;
    s_Xor <= i_D0 xor i_D1;
    s_Nor <= i_D0 nor i_D1;
    s_LowExt <= i_D1(15 downto 0) & x"0000";
    s_SLT <= (1 to 31 => '0') & s_Add_Sub(31);

    --with i_C.alu_select select
        --s_Shift <= std_logic_vector( (signed(i_D1) sll to_integer(unsigned(i_D0))) ) when "1000",

        --std_logic_vector( (signed(i_D1) srl to_integer(unsigned(i_D0(4 downto 0)))) ) when "1001",
        --std_logic_vector( (signed(i_D1) sra to_integer(unsigned(i_D0(4 downto 0)))) ) when "1010",
        --(others => '-') when others;

end structure;