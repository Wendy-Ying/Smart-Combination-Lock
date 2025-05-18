----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/05/12 16:23:15
-- Design Name: 
-- Module Name: top_module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_module is
    Port (
        CLK : in std_logic;
        SW : in std_logic_vector (15 downto 0);
        BTNC, BTNU, BTND, BTNL, BTNR : in std_logic;
        rst : in std_logic;
        rx : in std_logic;
        tx : out std_logic;
        SEG : out  std_logic_vector (7 downto 0);
        AN : out  std_logic_vector (7 downto 0);
        LED : out std_logic_vector (2 downto 0)
    );
end top_module;

architecture Behavioral of top_module is
    
    -- TYPE state is (lock, unlock, set_pwd, check_pwd), 0-3;

    component seven_segment_display is
        Port (
            clk : in std_logic;
            number : in std_logic_vector (31 downto 0);
            SEG : out std_logic_vector (7 downto 0);
            AN : out std_logic_vector (7 downto 0)
        );
    end component seven_segment_display;

    component btn_debounce is
        Port (
            clk : in std_logic;
            btn : in std_logic;
            btn_debounced : out std_logic
        );
    end component btn_debounce;


    component timer is
        Port (
            clk : in std_logic;
            lock_start : in std_logic;
            lock_end : out std_logic;
            lock_time : out std_logic_vector (15 downto 0)
        );
    end component timer;

    component mode is
        Port (
            clk : in std_logic;
            btnc, btnd, btnl, btnr, btnu : in std_logic;
            num_input : in std_logic_vector (15 downto 0);
            cur_mode : out integer range 0 to 3;
            num_display : out std_logic_vector (15 downto 0);
            lock_start : out std_logic;
            lock_end : in std_logic;
            led : out std_logic_vector (2 downto 0)
        );
    end component mode;

    component display is
        Port (
            clk : in std_logic;
            cur_mode : in integer range 0 to 3;
            lock_time : in std_logic_vector (15 downto 0);
            num_display : in std_logic_vector (15 downto 0);
            display_out : out std_logic_vector (31 downto 0)
        );
    end component display;

    component bluetooth is 
        Port (
            CLK : in STD_LOGIC;
            nRst : in STD_LOGIC;
            tx : out STD_LOGIC;
            rx : in STD_LOGIC
        );
    end component bluetooth;

    signal BTNC_debounced, BTNU_debounced, BTND_debounced, BTNL_debounced, BTNR_debounced : std_logic;
    
    signal cur_mode : integer range 0 to 3;

    signal num_display : std_logic_vector (15 downto 0);

    signal lock_start, lock_end : std_logic;
    signal lock_time : std_logic_vector (15 downto 0);

    signal display_out : std_logic_vector (31 downto 0);

begin
    btnc_inst : btn_debounce port map (
        clk => CLK,
        btn => BTNC,
        btn_debounced => BTNC_debounced
    );

    btnd_inst : btn_debounce port map (
        clk => CLK,
        btn => BTND,
        btn_debounced => BTND_debounced
    );

    btnl_inst : btn_debounce port map (
        clk => CLK,
        btn => BTNL,
        btn_debounced => BTNL_debounced
    );

    btnr_inst : btn_debounce port map (
        clk => CLK,
        btn => BTNR,
        btn_debounced => BTNR_debounced
    );

    btnu_inst : btn_debounce port map (
        clk => CLK,
        btn => BTNU,
        btn_debounced => BTNU_debounced
    );

    mode_inst : mode port map (
        clk => CLK,
        btnc => BTNC_debounced,
        btnd => BTND_debounced,
        btnl => BTNL_debounced,
        btnr => BTNR_debounced,
        btnu => BTNU_debounced,
        num_input => SW,
        cur_mode => cur_mode,
        num_display => num_display,
        lock_start => lock_start,
        lock_end => lock_end,
        led => LED
    );

    display_inst : display port map (
        clk => CLK,
        cur_mode => cur_mode,
        lock_time => lock_time,
        num_display => num_display,
        display_out => display_out
    );

    timer_inst : timer port map (
        clk => CLK,
        lock_start => lock_start,
        lock_end => lock_end,
        lock_time => lock_time
    );

    seven_segment_display_inst : seven_segment_display port map (
        clk => CLK,
        number => display_out,
        SEG => SEG,
        AN => AN
    );

    blue_tooth_inst : bluetooth port map (
        CLK => CLK,
        nRst => rst,
        tx => tx,
        rx => rx
    );

end Behavioral;
