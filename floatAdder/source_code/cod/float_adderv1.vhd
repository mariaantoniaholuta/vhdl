----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2022 07:10:27 PM
-- Design Name: 
-- Module Name: float_adderv1 - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity float_adderv1 is
  port( A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        sum    : out std_logic_vector(31 downto 0);
        clk    : in  std_logic;
        reset  : in  std_logic;
        go  : in  std_logic;
        done   : out std_logic
       );
end float_adderv1;

architecture Behavioral of float_adderv1 is
  signal state: std_logic_vector(2 downto 0) := "000"; 
  
  signal A_sign, B_sign : std_logic;
  signal A_exponent, B_exponent : std_logic_vector (8 downto 0);
  signal A_mantissa, B_mantissa : std_logic_vector (24 downto 0);
  
  signal A_mantissa_1, B_mantissa_1 : std_logic_vector (24 downto 0);
  signal A_mantissa_1_result, B_mantissa_1_result : std_logic_vector (24 downto 0);
  
  signal result_mantissa : std_logic_vector (24 downto 0);
  signal result_exponent : std_logic_vector (8 downto 0);
  signal result_sign : std_logic;
  
  signal adder_result1 : std_logic_vector (24 downto 0);
  signal sub_result1 : std_logic_vector (24 downto 0);
  signal sub_result2 : std_logic_vector (24 downto 0); 
  
  component add_mantissasv1 is
    Port ( A_mantissa : in std_logic_vector (24 downto 0);
           B_mantissa : in std_logic_vector (24 downto 0);
           sum : out std_logic_vector (24 downto 0));
  end component;
  
  component generic_adder_v1 is
    generic (N: INTEGER:= 25);
    Port ( addsub : in std_logic;
           a, b : in std_logic_vector (N-1 downto 0);
           sum : out std_logic_vector (N-1 downto 0);
           overflow : out std_logic;
           cout : out std_logic);
  end component;
  
  
  component RightShifter_1 is
      generic (
          n     :     integer        
      );                    
      port (
          x    :    in     std_logic_vector(24 downto 0);    
          y    :    out    std_logic_vector(24 downto 0)    
      );
  end component;
  
  component RightShifter is
      generic (
          n     :     integer;
          s     :    integer            
      );                    
      port (
          x    :    in     std_logic_vector(n-1 downto 0);    
          y    :    out    std_logic_vector(n-1 downto 0)    
      );
  end component;
  
  component RightShifter_1bit is					
      port (
          x    :    in     std_logic_vector(24 downto 0);    
          y    :    out    std_logic_vector(24 downto 0)    
      );
  end component;
  
  
  signal overflow, cout : std_logic;
  
  signal diff_int_1 : integer;
  signal diff_int_2 : integer;
  signal diff_int_3 : integer;
  signal diff_int_4 : integer;
  
  signal done_b_shift : std_logic := '0';
  signal done_a_shift : std_logic := '0';
  
  signal done_all: std_logic;
  signal diff_i: std_logic_vector(7 downto 0);
  signal difference_i_s : signed(8 downto 0) := (others => '0');
  
  --constant DataWidth : integer := 8;
  
  
  --state: 000 - wait
  --state: 001 - align using shifting in mantissa
  --state: 010 - add mantissas
  --state: 011 - normalize
  --state: 100 - make result

begin

--add_unsigned: add_mantissasv1 port map (A_mantissa, B_mantissa, adder_result1);
add_generic: generic_adder_v1 port map ('0', A_mantissa, B_mantissa, adder_result1, overflow, cout);
sub_generic: generic_adder_v1 port map ('1', A_mantissa, B_mantissa, sub_result1, overflow, cout);
sub_generic1: generic_adder_v1 port map ('1', B_mantissa, A_mantissa, sub_result2, overflow, cout);

shift: RightShifter_1bit port map(B_mantissa, B_mantissa_1);

--sh: RightShifter generic map (n => 25, s => diff_int_1) port map (B_mantissa,B_mantissa_1_result);

  
  Main : process (clk, reset) is
    variable difference : signed(8 downto 0);
    variable difference_i : signed(8 downto 0) := (others => '0');
  begin
    if(reset = '1') then
      state <= "000"; --wait state
      done <= '0';
    elsif rising_edge(clk) then
      case state is
        when "000" =>
          if (go = '1') then 
            A_sign <= A(31);
            A_exponent <= '0' & A(30 downto 23); --add one bit for signed subtraction
            A_mantissa <= "01" & A(22 downto 0); --add two bits, one for leading 1 and other one for carry
            B_sign <= B(31);
            B_exponent <= '0' & B(30 downto 23);	
            B_mantissa <= "01" & B(22 downto 0);
            state <= "001"; --align
          else
            state <= "000";    
          end if;
          
        when "101" =>
           if(to_integer(difference) > to_integer(difference_i_s)) then
              B_mantissa <= '0' & B_mantissa(24 downto 1);
              difference_i_s <= difference_i_s + 1;
              state <= "101";
           else
              done_b_shift <= '1';
              state <= "001";
           end if;
           
        when "111" =>
           if(to_integer(difference) > to_integer(difference_i)) then
               A_mantissa <= '0' & A_mantissa(24 downto 1);
               difference_i := difference_i + 1;
               state <= "111";
           else
               done_a_shift <= '1';
               state <= "001";
           end if;
           
        when "001" =>  --see if exponent match and and align it
          if unsigned(A_exponent) > unsigned(B_exponent) then
			--B needs right shifting
            difference := signed(A_exponent) - signed(B_exponent);  --Small Alu
            --difference_i := (others => '0');
            --diff_i <= (others => '0');
            if difference > 23 then
              result_exponent <= A_exponent;
              result_mantissa <= A_mantissa;  --B insignificant relative to A
              result_sign <= A_sign;
              state <= "100";   -- A as output result
            else       
			  --downshift B 
			  result_exponent <= A_exponent;
			  diff_int_1 <= to_integer(difference);
			  diff_int_2 <= to_integer(difference)-1;
			  diff_int_3 <= 25-to_integer(difference);
			  
			 if(done_b_shift = '0') then
                  state <= "101";
             else
                 state <= "010";
             end if;
             
              --if(done_b_shift = '0') then
               --             for i in 3 downto 0 loop
              --                B_mantissa <= '0' & B_mantissa(24 downto 1);
              --                if(i = 0) then
              --                  done_b_shift <= '1';                  
              --                end if;
               --             end loop;   
              --end if; 

			         	         
              
              --B_mantissa(24-to_integer(difference) downto 0) <= B_mantissa(24 downto to_integer(difference));
              --B_mantissa(24 downto 25-to_integer(difference)) <= (others => '0');
              state <= "010"; --addition state
            end if;
          elsif unsigned(A_exponent) < unsigned(B_exponent)  then   -- right shift A
            difference := signed(B_exponent) - signed(A_exponent);  -- Small Alu
            difference_i := (others => '0');
            if difference > 23 then
              result_mantissa <= B_mantissa;  --A insignificant relative to B
              result_sign <= B_sign;
              result_exponent <= B_exponent; 
              state <= "100";   --make result
            else       
			  --downshift A  
              result_exponent <= B_exponent;
              diff_int_4 <= to_integer(difference)-1;
              
              if(done_a_shift = '0') then
                 state <= "111";
              else 
                 state <= "010";
              end if;

              --A_mantissa(24-to_integer(difference) downto 0)  <= A_mantissa(24 downto to_integer(difference));
             -- A_mantissa(24 downto 25-to_integer(difference)) <= (others => '0');
              
            end if;
		  else				
		    result_exponent <= A_exponent;
            state <= "010";          
          end if;
        when "010" => --Mantissa addition
          --state <= "011";  --normalize
          if (A_sign xor B_sign) = '0' then  --signs are the same so add the mantissas
            result_mantissa <= adder_result1;
            result_sign <= A_sign;
          --sign are not the same, then substract from the bigger
          elsif unsigned(A_mantissa) >= unsigned(B_mantissa) then
            --result_mantissa <= std_logic_vector((unsigned(A_mantissa) - unsigned(B_mantissa)));
            result_mantissa <= sub_result1;
            result_sign <= A_sign;
          else
            result_mantissa <= sub_result2;
            result_sign <= B_sign;
          end if;
          state <= "011";  --normalize
        when "011" =>  --normalize 
          if unsigned(result_mantissa) = TO_UNSIGNED(0, 25) then
			--when the sum is 0
			result_exponent <= (others => '0');
            result_mantissa <= (others => '0');  
            state <= "100"; --make result 
          elsif(result_mantissa(24) = '1') then  --overflow, then right shift
            result_exponent <= std_logic_vector((unsigned(result_exponent)+ 1));
            result_mantissa <= '0' & result_mantissa(24 downto 1);  --shift the 1 
            state <= "100";
          elsif(result_mantissa(23) = '0') then  --left shift
          	  result_exponent <= std_logic_vector((unsigned(result_exponent)-1));
			  result_mantissa <= result_mantissa(23 downto 0) & '0';	
			  state <= "011"; -- shifting again untill leading 1 
          else
            state <= "100";  --leading 1, then make the result
          end if;
        when "100" => -- result state 
          sum(31) <= result_sign;
          sum(30 downto 23) <= result_exponent(7 downto 0);
          sum(22 downto 0) <= result_mantissa(22 downto 0);
          done <= '1'; 
          if (go = '0') then 
            done <= '0';
            state <= "000";
          end if;
        when others => 
			state <= "000"; 
      end case;
    end if;
  end process;

end Behavioral;

