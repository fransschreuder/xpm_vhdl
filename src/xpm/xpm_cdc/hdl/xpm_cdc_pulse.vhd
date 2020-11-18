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

entity xpm_cdc_pulse is
  generic (
    -- Common module generics
    DEST_SYNC_FF   : integer := 4;
    INIT_SYNC_FF   : integer := 0;
    REG_OUTPUT     : integer := 0;
    RST_USED       : integer := 1;
    SIM_ASSERT_CHK : integer := 0

  );
  port (
    src_clk    : in std_logic;
    src_rst    : in std_logic;
    src_pulse  : in std_logic;
    dest_clk   : in std_logic;
    dest_rst   : in std_logic;
    dest_pulse : out std_logic
  );
end xpm_cdc_pulse;

architecture rtl of xpm_cdc_pulse is
  -- If toggle flop is not initialized,then it can be un-known forever.
  -- It is assumed that there is no loss of coverage either way.
  -- For edge detect, we would want the logic to be more controlled.
  signal src_level_ff : std_logic := '0';
  
  signal src_in_ff : std_logic;
  signal src_level_nxt : std_logic;
  signal src_edge_det : std_logic;
  signal src_sync_in : std_logic;
  
  signal dest_sync_out : std_logic;
  signal dest_event_nxt : std_logic;
  signal dest_event_ff : std_logic;
  signal dest_sync_qual : std_logic;
  
  signal src_rst_qual : std_logic;
  signal dest_rst_qual : std_logic;
  
  signal dest_pulse_int : std_logic;
  signal dest_pulse_ff : std_logic;
  --attribute ASYNC_REG : string;
  --attribute ASYNC_REG of dest_hsdata_ff : signal is "TRUE";

begin

  -- -------------------------------------------------------------------------------------------------------------------
  -- Configuration DRCs
  -- -------------------------------------------------------------------------------------------------------------------
  config_drc_single: process
    variable drc_err_flag: integer := 0;
  begin

    if ((DEST_SYNC_FF < 2) or (DEST_SYNC_FF > 10)) then
       report("[XPM_CDC 4-2] DEST_SYNC_FF ("&integer'image(DEST_SYNC_FF)&") is outside of valid range of 2-10.") severity error;
       drc_err_flag := 1;
    end if;

    if ((INIT_SYNC_FF/=0) and (INIT_SYNC_FF/=1)) then
       report("[XPM_CDC 4-6] INIT_SYNC_FF ("&integer'image(INIT_SYNC_FF)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((REG_OUTPUT /= 0) and (REG_OUTPUT /= 1)) then
       report("[XPM_CDC 4-5] REG_OUTPUT ("&integer'image(REG_OUTPUT)&") value is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((RST_USED /= 0) and (RST_USED /= 1)) then
       report("[XPM_CDC 4-3] RST_USED ("&integer'image(RST_USED)&") value is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((SIM_ASSERT_CHK/=0) and (SIM_ASSERT_CHK/=1)) then
       report("[XPM_CDC 4-4] SIM_ASSERT_CHK ("&integer'image(SIM_ASSERT_CHK)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if (drc_err_flag = 1) then
       std.env.finish(1);
    end if;
    wait;
  end process config_drc_single;

  --Assignments
  src_edge_det   <= src_pulse and (not src_in_ff);
  src_level_nxt  <= src_level_ff xor src_edge_det;
  src_sync_in    <= src_level_ff;
  dest_event_nxt <= dest_sync_qual;
  dest_pulse_int <= dest_sync_qual xor dest_event_ff;
  dest_sync_qual <= dest_sync_out and (not dest_rst_qual);

  
  use_rst : if(RST_USED = 1) generate
    src_rst_qual <= src_rst;
    dest_rst_qual <= dest_rst;
  end generate use_rst;
  no_rst : if(RST_USED /= 1) generate 
    src_rst_qual <= '0';
    dest_rst_qual <= '0';
  end generate no_rst;
  
  reg_out : if(REG_OUTPUT = 1) generate
    dest_pulse     <= dest_pulse_ff;
  end generate reg_out;
  comb_out : if(REG_OUTPUT /= 1) generate
    dest_pulse     <= dest_pulse_int;
  end generate comb_out;
  

  xpm_cdc_single_inst: entity work.xpm_cdc_single 
  generic map (
    DEST_SYNC_FF   => DEST_SYNC_FF,
    INIT_SYNC_FF   => INIT_SYNC_FF,
    SRC_INPUT_REG  => 0           
  )  
  port map(
    src_clk       => src_clk      ,
    dest_clk      => dest_clk     ,
    src_in        => src_sync_in  ,
    dest_out      => dest_sync_out
  );

  process(src_clk, src_rst_qual)
  begin
    if src_rst_qual = '1' then
        src_in_ff <= '0';
        src_level_ff <= '0';
    elsif rising_edge(src_clk) then
        src_in_ff <= src_pulse;
        src_level_ff <= src_level_nxt;
    end if;
  end process;
  
  process(dest_clk, dest_rst_qual)
  begin
    if dest_rst_qual = '1' then
        dest_event_ff <= '0';
        dest_pulse_ff <= '0';
    elsif rising_edge(dest_clk) then
        dest_event_ff <= dest_event_nxt;
        dest_pulse_ff <= dest_pulse_int;
    end if;
  end process;

end architecture rtl;
