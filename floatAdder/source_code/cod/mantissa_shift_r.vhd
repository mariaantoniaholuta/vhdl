----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2022 05:00:57 PM
-- Design Name: 
-- Module Name: mantissa_shift_r - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RightShifter_1bit is					
	port (
		x	:	in 	std_logic_vector(24 downto 0);	
		y	:	out	std_logic_vector(24 downto 0)	
	);
end RightShifter_1bit;

architecture Behavioral of RightShifter_1bit is
	
begin

y <= '0' & x(24 downto 1);

end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RightShifter_1 is
	generic (
		n 	: 	integer		
	);					
	port (
		x	:	in 	std_logic_vector(24 downto 0);	
		y	:	out	std_logic_vector(24 downto 0)	
	);
end RightShifter_1;

architecture Behavioral of RightShifter_1 is

	signal x_c : std_logic_vector(24 downto 0);	
	
begin

process(x)
 begin
   --x_c <= x;
   x_c(24-n downto 0) <= x(24 downto n);
   x_c(24 downto 25-n) <= (others => '0');

end process;

y <= x_c;

end Behavioral;


library ieee;
use ieee.std_logic_1164.all;

entity RightShifter is
	generic (
		n 	: 	integer;
		s 	:	integer			
	);					
	port (
		x	:	in 	std_logic_vector(n-1 downto 0);	
		y	:	out	std_logic_vector(n-1 downto 0)	
	);
end RightShifter;

architecture Behavioral of RightShifter is

	constant zero : std_logic_vector(n-1 downto 0) := (others => '0');
	
begin

	process(x)
	begin
		if (s = 0) then
			y <= x;
		elsif (s >= n) then
			y <= zero;
		else
			y <= zero(s-1 downto 0) & x(n-1 downto s);
		end if;
	end process;
	
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mantissa_shift_r is
  Port ( x		:	in 	std_logic_vector(27 downto 0);	-- Original mantissa
		pos	:	in 	std_logic_vector(7 downto 0);		-- Shift amount
		y		:	out	std_logic_vector(27 downto 0)		-- Shifted mantissa 
		);
end mantissa_shift_r;

architecture Behavioral of mantissa_shift_r is

component RightShifter
		generic (
			n : integer;
			s : integer
		);
		port (
			x 	: in  	std_logic_vector(n-1 downto 0);
			y	: out 	std_logic_vector(n-1 downto 0)
		);
	end component;

	type vector28 is array (natural range <>) of std_logic_vector(27 downto 0);
	signal shiftsVector : vector28(28 downto 0);
	
begin

	gen_shift:
	for i in 0 to 28 generate
		shifter: RightShifter
			generic map (
				n => 28,
				s => i
			)
			port map (
				x => x(27 downto 0),
				y => shiftsVector(i)
			);
	end generate gen_shift;
	
	y <=	shiftsVector(0)	when pos = "00000000" else
			shiftsVector(1)	when pos = "00000001" else
			shiftsVector(2)	when pos = "00000010" else
			shiftsVector(3)	when pos = "00000011" else
			shiftsVector(4)	when pos = "00000100" else
			shiftsVector(5)	when pos = "00000101" else
			shiftsVector(6)	when pos = "00000110" else
			shiftsVector(7)	when pos = "00000111" else
			shiftsVector(8)	when pos = "00001000" else
			shiftsVector(9) 	when pos = "00001001" else
			shiftsVector(10)	when pos = "00001010" else
			shiftsVector(11)	when pos = "00001011" else
			shiftsVector(12)	when pos = "00001100" else
			shiftsVector(13)	when pos = "00001101" else
			shiftsVector(14)	when pos = "00001110" else
			shiftsVector(15)	when pos = "00001111" else
			shiftsVector(16)	when pos = "00010000" else
			shiftsVector(17)	when pos = "00010001" else
			shiftsVector(18)	when pos = "00010010" else
			shiftsVector(19)	when pos = "00010011" else
			shiftsVector(20)	when pos = "00010100" else
			shiftsVector(21)	when pos = "00010101" else
			shiftsVector(22)	when pos = "00010110" else
			shiftsVector(23)	when pos = "00010111" else
			shiftsVector(24)	when pos = "00011000" else
			shiftsVector(25)	when pos = "00011001" else
			shiftsVector(26)	when pos = "00011010" else
			shiftsVector(27)	when pos = "00011011" else
			shiftsVector(28);



end Behavioral;
