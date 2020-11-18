--------------------------------------------------------------------------------
--  (c) Copyright 2015 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES.
--------------------------------------------------------------------------------

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
