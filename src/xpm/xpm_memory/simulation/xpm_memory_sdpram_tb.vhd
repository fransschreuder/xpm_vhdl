--! Copyright [2020] [Frans Schreuder]
--!
--!   Licensed under the Apache License, Version 2.0 (the "License");
--!   you may not use this file except in compliance with the License.
--!   You may obtain a copy of the License at
--!
--!       http://www.apache.org/licenses/LICENSE-2.0
--!
--!   Unless required by applicable law or agreed to in writing, software
--!   distributed under the License is distributed on an "AS IS" BASIS,
--!   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--!   See the License for the specific language governing permissions and
--!   limitations under the License.
-- Module Name: xpm_memory_base_sdpram_tb.vhd
-- Description:
-- Regression test for cross-port read-during-write in a Simple Dual Port RAM.
-- With a common clock and the write port in READ_FIRST mode, UG573 guarantees
-- that a simultaneous read and write to the same address returns the *previously
-- stored* data on the read port (block RAM has no cross-port write-to-read
-- forwarding path). This testbench writes a location, then reads it while writing
-- a new value to it in the same cycle, and checks that the old value is returned.
library vunit_lib;
context vunit_lib.vunit_context;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library xpm;

entity xpm_memory_sdpram_tb is
  generic(runner_cfg : string := runner_cfg_default);
end xpm_memory_sdpram_tb;

architecture tb of xpm_memory_sdpram_tb is

  constant DW    : integer := 32;
  constant AW    : integer := 5;
  constant DEPTH : integer := 2 ** AW;

  constant OLD_VALUE : std_logic_vector(DW - 1 downto 0) := x"0000AAAA";
  constant NEW_VALUE : std_logic_vector(DW - 1 downto 0) := x"0000BBBB";
  constant ADDR      : std_logic_vector(AW - 1 downto 0) := std_logic_vector(to_unsigned(7, AW));

  signal clk   : std_logic := '0';
  signal wea   : std_logic_vector(0 downto 0) := "0";
  signal addra : std_logic_vector(AW - 1 downto 0) := (others => '0');
  signal dina  : std_logic_vector(DW - 1 downto 0) := (others => '0');
  signal addrb : std_logic_vector(AW - 1 downto 0) := (others => '0');
  signal doutb : std_logic_vector(DW - 1 downto 0);

  constant CLK_PERIOD : time := 10 ns;
  signal running : boolean := true;

begin

  clkgen : process
  begin
    while running loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
    wait;
  end process;

  dut : entity xpm.xpm_memory_sdpram
    generic map (
      MEMORY_PRIMITIVE   => "block",
      MEMORY_SIZE        => DEPTH * DW,
      CLOCKING_MODE      => "common_clock",
      WRITE_DATA_WIDTH_A => DW,
      BYTE_WRITE_WIDTH_A => DW,
      ADDR_WIDTH_A       => AW,
      READ_DATA_WIDTH_B  => DW,
      ADDR_WIDTH_B       => AW,
      READ_LATENCY_B     => 1,
      WRITE_MODE_B       => "read_first"
    )
    port map (
      sleep          => '0',
      clka           => clk,
      ena            => '1',
      wea            => wea,
      addra          => addra,
      dina           => dina,
      injectsbiterra => '0',
      injectdbiterra => '0',
      clkb           => clk,
      rstb           => '0',
      enb            => '1',
      regceb         => '1',
      addrb          => addrb,
      doutb          => doutb,
      sbiterrb       => open,
      dbiterrb       => open
    );

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    -- Inputs are driven on the falling edge so they are stable at the rising edge
    -- that acts on them; doutb (read latency 1) is then sampled on the next falling
    -- edge. Each step below spans exactly one rising edge.
    wea <= "0";
    wait until falling_edge(clk);

    -- Write OLD_VALUE to ADDR.
    addra <= ADDR;
    dina  <= OLD_VALUE;
    wea   <= "1";
    wait until falling_edge(clk);         -- rising edge here writes OLD_VALUE
    wea   <= "0";
    dina  <= (others => '0');

    -- Plain read-back of ADDR.
    addrb <= ADDR;
    wait until falling_edge(clk);         -- rising edge registers the read
    check_equal(doutb, OLD_VALUE, "plain read-back of written location");

    -- Cross-port read-during-write: write NEW_VALUE to ADDR while reading ADDR.
    addra <= ADDR;
    dina  <= NEW_VALUE;
    wea   <= "1";
    addrb <= ADDR;
    wait until falling_edge(clk);         -- rising edge: write NEW_VALUE, read ADDR
    wea   <= "0";
    dina  <= (others => '0');
    -- READ_FIRST: the read must see the OLD contents, not the value being written.
    check_equal(doutb, OLD_VALUE,
      "cross-port read-during-write must return OLD data (read_first)");

    -- The write must still have taken effect.
    addrb <= ADDR;
    wait until falling_edge(clk);         -- rising edge registers the read
    check_equal(doutb, NEW_VALUE, "write during the collision cycle took effect");

    running <= false;
    test_runner_cleanup(runner);
    wait;
  end process;

  test_runner_watchdog(runner, 1 ms);

end tb;
