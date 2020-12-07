#!/usr/bin/python
from vunit import VUnit
from os.path import join, dirname

prj = VUnit.from_argv()
root = dirname(__file__)

xpm_lib = prj.add_library('xpm')
xpm_lib.add_source_files(join(root, '../src/xpm', '*.vhd'))
xpm_lib.add_source_files(join(root, '../src/xpm/xpm_cdc/hdl', '*.vhd'))
xpm_lib.add_source_files(join(root, '../src/xpm/xpm_memory/hdl', '*.vhd'))
xpm_lib.add_source_files(join(root, '../src/xpm/xpm_fifo/hdl', '*.vhd'))

work_lib = prj.add_library('work_lib')
work_lib.add_source_files(join(root, '../src/xpm/xpm_fifo/simulation', '*.vhd'))
work_lib.set_sim_option("disable_ieee_warnings", True)
work_lib.set_sim_option("ghdl.sim_flags", ["--max-stack-alloc=0"])


prj.main()
