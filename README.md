# XPM library in VHDL

## Introduction

Xilinx has provided a very convenient library with Vivado called XPM. The library contains components for FIFO, RAM and CDC primitives. The problem with the Xilinx XPM library is that it was written in Verilog only. Some simulators (Like GHDL) are not able to do a cosimulation with Verilog, so the xpm library can not be used. For this reason, the XPM library has been translated into VHDL in this repository.

The XPM VHDL library needs to be compiled with the VHDL-2008 standard.

## Compilation (GHDL/Vunit)

In order to compile the library and run the testbench, a script was included.

Dependencies:
* GHDL
* GtkWave
* VUnit
* Python3

```
cd script
./run_vunit.py
```

## Synthesis

This library can probably be synthesized, however the intention is to use it with simulation only. If synthesis is needed, I recommend to use the original xpm library in Verilog that Xilinx provided.

## Disclaimer

This library was not created by Xilinx, but it should be functionally the same or similar to the Xilinx XPM library.

This library has not completely been verified, if you find any bugs or limitations please report using the bug trackers.

Known limitations:
 * ECC mode and bit error injection is not implemented
