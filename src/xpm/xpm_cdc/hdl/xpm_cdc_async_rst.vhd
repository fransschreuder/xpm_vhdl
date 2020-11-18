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

entity xpm_cdc_async_rst is
  generic (

    -- Common module parameters
    DEST_SYNC_FF    : integer := 4;
    INIT_SYNC_FF    : integer := 0;
    RST_ACTIVE_HIGH : integer := 0
  );
  port (

    src_arst  : in std_logic;
    dest_clk  : in std_logic;
    dest_arst : out std_logic
  );
end xpm_cdc_async_rst;

architecture rtl of xpm_cdc_async_rst is
  ---------------------------------------------------------------------------------------------------------------------
  -- Local parameter definitions
  ---------------------------------------------------------------------------------------------------------------------
  constant DEF_VALS : std_logic_vector(1 downto 0) := "01";
  constant DEF_VAL : std_logic := DEF_VALS(RST_ACTIVE_HIGH);
  constant INV_DEF_VALS : std_logic_vector(1 downto 0) := "10";
  constant INV_DEF_VAL : std_logic := INV_DEF_VALS(RST_ACTIVE_HIGH);
  
  -- Set asynchronous register property on synchronizers and initialize register with default value
  signal arststages_ff : std_logic_vector(DEST_SYNC_FF-1 downto 0) := (others => DEF_VAL);
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of arststages_ff : signal is "TRUE";
  signal async_path_bit : std_logic;
  
  constant async_path_bit : std_logic := DEF_VALS(RST_ACTIVE_HIGH);
  signal reset_pol : std_logic;
  signal reset_polo : std_logic;
  

begin

  -- -------------------------------------------------------------------------------------------------------------------
  -- Configuration DRCs
  -- -------------------------------------------------------------------------------------------------------------------
  config_drc_single: process
    variable drc_err_flag: integer := 0;
  begin
  
    if ((DEST_SYNC_FF<2) or (DEST_SYNC_FF>10)) then
       report("[XPM_CDC 7-2] DEST_SYNC_FF ("&integer'image(DEST_SYNC_FF)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((INIT_SYNC_FF/=0) and (INIT_SYNC_FF/=1)) then
       report("[XPM_CDC 7-4] INIT_SYNC_FF ("&integer'image(INIT_SYNC_FF)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((RST_ACTIVE_HIGH /= 0) and (RST_ACTIVE_HIGH /= 1)) then
       report("[XPM_CDC 7-3] RST_ACTIVE_HIGH ("&integer'image(RST_ACTIVE_HIGH)&") value is outside of valid range.") severity error
       drc_err_flag := 1;
    end if;
    
    if (drc_err_flag = 1) then
       std.env.finish(1);
    end if;
    wait;
  end process config_drc_single;



  reset_polo <= arststages_ff(DEST_SYNC_FF-1);
  reset_pol <= src_arst xor DEF_VAL;
  dest_arst <= reset_polo;

  -- Instantiate Xilinx Asynchronous Clear Registerprocess(dest_clk)
  process(dest_clk, reset_pol)
  begin
    if reset_pol = '1' then
        arststages_ff <= (others => INV_DEF_VAL);
    elsif rising_edge(dest_clk) then
        arststages_ff <= arststages_ff(DEST_SYNC_FF-2 downto 0) & async_path_bit;
    end if;
  end process;
  
end architecture rtl;
