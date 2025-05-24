library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_FeistelEncDec is
end tb_FeistelEncDec;

architecture Behavioral of tb_FeistelEncDec is
    signal clk        : std_logic := '0';

    signal plaintext  : std_logic_vector(15 downto 0);
    signal key        : std_logic_vector(15 downto 0);

    signal ciphertext : std_logic_vector(15 downto 0);

    signal decrypted  : std_logic_vector(15 downto 0);

    constant clk_period : time := 10 ns;

    type test_vector_type is record
        plaintext : std_logic_vector(15 downto 0);
        key       : std_logic_vector(15 downto 0);
    end record;

    type test_array_type is array (natural range <>) of test_vector_type;

    constant test_vectors : test_array_type := (
        (plaintext => x"1234", key => x"ABCD"),
        (plaintext => x"5678", key => x"1111"),
        (plaintext => x"9ABC", key => x"FFFF")
    );

begin
    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    uut_encrypt : entity work.FeistelEncrypt
        port map (
            clk        => clk,
            plaintext  => plaintext,
            key        => key,
            ciphertext => ciphertext
        );

    uut_decrypt : entity work.FeistelDecrypt
        port map (
            clk        => clk,
            ciphertext => ciphertext,
            key        => key,
            plaintext  => decrypted
        );

    test_process : process
    begin
        for i in test_vectors'range loop
            plaintext <= test_vectors(i).plaintext;
            key <= test_vectors(i).key;

            wait for clk_period * 3;

            wait for clk_period * 3;

            if decrypted = test_vectors(i).plaintext then
                report "  Result     : PASS" severity note;
            else
                report "  Result     : FAIL" severity error;
            end if;

            wait for clk_period * 2;
        end loop;

        report "All tests finished.";
        wait;
    end process;

end Behavioral;