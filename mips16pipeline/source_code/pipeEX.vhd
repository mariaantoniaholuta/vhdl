
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

entity pipeEX is
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
end pipeEX;

architecture Behavioral of pipeEX is

signal B : std_logic_vector (15 downto 0);
signal ALUCtrl: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal ALURes_1 : std_logic_vector (15 downto 0);

begin

B <= RD2 when ALUSrc='0' else Ext_Imm;

 process(RD1, B, ALUCtrl, sa)
    begin
    case ALUCtrl is
      when "000" => ALURes_1 <= RD1 + B;
      when "001" => ALURes_1 <= RD1 - B;
      --sll
      when "010" => if sa = '1' then
                       ALURes_1 <= RD1(14 downto 0) & '0';
                    else
                       ALURes_1 <= RD1;
                    end if;    
      --srl
      when "011" => if sa = '1' then
                              ALURes_1 <= '0' & RD1(15 downto 1);
                     else
                              ALURes_1 <= RD1;
                     end if;
       
      when "100" => ALURes_1 <= RD1 and B;
      when "101" => ALURes_1 <= RD1 or B;
      when "110" => ALURes_1 <= RD1 xor B;
      when others => if sa = '1' then
                         ALURes_1 <= RD1(15) & RD1(15 downto 1); --sra
                     else
                         ALURes_1 <= RD1;
                     end if;
    end case;
 end process;
 
 process(ALUOp, func)
   begin
    case ALUOp is
      when "00" =>
         case func is
            when "000" => ALUCtrl <= "000"; --add
            when "001" => ALUCtrl <= "001"; --sub
            when "010" => ALUCtrl <= "010"; --sll
            when "011" => ALUCtrl <= "011"; --srl
            when "100" => ALUCtrl <= "100"; --and
            when "101" => ALUCtrl <= "101"; --or
            when "110" => ALUCtrl <= "110"; --xor
            when others =>  ALUCtrl <= "111"; --sra
         end case;
      when "01" => ALUCtrl <= "001"; --beq
      when "10" => ALUCtrl <= "000"; --sw,lw
      when others => ALUCtrl <= "XXX"; --jump
    end case;
 end process;
 
 process(RegDst, rd, rt)
 begin
     if RegDst = '0' then
         WriteAddress <= rt;
     else 
         WriteAddress <= rd;
     end if; 
 end process; 
 
 BranchAddr <= PC_1 + Ext_Imm;
 ALURes <= ALURes_1;

end Behavioral;


