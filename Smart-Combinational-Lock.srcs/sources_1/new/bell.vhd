--蜂鸣器,发出1,2,3,4,5,6,7音
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bell is

    port
    (
        clkin:in std_logic;--时钟
        resetin :in std_logic;
        key:in std_logic_vector(2 downto 0);
        bell_out:out std_logic--bell脉冲输出
    );
end entity;

architecture behave of bell is
------------------------------
signal bell_tmp:std_logic;
signal pre_div:std_logic_vector(15 downto 0);--分频系数
---------------------------
begin
-------------------
bell_out<=bell_tmp;
----------------------
    process(clkin,key,resetin)
    variable cnt:std_logic_vector(15 downto 0):=X"0000";    
    begin
        if resetin='0' then
            bell_tmp<='0';--复位时，bell不出声
            cnt:=X"0000";
            pre_div<=X"0000";--1
        else
            if rising_edge(clkin) then
                if cnt>=pre_div then   --  > & =
                    bell_tmp<=not bell_tmp;
                    cnt:=X"0000";                   
                    if key="000" then
                        pre_div<=X"0000";--0
                    elsif key="001" then
                        pre_div<=X"4AA7";--1
                    elsif key="010" then
                        pre_div<=X"4282";--2
                    elsif key="011"then
                        pre_div<=X"3B41";--3
                    elsif key="100" then
                        pre_div<=X"37ED";--4
                    elsif key="101"then
                        pre_div<=X"31D3";--5
                    elsif key="110" then
                        pre_div<=X"2C64";--6
                    elsif key="111" then
                        pre_div<=X"278C";--7
                    end if;
                else
                    cnt:=cnt+'1';
                end if;
            end if;
        end if;
    end process;
----------------------------------------------------------

end behave;
