----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2022 01:36:15 PM
-- Design Name: 
-- Module Name: Mips16_3 - Behavioral
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

entity Mips16_3 is
Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end Mips16_3;

architecture Behavioral of Mips16_3 is

component SSDisplay is
    Port ( clock : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR (15 downto 0);
           an_out : out STD_LOGIC_VECTOR (3 downto 0);
           cat_out : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component Instruction_Fetch is
Port (     clk_in : in STD_LOGIC;
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           PC_1 : out STD_LOGIC_VECTOR(15 downto 0);
           btn : in STD_LOGIC;
           reset : in STD_LOGIC;
           Branch_Address : in STD_LOGIC_VECTOR(15 downto 0);
           Jump_Address : in STD_LOGIC_VECTOR(15 downto 0);
           Instruction : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component Instruction_Decode is
Port ( clk : in std_logic;
       Instr : in std_logic_vector (15 downto 0);
       WD : in std_logic_vector (15 downto 0);
       en : in std_logic;
       RegWrite : in std_logic;
       RegDst : in std_logic;
       ExtOp : in std_logic;
       RD1 : out std_logic_vector (15 downto 0);
       RD2 : out std_logic_vector (15 downto 0);
       Ext_Imm : out std_logic_vector (15 downto 0);
       func : out std_logic_vector (2 downto 0);
       sa : out std_logic );
end component;

component MainControl is
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
end component;

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component EX is
 Port ( RD1: in STD_LOGIC_VECTOR (15 downto 0);
       ALUSrc: in STD_LOGIC;
       RD2: in STD_LOGIC_VECTOR (15 downto 0);
       Ext_Imm: in STD_LOGIC_VECTOR (15 downto 0);
       sa: in STD_LOGIC;
       func: in STD_LOGIC_VECTOR (2 downto 0);
       ALUOp: in STD_LOGIC_VECTOR (1 downto 0);
       PC_1: in STD_LOGIC_VECTOR (15 downto 0);   
       Zero: out STD_LOGIC;
       ALURes: out STD_LOGIC_VECTOR (15 downto 0);
       BranchAddr: out STD_LOGIC_VECTOR (15 downto 0) );
end component;

component MEM is
Port ( MemWrite : in std_logic;
       clk : in std_logic;
       Address : in std_logic_vector(15 downto 0);
       WriteData : in std_logic_vector(15 downto 0);
       EN : in std_logic;
       ReadData : out std_logic_vector(15 downto 0) );
end component;

signal cnt: std_logic_vector(7 downto 0);
signal CE: std_logic;
signal CE_R: std_logic;
signal r_out: std_logic_vector(15 downto 0);
signal Branch_Addr : STD_LOGIC_VECTOR(15 downto 0):="0000000000000011";
signal Jump_Addr : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');

signal PC_1: std_logic_vector(15 downto 0);
signal Instruction: std_logic_vector(15 downto 0);

signal WD : STD_LOGIC_VECTOR(15 downto 0);

signal RegDst: std_logic;
signal ExtOp: std_logic;
signal ALUSrc: std_logic;
signal Branch: std_logic;
signal Jump: std_logic;
signal ALUOp: std_logic_vector(1 downto 0);
signal MemWrite: std_logic;
signal MemtoReg: std_logic;
signal RegWrite: std_logic;

signal RD1: std_logic_vector(15 downto 0);
signal RD2: std_logic_vector(15 downto 0);
signal Ext_Imm: std_logic_vector(15 downto 0);
signal func: std_logic_vector(2 downto 0);
signal sa: std_logic;

signal Sum_RD: std_logic_vector(15 downto 0);
signal ZEXT_f: std_logic_vector(15 downto 0);
signal ZEXT_sa: std_logic_vector(15 downto 0);
signal sel: std_logic_vector(7 downto 5);

signal ALURes: std_logic_vector(15 downto 0);
signal Zero: std_logic;
signal BranchAddress: std_logic_vector(15 downto 0);

signal PCSrc: std_logic;
signal MemData: std_logic_vector(15 downto 0);

begin


MG: MPG port map (CE, btn(0),clk);
MG1: MPG port map (CE_R, btn(1),clk);
I_F: Instruction_Fetch port map (clk, Jump, PCSrc, PC_1, CE, CE_R, Branch_Addr, Jump_Addr, Instruction);

MC: MainControl port map(Instruction, RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);

--led(9 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
led(7) <= RegDst;
led(6) <= ExtOp;
led(5) <= ALUSrc;
led(4) <= Branch;
led(3) <= Jump;
led(2) <= MemWrite;
led(1) <= MemtoReg;
led(0) <= RegWrite;
led(9 downto 8) <= ALUOp;

I_D: Instruction_Decode port map (clk, Instruction, WD, CE, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_Imm, func, sa); 

EX1: EX port map (RD1, ALUSrc, RD2, Ext_Imm, sa, func, ALUOp, PC_1, Zero, ALURes, BranchAddress);

Branch_Addr <= BranchAddress;
PCSrc <= Zero and Branch;
Jump_Addr <= PC_1(15 downto 13) & Instruction(12 downto 0);

memo: MEM port map (MemWrite, clk, ALURes, RD2, CE, MemData);

WD <= ALURes when MemtoReg='0' else MemData;

sel <= sw(7 downto 5);

Zero <= '1' when RD1 = RD2 else '0';

process(sel)
begin
  case sel is
     when "000" => r_out <= Instruction;
     when "001" => r_out <= PC_1;
     when "010" => r_out <= RD1;
     when "011" => r_out <= RD2;
     when "100" => r_out <= Ext_Imm;
     when "101" => r_out <= ALURes;
     when "110" => r_out <= MemData;
     when others => r_out <= WD;
  end case;
end process;

Display: SSDisplay port map (clk, r_out, an, cat);

end Behavioral;
