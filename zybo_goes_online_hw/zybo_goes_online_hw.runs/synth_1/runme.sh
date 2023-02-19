#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/media/alex/Transcend/Xilinx/Vitis/2019.2/bin:/media/alex/Transcend/Xilinx/Vivado/2019.2/ids_lite/ISE/bin/lin64:/media/alex/Transcend/Xilinx/Vivado/2019.2/bin
else
  PATH=/media/alex/Transcend/Xilinx/Vitis/2019.2/bin:/media/alex/Transcend/Xilinx/Vivado/2019.2/ids_lite/ISE/bin/lin64:/media/alex/Transcend/Xilinx/Vivado/2019.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/alex/github_repos/zybo_petalinux/zybo_goes_online_hw/zybo_goes_online_hw.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log design_1_wrapper.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source design_1_wrapper.tcl
