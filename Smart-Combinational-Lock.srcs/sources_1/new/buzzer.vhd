library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity buzzer is
    port
    (
        clk_in:in std_logic;
        reset_in :in std_logic;
        mode:in std_logic; -- 0 为wrong，1为right
        outbell:out std_logic
    );
end entity;

architecture lin of buzzer is
signal bells:std_logic;
signal clk_tmp:std_logic;--10M锟斤拷锟斤拷
signal clk_tmp2:std_logic;--10M锟斤拷?
signal key_in:std_logic_vector(2 downto 0);
signal key_wrong: std_logic_vector(2 downto 0);
signal key_right: std_logic_vector(2 downto 0);
signal pre_div:std_logic_vector(15 downto 0);
signal not_reset_in:std_logic;

component false_music is
    port
    (
        clk:in std_logic;--时钟
        rst: in std_logic;
        key_output:out std_logic_vector(2 downto 0)
    );
end component;

component true_music is
    port
    (
        clk:in std_logic;--时钟
        rst: in std_logic;
        key_output:out std_logic_vector(2 downto 0)
    );
end component;

component gen_div is--锟斤拷频元锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷
generic(div_param:integer:=2);--4锟斤拷频锟斤拷,锟斤拷锟斤拷10M锟斤拷锟斤拷
port
(
    clk:in std_logic;
    bclk:out std_logic;
    resetb:in std_logic
);
end component;

component bell is
port
(
    clkin:in std_logic;--时锟斤拷
    resetin :in std_logic;
    key:in std_logic_vector(2 downto 0);
    bell_out:out std_logic--bell锟斤拷锟斤拷锟斤拷锟?
);
end component;

begin
outbell <=bells when reset_in = '1' else '1';
--key_in <=keyin;
key_in <= key_wrong when mode = '0' else key_right;
--outbell <= key_wrong when mode = '0' else key_right;
not_reset_in <= not reset_in;   

music_correct: 
        true_music port map
        (
        clk=>clk_in,
        rst=>reset_in,
        key_output=>key_right
        );
        
music_wrong: 
        false_music port map
        (
        clk=>clk_in,
        rst=>reset_in,
        key_output=>key_wrong
        );

gen_10M: --锟斤拷频锟斤拷锟斤拷10M锟斤拷锟斤拷
        gen_div generic map(2)--4锟斤拷频锟斤拷,锟斤拷锟斤拷10M锟斤拷锟斤拷
        port map--锟斤拷频元锟斤拷锟斤拷锟斤拷
        (
            clk=>clk_in,
            resetb => not_reset_in,
            bclk=>clk_tmp
        );

bell8s:
        bell port map
        (
        clkin=>clk_tmp,
        resetin =>reset_in,
        key=>key_in,
        bell_out=>bells
        );

end lin;    