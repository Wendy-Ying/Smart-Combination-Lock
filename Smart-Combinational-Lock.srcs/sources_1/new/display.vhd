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

    -- TYPE state is (lock, unlock, set_pwd, check_pwd), 0-3, (LC, OK, SEPD, CHPD);
    signal C : std_logic_vector (3 downto 0) := "1010";
    signal E : std_logic_vector (3 downto 0) := "1011";
    signal L : std_logic_vector (3 downto 0) := "1100";
    signal H : std_logic_vector (3 downto 0) := "1101";
    signal P : std_logic_vector (3 downto 0) := "1110";
    signal lock_time_display : std_logic_vector (15 downto 0);

begin
    lock_time_display <= (others => '1') when lock_time = x"0000" else lock_time;

    with cur_mode select
        display_out <= 
            L & C & x"FF" & lock_time_display when 0,
            "0000" & H & x"FFFFFF" when 1,
            "0101" & E & P & "0000" & num_display when 2,
            C & H & P & "0000" & num_display when 3,
            x"FFFFFFFF" when others;

end Behavioral;
