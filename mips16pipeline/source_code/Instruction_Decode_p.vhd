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

entity Instruction_Decode_p is
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
end Instruction_Decode_p;

architecture Behavioral of Instruction_Decode_p is

type memory is array (0 to 7) of std_logic_vector(15 downto 0);
signal RegisterFile : memory := (
      x"0000",
      x"0002",
      x"0004",
      x"0006",
      x"0008",
      x"0004",
      x"0008",
      others => x"0000" );

begin

func <= Instr(2 downto 0);
sa <= Instr(3);

process(ExtOp)
begin
  if(ExtOp = '0') then  
      Ext_Imm(6 downto 0)<=Instr(6 downto 0);
      Ext_Imm(15 downto 7)<=(others=>'0');
  end if;
  if(ExtOp = '1') then 
     if(Instr(6) = '0') then 
        Ext_Imm(6 downto 0)<=Instr(6 downto 0);
        Ext_Imm(15 downto 7)<=(others=>'0');
     else
        Ext_Imm(6 downto 0)<=Instr(6 downto 0);
        Ext_Imm(15 downto 7)<=(others=>'1');
     end if;
  end if;
end process;

process(clk)
begin
   if(falling_edge(clk)) then
       if(en = '1' and RegWrite = '1') then
          RegisterFile(conv_integer(WriteAddress)) <= WD;
       end if;
   end if;
end process;

RD1 <=  RegisterFile(conv_integer(Instr(12 downto 10)));
RD2 <=  RegisterFile(conv_integer(Instr(9 downto 7)));

 rt <= Instr(9 downto 7);
 rd <= Instr(6 downto 4);

end Behavioral;

