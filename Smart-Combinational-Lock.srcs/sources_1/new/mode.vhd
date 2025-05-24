library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mode is 
    Port (
        clk : in std_logic;
        btnc, btnd, btnl, btnr, btnu : in std_logic;
        num_input : in std_logic_vector (15 downto 0);
        lock_end : in std_logic;
        cur_mode : out integer range 0 to 3;  -- TYPE state is (lock, unlock, set_pwd, check_pwd), 0-3;
        num_display : out std_logic_vector (15 downto 0);
        lock_start : out std_logic;
        led : out std_logic_vector (2 downto 0);
        buzzer_en : out std_logic;
        buzzer_opt : out std_logic
    );
end mode;

architecture Behavioral of mode is

signal mode_reg : integer range 0 to 3 := 2;
signal lock_start_reg : std_logic := '0';
signal led_reg : std_logic_vector (2 downto 0) := "000";
signal pass_word : std_logic_vector (15 downto 0);
signal check_pwd_acc_fault : integer range 0 to 3 := 0; -- check_pwd_acc_fault
signal check_pwd_result : std_logic := '0';

begin
    process(clk) is
    begin
        if rising_edge(clk) then

            case mode_reg is
                when 0 =>
                    if btnu = '1' and lock_end = '1' then -- lock -> check_pwd
                        check_pwd_acc_fault <= 0;
                        mode_reg <= 3;
                    end if;
                    lock_start_reg <= '0';
                    led_reg <= "000";

                when 1 =>
                    if btnc = '1' and lock_end = '1' then
                        mode_reg <= 0;
                        buzzer_en <= '0';
                    elsif btnl = '1' and lock_end = '1' then
                        mode_reg <= 2;
                        buzzer_en <= '0';
                    end if;
                    led_reg <= "000";

                when 2 =>
                    if btnl = '1' and lock_end = '1' then
                        mode_reg <= 0;
                    end if;
                    led_reg <= "000";

                when 3 =>
                    if btnu = '1' and lock_end = '1' and check_pwd_result = '0' and check_pwd_acc_fault = 3 then -- fail last time and accumulate three times
                        check_pwd_acc_fault <= 0;    
                        mode_reg <= 0;
                        lock_start_reg <= '1';
                        led_reg <= "000";
                        buzzer_en <= '1';
                        buzzer_opt <= '0';
                    elsif btnu = '1'and lock_end = '1' and check_pwd_result = '0' and check_pwd_acc_fault = 0 then
                        check_pwd_acc_fault <= 1;
                        mode_reg <= 3;
                        lock_start_reg <= '0';
                        led_reg <= "001";
                        buzzer_en <= '1';
                        buzzer_opt <= '0';
                    elsif btnu = '1'and lock_end = '1' and check_pwd_result = '0' and check_pwd_acc_fault = 1 then
                        check_pwd_acc_fault <= 2;
                        mode_reg <= 3;
                        lock_start_reg <= '0';
                        led_reg <= "011";
                        buzzer_en <= '1';
                        buzzer_opt <= '0';
                    elsif btnu = '1'and lock_end = '1' and check_pwd_result = '0' and check_pwd_acc_fault = 2 then
                        check_pwd_acc_fault <= 3;
                        mode_reg <= 3;
                        lock_start_reg <= '0';
                        led_reg <= "111";
                        buzzer_en <= '1';
                        buzzer_opt <= '0';
                    elsif btnu = '1' and lock_end = '1' and check_pwd_result = '1' then
                        mode_reg <= 1;
                        lock_start_reg <= '0';
                        led_reg <= "000";
                        buzzer_en <= '1';
                        buzzer_opt <= '1';
                    end if;
            end case;
        end if;
    end process;

cur_mode <= mode_reg;
num_display <= num_input;
lock_start <= lock_start_reg;
led <= led_reg;
pass_word <= num_input when mode_reg = 2;
check_pwd_result <= '1' when (num_input = pass_word and mode_reg = 3) else '0';


end Behavioral;