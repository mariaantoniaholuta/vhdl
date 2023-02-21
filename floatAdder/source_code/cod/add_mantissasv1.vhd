----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/23/2022 10:38:34 PM
-- Design Name: 
-- Module Name: add_mantissasv1 - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity add_mantissasv1 is
  Port ( A_mantissa : in std_logic_vector (24 downto 0);
         B_mantissa : in std_logic_vector (24 downto 0);
         sum : out std_logic_vector (24 downto 0));
end add_mantissasv1;

architecture Behavioral of add_mantissasv1 is

begin

       sum <= std_logic_vector((unsigned(A_mantissa) + unsigned(B_mantissa)));

end Behavioral;
