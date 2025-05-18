library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port (
        clk : in std_logic;
        lock_start : in std_logic;
        lock_end : out std_logic;
        lock_time : out std_logic_vector(15 downto 0)
    );
end timer;

architecture Behavioral of timer is

    signal clock_divider : integer range 0 to 99999999 := 0;
    signal seconds_reg : integer range 0 to 59 := 0;
    signal minutes_reg : integer range 0 to 59 := 0;
    signal timer_running : boolean := false;

    signal sec_tens : integer range 0 to 5 := 0;
    signal sec_units : integer range 0 to 9 := 0;
    signal min_tens : integer range 0 to 5 := 0;
    signal min_units : integer range 0 to 9 := 0;

    signal lock_end_reg : std_logic := '1';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if lock_start = '1' then
                clock_divider <= 0;
                seconds_reg <= 0;
                minutes_reg <= 2;
                timer_running <= true;
                lock_end_reg <= '0';
            elsif timer_running then
                if clock_divider = 99999999 then
                    clock_divider <= 0;
                    if seconds_reg = 0 then
                        if minutes_reg = 0 then
                            timer_running <= false;
                            lock_end_reg <= '1';
                        else
                            minutes_reg <= minutes_reg - 1;
                            seconds_reg <= 59;
                        end if;
                    else
                        seconds_reg <= seconds_reg - 1;
                    end if;
                else
                    clock_divider <= clock_divider + 1;
                end if;
            else
                clock_divider <= 0;
            end if;
        end if;
    end process;

    sec_tens <= seconds_reg / 10;
    sec_units <= seconds_reg mod 10;
    min_tens <= minutes_reg / 10;
    min_units <= minutes_reg mod 10;

    lock_time(15 downto 12) <= std_logic_vector(to_unsigned(min_tens, 4));
    lock_time(11 downto 8) <= std_logic_vector(to_unsigned(min_units, 4));
    lock_time(7 downto 4) <= std_logic_vector(to_unsigned(sec_tens, 4));
    lock_time(3 downto 0) <= std_logic_vector(to_unsigned(sec_units, 4));

    lock_end <= lock_end_reg;

end Behavioral;