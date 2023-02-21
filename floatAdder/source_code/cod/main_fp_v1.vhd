----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2022 01:35:50 PM
-- Design Name: 
-- Module Name: main_fp_v1 - Behavioral
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

entity main_fp_v1 is
  Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           dp : out STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end main_fp_v1;

architecture Behavioral of main_fp_v1 is

component counter_9 is
  Port ( rst, clk, sw : in std_logic;
           o : out std_logic_vector(3 downto 0));
end component;

component hex_SSD is
  Port (  clk: in STD_LOGIC;
	      clear: in STD_LOGIC;
	      nr:  in STD_LOGIC_VECTOR(15 downto 0);
	      point_location : in STD_LOGIC_VECTOR(2 downto 0);						  
	      cat: out STD_LOGIC_VECTOR(6 downto 0);
	      an: out STD_LOGIC_VECTOR(3 downto 0);
	      point : out STD_LOGIC
           );
end component;

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component make_number_binary is
  Port ( clk : in STD_LOGIC;
         hex_bcd: in STD_LOGIC_VECTOR(15 downto 0);
         sign : in STD_LOGIC;
         load : in STD_LOGIC;
         bin : out STD_LOGIC_VECTOR(31 downto 0);
         done : out STD_LOGIC
        );
end component;

component float_adderv1 is
  port( A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        sum    : out std_logic_vector(31 downto 0);
        clk    : in  std_logic;
        reset  : in  std_logic;
        go  : in  std_logic;
        done   : out std_logic
       );
end component;

component bin_fractional_to_bcd is
  Port ( clk : in STD_LOGIC;
         bin_iee : in STD_LOGIC_VECTOR(31 downto 0);
         sign : out STD_LOGIC;
	     BCD : out STD_LOGIC_VECTOR(15 downto 0);
	     load : in STD_LOGIC;													  										   							  				   
	     done : out STD_LOGIC );
end component;

signal result_sign: std_logic;
signal to_bcd_done: std_logic;
signal load_bin_to_bcd: std_logic;


signal clear: std_logic := '0';
signal point: std_logic;
signal nr_display: STD_LOGIC_VECTOR(15 downto 0);
signal point_location : STD_LOGIC_VECTOR(2 downto 0) := "001";
signal rst: std_logic := '0';
signal a_output_c1: std_logic_vector(3 downto 0);
signal a_output_c2: std_logic_vector(3 downto 0);
signal a_output_c3: std_logic_vector(3 downto 0);
signal a_output_c4: std_logic_vector(3 downto 0);

signal a: STD_LOGIC_VECTOR(15 downto 0);

signal a1,a2,a3,a4: std_logic;

signal b_output_c1: std_logic_vector(3 downto 0);
signal b_output_c2: std_logic_vector(3 downto 0);
signal b_output_c3: std_logic_vector(3 downto 0);
signal b_output_c4: std_logic_vector(3 downto 0);

signal b: STD_LOGIC_VECTOR(15 downto 0);

signal b1,b2,b3,b4: std_logic;

signal c: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
signal result_1: STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";

signal done: std_logic := '0';
signal select_nr: std_logic;
signal sign_a: std_logic;
signal sign_b: std_logic;
signal sign_a_calculated: std_logic;
signal sign_b_calculated: std_logic;

signal a_binary :  std_logic_vector(31 downto 0);
signal b_binary :  std_logic_vector(31 downto 0);
signal c_binary :  std_logic_vector(31 downto 0);

signal result_1_binary :  std_logic_vector(31 downto 0);

signal a_load : std_logic;
signal b_load : std_logic;

signal a_done : std_logic;
signal b_done : std_logic;
signal result_done : std_logic;

signal op : std_logic; --0 for add, 1 for sub
signal go : std_logic := '0';

signal alu_loaded, final_loaded: std_logic;

signal sel_ck: STD_LOGIC_VECTOR(1 downto 0);
signal clkdiv: STD_LOGIC_VECTOR(18 downto 0);

begin

process(clk)
	begin
		if clk'event and clk = '1' then
			clkdiv <= clkdiv + 1;
		end if;
end process;

sel_ck <= clkdiv(18 downto 17);
process(sel_ck)
 begin
  if(conv_integer(3-sel_ck) = "001") then 
	  dp <= '0';
  else
      dp <= '1';
  end if;
end process;


deb1: MPG port map (a1, btn(2), clk);
deb2: MPG port map (a2, btn(0), clk);
deb3: MPG port map (a3, btn(3), clk);
deb4: MPG port map (a4, btn(4), clk);

deb5: MPG port map (b1, sw(3), clk);
deb6: MPG port map (b2, sw(4), clk);
deb7: MPG port map (b3, sw(5), clk);
deb8: MPG port map (b4, sw(6), clk);


--first number
count_1: counter_9 port map (rst,clk,a1,a_output_c1);
count_2: counter_9 port map (rst,clk,a2,a_output_c2);
count_3: counter_9 port map (rst,clk,a3,a_output_c3);
count_4: counter_9 port map (rst,clk,a4,a_output_c4);

count_5: counter_9 port map (rst,clk,b1,b_output_c1);
count_6: counter_9 port map (rst,clk,b2,b_output_c2);
count_7: counter_9 port map (rst,clk,b3,b_output_c3);
count_8: counter_9 port map (rst,clk,b4,b_output_c4);

point <= '1';
led(12) <= op;
clear <= sw(0);
select_nr <= sw(15);
led(0) <= result_done;
led(1) <= b_done;
led(2) <= a_done;
led(5) <= to_bcd_done;
led(6) <= go;


--operation
sign_a <= sw(14);
sign_b <= sw(13);
op <= sw(2);
process(clk, op)
  begin
   if(rising_edge(clk)) then
    if(op = '1') then
       if(sign_b = '1') then
          sign_b_calculated <= '0';
          sign_a_calculated <= sign_a;
       elsif(sign_b = '0') then
          sign_b_calculated <= '1';
          sign_a_calculated <= sign_a;    
       end if;
    else
       sign_b_calculated <= sign_b;
       sign_a_calculated <= sign_a;
    end if;
  end if;
end process;


--make numbers and display
process(clk,select_nr)
  begin
   if(rising_edge(clk)) then
   
      a <= a_output_c4 & a_output_c3 & a_output_c2 & a_output_c1;

      b <= b_output_c4 & b_output_c3 & b_output_c2 & b_output_c1;
      
      if(sw(1) = '0') then
          go <= '0';
          alu_loaded <= '0';
          load_bin_to_bcd <= '0';
          if(sw(15) = '0') then
                a_load <= '1';
                b_load <= '0';
                nr_display <= a;

          else
                b_load <= '1';
                a_load <= '0';
                nr_display <= b;
          end if;
      else
          --nr_display <= c;
          nr_display <= result_1;
          b_load <= '0';
          a_load <= '0';

                         
          if(a_done = '1' and b_done = '1') then
               if(alu_loaded = '0') then
                   go <= '1';    
                   alu_loaded <= '1';
               else
                   
                   if(result_done = '1') then
                      --go <= '0'; 
                     if(final_loaded = '0') then
                       load_bin_to_bcd <= '1';
                       final_loaded <= '1';
                     else
                       load_bin_to_bcd <= '0';
                       go <= '0';
                     end if;
                   end if;
                   
                   if(to_bcd_done = '1') then
                     result_1 <= c;
                   end if;
                   
                  
                   
             end if;
         end if;
      end if;
   end if;

end process;


display: hex_SSD port map (clk, clear, nr_display, point_location, cat, an, point);
make_a: make_number_binary port map(clk, a, sign_a_calculated, a_load, a_binary, a_done);
make_b: make_number_binary port map(clk, b, sign_b_calculated, b_load, b_binary, b_done);



calculator: float_adderv1 port map(a_binary, b_binary, result_1_binary, clk, sw(0), go, result_done);  


nr_display_result: bin_fractional_to_bcd port map(clk, c_binary, result_sign, c, load_bin_to_bcd, to_bcd_done);

c_binary <= result_1_binary;

end Behavioral;
