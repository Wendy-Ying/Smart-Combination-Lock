library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decrypt is
    Port (
        clk : in STD_LOGIC;
        ciphertext : in STD_LOGIC_VECTOR(15 downto 0);
        key : in STD_LOGIC_VECTOR(15 downto 0);
        plaintext : out STD_LOGIC_VECTOR(15 downto 0)
    );
end decrypt;

architecture Behavioral of decrypt is
    constant NUM_ROUNDS : integer := 4;

    type round_array is array (0 to NUM_ROUNDS) of STD_LOGIC_VECTOR(7 downto 0);
    type subkey_array is array (1 to NUM_ROUNDS) of STD_LOGIC_VECTOR(7 downto 0);

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
        variable left_var  : round_array;
        variable right_var : round_array;
        variable i        : integer;
    begin
        if rising_edge(clk) then
            right_var(NUM_ROUNDS) := ciphertext(15 downto 8);
            left_var(NUM_ROUNDS)  := ciphertext(7 downto 0);

            for i in NUM_ROUNDS downto 1 loop
                right_var(i-1) := left_var(i);
                left_var(i-1)  := right_var(i) xor F(left_var(i), subkeys(i));
            end loop;

            plaintext <= left_var(0) & right_var(0);
        end if;
    end process;

end Behavioral;
