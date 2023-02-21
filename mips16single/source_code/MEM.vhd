----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2022 01:19:25 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is
Port ( MemWrite : in std_logic;
       clk : in std_logic;
       Address : in std_logic_vector(15 downto 0);
       WriteData : in std_logic_vector(15 downto 0);
       EN : in std_logic;
       ReadData : out std_logic_vector(15 downto 0) );
end MEM;

architecture Behavioral of MEM is
 type memory is array (0 to 7) of std_logic_vector(15 downto 0);
   signal RAM: memory := (
       x"0001",
       x"0002",
       x"0003",
       others => x"0000"
   );

begin
process (clk)
  begin
    if rising_edge(clk) then
      if MemWrite = '1'and EN='1' then
        RAM(conv_integer(Address)) <= WriteData;
        ReadData <= WriteData;
      else
        ReadData <= RAM(conv_integer(Address));
      end if;
    end if;
ReadData <= RAM(conv_integer(Address));
end process;

end Behavioral;
