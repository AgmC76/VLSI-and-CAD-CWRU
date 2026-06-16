library ieee;
use ieee.std_logic_1164.all;

-- structural model of the multiplier 
entity structural_multiplier is
    	generic (N : integer := 4);
    	port (
        	clk, reset, start : in  std_logic;
        	multiplicand, multiplier : in  std_logic_vector(N-1 downto 0);
        	product : out std_logic_vector(2*N-1 downto 0);
        	done : out std_logic
    	);
end entity structural_multiplier;

-- defining the structure of the multiplier
-- register P, A, and B are n bits
-- Cout is a 1bit ff
-- Pinit and CoutInit are 0
-- shift registre between p, a, and carrout
-- every bit of b is anded with lowest bit of a to fom new set of n bits ~ multiplicand x either 1 or 0
-- new bits are added to P
-- carrout is loaded to ff
-- n clock cycles = n partial products
-- results stored in P,A register

architecture structural of structural_multiplier is
    	-- Component declarations
	-- register
    	component nbit_register is
        	generic (N : integer);
        	port (clk, reset, load : in std_logic; 
              		d : in std_logic_vector(N-1 downto 0); 
              		q : out std_logic_vector(N-1 downto 0));
    	end component;
    
	-- adder
    	component nbit_adder is
        	generic (N : integer);
        	port (a, b : in std_logic_vector(N-1 downto 0);
              		cin : in std_logic;
              		sum : out std_logic_vector(N-1 downto 0);
              		cout : out std_logic);
    	end component;
    
	-- and gate for A and B
    	component and_gate is
        	port (a, b : in std_logic; y : out std_logic);
    	end component;
    
	-- dff for the carry
    	component dff is
        	port (clk, reset, d : in std_logic; q : out std_logic);
    	end component;
    
    	-- Internal signals
    	signal A_reg, B_reg, P_reg : std_logic_vector(N-1 downto 0);
    	signal A_next, P_next, B_next : std_logic_vector(N-1 downto 0);
    	signal adder_out : std_logic_vector(N-1 downto 0);
    	signal adder_cout, carry_reg, carry_next : std_logic;
    	signal and_out : std_logic_vector(N-1 downto 0);
    	signal load_regs, shift_enable : std_logic;
    
    	signal counter : integer range 0 to N;
    	signal computing, done_signal : std_logic;
    
	begin
    	-- Control logic -> synchronous
    	process(clk, reset)
    	begin
        	if reset = '1' then
            		counter <= 0;
            		computing <= '0';
            		done_signal <= '0';
        	elsif rising_edge(clk) then
            		if start = '1' then
                		counter <= 0;
                		computing <= '1';
                		done_signal <= '0';
            		elsif computing = '1' then
                		if counter < N-1 then
                    			counter <= counter + 1;
                		else
                    			computing <= '0';
                    			done_signal <= '1';
                		end if;
            		end if;
        	end if;
    	end process;
    
    	done <= done_signal;
    	load_regs <= start;
    	shift_enable <= computing when counter < N else '0'; -- counter is just to keep track of the number of partical products, the final count should be N
    
    	-- AND gates between B and A(0)
    	GEN_AND: for i in 0 to N-1 generate
        	AND_INST: and_gate port map (
            		a => B_reg(i),
            		b => A_reg(0),
            		y => and_out(i)
        	);
    	end generate;
    
    	-- Adder: P + (B AND A(0))
    	ADDER_INST: nbit_adder generic map (N => N)
        	port map (
            		a => P_reg,
            		b => and_out,
            		cin => '0',
            		sum => adder_out,
            		cout => adder_cout
        	);
    
    	-- Register for carry
    	CARRY_FF: dff port map (
        	clk => clk,
        	reset => reset,
        	d => carry_next,
        	q => carry_reg
    	);
    
    	-- A register (shift right)
    	A_REG_INST: nbit_register generic map (N => N)
        	port map (
            		clk => clk,
            		reset => reset,
            		load => '1',  -- Always load from A_next
            		d => A_next,
            		q => A_reg
        	); 
    
    	-- B register (multiplicand - stays constant)
    	B_REG_INST: nbit_register generic map (N => N)
        	port map (
            		clk => clk,
            		reset => reset,
            		load => '1',  -- Always load from B_next
            		d => B_next,
            		q => B_reg
        	);
    
    	-- P register 
    	P_REG_INST: nbit_register generic map (N => N)
        	port map (
            		clk => clk,
            		reset => reset,
            		load => '1',  -- Always load from P_next
            		d => P_next,
            		q => P_reg
        	);
    

        -- logic for getting the next value
    	process(load_regs, shift_enable,
            	A_reg, B_reg, P_reg, carry_reg,
            	adder_out, adder_cout,
            	multiplicand, multiplier)

        -- temporary signals to hold adder result before shift
        variable P_tmp     : std_logic_vector(N-1 downto 0);
        variable carry_tmp : std_logic;
    
	begin
        	if load_regs = '1' then
            		-- loading logic
            		A_next      <= multiplier;          -- multiplier in A
            		B_next      <= multiplicand;        -- multiplicand in B
            		P_next      <= (others => '0');     -- clear partial product
            		carry_next  <= '0';
        
        	elsif shift_enable = '1' then
            		-- right shift logic

            		-- perform addition P + (B AND A(0))
            		P_tmp     := adder_out;
            		carry_tmp := adder_cout;

            		-- shift right the concatenation {carry_reg, P_tmp, A_reg}
			P_next     <= adder_cout & adder_out(N-1 downto 1);
            		A_next     <= adder_out(0) & A_reg(N-1 downto 1); -- using output directly from the adder instead
            		--P_next     <= adder_cout & adder_out(N-1 downto 1);
            		B_next     <= B_reg;                -- multiplicand stays constant, didn't really need to name it next...
            		carry_next <= '0';            -- testing with 0, if it doesnt work, change back to adder_cout

        	else
            		-- holding logic
            		A_next      <= A_reg;
            		B_next      <= B_reg;
            		P_next      <= P_reg;
            		carry_next  <= carry_reg;
        	end if;
    	end process;

    
    	-- Output assignment
    	product <= P_reg & A_reg; -- keep getting the 12 x 3 value slightly off?? 
    	-- product <= P_reg(N-1 downto 0) & A_reg(N-1 downto 0); -- same result as before 12 x 3 is off

end architecture structural;
