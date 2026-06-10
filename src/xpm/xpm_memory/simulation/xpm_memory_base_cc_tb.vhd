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
-- Module Name: xpm_memory_base_cc_tb.vhd
-- Description:
--   Memory-level regression test for the common-clocking-mode change in
--   xpm_memory_base (PR #19 / PR #20). Instantiates xpm_memory_base directly in
--   common-clock, simple-dual-port, read_first, READ_LATENCY=1 configuration.
--   Writes a ramp to consecutive addresses on port A and reads them back on port
--   B, then checks the read-back sequence is the intact ramp.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
library xpm;

entity xpm_memory_base_cc_tb is
  generic (runner_cfg : string := runner_cfg_default);
end entity;

architecture tb of xpm_memory_base_cc_tb is
  constant DW    : integer := 32;          -- data width
  constant AW    : integer := 12;          -- address width
  constant DEPTH : integer := 4096;
  constant N     : integer := 64;          -- words written/read back
  constant BASE  : integer := 256;          -- ramp offset so the read-port reset
                                            -- value (0) can't masquerade as data
  constant MARGIN: integer := 4;           -- extra capture cycles for latency

  signal clk  : std_logic := '0';
  signal wea  : std_logic_vector(DW/8-1 downto 0) := (others => '0');
  signal addra, addrb : std_logic_vector(AW-1 downto 0) := (others => '0');
  signal dina : std_logic_vector(DW-1 downto 0) := (others => '0');
  signal doutb: std_logic_vector(DW-1 downto 0);

  type int_array is array (natural range <>) of integer;
begin

  clk <= not clk after 1 ns;

  dut: entity xpm.xpm_memory_base
    generic map (
      MEMORY_SIZE        => DEPTH*DW,
      MEMORY_PRIMITIVE   => 1,
      CLOCKING_MODE      => 0,            -- common_clock
      WRITE_DATA_WIDTH_A => DW, READ_DATA_WIDTH_A => DW, BYTE_WRITE_WIDTH_A => 8,
      ADDR_WIDTH_A       => AW, READ_LATENCY_A => 1, WRITE_MODE_A => 1,
      WRITE_DATA_WIDTH_B => DW, READ_DATA_WIDTH_B => DW, BYTE_WRITE_WIDTH_B => 8,
      ADDR_WIDTH_B       => AW, READ_LATENCY_B => 1, WRITE_MODE_B => 1
    )
    port map (
      sleep => '0',
      clka => clk, rsta => '0', ena => '1', regcea => '1',
      wea => wea, addra => addra, dina => dina,
      injectsbiterra => '0', injectdbiterra => '0',
      douta => open, sbiterra => open, dbiterra => open,
      clkb => clk, rstb => '0', enb => '1', regceb => '1',
      web => (others => '0'), addrb => addrb, dinb => (others => '0'),
      injectsbiterrb => '0', injectdbiterrb => '0',
      doutb => doutb, sbiterrb => open, dbiterrb => open
    );

  main: process
    variable capv    : int_array(0 to N+MARGIN-1) := (others => -1);
    variable aligned : boolean;
  begin
    test_runner_setup(runner, runner_cfg);

    -- write a ramp: address a holds value a + BASE
    wea <= (others => '1');
    for a in 0 to N-1 loop
      addra <= std_logic_vector(to_unsigned(a, AW));
      dina  <= std_logic_vector(to_unsigned(a + BASE, DW));
      wait until rising_edge(clk);
    end loop;
    wea <= (others => '0');
    addra <= (others => '0');

    -- read back addresses 0..N-1 in order, capturing dout each cycle
    for c in 0 to N+MARGIN-1 loop
      if c < N then
        addrb <= std_logic_vector(to_unsigned(c, AW));
      end if;
      wait until rising_edge(clk);
      capv(c) := to_integer(unsigned(doutb));
    end loop;

    -- The intact ramp BASE..BASE+N-1 must appear as a contiguous in-order run,
    -- regardless of absolute read latency. A delta-skew shift reads one address
    -- ahead, so value BASE is never returned and this run is absent.
    aligned := false;
    for off in 0 to MARGIN loop
      aligned := true;
      for k in 0 to N-1 loop
        if capv(off+k) /= k + BASE then
          aligned := false;
        end if;
      end loop;
      exit when aligned;
    end loop;

    check(aligned, "common-clock read-back is not the intact ramp BASE..BASE+N-1 (delta-skew shift)");
    test_runner_cleanup(runner);
    wait;
  end process;

  test_runner_watchdog(runner, 100 us);
end architecture;
