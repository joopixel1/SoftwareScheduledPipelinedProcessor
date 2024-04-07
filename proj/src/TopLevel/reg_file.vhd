-------------------------------------------------------------------------
-- joopixel1
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- reg_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of 32 32-bit register file
--
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.MIPS_types.all;

entity reg_file is

    port(
        i_CLK       : in std_logic;
        i_WEN       : in std_logic;
        i_RST       : in std_logic;
        i_W         : in std_logic_vector(DATA_WIDTH-1 downto 0); 
        i_WS        : in std_logic_vector(SELECT_WIDTH-1 downto 0);   
        i_R1S       : in std_logic_vector(SELECT_WIDTH-1 downto 0);  
        i_R2S       : in std_logic_vector(SELECT_WIDTH-1 downto 0);
        o_R1        : out std_logic_vector(DATA_WIDTH-1 downto 0); 
        o_R2        : out std_logic_vector(DATA_WIDTH-1 downto 0)   
    );

end reg_file;

architecture structure of reg_file is

    component decoder
        generic(
            N           :positive           := SELECT_WIDTH
        );
        port(
            i_WE         : in std_logic;                            -- Write enable input
            i_S          : in std_logic_vector(N-1 downto 0);       -- Data value input
            o_Q          : out std_logic_vector((2**N)-1 downto 0)  -- Data value output
        );
    end component;

    component reg
        generic(
            N           :positive       := DATA_WIDTH     
        );
        port(
          i_CLK        : in std_logic;                            -- Clock input
          i_RST        : in std_logic;                            -- Reset input
          i_WE         : in std_logic;                            -- Write enable input
          i_D          : in std_logic_vector(N-1 downto 0);       -- Data value input
          o_Q          : out std_logic_vector(N-1 downto 0)       -- Data value output
      );
    end component;

    component nm_mux
        generic(
            N           : positive          := SELECT_WIDTH;
            M           : positive          := DATA_WIDTH
        );
        port(
            i_D         : in std_logic_vector_vector((2**N)-1 downto 0)(M-1 downto 0);       -- Data input
            i_S         : in std_logic_vector(N-1 downto 0);                                   -- Select value input
            o_Q         : out std_logic_vector(M-1 downto 0)                                   -- Data value output
        );
    end component;   


    signal s_I              : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_V              : std_logic_vector_vector((2**SELECT_WIDTH)-1 downto 0)(DATA_WIDTH-1 downto 0)      := (others => x"00000000");
  
begin

    i_decoder: decoder
    port map(
        i_WE  => i_WEN,
        i_S   => i_WS,
        o_Q   => s_I
    );

    n_dffg0_instance : reg
    port MAP(
        i_CLK       => i_CLK,
        i_RST       => i_RST,
        i_WE        => '0',
        i_D         => i_W,
        o_Q         => s_V(0)
    );

    n_dffg_instances: for i in (2**SELECT_WIDTH)-1 downto 1 generate
        n_dffg_instance : reg
        port MAP(
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => s_I(i),
            i_D         => i_W,
            o_Q         => s_V(i)
        );
    end generate;
  
    i1_nm_mux: nm_mux
	port map(
        i_D   => s_V,
        i_S   => i_R1S,
        o_Q   => o_R1
    );

    i2_nm_mux: nm_mux
	port map(
        i_D   => s_V,
        i_S   => i_R2S,
        o_Q   => o_R2
    );
    
end structure;
