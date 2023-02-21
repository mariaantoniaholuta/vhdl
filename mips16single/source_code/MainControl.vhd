----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2022 01:00:14 PM
-- Design Name: 
-- Module Name: MainControl - Behavioral
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

entity MainControl is
Port (  Instr: in std_logic_vector(15 downto 0);
        RegDst: out std_logic;
        ExtOp: out std_logic;
        ALUsrc: out std_logic;
        Branch: out std_logic;
        Jump: out std_logic;
        ALUOp: out std_logic_vector(1 downto 0);
        MemWrite: out std_logic;
        MemtoReg: out std_logic;
        RegWrite: out std_logic );
end MainControl;

architecture Behavioral of MainControl is

begin
process(Instr(15 downto 13))
begin
  RegDst <= '0';
  ExtOp <= '0';
  ALUsrc <= '0';
  Branch <= '0';
  Jump <= '0';
  ALUOp <= "00";
  MemWrite <= '0';
  MemtoReg <= '0';
  RegWrite <= '0';
  
  case Instr(15 downto 13) is
     when "000" => 
          RegDst <= '1';
          RegWrite <= '1';
          ALUOp <= "00";
     when "001" =>
          RegDst <= '1';
          RegWrite <= '1';
          ALUOp <= "10";
          ALUsrc <= '1';
     when "010" =>
           RegDst <= '0';
           RegWrite <= '1';
           ALUOp <= "10";
           ALUsrc <= '1';
           ExtOp <= '1';
           MemtoReg <= '1';
     when "011" =>
           RegDst <= 'X';
           RegWrite <= '0';
           ALUOp <= "10";
           ALUsrc <= '1';
           MemWrite <= '1';
      when "100" =>
           RegDst <= 'X';
           RegWrite <= '0';
           ExtOp <= '1';
           ALUOp <= "01";
           ALUsrc <= '0';
           Branch <= '1';
           MemWrite <= '0';
           MemtoReg <= 'X';
       when "111" =>
            RegDst <= 'X';
            RegWrite <= '0';
            ExtOp <= 'X';
            ALUOp <= "XX";
            ALUsrc <= 'X';
            Branch <= 'X';
            Jump <= '1';
            MemWrite <= '0';
            MemtoReg <= 'X';
        when others =>
            RegDst <='0';
            RegWrite <='0';
            ExtOp <='0';
            ALUOp <= "00";
            ALUSrc <='0';
            Branch <='0';
            Jump <='0';
            MemWrite <='0';
            MemtoReg <='0';
           
     end case;
          
end process;

end Behavioral;
