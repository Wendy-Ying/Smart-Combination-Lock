library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity btn_debounce is
    Port (
        clk : in std_logic;
        btn : in std_logic;
        btn_debounced : out std_logic
    );
end btn_debounce;

architecture Behavioral of btn_debounce is

    signal btn_prev : std_logic := '0';
    signal btn_sync : std_logic_vector(1 downto 0) := "00";
    signal counter : std_logic_vector(20 downto 0) := (others => '0');
    signal btn_stable : std_logic := '0';

begin

    -- Synchronization and Debounce process
    process(clk)
    begin
        if rising_edge(clk) then
            -- Update btn_sync in this process only
            btn_sync <= btn_sync(0) & btn;

            -- Debounce logic
            if btn_sync(1) /= btn_stable then
                if counter = 2_000_000 then
                    btn_stable <= btn_sync(1);
                    counter <= (others => '0');
                else
                    counter <= counter + 1;
                end if;
            else
                counter <= (others => '0');
            end if;
        end if;
    end process;

    -- Button output process
    process(clk)
    begin
        if rising_edge(clk) then
            btn_prev <= btn_stable;
            if btn_prev = '0' and btn_stable = '1' then
                btn_debounced <= '1';
            else
                btn_debounced <= '0';
            end if;
        end if;
    end process;

end Behavioral;
