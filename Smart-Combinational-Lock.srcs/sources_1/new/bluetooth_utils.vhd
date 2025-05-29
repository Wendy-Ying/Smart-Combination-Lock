library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- uart_en
entity uart_en is
    generic(
        BPS : integer := 115200;
        sysclk : integer := 100_000_000
    );
    Port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        rx_en : out STD_LOGIC;
        tx_en : out STD_LOGIC
    );
end uart_en;

architecture Behavioral of uart_en is
    signal cnt_tx : integer range 0 to sysclk/BPS-1 := 0;
    constant bps_tx : integer := sysclk/BPS;
    signal cnt_rx : integer range 0 to sysclk/(BPS*8)-1 := 0;
    constant bps_rx : integer := sysclk/(BPS*8);
begin
    process(clk, rst)
    begin
        if rst = '0' then
            cnt_tx <= 0;
        elsif rising_edge(clk) then
            if cnt_tx >= bps_tx - 1 then
                cnt_tx <= 0;
            else
                cnt_tx <= cnt_tx + 1;
            end if;
        end if;
    end process;
    tx_en <= '1' when cnt_tx = bps_tx - 1 else '0';

    process(clk, rst)
    begin
        if rst = '0' then
            cnt_rx <= 0;
        elsif rising_edge(clk) then
            if cnt_rx >= bps_rx - 1 then
                cnt_rx <= 0;
            else
                cnt_rx <= cnt_rx + 1;
            end if;
        end if;
    end process;
    rx_en <= '1' when cnt_rx = bps_rx - 1 else '0';
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- uart_rx
entity uart_rx is
    generic(
        PARITY : string := "NONE";
        STOP : integer := 1
    );
    Port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        rx_en : in STD_LOGIC;
        tx_en : in STD_LOGIC;
        rx : in STD_LOGIC;
        rx_data : out STD_LOGIC_VECTOR(7 downto 0);
        rx_end : out STD_LOGIC;
        rx_data_vld : buffer STD_LOGIC
    );
end uart_rx;

architecture Behavioral of uart_rx is
    signal rx_r : STD_LOGIC_VECTOR(1 downto 0) := "11";
    signal rx_edge : STD_LOGIC;
    signal rx_data_vld_r : STD_LOGIC;
    signal rx_data_vld_rr : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal rx_data_r : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal state : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal sample_cnt : integer range 0 to 255 := 0;
    signal odd : STD_LOGIC;
    signal rx_end_reg : STD_LOGIC_VECTOR(13 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '0' then
            rx_r <= "11";
        elsif rising_edge(clk) then
            if rx_en = '1' then
                rx_r(0) <= rx;
                rx_r(1) <= rx_r(0);
            end if;
        end if;
    end process;
    rx_edge <= '1' when (not rx_r(0) and rx_r(1)) = '1' else '0';

    process(clk, rst)
    begin
        if rst = '0' then
            rx_data_vld_rr <= "00";
        elsif rising_edge(clk) then
            rx_data_vld_rr <= rx_data_vld_rr(0) & rx_data_vld_r;
        end if;
    end process;
    rx_data_vld <= '1' when (not rx_data_vld_rr(1) and rx_data_vld_rr(0)) = '1' else '0';

    odd <= '1' when (rx_data_r(0) xor rx_data_r(1) xor rx_data_r(2) xor rx_data_r(3) xor rx_data_r(4) xor rx_data_r(5) xor rx_data_r(6) xor rx_data_r(7)) = '1' else '0';

    process(clk, rst)
    begin
        if rst = '0' then
            rx_data <= (others => '0');
            rx_data_vld_r <= '0';
            sample_cnt <= 0;
            state <= "0000";
        elsif rising_edge(clk) then
            if rx_en = '1' then
                case state is
                    when "0000" => -- idle
                        rx_data_r <= (others => '0');
                        rx_data_vld_r <= '0';
                        sample_cnt <= 0;
                        if rx_edge = '1' then
                            state <= "0001";
                        end if;
                    when "0001" => -- start
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 3 then
                            sample_cnt <= 0;
                            state <= "0010";
                        end if;
                    when "0010" => -- s1
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(0) <= rx_r(1);
                            state <= "0011";
                        end if;
                    when "0011" => -- s2
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(1) <= rx_r(1);
                            state <= "0100";
                        end if;
                    when "0100" => -- s3
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(2) <= rx_r(1);
                            state <= "0101";
                        end if;
                    when "0101" => -- s4
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(3) <= rx_r(1);
                            state <= "0110";
                        end if;
                    when "0110" => -- s5
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(4) <= rx_r(1);
                            state <= "0111";
                        end if;
                    when "0111" => -- s6
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(5) <= rx_r(1);
                            state <= "1000";
                        end if;
                    when "1000" => -- s7
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(6) <= rx_r(1);
                            state <= "1001";
                        end if;
                    when "1001" => -- s8
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            rx_data_r(7) <= rx_r(1);
                            if PARITY = "NONE" then
                                state <= "1100";
                            elsif PARITY = "ODD" then
                                state <= "1010";
                            else
                                state <= "1011";
                            end if;
                        end if;
                    when "1010" => -- parity_odd
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 and rx_r(1) = not odd then
                            sample_cnt <= 0;
                            state <= "1100";
                        end if;
                    when "1011" => -- parity_even
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 and rx_r(1) = odd then
                            sample_cnt <= 0;
                            state <= "1100";
                        end if;
                    when "1100" => -- stop1
                        if STOP = 1 then
                            sample_cnt <= sample_cnt + 1;
                            if sample_cnt >= 7 then
                                sample_cnt <= 0;
                                state <= "0000";
                                rx_data <= rx_data_r;
                                rx_data_vld_r <= '1';
                            end if;
                        else
                            sample_cnt <= sample_cnt + 1;
                            if sample_cnt >= 7 and rx_r(1) = '1' then
                                state <= "1101";
                                sample_cnt <= 0;
                            end if;
                        end if;
                    when "1101" => -- stop2
                        sample_cnt <= sample_cnt + 1;
                        if sample_cnt >= 7 then
                            sample_cnt <= 0;
                            state <= "0000";
                            rx_data <= rx_data_r;
                            rx_data_vld_r <= '1';
                        end if;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '0' then
            rx_end_reg <= (others => '0');
        elsif rising_edge(clk) then
            if rx_data_vld = '1' then
                rx_end_reg <= B"11_1111_1111_1111"; --x"3FFF";
            elsif tx_en = '1' then
                rx_end_reg <= '0' & rx_end_reg(13 downto 1);
            elsif rx_end_reg = B"00_0000_0000_0001" then    --x"0001" then
                rx_end_reg <= (others => '0');
            end if;
        end if;
    end process;
    rx_end <= '1' when rx_end_reg = B"00_0000_0000_0001" else '0';  --x"0001" else '0';
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- uart_tx
entity uart_tx is
    generic(
        PARITY : string := "NONE";
        STOP : integer := 1
    );
    Port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx_data_vld : in STD_LOGIC;
        tx_data : in STD_LOGIC_VECTOR(7 downto 0);
        tx_en : in STD_LOGIC;
        tx_ack : buffer STD_LOGIC;
        tx : out STD_LOGIC
    );
end uart_tx;

architecture Behavioral of uart_tx is
    signal tx_data_rdy : STD_LOGIC := '0';
    signal state : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal tx_data_r : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal odd : STD_LOGIC;
begin
    process(clk, rst)
    begin
        if rst = '0' then
            tx_data_rdy <= '0';
        elsif rising_edge(clk) then
            if tx_ack = '1' then
                tx_data_rdy <= '0';
            elsif tx_data_vld = '1' then
                tx_data_rdy <= '1';
            end if;
        end if;
    end process;

    odd <= '1' when (tx_data_r(0) xor tx_data_r(1) xor tx_data_r(2) xor tx_data_r(3) xor tx_data_r(4) xor tx_data_r(5) xor tx_data_r(6) xor tx_data_r(7)) = '1' else '0';

    process(clk, rst)
    begin
        if rst = '0' then
            tx_data_r <= (others => '0');
            state <= "0000";
            tx <= '1';
            tx_ack <= '0';
        elsif rising_edge(clk) then
            if tx_en = '1' then
                case state is
                    when "0000" => -- idle
                        tx <= '1';
                        if tx_data_rdy = '1' then
                            tx_data_r <= tx_data;
                            state <= "0001";
                            tx_ack <= '1';
                        end if;
                    when "0001" => -- start
                        tx <= '0';
                        tx_ack <= '0';
                        state <= "0010";
                    when "0010" => -- s1
                        tx <= tx_data_r(0);
                        state <= "0011";
                    when "0011" => -- s2
                        tx <= tx_data_r(1);
                        state <= "0100";
                    when "0100" => -- s3
                        tx <= tx_data_r(2);
                        state <= "0101";
                    when "0101" => -- s4
                        tx <= tx_data_r(3);
                        state <= "0110";
                    when "0110" => -- s5
                        tx <= tx_data_r(4);
                        state <= "0111";
                    when "0111" => -- s6
                        tx <= tx_data_r(5);
                        state <= "1000";
                    when "1000" => -- s7
                        tx <= tx_data_r(6);
                        state <= "1001";
                    when "1001" => -- s8
                        tx <= tx_data_r(7);
                        if PARITY = "NONE" then
                            state <= "1011";
                        else
                            state <= "1010";
                        end if;
                    when "1010" => -- parity
                        state <= "1011";
                        if PARITY = "ODD " then
                            tx <= not odd;
                        else
                            tx <= odd;
                        end if;
                    when "1011" => -- stop1
                        tx <= '1';
                        if STOP = 1 then
                            if tx_data_rdy = '1' then
                                tx_data_r <= tx_data;
                                state <= "0001";
                                tx_ack <= '1';
                            end if;
                        end if;
                    when "1100" => -- stop2
                        tx <= '1';
                        if tx_data_rdy = '1' then
                            tx_data_r <= tx_data;
                            state <= "0001";
                            tx_ack <= '1';
                        end if;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
