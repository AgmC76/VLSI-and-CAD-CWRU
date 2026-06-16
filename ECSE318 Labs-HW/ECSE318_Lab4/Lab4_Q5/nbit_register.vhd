library ieee;
use ieee.std_logic_1164.all;

-- have to create the registers manually unlike verilog I think :/
entity nbit_register is
    generic (N : integer := 4);
    port (
        clk, reset, load : in  std_logic;
        d : in  std_logic_vector(N-1 downto 0);
        q : out std_logic_vector(N-1 downto 0)
    );
end entity nbit_register;

architecture structural of nbit_register is
    component dff is
        port (clk, reset, d : in std_logic; q : out std_logic);
    end component;
begin
    GEN_REG: for i in 0 to N-1 generate
        DFF_INST: dff port map (
            clk => clk,
            reset => reset,
            d => d(i),
            q => q(i)
        );
    end generate;
end architecture structural;
