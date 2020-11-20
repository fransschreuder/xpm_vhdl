library ieee;
use ieee.std_logic_1164.all;
library std;
use std.env.all;

entity  xpm_fifo_reg_bit is
generic (
    RST_VALUE        : std_logic := '0'

);
port(
    rst : in std_logic;
    clk : in std_logic;
    d_in : in std_logic;
    d_out : out std_logic := RST_VALUE
);
end xpm_fifo_reg_bit;

architecture rtl of xpm_fifo_reg_bit is

begin

  process(clk)
  begin
    if rst = '1' then
        d_out <= RST_VALUE;
    elsif rising_edge(clk) then
        d_out  <= d_in;
    end if;
  end process;

end rtl;
