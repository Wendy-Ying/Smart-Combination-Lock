library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bluetooth is
    Port (
        CLK : in STD_LOGIC;
        nRst : in STD_LOGIC;
        tx : out STD_LOGIC; -- uart output
        rx : in STD_LOGIC -- uart input
    );
end bluetooth;

architecture Behavioral of bluetooth is
    signal RegCnt : unsigned(29 downto 0) := (others => '0');
    signal rx_en : STD_LOGIC;
    signal tx_en : STD_LOGIC;

    component uart_en is    -- UART baud rate generater
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

    component uart_rx is    -- UART receiver
        generic(
            PARITY : string := "NONE";  -- none check
            STOP : integer := 1     -- stop flag
        );
        Port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            rx_en : in STD_LOGIC;
            tx_en : in STD_LOGIC;
            rx : in STD_LOGIC;
            rx_data : out STD_LOGIC_VECTOR(7 downto 0); -- data to be saved
            rx_end : out STD_LOGIC;
            rx_data_vld : buffer STD_LOGIC  -- valid data appear
        );
    end component;

    component uart_tx is    --  UART sender
        generic(
            PARITY : string := "NONE";  -- none check
            STOP : integer := 1 -- stop flag
        );
        Port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            tx_data_vld : in STD_LOGIC; -- valid data appear
            tx_data : in STD_LOGIC_VECTOR(7 downto 0);  -- data to be saved
            tx_en : in STD_LOGIC;
            tx_ack : buffer STD_LOGIC;  -- data put in ok
            tx : out STD_LOGIC
        );
    end component;

    signal rx_data_vld : STD_LOGIC;
    signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_end : STD_LOGIC;
    signal tx_ack : STD_LOGIC;
    signal SendData : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal SendValid : STD_LOGIC := '0';

begin

    process(CLK, nRst)
    begin
        if nRst = '0' then
            RegCnt <= (others => '0');
        elsif rising_edge(CLK) then
            RegCnt <= RegCnt + 1;
        end if;
    end process;

    uart_en_inst : uart_en
    generic map(
        BPS => 9600, 
        sysclk => 100_000_000
    )
    port map(
        clk => CLK,
        rst => nRst,
        rx_en => rx_en,
        tx_en => tx_en
    );

    uart_rx_inst : uart_rx
    generic map(
        PARITY => "NONE",
        STOP => 1
    )
    port map(
        clk => CLK,
        rst => nRst,
        rx_en => rx_en,
        tx_en => tx_en,
        rx => rx,
        rx_data => rx_data,
        rx_end => rx_end,
        rx_data_vld => rx_data_vld
    );

    uart_tx_inst : uart_tx
    generic map(
        PARITY => "NONE",
        STOP => 1
    )
    port map(
        clk => CLK,
        rst => nRst,
        tx_data_vld => SendValid,
        tx_data => SendData,
        tx_en => tx_en,
        tx_ack => tx_ack,
        tx => tx
    );

    process(CLK, nRst)
    begin
        if nRst = '0' then
            SendData <= (others => '0');
            SendValid <= '0';
        elsif rising_edge(CLK) then
            if rx /= '1' then
                SendValid <= '0';
            else
                SendData <= (others => '0');
                SendValid <= '1';
            end if;
        end if;
    end process;


end Behavioral;
