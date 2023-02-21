----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2022 12:27:46 PM
-- Design Name: 
-- Module Name: Instruction_Fetch - Behavioral
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

entity Instruction_Fetch is
Port (     clk_in : in STD_LOGIC;
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           PC_1 : out STD_LOGIC_VECTOR(15 downto 0);
           btn : in STD_LOGIC;
           reset : in STD_LOGIC;
           Branch_Address : in STD_LOGIC_VECTOR(15 downto 0);
           Jump_Address : in STD_LOGIC_VECTOR(15 downto 0);
           Instruction : out STD_LOGIC_VECTOR(15 downto 0));
end Instruction_Fetch;

architecture Behavioral of Instruction_Fetch is

signal PC: std_logic_vector(15 downto 0);
signal PC1: std_logic_vector(15 downto 0);
signal temp: std_logic_vector(15 downto 0);
signal temp1: std_logic_vector(15 downto 0);

type memory is array (0 to 255) of std_logic_vector(15 downto 0);

  signal ROM: memory := (
  
  B"000_011_010_001_0_001", --sub 1 3 2 initializeaza r1 cu 1  #0D11  
  B"000_001_001_010_0_000", --add 2 1 1 initializeaza r2 cu 2  #04A0 
  B"000_000_001_011_1_010", --sll 3 1 1 deplaseaza r3 la stanga cu 1 #00BA
  B"000_001_000_100_0_100", --and 4 1 0 r4 cu 0 #0444
  B"000_000_001_101_0_011", --srl 5 1 0 deplaseaza r5 la dreapta cu 1 #00D3
  B"000_010_101_110_0_101", --or 6 4 5 r6 cu r4|r5 #0AE5
  B"000_010_101_110_0_110", --xor 6 4 5 #0AE6
  B"000_010_011_110_0_111", --sra 4 2 3 #09E7
  B"011_110_011_0000001", --sw 3 6 stocheaza la adr 6+r1 valoarea 3 #7981
  B"011_111_100_0000100", --sw 4 7 #7E04
  B"001_001_111_0000100", --addi 7 1 4 r7 primeste r1+imm #2784
  B"100_001_010_0000111", --beq 1 2 7 #8507 salt peste instructiuni la egalitate
  B"010_000_000_0000001", --lw 0 0 #4001
  B"010_111_100_0000100", --lw 4 7 incarca in r4 de la adr 4+r7 #5E08
  B"011_010_001_0000011", --sw 2 1 #6883
  B"111_0000000001010", --j 10 salt la instructiunea 10 #E00A
  
  others => x"0000"
  
  );

begin

process(clk_in,reset)
begin
   if reset='1' then
     PC <= (others=>'0');
   else 
     if rising_edge(clk_in) then
        if btn='1' then
            PC <= temp;
        end if;
     end if;
   end if;
end process;

process(PCSrc, Branch_Address, PC1)
begin
 case PCSrc is
 when '0' => temp <= PC1;
 when '1' => temp <= Branch_Address;
 end case;
end process;

process(Jump, Jump_Address, temp)
begin
 case Jump is
   when '0' => temp1 <= temp;
   when '1' => temp1 <= Jump_Address;
 end case;
end process;

PC1 <= PC + 1;
Instruction <= ROM(conv_integer(PC));
PC_1 <= PC1;

end Behavioral;
