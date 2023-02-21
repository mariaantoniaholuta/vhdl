----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2022 04:08:33 PM
-- Design Name: 
-- Module Name: adder_4bit - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder_4bit is
  Port (  a,b  : in STD_LOGIC_VECTOR(3 downto 0); 
          carry_in : in std_logic;
          sum  : out STD_LOGIC_VECTOR(3 downto 0);
          carry : out std_logic );
end adder_4bit;

architecture Behavioral of adder_4bit is

begin

process(a,b)
variable sum_temp : unsigned(4 downto 0);
begin
    sum_temp := ('0' & unsigned(a)) + ('0' & unsigned(b)) + ("0000" & carry_in); 
    if(sum_temp > 9) then
        carry <= '1';
        sum <= std_logic_vector(resize((sum_temp + "00110"),4));
    else
        carry <= '0';
        sum <= std_logic_vector(sum_temp(3 downto 0));
    end if; 
end process; 


end Behavioral;
