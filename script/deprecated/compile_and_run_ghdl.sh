#!/bin/bash
export XPM_TOP_DIR=$( dirname "${BASH_SOURCE[0]}" )/..
echo $XPM_TOP_DIR

ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_VCOMP.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_single.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_array_single.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_async_rst.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_gray.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_handshake.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_low_latency_handshake.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_pulse.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_sync_rst.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_base.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_dpdistram.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_dprom.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_sdpram.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_spram.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_sprom.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_tdpram.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_rst.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_reg_bit.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_counter_updn.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_reg_vec.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_reg_pipe_bit.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_base.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_async.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axi_reg_slice.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axif.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axil.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axis.vhd
ghdl -a --work=xpm --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_sync.vhd
ghdl -a --work=work --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/simulation/xpm_fifo_gen_rng.vhd
ghdl -a --work=work --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/simulation/xpm_fifo_gen_dgen.vhd
ghdl -a --work=work --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/simulation/xpm_fifo_gen_dverif.vhd
ghdl -a --work=work --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/simulation/xpm_fifo_gen_pctrl.vhd
ghdl -a --work=work --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/simulation/xpm_fifo_ex.vhd
ghdl -a --work=work --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/simulation/xpm_fifo_tb.vhd
ghdl -a --work=work --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/simulation/xpm_fifo_axis_tb.vhd
ghdl -e --work=work --std=08 xpm_fifo_tb
ghdl -e --work=work --std=08 xpm_fifo_axis_tb
ghdl -r --work=work --std=08 xpm_fifo_tb --max-stack-alloc=0 --ieee-asserts=disable-at-0 --wave=xpm_fifo_tb.ghw
ghdl -r --work=work --std=08 xpm_fifo_axis_tb --max-stack-alloc=0 --ieee-asserts=disable --wave=xpm_fifo_axis_tb.ghw
if xhost >& /dev/null ; then 
    gtkwave xpm_fifo_tb.ghw
    gtkwave xpm_fifo_axis_tb.ghw
else 
    echo "Display invalid" 
fi


