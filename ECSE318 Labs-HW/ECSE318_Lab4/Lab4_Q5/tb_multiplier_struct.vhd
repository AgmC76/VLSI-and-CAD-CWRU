library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiplier is
end entity;

architecture test of tb_multiplier is
    constant N : integer := 4;
    signal clk, reset, start, done : std_logic;
    signal multiplicand, multiplier : std_logic_vector(N-1 downto 0);
    signal product : std_logic_vector(2*N-1 downto 0);
    
begin
    UUT: entity work.structural_multiplier
        generic map (N => N)
        port map (clk, reset, start, multiplicand, multiplier, product, done);
    
    -- Clock generation
    process begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;
    
    -- Test process
    process
    begin
        reset <= '1';
        start <= '0';
        wait for 20 ns;
        
        reset <= '0';
        wait for 30 ns;
        
        -- Test case 1: 2 × 6 = 12
        report "Testing 2 × 6 = 12";
        multiplicand <= "0010";  -- 2
        multiplier <= "0110";    -- 6
        start <= '1';
        wait for 10 ns;
        start <= '0';
        
        wait until done = '1';
        wait for 10 ns;
        assert product = "00001100" 
            report "2*6 failed: got " & integer'image(to_integer(unsigned(product))) 
            severity error;
        
        wait for 50 ns;

	-- just testing if reseting again solves my issue --> it did not
	reset <= '1';
	start <= '0';
	wait for 20 ns;

	reset <= '0';
	wait for 30 ns;
        
        -- Test case 2: 12 × 3 = 36  , my error occurs here, I dont get a fault for 2 x 6
        report "Testing 12 × 3 = 36";
        multiplicand <= "1100";  -- 12
        multiplier <= "0011";    -- 3
        start <= '1';
        wait for 10 ns;
        start <= '0';
        
        wait until done = '1';
        wait for 10 ns;
        assert product = "00100100" 
            report "12*3 failed: got " & integer'image(to_integer(unsigned(product)))
            severity error;
        
        report "All tests completed";
        wait; -- cant change this to a discrete time, or when I run all it keeps looping

    end process;

end architecture;
