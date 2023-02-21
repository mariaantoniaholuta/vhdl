----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2022 01:37:04 PM
-- Design Name: 
-- Module Name: counter_9 - Behavioral
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

entity counter_9 is
  Port ( rst, clk, sw : in std_logic;
           o : out std_logic_vector(3 downto 0));
end counter_9;

architecture Behavioral of counter_9 is

signal tmp : STD_LOGIC_VECTOR(3 downto 0);

begin


process(rst, clk)
      begin
      
        if(rst = '1') then
          tmp <= "0000";
        end if;
        if(rising_edge(clk)) then
          if(sw = '1') then
             if(tmp = "1001") then
                tmp <= "0000";     
             else
                tmp <= tmp + 1;
           end if;
          end if;
        end if;
        
end process;

o <= tmp;

end Behavioral;
