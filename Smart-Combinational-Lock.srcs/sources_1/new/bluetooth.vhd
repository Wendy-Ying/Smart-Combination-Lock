library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bluetooth is
    Port (
        CLK : in STD_LOGIC;  -- 输入时钟，我的系统为50MHz
        nRst : in STD_LOGIC;    -- 系统复位，低电平复位
        tx : out STD_LOGIC;     -- UART的输出信号管脚
        rx : in STD_LOGIC       -- UART的输入信号管脚
    );
end bluetooth;

architecture Behavioral of bluetooth is
    signal RegCnt : unsigned(29 downto 0) := (others => '0');
    signal rx_en : STD_LOGIC;
    signal tx_en : STD_LOGIC;

    component uart_en is    -- UART的波特率生成模块
        generic(
            BPS : integer := 9600;  -- 波特率参数，蓝牙模块采用9600
            sysclk : integer := 100_000_000  -- 系统使用是50MHz，如果你的系统是100MHz，这里修改即可
        );
        Port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            rx_en : out STD_LOGIC;
            tx_en : out STD_LOGIC
        );
    end component;

    component uart_rx is    -- UART接收模块
        generic(
            PARITY : string := "NONE";  -- UART的模式为无校验模式，当前蓝牙采用该模式
            STOP : integer := 1     -- 停止位，当前蓝牙模块使用1位停止位
        );
        Port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            rx_en : in STD_LOGIC;
            tx_en : in STD_LOGIC;
            rx : in STD_LOGIC;
            rx_data : out STD_LOGIC_VECTOR(7 downto 0); -- 收到的数据位保存所在，一个byte
            rx_end : out STD_LOGIC;
            rx_data_vld : buffer STD_LOGIC  -- 收到信号为有效时，该信号为高，表明此时 rx_data是有效接收数据
        );
    end component;

    component uart_tx is    --  UART发送模块
        generic(
            PARITY : string := "NONE";  -- 无校验模式
            STOP : integer := 1 -- 停止位位数
        );
        Port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            tx_data_vld : in STD_LOGIC; -- 发送数据有效信号
            tx_data : in STD_LOGIC_VECTOR(7 downto 0);  -- 发送数据存入的地方
            tx_en : in STD_LOGIC;
            tx_ack : buffer STD_LOGIC;  -- 发送数据移入移位寄存器后的指示信号
            tx : out STD_LOGIC  -- 发送数据线管脚
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

-- 这里开始的模块管脚引用，是实际使用UART三个模块的地方
    -- UART时钟生产模块引用
    uart_en_inst : uart_en
    generic map(
        BPS => 9600,    -- 实际采用9600bps波特率
        sysclk => 100_000_000    -- 系统输入为50MHz时钟
    )
    port map(
        clk => CLK,
        rst => nRst,
        rx_en => rx_en,
        tx_en => tx_en
    );
    -- UART接收模块引用
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
    -- UART发送模块引用
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

    -- 这里是实际使用UART功能实现的地方
    -- 当前做的是将收到的数据回环发给发送模块
    process(CLK, nRst)
    begin
        if nRst = '0' then
            SendData <= (others => '0');    -- 缺省发送缓冲器为全0
            SendValid <= '0';   -- 缺省发送有效指示为0，表明没有数据发送
        elsif rising_edge(CLK) then
            if tx_ack = '1' then    -- 当发送数据已经存入移位寄存器，则将发送有效信号关闭当
                SendValid <= '0';
            elsif rx_data_vld = '1' then    --当接收有效信号为1，表明rx_data接收到有效的数据
                SendData <= rx_data;    --该数据存入发送缓冲器
                SendValid <= '1';           --并且使能发送信号标识
            end if;
        end if;
    end process;


end Behavioral;
