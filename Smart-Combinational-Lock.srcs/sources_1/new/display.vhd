library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity display is
    Port (
        clk : in std_logic;
        cur_mode : in integer range 0 to 3;
        lock_time : in std_logic_vector (15 downto 0);
        num_display : in std_logic_vector (15 downto 0);
        display_out : out std_logic_vector (31 downto 0)
    );
end display;

architecture Behavioral of display is


begin


end Behavioral;
