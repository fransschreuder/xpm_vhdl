#!/bin/bash
export XPM_TOP_DIR=$( dirname "${BASH_SOURCE[0]}" )/..
echo $XPM_TOP_DIR
export XPM_LIB_WORK_DIR=$( dirname `which vivado` )/../data/vhdl/ghdl/xilinx-vivado/xpm/v08
echo $XPM_LIB_WORK_DIR

mkdir -p $XPM_LIB_WORK_DIR

echo "Compiling xpm library (directory is ${XPM_LIB_WORK_DIR})"
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_VCOMP.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_single.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_array_single.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_async_rst.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_gray.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_handshake.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_low_latency_handshake.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_pulse.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_cdc/hdl/xpm_cdc_sync_rst.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_base.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_dpdistram.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_dprom.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_sdpram.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_spram.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_sprom.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_memory/hdl/xpm_memory_tdpram.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_rst.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_reg_bit.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_counter_updn.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_reg_vec.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_reg_pipe_bit.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_base.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_async.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axi_reg_slice.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axif.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axil.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_axis.vhd
ghdl -a --work=xpm --workdir=${XPM_LIB_WORK_DIR} --std=08 ${XPM_TOP_DIR}/src/xpm/xpm_fifo/hdl/xpm_fifo_sync.vhd
