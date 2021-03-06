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

-- -------------------------------------------------------------------------------------------------------------------
-- Single-bit Synchronizer
-- -------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library std;
use std.env.all;

entity xpm_cdc_sync_rst is
  generic (

    -- Common module generics
    DEST_SYNC_FF   : integer := 4;
    INIT           : integer := 1;
    INIT_SYNC_FF   : integer := 0;
    SIM_ASSERT_CHK : integer := 0

);
  port (

    src_rst  : in std_logic;
    dest_clk : in std_logic;
    dest_rst : out std_logic
);
end xpm_cdc_sync_rst;

architecture rtl of xpm_cdc_sync_rst is
  -- Define local parameter for settings
  constant DEF_VALS : std_logic_vector(1 downto 0) := "10";
  constant DEF_VAL : std_logic := DEF_VALS(INIT);
  signal syncstages_ff : std_logic_vector(DEST_SYNC_FF-1 downto 0) := (others => DEF_VAL);
  
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of syncstages_ff : signal is "TRUE";
  signal async_path_bit : std_logic;

begin

  -- -------------------------------------------------------------------------------------------------------------------
  -- Configuration DRCs
  -- -------------------------------------------------------------------------------------------------------------------
  config_drc_single: process
    variable drc_err_flag: integer := 0;
  begin
  
    if ((INIT/=0) and (INIT/=1)) then
       report("[XPM_CDC 6-3] INIT ("&integer'image(INIT)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((INIT_SYNC_FF/=0) and (INIT_SYNC_FF/=1)) then
       report("[XPM_CDC 6-5] INIT_SYNC_FF ("&integer'image(INIT_SYNC_FF)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((DEST_SYNC_FF<2) or (DEST_SYNC_FF>10)) then
       report("[XPM_CDC 6-2] DEST_SYNC_FF ("&integer'image(DEST_SYNC_FF)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;


    if ((SIM_ASSERT_CHK/=0) and (SIM_ASSERT_CHK/=1)) then
       report("[XPM_CDC 6-4] SIM_ASSERT_CHK ("&integer'image(SIM_ASSERT_CHK)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if (drc_err_flag = 1) then
       std.env.finish(1);
    end if;
    wait;
  end process config_drc_single;

  dest_rst <= syncstages_ff(DEST_SYNC_FF-1);
  async_path_bit <= src_rst;

  -- Instantiate Xilinx Synchronous Register
  process(dest_clk)
  begin
    if rising_edge(dest_clk) then
        syncstages_ff <= syncstages_ff(DEST_SYNC_FF-2 downto 0) & async_path_bit;
    end if;
  end process;
  
end architecture rtl;
