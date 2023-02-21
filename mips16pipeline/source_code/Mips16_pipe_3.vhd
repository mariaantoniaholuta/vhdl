----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2022 05:09:10 PM
-- Design Name: 
-- Module Name: Mips16_pipeline - Behavioral
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

entity Mips16_pipe_3 is
Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end Mips16_pipe_3;

architecture Behavioral of Mips16_pipe_3 is

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

component pipeEX is
 Port ( RD1: in STD_LOGIC_VECTOR (15 downto 0);
       ALUSrc: in STD_LOGIC;
       RD2: in STD_LOGIC_VECTOR (15 downto 0);
       Ext_Imm: in STD_LOGIC_VECTOR (15 downto 0);
       sa: in STD_LOGIC;
       func: in STD_LOGIC_VECTOR (2 downto 0);
       ALUOp: in STD_LOGIC_VECTOR (1 downto 0);
       PC_1: in STD_LOGIC_VECTOR (15 downto 0); 
       RegDst: in std_logic;
       rt: in std_logic_vector(2 downto 0);
       rd: in std_logic_vector(2 downto 0); 
       Zero: out STD_LOGIC;
       ALURes: out STD_LOGIC_VECTOR (15 downto 0);
       BranchAddr: out STD_LOGIC_VECTOR (15 downto 0);
       WriteAddress: out std_logic_vector(2 downto 0) );
end component;

component Instruction_Decode_p is
Port ( clk : in std_logic;
       Instr : in std_logic_vector (15 downto 0);
       WD : in std_logic_vector (15 downto 0);
       en : in std_logic;
       RegWrite : in std_logic;
       RegDst : in std_logic;
       ExtOp : in std_logic;
       WriteAddress : in std_logic_vector(2 downto 0);
       RD1 : out std_logic_vector (15 downto 0);
       RD2 : out std_logic_vector (15 downto 0);
       Ext_Imm : out std_logic_vector (15 downto 0);
       func : out std_logic_vector (2 downto 0);
       sa : out std_logic;
       rt: out std_logic_vector(2 downto 0);
       rd: out std_logic_vector(2 downto 0));
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


--pipeline
signal IF_ID: std_logic_vector(31 downto 0);
signal ID_EX : std_logic_vector(81 downto 0);
signal EX_MEM : std_logic_vector(55 downto 0);
signal MEM_WB : std_logic_vector(36 downto 0);

signal WriteAddress: std_logic_vector(2 downto 0);
signal rd: std_logic_vector(2 downto 0) := "000";
signal rt:  std_logic_vector(2 downto 0) := "000";

begin


MG: MPG port map (CE, btn(0),clk);
MG1: MPG port map (CE_R, btn(1),clk);
I_F: Instruction_Fetch port map (clk, Jump, PCSrc, PC_1, CE, CE_R, Branch_Addr, Jump_Addr, Instruction);

MC: MainControl port map(IF_ID(31 downto 16), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);

led(7) <= RegDst;
led(6) <= ExtOp;
led(5) <= ALUSrc;
led(4) <= Branch;
led(3) <= Jump;
led(2) <= MemWrite;
led(1) <= MemtoReg;
led(0) <= RegWrite;
led(9 downto 8) <= ALUOp;

I_D: Instruction_Decode_p port map (clk, IF_ID(31 downto 16), WD, CE, MEM_WB(0), RegDst, ExtOp, WriteAddress, RD1, RD2, Ext_Imm, func, sa, rt, rd); 

EX3: pipeEX port map (ID_EX(23 downto 8), ID_EX(1), ID_EX(39 downto 24), ID_EX(55 downto 40), ID_EX(59), ID_EX(58 downto 56), ID_EX(4 downto 3), ID_EX(75 downto 60), ID_EX(0), ID_EX(78 downto 76), ID_EX(81 downto 79), Zero, ALURes, BranchAddress, WriteAddress);

Branch_Addr <= BranchAddress;

PCSrc <= EX_MEM(20) and EX_MEM(3);

Jump_Addr <= IF_ID(15 downto 0)(15 downto 13) & IF_ID(31 downto 16)(12 downto 0);

memo: MEM port map (EX_MEM(2), clk, EX_MEM(36 downto 21), EX_MEM(52 downto 37), CE, MemData);

--WD <= ALURes when MemtoReg='0' else MemData;
WD <= MEM_WB(33 downto 18) when MEM_WB(1)='0' else MEM_WB(17 downto 2);

sel <= sw(7 downto 5);

Zero <= '1' when RD1 = RD2 else '0';

process(sel)
begin
  case sel is
     when "000" => r_out <= IF_ID(31 downto 16); --Instruction;
     when "001" => r_out <= IF_ID(15 downto 0); --PC_1;
     when "010" => r_out <= ID_EX(23 downto 8); --RD1;
     when "011" => r_out <= ID_EX(39 downto 24); --RD2;
     when "100" => r_out <= ID_EX(55 downto 40); --Ext_Imm;
     when "101" => r_out <= MEM_WB(33 downto 18); --ALURes;
     when "110" => r_out <= MEM_WB(17 downto 2); --MemData;
     when others => r_out <= WD;
  end case;
end process;


process(clk, CE)
  begin
    if rising_edge(clk) then
      if CE = '1' then
         IF_ID(15 downto 0) <= PC_1;
         IF_ID(31 downto 16) <= Instruction;
         
         ID_EX(0) <= RegDst;
         ID_EX(1) <= ALUSrc;
         ID_EX(2) <= Branch;
         ID_EX(4 downto 3) <= ALUOp;
         ID_EX(5) <= MemWrite;
         ID_EX(6) <= MemtoReg;
         ID_EX(7) <= RegWrite;
         ID_EX(23 downto 8) <= RD1;
         ID_EX(39 downto 24) <= RD2;
         ID_EX(55 downto 40) <= Ext_Imm;
         ID_EX(58 downto 56) <= func;
         ID_EX(59) <= sa;
         ID_EX(75 downto 60) <= IF_ID(15 downto 0); --PC NEXT
         ID_EX(78 downto 76) <= rt;
         ID_EX(81 downto 79) <= rd;
         
        
         EX_MEM(0) <= ID_EX(7); --regwrite
         EX_MEM(1) <= ID_EX(6); --memtoreg
         EX_MEM(2) <= ID_EX(5); --memwrite
         EX_MEM(3) <= ID_EX(2); --branch
         EX_MEM(19 downto 4) <= BranchAddress;
         EX_MEM(20) <= Zero;
         EX_MEM(36 downto 21) <= ALURes;
         EX_MEM(52 downto 37) <= ID_EX(60 downto 45); --rd2
         EX_MEM(55 downto 53) <= WriteAddress;    
         
         MEM_WB(0) <= EX_MEM(1); --regwrite
         MEM_WB(1) <= EX_MEM(1); --memtoreg
         MEM_WB(17 downto 2) <= MemData;
         MEM_WB(33 downto 18) <= EX_MEM(36 downto 21); --ALURes
         MEM_WB(36 downto 34) <= EX_MEM(42 downto 40); --WriteAddress; 
         
         
      end if;
    end if;

end process; 

Display: SSDisplay port map (clk, r_out, an, cat);

end Behavioral;

