----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2022 01:27:08 PM
-- Design Name: 
-- Module Name: hex_SSD - Behavioral
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

entity hex_SSD is
  Port (  clk: in STD_LOGIC;
	      clear: in STD_LOGIC;
	      nr:  in STD_LOGIC_VECTOR(15 downto 0);
	      point_location : in STD_LOGIC_VECTOR(2 downto 0);						  
	      cat: out STD_LOGIC_VECTOR(6 downto 0);
	      an: out STD_LOGIC_VECTOR(3 downto 0);
	      point : out STD_LOGIC
           );
end hex_SSD;

architecture Behavioral of hex_SSD is

signal clkdiv: STD_LOGIC_VECTOR(18 downto 0);
signal sel: STD_LOGIC_VECTOR(1 downto 0);
signal digit: STD_LOGIC_VECTOR(3 downto 0);


begin
   sel <= clkdiv(18 downto 17);
process(sel, clear)
	  begin
		an <= "1111";
		point <= '1';
		if clear = '0' then
			an(conv_integer(sel)) <= '0';
			if(conv_integer(3-sel) = point_location) then
				point <= '0';
			end if;
		end if;
end process;

process(clk, clear)
	begin
		if clear = '1' then
			clkdiv <= (others => '0');

		elsif clk'event and clk = '1' then
			clkdiv <= clkdiv + 1;
		end if;
	end process;

process(sel, nr)
	begin
		case sel is
			when "00" => digit <= nr(15 downto 12);
			when "01" => digit <= nr(11 downto 8);
			when "10" => digit <= nr(7 downto 4);
			when others => digit <= nr(3 downto 0);
		end case;
end process;
	
process(digit)
	begin
		case digit is
			when "0000"=> cat <= "1000000";  -- '0'
			when "0001"=> cat <= "1111001";  -- '1'
			when "0010"=> cat  <="0100100";  -- '2'
			when "0011"=> cat  <="0110000";  -- '3'
			when "0100"=> cat  <="0011001";  -- '4' 
			when "0101"=> cat  <="0010010";  -- '5'
			when "0110"=> cat  <="0000010";  -- '6'
			when "0111"=> cat  <="1111000";  -- '7'
			when "1000"=> cat  <="0000000";  -- '8'
			when "1001"=> cat  <="0010000";  -- '9'
			when others=> cat  <="1111111"; 
		end case;
end process;


end Behavioral;
