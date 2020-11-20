library ieee;
use ieee.std_logic_1164.all;
library std;
use std.env.all;

entity xpm_fifo_reg_vec is
generic (
    REG_WIDTH : integer := 4
);
port (
  rst : in std_logic;
  clk : in std_logic;
  reg_in : in std_logic_vector(REG_WIDTH-1 downto 0);
  reg_out : out std_logic_vector(REG_WIDTH-1 downto 0)
);
end xpm_fifo_reg_vec;

architecture rtl of xpm_fifo_reg_vec is
    signal reg_out_i : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');
begin
  
  process(clk, rst)
  begin
    if rst = '1' then
        reg_out_i <= (others => '0');
    elsif rising_edge(clk) then
        reg_out_i <= reg_in;
    end if;
  end process;
  
  reg_out <= reg_out_i;

end rtl;
