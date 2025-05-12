library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity timer is 
    Port (
        clk : in std_logic;
        lock_start : in std_logic;
        lock_end : out std_logic;
        lock_time : out std_logic_vector (15 downto 0)
    );
end timer;

architecture Behavioral of timer is

begin

end Behavioral;