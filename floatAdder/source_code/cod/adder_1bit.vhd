library ieee;
use ieee.std_logic_1164.all;


entity full_adder is
   port ( a,b,ci:in std_logic; 
          sm,cout: out std_logic);
end full_adder;

architecture full_adder_a of full_adder is
  begin
    sm <= a xor b xor ci;
    cout <= (a and b) or (b and ci) or (ci and a);
end full_adder_a;
