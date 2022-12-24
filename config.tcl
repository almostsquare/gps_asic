# User config
set ::env(DESIGN_NAME) channel

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

# Recommendations to run faster
set ::env(ROUTING_CORES) 4
set ::env(RUN_KLAYOUT_XOR) 0
set ::env(RUN_KLAYOUT_DRC) 0

# Fixes for when the design is too small
set ::env(PL_TARGET_DENSITY) 0.56
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 200 200"

# Attempt to fix missing $_ALDFF_PP_ primitive
# workaround from https://github.com/The-OpenROAD-Project/OpenLane/issues/1070
set ::env(SYNTH_EXTRA_MAPPING_FILE) $::env(DESIGN_DIR)/yosys_mapping.v