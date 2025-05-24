library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity false_music is
    port
    (
        clk:in std_logic;--Ê±ÖÓ
        rst: in std_logic;
        key_output:out std_logic_vector(2 downto 0)
    );
end entity;

architecture Behavioral of false_music is
--type integer_array is array (natural range <>) of integer;
--constant music: integer_array(0 to 1) := (1, 5);
--signal note_cnt: unsigned(0 downto 0);

--constant max_count : integer := 99_999_999;
--signal counter : unsigned(26 downto 0) := (others => '0');

--signal key_temp : std_logic_vector(2 downto 0) := "000";
begin
--    process(clk, rst)
--    begin
--        if (rst = '0') then
--            key_temp <= "000";
--        elsif (rising_edge(clk)) then
--            if(counter = max_count) then
--                counter <= (others => '0');
--                if (note_cnt = 0) then
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(0), 3));
--                else
--                    key_temp <= std_logic_vector(TO_UNSIGNED(music(1), 3));
--                end if;
--                note_cnt <= note_cnt + 1;
--            else
--                counter <= counter + 1;
--            end if;
--        end if;
--    end process;
    
    key_output <= "111";
end Behavioral;
