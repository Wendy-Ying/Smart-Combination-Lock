library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is
end top_tb;

architecture tb of top_tb is
    signal clk_in: std_logic := '0';
    signal reset_in: std_logic := '1';
    signal mode: std_logic := '0';
    signal key_in:std_logic_vector(2 downto 0); 
    constant clk_period: time := 10 ns;
    
    component buzzer is
        port
        (
            clk_in:in std_logic;
            reset_in :in std_logic;
            mode:in std_logic; 
            keyin: out std_logic_vector(2 downto 0)
        );
    end component;

begin
    uut: buzzer
        port map (
            clk_in =&gt; clk_in,
            reset_in =&gt; reset_in,
            mode =&gt; mode,
            keyin =&gt; key_in
        );
    clk_gen: process
    begin
        clk_in &lt;= '0';
        wait for clk_period/2;
        clk_in &lt;= '1';
        wait for clk_period/2;
    end process clk_gen;
    
    stimulus: process
    begin
        reset_in &lt;= '1';
        wait for 10000 ns;
        reset_in &lt;= '0';
        wait for 10000 ns;
        reset_in &lt;= '1';
        
        mode &lt;= '0';
        wait for 100000 ns;
        mode &lt;= '1';
        wait for 100000 ns;
        mode &lt;= '0';
        wait for 100000 ns;
        
        wait;
    end process stimulus;

end tb;