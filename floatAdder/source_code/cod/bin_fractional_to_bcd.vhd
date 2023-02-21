----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2022 08:34:40 PM
-- Design Name: 
-- Module Name: bin_fractional_to_bcd - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_15_bits is
port(  clk : in STD_LOGIC;
       a : in STD_LOGIC_VECTOR(15 downto 0);
       b : in STD_LOGIC_VECTOR(15 downto 0);
	   result : out STD_LOGIC_VECTOR(15 downto 0);	   
	   int : out STD_LOGIC
	);
end adder_15_bits;

architecture Behavioral of adder_15_bits is

component adder_4bit is
  Port (  a,b  : in STD_LOGIC_VECTOR(3 downto 0); 
          carry_in : in std_logic;
          sum  : out STD_LOGIC_VECTOR(3 downto 0);
          carry : out std_logic );
end component;

signal carry1, carry2, carry3 : STD_LOGIC;

begin

add1: adder_4bit port map(a(3 downto 0), b(3 downto 0), '0', result(3 downto 0), carry1);
add2: adder_4bit port map(a(7 downto 4), b(7 downto 4), carry1, result(7 downto 4), carry2);
add3: adder_4bit port map(a(11 downto 8), b(11 downto 8), carry2, result(11 downto 8), carry3);
add4: adder_4bit port map(a(15 downto 12), b(15 downto 12), carry3, result(15 downto 12), int);

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bin_fractional_to_bcd is
  Port ( clk : in STD_LOGIC;
         bin_iee : in STD_LOGIC_VECTOR(31 downto 0);
         sign : out STD_LOGIC;
	     BCD : out STD_LOGIC_VECTOR(15 downto 0);
	     load : in STD_LOGIC;													  										   							  				   
	     done : out STD_LOGIC );
end bin_fractional_to_bcd;

architecture Behavioral of bin_fractional_to_bcd is

component IEEEtoBinary is
	port( clk : in STD_LOGIC;
		bin_iee : in STD_LOGIC_VECTOR(31 downto 0);
		load : in STD_LOGIC;
		
		binary_integer : out STD_LOGIC_VECTOR(13 downto 0);	
		binary_fractional : out STD_LOGIC_VECTOR(45 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component IntegerBinaryToBCD is
	port(
	    clk : in STD_LOGIC;
		binary_integer : in STD_LOGIC_VECTOR(13 downto 0);
		load : in STD_LOGIC;
		
		BCDinteger : out STD_LOGIC_VECTOR(15 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component FractionalBinaryToBCD is
	port(
	    clk : in STD_LOGIC;
		binary_fractional_46bits : in STD_LOGIC_VECTOR(45 downto 0);
		load : in STD_LOGIC;
		
		BCDfractional : out STD_LOGIC_VECTOR(15 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
		
    signal point_location_copy : STD_LOGIC_VECTOR(2 downto 0);
	signal binary_integer : STD_LOGIC_VECTOR(13 downto 0);	
	signal binary_fractional : STD_LOGIC_VECTOR(45 downto 0);
	signal binary_conversion_done, en, bcd_int_done, bcd_frac_done : STD_LOGIC;
	signal bcdcopy, BCDinteger, BCDfractional : STD_LOGIC_VECTOR(15 downto 0);

begin 

	en <= not binary_conversion_done;

IEEEtoBin: IEEEtoBinary port map(clk, bin_iee, load, binary_integer, binary_fractional, binary_conversion_done);
BinaryIntToBCD: IntegerBinaryToBCD port map(clk, binary_integer, en, BCDinteger, bcd_int_done);
BinaryFracToBCD: FractionalBinaryToBCD port map(clk, binary_fractional, en, BCDfractional, bcd_frac_done);
	
	process(bcd_int_done, bcd_frac_done)
	begin		
		if (bcd_int_done = '1' and bcd_frac_done = '1') then
			if(BCDinteger(15 downto 12) = x"0") then
				if(BCDinteger(11 downto 8) = x"0") then
					if(BCDinteger(7 downto 4) = x"0") then
						if(BCDinteger(3 downto 0) = x"0") then
							bcdcopy <= BCDfractional;
							point_location_copy <= "100";
						else
							bcdcopy(15 downto 12) <= BCDinteger(3 downto 0);
							bcdcopy(11 downto 0) <= BCDfractional(15 downto 4);
							point_location_copy <= "011";
						end if;
					else
						bcdcopy(15 downto 8) <= BCDinteger(7 downto 0);
						bcdcopy(7 downto 0) <= BCDfractional(15 downto 8);
						point_location_copy <= "010";
					end if;
				else   
					bcdcopy(15 downto 4) <= BCDinteger(11 downto 0);
					bcdcopy(3 downto 0) <= BCDfractional(15 downto 12);
					point_location_copy <= "001";
				end if;
			else
				bcdcopy <= BCDinteger;
				point_location_copy <= "000";
			end if;
		end if;
	end process;
	
	BCD <= bcdcopy;
	done <= bcd_int_done and bcd_frac_done;
	

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IEEEtoBinary is
port(clk : in STD_LOGIC;
	bin_iee : in STD_LOGIC_VECTOR(31 downto 0);
	load : in STD_LOGIC;
	binary_integer : out STD_LOGIC_VECTOR(13 downto 0);	
	binary_fractional : out STD_LOGIC_VECTOR(45 downto 0);
	done : out STD_LOGIC
	);
end IEEEtoBinary;

architecture Behavioral of IEEEtoBinary is

    signal shift_amount : STD_LOGIC_VECTOR(7 downto 0); 
	signal exponent : STD_LOGIC_VECTOR(7 downto 0);
	signal mantissa : STD_LOGIC_VECTOR(22 downto 0);	  														 
	signal bin_integer_copy : STD_LOGIC_VECTOR(13 downto 0);	
	signal bin_fract_copy : STD_LOGIC_VECTOR(45 downto 0);
	signal state : STD_LOGIC_VECTOR(7 downto 0);
	signal sign_of_exp, done_signal : STD_LOGIC;

begin

	exponent <= bin_iee(30 downto 23);
	mantissa <= bin_iee(22 downto 0);
	
	process(exponent)
	begin		
		if(exponent < 127) then
		            shift_amount <= 127 - exponent;
                    sign_of_exp <= '1';
			
		else
			       shift_amount <= exponent - 127;
                   sign_of_exp <= '0';
		end if;
	end process;
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
			    state <= shift_amount; 
                done_signal <= '0';
				bin_integer_copy(13 downto 1) <= (others => '0');
				bin_integer_copy(0) <= '1';  
				bin_fract_copy(45 downto 23) <= mantissa;
				bin_fract_copy(22 downto 0) <= (others => '0');
				
			elsif(state > x"00") then
				state <= state - 1;
				if(sign_of_exp = '0') then
					bin_integer_copy <= bin_integer_copy(12 downto 0) & bin_fract_copy(45);
					bin_fract_copy <= bin_fract_copy(44 downto 0) & '0';
				else
					bin_integer_copy <= (others => '0');
					bin_fract_copy <= '0' & bin_fract_copy(45 downto 1);
				end if;
			else
				done_signal <= '1';
			end if;
		end if;
	end process;
	
	binary_integer <= bin_integer_copy;
	binary_fractional <= bin_fract_copy;
	done <= done_signal;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IntegerBinaryToBCD is
port(clk : in STD_LOGIC;
	binary_integer : in STD_LOGIC_VECTOR(13 downto 0);
	load : in STD_LOGIC;
	BCDinteger : out STD_LOGIC_VECTOR(15 downto 0);
	done : out STD_LOGIC
	);
end IntegerBinaryToBCD;	

architecture Behavioral of IntegerBinaryToBCD is

component adder_15_bits is
port(  clk : in STD_LOGIC;
       a : in STD_LOGIC_VECTOR(15 downto 0);
       b : in STD_LOGIC_VECTOR(15 downto 0);
	   result : out STD_LOGIC_VECTOR(15 downto 0);	   
	   int : out STD_LOGIC
	);
end component;
	

	
	signal state : STD_LOGIC_VECTOR(3 downto 0);
	signal nr_for_adder, result, new_result, adder_res : STD_LOGIC_VECTOR(15 downto 0);
	signal done_0, done_signal : STD_LOGIC;	 

begin

add: adder_15_bits port map(clk, result, nr_for_adder, adder_res);


	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				done_signal <= '0';
				done_0 <= '0';
				result <= (others => '0');
				nr_for_adder <= x"0000";
				new_result <= (others => '0');
				state <= "1101";
			else
				if(done_0 = '0') then
					result <= new_result;
					case state is
						when x"D" =>
							if(binary_integer(13) = '1') then
								nr_for_adder <= x"8192";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"C" => 
							if(binary_integer(12) = '1') then
								nr_for_adder <= x"4096";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"B" => 
							if(binary_integer(11) = '1') then
								nr_for_adder <= x"2048";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"A" => 
							if(binary_integer(10) = '1') then
								nr_for_adder <= x"1024";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"9" =>
							if(binary_integer(9) = '1') then
								nr_for_adder <= x"0512";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"8" =>
							if(binary_integer(8) = '1') then
								nr_for_adder <= x"0256";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"7" =>
							if(binary_integer(7) = '1') then
								nr_for_adder <= x"0128";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"6" =>
							if(binary_integer(6) = '1') then
								nr_for_adder <= x"0064";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"5" =>
							if(binary_integer(5) = '1') then
								nr_for_adder <= x"0032";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"4" =>
							if(binary_integer(4) = '1') then
								nr_for_adder <= x"0016";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"3" =>
							if(binary_integer(3) = '1') then
								nr_for_adder <= x"0008";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"2" =>
							if(binary_integer(2) = '1') then
								nr_for_adder <= x"0004";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"1" =>
							if(binary_integer(1) = '1') then
								nr_for_adder <= x"0002";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when others => --0
							if(binary_integer(0) = '1') then
								nr_for_adder <= x"0001";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
					end case;
					
					if(state = x"0") then
						done_0 <= '1';
					else
						state <= state - 1;
					end if;
				elsif(done_signal = '0') then
					result <= adder_res;
					done_signal <= '1';
				end if;
			end if;
		end if;
	end process;
	
	BCDinteger <= result; 
	done <= done_signal;

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FractionalBinaryToBCD is
port(
	binary_fractional_46bits : in STD_LOGIC_VECTOR(45 downto 0);
	clk, load : in STD_LOGIC;
	
	BCDfractional : out STD_LOGIC_VECTOR(15 downto 0);
	done : out STD_LOGIC
	);
end FractionalBinaryToBCD;

architecture Behavioral of FractionalBinaryToBCD is


	
	component adder_15_bits is
    port(  clk : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR(15 downto 0);
           b : in STD_LOGIC_VECTOR(15 downto 0);
           result : out STD_LOGIC_VECTOR(15 downto 0);       
           int : out STD_LOGIC
        );
    end component;
	
	signal state : STD_LOGIC_VECTOR(3 downto 0);
	signal nr_for_adder, result, new_result, adder_res : STD_LOGIC_VECTOR(15 downto 0);
	signal done_0, done_copy : STD_LOGIC;
	signal binary_fractional : STD_LOGIC_VECTOR(13 downto 0);


begin
	
	
add1: adder_15_bits port map(clk, result, nr_for_adder, adder_res);

    binary_fractional <= binary_fractional_46bits(45 downto 32);
    
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				done_copy <= '0';
				done_0 <= '0';
				result <= (others => '0');
				nr_for_adder <= x"0000";
				new_result <= (others => '0');
				state <= "1101";
			else
				if(done_0 = '0') then
					result <= new_result;
					case state is
						when x"D" =>
							if(binary_fractional(13) = '1') then
								nr_for_adder <= x"5000";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"C" =>
							if(binary_fractional(12) = '1') then
								nr_for_adder <= x"2500"; 
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"B" =>
							if(binary_fractional(11) = '1') then
								nr_for_adder <= x"1250"; 
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"A" => --10
							if(binary_fractional(10) = '1') then
								nr_for_adder <= x"0625";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"9" =>
							if(binary_fractional(9) = '1') then
								nr_for_adder <= x"0313";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"8" =>
							if(binary_fractional(8) = '1') then
								nr_for_adder <= x"0157";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"7" =>
							if(binary_fractional(7) = '1') then
								nr_for_adder <= x"0079";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"6" =>
							if(binary_fractional(6) = '1') then
								nr_for_adder <= x"0040";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"5" =>
							if(binary_fractional(5) = '1') then
								nr_for_adder <= x"0020";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"4" =>
							if(binary_fractional(4) = '1') then
								nr_for_adder <= x"0010";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"3" =>
							if(binary_fractional(3) = '1') then
								nr_for_adder <= x"0005";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"2" =>
							if(binary_fractional(2) = '1') then
								nr_for_adder <= x"0003";
 							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when x"1" =>
							if(binary_fractional(1) = '1') then
								nr_for_adder <= x"0002";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
						when others => 
							if(binary_fractional(0) = '1') then
								nr_for_adder <= x"0001";
							else
								nr_for_adder <= x"0000";
							end if;
							result <= adder_res;
					end case;
					
					if(state = x"0") then
						done_0 <= '1';
					else
						state <= state - 1;
					end if;
				elsif(done_copy = '0') then
					result <= adder_res;
					done_copy <= '1';
				end if;
			end if;
		end if;
	end process;
	
	BCDfractional <= result; 
	done <= done_copy;

end Behavioral;


