#-------------------------------------------------------------------------------
# TCL Script   : synthesize_approx_v1.tcl
# Project      : 8:2 Approximate Compressor Study
# Author       : Monish Alavalapati
# Description  : Example Synthesis Script for Approximate (v1) 8:2 Compressor
#                (Synopsys DC).
#                ** REQUIRES USER MODIFICATION FOR LIBRARIES AND CONSTRAINTS **
#-------------------------------------------------------------------------------

# --- Design Setup ---
set DESIGN_NAME "approx_compressor_8_2_v1" # Changed design name
set RTL_DIR "../../rtl"
set REPORT_DIR "../reports/approximate_v1" # Changed report directory
set RESULTS_DIR "../results/approximate_v1" # Optional for saving intermediate files

# --- Library Setup (!! USER MUST EDIT THESE !!) ---
# Define paths to your technology libraries (.db files)
set TARGET_LIBRARY_FILES { your_std_cell_library.db your_io_library.db }
set LINK_LIBRARY_FILES   {* $TARGET_LIBRARY_FILES your_design_specific_libs.db}
set SYMBOL_LIBRARY_FILES { your_symbol_library.sdb } # Optional for schematic viewer

set search_path ". $RTL_DIR/common $RTL_DIR/approximate /path/to/your/libraries $search_path" # Updated RTL search path if needed
set target_library $TARGET_LIBRARY_FILES
set link_library $LINK_LIBRARY_FILES
# set symbol_library $SYMBOL_LIBRARY_FILES # Uncomment if you have symbol libraries

# Create report/results directories
exec mkdir -p $REPORT_DIR
# exec mkdir -p $RESULTS_DIR

# --- Read RTL Files ---
# Analyze common blocks first, then the specific approximate DUT
analyze -format verilog "$RTL_DIR/common/approx_full_adder_v1.v" # Analyze the approx FA
analyze -format verilog "$RTL_DIR/approximate/$DESIGN_NAME.v"     # Analyze the approx compressor
elaborate $DESIGN_NAME

# --- Constraints (!! USER SHOULD ADJUST THESE !!) ---
# Use the SAME constraints as the exact design for a fair comparison
set CLK_PERIOD 10.0
create_clock -name "virtual_clk" -period $CLK_PERIOD

set IO_DELAY [expr 0.2 * $CLK_PERIOD]
set_input_delay $IO_DELAY -clock "virtual_clk" [all_inputs]
set_output_delay $IO_DELAY -clock "virtual_clk" [all_outputs]

# Operating Conditions (Example - use corners provided by your library)
# set_operating_conditions -max "worst_case_corner" -min "best_case_corner"

# Wire Load Model (Select appropriate model from your library)
# set_wire_load_model -name "your_wire_load_model"

# Driving Cell / Output Load (Example)
# set_driving_cell -lib_cell "your_driver_cell" [all_inputs]
# set_load [expr [load_of "your_lib/your_load_cell/A"] * 4] [all_outputs]

# --- Synthesis ---
# Set optimization goals (e.g., optimize for delay then power)
# current_design $DESIGN_NAME
# set_max_delay ... # Add specific path constraints if needed

# Perform Synthesis
compile_ultra -incremental -no_autoungroup # Use compile_ultra for better optimization

# --- Reporting ---
echo "Generating reports in $REPORT_DIR for $DESIGN_NAME"
report_timing -path full -delay max -max_paths 50 > "$REPORT_DIR/${DESIGN_NAME}_timing.rpt"
report_area -hierarchy > "$REPORT_DIR/${DESIGN_NAME}_area.rpt"
report_power -hierarchy > "$REPORT_DIR/${DESIGN_NAME}_power.rpt"
report_constraints -all_violators > "$REPORT_DIR/${DESIGN_NAME}_constraints.rpt"
report_qor > "$REPORT_DIR/${DESIGN_NAME}_qor.rpt"

# --- Save Synthesized Design ---
# Save netlist
write -format verilog -hierarchy -output "$REPORT_DIR/${DESIGN_NAME}_netlist.v"
# Save constraints
write_sdc "$REPORT_DIR/${DESIGN_NAME}.sdc"
# Save design database (optional)
# write -format ddc -hierarchy -output "$RESULTS_DIR/${DESIGN_NAME}.ddc"

echo "Synthesis complete for $DESIGN_NAME."
quit
