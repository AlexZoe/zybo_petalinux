#-------------------------------------------------------------------------------
#
# @author		Alexander Zoellner
# @date			2019/06/20
# @mail			zoellner.contact<at>gmail.com
# @file			project.tcl
#
# @brief		Creates a new vivado project from scratch.
#
#				Create new vivado project and instantiates required components.
#
#-------------------------------------------------------------------------------

# Source and variable definitions and
source tcl/settings.tcl

######################### Basic project part ############################

# Use -in_memory if you only want to generate the bitstream and do not want to
# edit the project afterwards
#create_project ${MODULE} -in_memory -part ${CHIP}
# Omit -in_memory if you want to keep the project for further editing
create_project -force ${outputDir}/${MODULE} -part ${CHIP} ${MODULE}

# Set the board pre-sets
set_property board_part ${BOARD} [current_project]

# Create design name
create_bd_design ${MODULE}
update_compile_order -fileset sources_1
# Instantiate ARM cores (PS) (only for SoCs)
startgroup
	create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 \
		processing_system7_0
endgroup

# Let Vivado wizard connect basic peripherals
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
	-config {make_external "FIXED_IO, DDR" \
		apply_board_preset "1" \
		Master "Disable" \
		Slave "Disable" } \
	[get_bd_cells processing_system7_0]

# No peripherals used, connect GP0 clock with FCLK
connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]

save_bd_design

# Check if the block design does not contain errors
validate_bd_design

# Add system wrapper file for the current block design
make_wrapper -files [get_files ${MODULE}/${MODULE}.srcs/sources_1/bd/${MODULE}/${MODULE}.bd] -top
# Add all files
add_files -norecurse ${MODULE}/${MODULE}.srcs/sources_1/bd/${MODULE}/hdl/${MODULE}_wrapper.v

# Synthesis run
reset_run synth_1

# Implementation run (routing/mapping) and bitstream generation
launch_runs impl_1 -to_step write_bitstream -jobs 2

# Wait until the run has finished
wait_on_run impl_1

# Export hardware
write_hw_platform -fixed -force  -include_bit -file zybo_goes_online_hw/design_1_wrapper.xsa
