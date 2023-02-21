----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/23/2022 10:53:49 PM
-- Design Name: 
-- Module Name: generic_adder_v1 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generic_adder_v1 is
  generic (N: INTEGER:= 25);
  Port ( addsub : in std_logic;
         a, b : in std_logic_vector (N-1 downto 0);
         sum : out std_logic_vector (N-1 downto 0);
         overflow : out std_logic;
         cout : out std_logic);
end generic_adder_v1;

architecture Behavioral of generic_adder_v1 is

component full_adder_1bit is
  Port (a,b,cin: in std_logic; 
        sm,cout: out std_logic );
end component;

signal c: std_logic_vector (N downto 0);
signal bx: std_logic_vector (N-1 downto 0);

begin

  c(0) <= addsub; 
  cout <= c(N);
  overflow <= c(N) xor c(N-1);
  
gi: for i in 0 to N-1 generate
   bx(i) <= b(i) xor addsub;
fi: full_adder_1bit port map (a(i), bx(i), 
c(i), sum(i), c(i+1));

end generate;


end Behavioral;
