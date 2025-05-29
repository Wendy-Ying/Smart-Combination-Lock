library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench for UART modules
entity uart_tb is
end uart_tb;

architecture Behavioral of uart_tb is
    -- Constants
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock period
    constant BPS : integer := 9600; -- Baud rate
    constant SYSCLK : integer := 100_000_000; -- System clock frequency
    constant BIT_PERIOD : time := 1041.67 us; -- Time for one bit at 9600 bps

    -- Signals
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal rx_en : STD_LOGIC;
    signal tx_en : STD_LOGIC;
    signal loopsignal : STD_LOGIC; -- UART transmit signal (renamed for loopback)
    signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_end : STD_LOGIC;
    signal rx_data_vld : STD_LOGIC;
    signal tx_data_vld : STD_LOGIC := '0';
    signal tx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx_ack : STD_LOGIC;

    -- Test data array
    type test_data_array is array (natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
    constant test_data : test_data_array := (
        x"AA", x"1F", x"55", x"88", x"FF", x"37", x"7E", x"2B", x"4D", x"9A"
    );

    -- Components
    component uart_en is
        generic(
            BPS : integer := 9600;
            sysclk : integer := 100_000_000
        );
        Port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            rx_en : out STD_LOGIC;
            tx_en : out STD_LOGIC
        );
    end component;

    component uart_rx is
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
    end component;

    component uart_tx is
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
    end component;

begin
    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- UART enable module instantiation
    uart_en_inst : uart_en
        generic map(
            BPS => BPS,
            sysclk => SYSCLK
        )
        port map(
            clk => clk,
            rst => rst,
            rx_en => rx_en,
            tx_en => tx_en
        );

    -- UART receiver module instantiation
    uart_rx_inst : uart_rx
        generic map(
            PARITY => "NONE",
            STOP => 1
        )
        port map(
            clk => clk,
            rst => rst,
            rx_en => rx_en,
            tx_en => tx_en,
            rx => loopsignal, -- Connect RX to loopback signal
            rx_data => rx_data,
            rx_end => rx_end,
            rx_data_vld => rx_data_vld
        );

    -- UART transmitter module instantiation
    uart_tx_inst : uart_tx
        generic map(
            PARITY => "NONE",
            STOP => 1
        )
        port map(
            clk => clk,
            rst => rst,
            tx_data_vld => tx_data_vld,
            tx_data => tx_data,
            tx_en => tx_en,
            tx_ack => tx_ack,
            tx => loopsignal -- Connect TX to loopback signal
        );

    -- Test process
    test_process : process
    begin
        -- Initialize
        rst <= '1'; -- Start the system
        wait for CLK_PERIOD;
        rst <= '0'; -- Hold reset
        wait for CLK_PERIOD;
        rst <= '1'; -- Release reset
        wait for CLK_PERIOD;

        -- Test UART transmit and receive (loopback)
        report "Starting UART loopback test";

        -- Loop through test data array
        for i in test_data'range loop
            -- Prepare data to send
            tx_data <= test_data(i);
            tx_data_vld <= '1';
            wait until tx_ack = '1'; -- Wait for transmitter to acknowledge
            tx_data_vld <= '0';
            -- Wait for the received data to be valid
            wait until rx_data_vld = '1';
            wait for BIT_PERIOD; -- Wait for the next bit
        end loop;

        -- End simulation
        report "Simulation completed successfully";
        wait;
    end process;

end Behavioral;