----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2022 07:12:03 PM
-- Design Name: 
-- Module Name: float_adderv1_sim - Behavioral
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

entity float_adderv1_sim is
--  Port ( );
end float_adderv1_sim;

architecture Behavioral of float_adderv1_sim is

component float_adderv1 is
  port(A: in  std_logic_vector(31 downto 0);
       B: in  std_logic_vector(31 downto 0);
       sum: out std_logic_vector(31 downto 0);
       clk: in  std_logic;
       reset: in  std_logic;
       go: in  std_logic;
       done: out std_logic
       );
end component;

signal A: std_logic_vector(31 downto 0);
signal B: std_logic_vector(31 downto 0);
signal clk : std_logic;
signal reset: std_logic;
signal go: std_logic;
signal done: std_logic;
signal sum: std_logic_vector(31 downto 0);

begin

fa: float_adderv1 port map (A,B,sum,clk,reset,go,done);

Clock : process
begin

  clk <= '0';
  wait for 20 ns;
  clk <= '1';
  wait for 20 ns;

end process;

Stim : process
begin

    A <= "00101011011100111000000011000011";
    B <= "00101001110011100101111100011111";
    reset <= '0';
    go <= '0';
    wait for 40 ns;
    
    A <= "00101011011100111000000011000011";
        B <= "00101001110011100101111100011111";
        reset <= '0';
        go <= '1';
        wait for 40 ns; 
        
    A <= "00101011011100111000000011000011";
            B <= "00101001110011100101111100011111";
            reset <= '0';
            go <= '1';
            wait for 40 ns; 
            
    A <= "00101011011100111000000011000011";
                B <= "00101001110011100101111100011111";
                reset <= '0';
                go <= '1';
                wait for 40 ns;
    A <= "00101011011100111000000011000011";
                B <= "00101001110011100101111100011111";
                reset <= '0';
                go <= '1';
                wait for 40 ns;
    A <= "00101011011100111000000011000011";
                B <= "00101001110011100101111100011111";
                reset <= '0';
                go <= '1';
                wait for 40 ns;  
                
--2         
     reset <= '1';
     go <= '0';
     wait for 40 ns; 
     A <= "01000001101010000001010001111010";
             B <= "01000001110000000001010001111010";
             reset <= '0';
             go <= '1';
             wait for 40 ns; 
             
          A <= "01000001101010000001010001111010";
                         B <= "01000001110000000001010001111010";
                 reset <= '0';
                 go <= '1';
                 wait for 40 ns; 
                 
         A <= "01000001101010000001010001111010";
                             B <= "01000001110000000001010001111010";
                     reset <= '0';
                     go <= '1';
                     wait for 40 ns;
          A <= "01000001101010000001010001111010";
                                 B <= "01000001110000000001010001111010";
                     reset <= '0';
                     go <= '1';
                     wait for 40 ns;
         A <= "01000001101010000001010001111010";
                                 B <= "01000001110000000001010001111010";
                     reset <= '0';
                     go <= '1';
                     wait for 40 ns;             
 --3 24.01 - 4.57 = 19.44
     reset <= '1';
     go <= '0';
     wait for 40 ns; 
     A <= "01000001110000000001010001111010";
             B <= "11000000100100100011110101110000";
             reset <= '0';
             go <= '1';
             wait for 40 ns; 
             
         A <= "01000001110000000001010001111010";
                          B <= "11000000100100100011110101110000";
                 reset <= '0';
                 go <= '1';
                 wait for 40 ns; 
                 
         A <= "01000001110000000001010001111010";
                              B <= "11000000100100100011110101110000";
                     reset <= '0';
                     go <= '1';
                     wait for 40 ns;
          A <= "01000001110000000001010001111010";
                                  B <= "11000000100100100011110101110000";
                     reset <= '0';
                     go <= '1';
                     wait for 40 ns;
         A <= "01000001110000000001010001111010";
                                  B <= "11000000100100100011110101110000";
                     reset <= '0';
                     go <= '1';
                     wait for 40 ns;
                                

end process;


end Behavioral;
