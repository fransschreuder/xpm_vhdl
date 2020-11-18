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

entity xpm_cdc_gray is
  generic (

    -- Common module generics
    DEST_SYNC_FF          : integer := 4;
    INIT_SYNC_FF          : integer := 0;
    REG_OUTPUT            : integer := 0;
    SIM_ASSERT_CHK        : integer := 0;
    SIM_LOSSLESS_GRAY_CHK : integer := 0;
    WIDTH                 : integer := 2
  );
  port (

    src_clk      : in std_logic;
    src_in_bin   : in std_logic_vector(WIDTH-1 downto 0);
    dest_clk     : in std_logic;
    dest_out_bin : out std_logic_vector(WIDTH-1 downto 0)
  );
end xpm_cdc_gray;

architecture rtl of xpm_cdc_gray is

  -- Set Asynchronous Register property on synchronizers
  type reg_type is array(DEST_SYNC_FF-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
  signal dest_graysync_ff : reg_type := (others => (others => '0'));
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of dest_graysync_ff : signal is "TRUE";

  signal  gray_enc        : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal  binval          : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal  src_gray_ff     : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal  synco_gray      : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal  async_path      : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
  signal  dest_out_bin_ff : std_logic_vector(WIDTH-1 downto 0) := (others => '0');


begin

  -- -------------------------------------------------------------------------------------------------------------------
  -- Configuration DRCs
  -- -------------------------------------------------------------------------------------------------------------------
  config_drc_single: process
    variable drc_err_flag: integer := 0;
  begin
    
    if ((DEST_SYNC_FF < 2) or (DEST_SYNC_FF > 10)) then
       report("[XPM_CDC 1-2] DEST_SYNC_FF ("&integer'image(DEST_SYNC_FF)&") value is outside of valid range of 2-10.") severity error;
       drc_err_flag := 1;
    end if;

    if ((INIT_SYNC_FF/=0) and (INIT_SYNC_FF/=1)) then
       report("[XPM_CDC 1-5] INIT_SYNC_FF ("&integer'image(INIT_SYNC_FF)&") is outside of valid range." ) severity error;
       drc_err_flag := 1;
    end if;
    
    if ((REG_OUTPUT/=0) and (REG_OUTPUT/=1)) then
       report("[XPM_CDC 2-6] REG_OUTPUT ("&integer'image(REG_OUTPUT)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((SIM_ASSERT_CHK/=0) and (SIM_ASSERT_CHK/=1)) then
       report("[XPM_CDC 1-4] SIM_ASSERT_CHK ("&integer'image(SIM_ASSERT_CHK)&") value is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;
    
    if (SIM_LOSSLESS_GRAY_CHK>1) then
       report("[XPM_CDC 2-5] SIM_LOSSLESS_GRAY_CHK ("&integer'image(SIM_LOSSLESS_GRAY_CHK)&") is outside of valid range.") severity error;
       drc_err_flag := 1;
    end if;

    if ((WIDTH < 2) or (WIDTH > 32)) then
       report("[XPM_CDC 2-3] WIDTH ("&integer'image(WIDTH)&") is outside of valid range of 2-32.") severity error;
       drc_err_flag := 1;
    end if;


    if (drc_err_flag = 1) then
      std.env.finish(1);
    end if;
    wait;
  end process config_drc_single;

  process(dest_clk)
  begin
    if rising_edge(dest_clk) then
      dest_graysync_ff(0) <= async_path;
    end if;
    for syncstage in 1 to DEST_SYNC_FF-1 loop
      dest_graysync_ff(syncstage) <= dest_graysync_ff (syncstage-1);
    end loop;
  end process;
  
  async_path <= src_gray_ff;

  synco_gray <= dest_graysync_ff(DEST_SYNC_FF-1);
  gray_enc <= src_in_bin xor ("0" & src_in_bin(WIDTH-1 downto 1));

  -- Convert gray code back to binary
  process(synco_gray, binval)
  begin
    binval(WIDTH-1) <= synco_gray(WIDTH-1);
    for j in WIDTH-2 downto 0 loop
      binval(j) <= binval(j+1) xor synco_gray(j);
    end loop;
  end process;
  
  reg_out: if(REG_OUTPUT = 1) generate
    dest_out_bin     <= dest_out_bin_ff;
  end generate;
  comb_out: if(REG_OUTPUT /= 1) generate
    dest_out_bin     <= binval;
  end generate;
  

  process(src_clk)
  begin
    if rising_edge(src_clk) then
        src_gray_ff <= gray_enc;
    end if;
  end process;
  
  process(dest_clk)
  begin
    if rising_edge(dest_clk) then
        dest_out_bin_ff <= binval;
    end if;
  end process;

end architecture rtl;
