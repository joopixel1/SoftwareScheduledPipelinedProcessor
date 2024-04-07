-------------------------------------------------------------------------
-- Fadahunsi Adeife
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- ID_EX.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the decode to execute
-- register for the pipelined processor.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.MIPS_types.all;

entity ID_EX is

    generic(
        N           : positive;
        M           : positive
    );

    port(
        i_CLK           : in std_logic;
        i_RST           : in std_logic;
        i_Reg1Out       : in std_logic_vector(N-1 downto 0);
        i_Reg2Out       : in std_logic_vector(N-1 downto 0);
        i_Shamt         : in std_logic_vector(N-1 downto 0);
        i_ZeroExt       : in std_logic_vector(N-1 downto 0);
        i_SignExt       : in std_logic_vector(N-1 downto 0);
        i_PCInc         : in std_logic_vector(N-1 downto 0);
        i_RegWrAddr     : in std_logic_vector(M-1 downto 0);
        i_EXControl     : in ex_control_t;
        i_MEMControl    : in mem_control_t;
        i_WBControl     : in wb_control_t;
        o_Reg1Out       : out std_logic_vector(N-1 downto 0);
        o_Reg2Out       : out std_logic_vector(N-1 downto 0);
        o_Shamt         : out std_logic_vector(N-1 downto 0);
        o_ZeroExt       : out std_logic_vector(N-1 downto 0);
        o_SignExt       : out std_logic_vector(N-1 downto 0);
        o_PCInc         : out std_logic_vector(N-1 downto 0);
        o_RegWrAddr     : out std_logic_vector(M-1 downto 0);
        o_EXControl     : out ex_control_t;
        o_MEMControl    : out mem_control_t;
        o_WBControl     : out wb_control_t
    ); 
end ID_EX;

architecture structure of ID_EX is

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

    component ex_dffg
        port(
            i_CLK        : in std_logic;                            -- Clock input
            i_RST        : in std_logic;                            -- Reset input
            i_WE         : in std_logic;                            -- Write enable input
            i_D          : in ex_control_t;                         -- Data value input
            o_Q          : out ex_control_t                         -- Data value output
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

    Reg1Out_input : n_dffg
    port MAP(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_Reg1Out,
        o_Q     => o_Reg1Out
    );

    Reg2Out_input : n_dffg
    port MAP(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_Reg2Out,
        o_Q     => o_Reg2Out
    );

    ZeroExtend_input : n_dffg
    port MAP(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_ZeroExt,
        o_Q     => o_ZeroExt
    );

    SignExtend_input : n_dffg
    port MAP(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_SignExt,
        o_Q     => o_SignExt
    );

    ShamOut_input : n_dffg
    port MAP(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_Shamt,
        o_Q     => o_Shamt
    );

    PCIncOut_input : n_dffg
    port MAP(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_PCInc,
        o_Q     => o_PCInc
    );

    RegWrAddrOut_input : n_dffg
    generic map(
        N       => M
    )
    port MAP(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_RegWrAddr,
        o_Q     => o_RegWrAddr
    );

    EXControl_FF : ex_dffg
    port map(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_EXControl,
        o_Q     => o_EXControl
    );

    MEMControl_FF : mem_dffg
    port map(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_MEMControl,
        o_Q     => o_MEMControl
    );

    WBControl_FF : wb_dffg
    port map(
        i_CLK   => i_CLK,
        i_RST   => i_RST,
        i_WE    => '1',
        i_D     => i_WBControl,
        o_Q     => o_WBControl
    );

end structure;
