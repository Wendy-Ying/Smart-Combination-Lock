library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mode is 
    Port (
        btnc, btnd, btnl, btnr, btnu : in std_logic;
        num_input : in std_logic_vector (15 downto 0);
        cur_mode : out integer range 0 to 3;
        num_display : out std_logic_vector (15 downto 0);
        lock_start : out std_logic;
        lock_end : in std_logic;
        led : out std_logic_vector (2 downto 0)
    );
end mode;

architecture Behavioral of mode is

begin

end Behavioral;