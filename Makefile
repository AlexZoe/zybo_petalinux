#-------------------------------------------------------------------------------
#
#  @author	Alexander Zoellner
#  @date	2019/07/21
#  @mail	zoellner.contact<at>gmail.com
#  @file	Makefile-vivado
#
#  brief	Makefile template for building IP core and system (bitstream).
#
#-------------------------------------------------------------------------------

# Project name of the Vivado system (same as 'MODULE' name used in tcl)
PROJECT			:= zybo_goes_online_hw
# Path to Vivado environment source script (located in the installation folder
# and usually named settings64.sh)
# Alternatively, source the environment before using the Makefile
XLNX_TOOL_CHAIN	:= /opt/Xilinx/Vivado/2019.2/settings64.sh
SHELL			:= /bin/bash

# Directory to be packed as IP core
SCRIPT_DIR		:= tcl
BUILD_DIR		:= .

# Check if a Vivado toolchain is already available, otherwise use default
ifdef XILINX_VIVADO
ENV_CMD :=
else
ENV_CMD := source $(XLNX_TOOL_CHAIN) &&
endif

.PHONY: system
.DEFAULT_GOAL := system

# Build system and generate bitstream
system:
	@$(ENV_CMD) \
	vivado -mode batch -source $(SCRIPT_DIR)/project.tcl

# Remove Vivado output files
clean:
	rm -rf $(BUILD_DIR)/$(PROJECT)
	rm -rf vivado*.log
	rm -rf vivado*.jou
	rm -rf .Xil
	rm -rf *.str
