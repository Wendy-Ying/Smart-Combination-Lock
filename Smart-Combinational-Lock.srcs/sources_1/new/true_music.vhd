library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity true_music is
    port
    (
        clk:in std_logic;--Ê±ÖÓ
        rst: in std_logic;
        key_output:out std_logic_vector(2 downto 0)
    );
end entity;

architecture Behavioral of true_music is
type integer_array is array (natural range <>) of integer;
constant len : integer := 4;
constant music: integer_array(0 to len-1) := (1, 3, 5, 7);
signal note_cnt: unsigned(1 downto 0);

constant max_count : integer := 99_999_999;
signal counter : unsigned(26 downto 0) := (others => '0');

signal key_temp : std_logic_vector(2 downto 0) := "000";
begin
    process(clk, rst)
    begin
        if (rst = '0') then
            key_temp <= "000";
        elsif (rising_edge(clk)) then
            if(counter = max_count) then
                counter <= (others => '0');
                if (note_cnt mod len = 0) then
                    key_temp <= std_logic_vector(TO_UNSIGNED(music(0), 3));
                elsif (note_cnt mod len = 1) then
                    key_temp <= std_logic_vector(TO_UNSIGNED(music(1), 3));
                elsif (note_cnt mod len = 2) then
                    key_temp <= std_logic_vector(TO_UNSIGNED(music(2), 3));
                elsif (note_cnt mod len = 3) then
                    key_temp <= std_logic_vector(TO_UNSIGNED(music(3), 3));
--                elsif (note_cnt mod 32 = 4) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(4), 3));
--                elsif (note_cnt mod 32 = 5) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(5), 3));
--                elsif (note_cnt mod 32 = 6) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(6), 3));
--                elsif (note_cnt mod 32 = 7) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(7), 3));
--                elsif (note_cnt mod 32 = 8) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(8), 3));
--                elsif (note_cnt mod 32 = 9) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(9), 3));
--                elsif (note_cnt mod 32 = 10) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(10), 3));
--                elsif (note_cnt mod 32 = 11) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(11), 3));
--                elsif (note_cnt mod 32 = 12) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(12), 3));
--                elsif (note_cnt mod 32 = 13) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(13), 3));
--                elsif (note_cnt mod 32 = 14) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(14), 3));
--                elsif (note_cnt mod 32 = 15) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(15), 3));
--                elsif (note_cnt mod 32 = 16) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(16), 3));
--                elsif (note_cnt mod 32 = 17) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(17), 3));
--                elsif (note_cnt mod 32 = 18) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(18), 3));
--                elsif (note_cnt mod 32 = 19) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(19), 3));
--                elsif (note_cnt mod 32 = 20) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(20), 3));
--                elsif (note_cnt mod 32 = 21) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(21), 3));
--                elsif (note_cnt mod 32 = 22) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(22), 3));
--                elsif (note_cnt mod 32 = 23) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(23), 3));
--                elsif (note_cnt mod 32 = 24) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(24), 3));
--                elsif (note_cnt mod 32 = 25) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(25), 3));
--                elsif (note_cnt mod 32 = 26) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(26), 3));
--                elsif (note_cnt mod 32 = 27) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(27), 3));
--                elsif (note_cnt mod 32 = 28) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(28), 3));
--                elsif (note_cnt mod 32 = 29) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(29), 3));
--                elsif (note_cnt mod 32 = 30) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(30), 3));
--                elsif (note_cnt mod 32 = 31) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(31), 3));
                end if;
                note_cnt <= note_cnt + 1;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    key_output <= key_temp;
end Behavioral;
