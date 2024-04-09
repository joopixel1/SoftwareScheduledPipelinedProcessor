-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- IF_ID.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the execute to memory
-- register for the pipelined processor.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.MIPS_types.all;

entity EX_MEM is

    generic(
        N           : positive;
        M           : positive
    );


    port(
        i_CLK           : in std_logic;
        i_RST           : in std_logic;
        i_ALUOut        : in std_logic_vector(N-1 downto 0);
        i_Reg2Out       : in std_logic_vector(N-1 downto 0);
        i_PCInc         : in std_logic_vector(N-1 downto 0);
        i_RegWrAddr     : in std_logic_vector(M-1 downto 0);
        i_MEMControl    : in mem_control_t;
        i_WBControl     : in wb_control_t;
        o_ALUOut        : out std_logic_vector(N-1 downto 0);
        o_Reg2Out       : out std_logic_vector(N-1 downto 0);
        o_PCInc         : out std_logic_vector(N-1 downto 0);
        o_RegWrAddr     : out std_logic_vector(M-1 downto 0);
        o_MEMControl    : out mem_control_t;
        o_WBControl     : out wb_control_t
    ); 

end EX_MEM;

architecture structure of EX_MEM is

    component n_dffg
        generic(
            N           :positive   := N
        );

        port(
            i_CLK        : in std_logic;                          
            i_RST        : in std_logic;                         
            i_WE         : in std_logic;                         
            i_D          : in std_logic_vector(N-1 downto 0);   
            o_Q          : out std_logic_vector(N-1 downto 0)      
        );
    end component;

    component mem_dffg
        port(
            i_CLK        : in std_logic;                            -- Clock input
            i_RST        : in std_logic;                            -- Reset input
            i_WE         : in std_logic;                            -- Write enable input
            i_D          : in mem_control_t;                       -- Data value input
            o_Q          : out mem_control_t                       -- Data value output
        );
    end component;

    component wb_dffg
        port(
            i_CLK        : in std_logic;                            -- Clock input
            i_RST        : in std_logic;                            -- Reset input
            i_WE         : in std_logic;                            -- Write enable input
            i_D          : in wb_control_t;                        -- Data value input
            o_Q          : out wb_control_t                        -- Data value output
        );
    end component;

begin

    -- Instantiate D flip-flops for each input
    ALUOut_dffg: n_dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_ALUOut,
        o_Q   => o_ALUOut
    );

    Reg1Out_dffg: n_dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_Reg2Out,
        o_Q   => o_Reg2Out
    );

    PCInc_dffg: n_dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_PCInc,
        o_Q   => o_PCInc
    );

    RegWrAddr_dffg: n_dffg
    generic map(
        N       => M
    )
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_RegWrAddr,
        o_Q   => o_RegWrAddr
    );

    -- Instantiate flip-flops for control signals
    MEMControl_dffg: mem_dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_MEMControl,
        o_Q   => o_MEMControl
    );

    WBControl_dffg: wb_dffg
    port map(
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => '1',
        i_D   => i_WBControl,
        o_Q   => o_WBControl
    );

end structure;
