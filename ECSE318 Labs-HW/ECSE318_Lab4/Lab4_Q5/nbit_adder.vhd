library ieee;
use ieee.std_logic_1164.all;


entity nbit_adder is
    generic (N : integer := 4);
    port (
        a, b : in  std_logic_vector(N-1 downto 0);
        cin : in  std_logic;
        sum : out std_logic_vector(N-1 downto 0);
        cout : out std_logic
    );
end entity;

architecture structural of nbit_adder is
    component full_adder is
        port (a, b, cin : in std_logic; sum, cout : out std_logic);
    end component;
    
    signal carry_chain : std_logic_vector(N downto 0);
begin
    carry_chain(0) <= cin;
    
    GEN_ADDERS: for i in 0 to N-1 generate
        FA: full_adder port map (
            a => a(i),
            b => b(i),
            cin => carry_chain(i),
            sum => sum(i),
            cout => carry_chain(i+1)
        );
    end generate;
    
    cout <= carry_chain(N);
end architecture;
