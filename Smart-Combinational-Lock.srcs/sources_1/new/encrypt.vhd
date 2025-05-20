library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity encrypt is
    Port (
        clk : in STD_LOGIC;
        plaintext : in STD_LOGIC_VECTOR(15 downto 0);
        key : in STD_LOGIC_VECTOR(15 downto 0);
        ciphertext : out STD_LOGIC_VECTOR(15 downto 0)
    );
end encrypt;

architecture Behavioral of encrypt is
    constant NUM_ROUNDS : integer := 4;

    type left_array is array (0 to NUM_ROUNDS) of STD_LOGIC_VECTOR(7 downto 0);
    type right_array is array (0 to NUM_ROUNDS) of STD_LOGIC_VECTOR(7 downto 0);
    type subkey_array is array (1 to NUM_ROUNDS) of STD_LOGIC_VECTOR(7 downto 0);

    signal left_round : left_array;
    signal right_round : right_array;
    signal subkeys : subkey_array;

    function F(right : STD_LOGIC_VECTOR(7 downto 0); key : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : unsigned(7 downto 0);
        variable rotated : unsigned(7 downto 0);
    begin
        temp := unsigned(right) xor unsigned(key);
        temp := temp + 5;
        rotated := temp(6 downto 0) & temp(7);
        return std_logic_vector(rotated);
    end function;

    function GenerateSubkeys(input_key : STD_LOGIC_VECTOR(15 downto 0)) return subkey_array is
        variable keys     : subkey_array;
        variable temp_key : STD_LOGIC_VECTOR(15 downto 0) := input_key;
    begin
        for i in 1 to NUM_ROUNDS loop
            temp_key := temp_key(11 downto 0) & temp_key(15 downto 12);
            keys(i) := temp_key(15 downto 8) xor std_logic_vector(to_unsigned(i, 8));
        end loop;
        return keys;
    end function;

begin
    subkeys <= GenerateSubkeys(key);

    process(clk)
        variable i : integer;
        variable temp_L, temp_R : STD_LOGIC_VECTOR(7 downto 0);
    begin
        if rising_edge(clk) then
            left_round(0) <= plaintext(15 downto 8);
            right_round(0) <= plaintext(7 downto 0);
            for i in 1 to NUM_ROUNDS loop
                temp_L := right_round(i-1);
                temp_R := left_round(i-1) xor F(right_round(i-1), subkeys(i));
                left_round(i) <= temp_L;
                right_round(i) <= temp_R;
            end loop;
        end if;
    end process;

    ciphertext <= right_round(NUM_ROUNDS) & left_round(NUM_ROUNDS);

end Behavioral;
