library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seven_segment_display is 
    Port (
        clk : in std_logic;
        number : in std_logic_vector (31 downto 0);
        SEG : out std_logic_vector (7 downto 0);
        AN : out std_logic_vector (7 downto 0)
    );
end seven_segment_display;

architecture Behavioral of seven_segment_display is

begin

end Behavioral;