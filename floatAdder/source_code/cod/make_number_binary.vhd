----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2022 04:26:47 PM
-- Design Name: 
-- Module Name: make_number_binary - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity make_number_binary is
  Port ( clk : in STD_LOGIC;
         hex_bcd: in STD_LOGIC_VECTOR(15 downto 0);
         sign : in STD_LOGIC;
         load : in STD_LOGIC;
         bin : out STD_LOGIC_VECTOR(31 downto 0);
         done : out STD_LOGIC
        );
end make_number_binary;

architecture Behavioral of make_number_binary is

component fractional_to_bin is
  Port ( clk : in STD_LOGIC;
         hex : in STD_LOGIC_VECTOR(15 downto 0);
	     load : in STD_LOGIC;
	     binary : out STD_LOGIC_VECTOR(45 downto 0);
	     done : out STD_LOGIC);
end component;

component int_to_bin is
  Port ( clk : in STD_LOGIC;
         hex : in STD_LOGIC_VECTOR(15 downto 0);
	     load : in STD_LOGIC;
	     binary : out STD_LOGIC_VECTOR(13 downto 0);
	     done : out STD_LOGIC);
end component;

    type hex_bcd_digit_type is array(3 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
    signal hex_bcd_digit : hex_bcd_digit_type;

	signal integer_number_bin : STD_LOGIC_VECTOR(13 downto 0);
	signal integer_number_bin_copy : STD_LOGIC_VECTOR(13 downto 0);
	signal fract_number_bin : STD_LOGIC_VECTOR(45 downto 0); 
	signal fract_number_bin_copy : STD_LOGIC_VECTOR(45 downto 0);
	signal combined_bin : STD_LOGIC_VECTOR(59 downto 0);											  
	signal hex_bcdinteger, hex_bcdfractional : STD_LOGIC_VECTOR(15 downto 0);
    signal load_integer, load_fractional, done_integer, done_fractional : STD_LOGIC; 	
	signal done_signal : STD_LOGIC;
	signal firstOne_found, firstOne_int : STD_LOGIC;
	
	signal posInInt : STD_LOGIC_VECTOR(3 downto 0);
	signal posInFractional : STD_LOGIC_VECTOR(5 downto 0);
	signal shift_for_int : STD_LOGIC_VECTOR(3 downto 0);
	signal shift_for_fract : STD_LOGIC_VECTOR(5 downto 0);
	
	signal approximate : STD_LOGIC;
	signal iterator : STD_LOGIC_VECTOR(5 downto 0);
	signal copied, combined : STD_LOGIC;
	
	signal sign_copy : STD_LOGIC;
    signal exponent : STD_LOGIC_VECTOR(7 downto 0);
    signal mantissa : STD_LOGIC_VECTOR(22 downto 0);  
    

begin

   hex_bcd_digit(3) <= hex_bcd(15 downto 12);
   hex_bcd_digit(2) <= hex_bcd(11 downto 8);
   hex_bcd_digit(1) <= hex_bcd(7 downto 4);
   hex_bcd_digit(0) <= hex_bcd(3 downto 0);
   
int_b: int_to_bin port map(clk, hex_bcdinteger, load, integer_number_bin, done_integer);
frac_b: fractional_to_bin port map(clk, hex_bcdfractional, load, fract_number_bin, done_fractional);

   shift_for_fract <= 46 - posInFractional; 
   shift_for_int <= 14 - posInInt; 

   
   process(clk)
       begin
           if(rising_edge(clk)) then
               if(load = '1') then
                                  hex_bcdinteger <= x"00" & hex_bcd_digit(3) & hex_bcd_digit(2);
                                  hex_bcdfractional <= hex_bcd_digit(1) & hex_bcd_digit(0) & x"00";
                                  
                                  done_signal <= '0';
                                  firstOne_found <= '0';
                                  posInInt <= "1101";
                                  posInFractional <= "101101"; 
                                  approximate <= '0';
                                  iterator <= (others => '0');
                                  copied <= '0';
                                  combined <= '0';
                   elsif(done_signal = '0') then  
                                  if((done_integer and done_fractional) = '1') then
                                      if(copied = '0') then
                                          integer_number_bin_copy <= integer_number_bin;
                                          fract_number_bin_copy <= fract_number_bin;
                                          copied <= '1';
                                      elsif(combined = '0') then
                                          combined_bin <= integer_number_bin_copy & fract_number_bin_copy;
                                          combined <= '1';
                                      else
                                          if((integer_number_bin = x"0000") and (fract_number_bin = x"0000")) then
                                              sign_copy <= '0';
                                              mantissa <= (others => '0');
                                              exponent <= (others => '0');
                                              done_signal <= '1';
                                           elsif(firstOne_int = '1') then 
                                              exponent <= "01111111" + ("0000" & posInInt);
                                              if(posInInt = "0000") then
                                               mantissa <= fract_number_bin(45 downto 23);
                                               done_signal <= '1';
                                               else
                                                 if(iterator = shift_for_int) then
                                                    mantissa <= combined_bin(59 downto 37);
                                                    done_signal <= '1';
                                                 else
                                                    combined_bin <= combined_bin(58 downto 0) & '0';
                                                    iterator <= iterator + 1;
                                                 end if;
                                                                                              
                                               end if;
                                               for i in 22 downto 0 loop
                                               if (fract_number_bin(i) = '1') then
                                                      approximate <= '1';
                                               end if;
                                               end loop;                                         
                                          elsif(firstOne_found = '0') then
                                              sign_copy <= sign;
                                              if(integer_number_bin <= 0) then
                                                 if(fract_number_bin(conv_integer(posInFractional)) = '1') then
                                                      firstOne_found <= '1';
                                                      firstOne_int <= '0';
                                                 else
                                                       posInFractional <= posInFractional - 1;
                                                 end if;
                                              
                                              else
                                                  if(integer_number_bin(conv_integer(posInInt)) = '1') then
                                                      firstOne_found <= '1';
                                                      firstOne_int <= '1';
                                                  else
                                                      posInInt <= posInInt - 1;
                                                 end if;
                                                  
                                              end if;
                                         
                                          else
                                              exponent <= "01111111" - ("00" & (46-posInFractional)); 
                                              if(posInFractional = "10110") then 
                                                  mantissa <= fract_number_bin(45 downto 23);
                                                  done_signal <= '1';
                                              else
                                                  if(iterator = shift_for_fract) then
                                                      mantissa <= fract_number_bin_copy(45 downto 23);
                                                      done_signal <= '1';
                                                  else
                                                      fract_number_bin_copy <= fract_number_bin_copy(44 downto 0) & '0';
                                                      iterator <= iterator + 1;
                                                  end if;
                                                 
                                              end if;
                                              for i in 22 downto 0 loop 
                                                  if (fract_number_bin(i) = '1') then
                                                      approximate <= '1';
                                                  end if;
                                              end loop;
                                          end if;
                                      
                                      end if;
                                  
                            end if;           
                   
               
               elsif(approximate = '1') then
                   mantissa <= mantissa + 1;
                   approximate <= '0';
               end if;
           end if;
       end process;
       
       bin <= sign_copy & exponent & mantissa;
       done <= done_signal and (not approximate);

end Behavioral;
