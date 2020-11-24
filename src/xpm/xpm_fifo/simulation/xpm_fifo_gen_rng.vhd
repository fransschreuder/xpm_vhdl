-- Module Name: xpm_fifo_gen_rng
-- Description:
--   Used for generation of pseudo random numbers
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;
library std;
use std.env.all;
entity xpm_fifo_gen_rng is
generic(
  WIDTH    : integer := 8;
  SEED     : integer := 3
  );
port(
  clk        : in std_logic;
  rst        : in std_logic;
  enable     : in std_logic;
  random_num : out std_logic_vector(WIDTH-1 downto 0)
);
end xpm_fifo_gen_rng;

architecture tb of xpm_fifo_gen_rng is  
  signal rand_temp: std_logic_vector(WIDTH-1 downto 0);
  signal temp: std_logic;
begin

  process(rst, clk)
  begin
    if (rst = '1') then
      temp      <= '0';
      rand_temp <= std_logic_vector(to_unsigned(SEED, WIDTH));
    elsif rising_edge(clk) then
      if(enable = '1') then
    
        temp      <= rand_temp(WIDTH-1) xnor rand_temp(WIDTH-3) xnor rand_temp(WIDTH-4) xnor rand_temp(WIDTH-5);
        rand_temp <= rand_temp(WIDTH-2 downto 0) & temp;
      end if;
    end if;
  end process;
  random_num <= rand_temp;

end tb;-- : xpm_fifo_gen_rng
