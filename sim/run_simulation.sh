#!/bin/bash
#-------------------------------------------------------------------------------
# Shell Script : run_simulation.sh
# Project      : 8:2 Approximate Compressor Study
# Author       : Monish Alavalapati
# Description  : Compiles and runs the testbench using Icarus Verilog.
#                Alternative to using the Makefile.
#-------------------------------------------------------------------------------

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
VERILOG_COMPILER="iverilog"
SIMULATOR="vvp"
SIM_EXECUTABLE="compressor_tb_sh" # Use a different name than Makefile's output
WAVEFORM_DIR="waves"
WAVEFORM_FILE="$WAVEFORM_DIR/tb_compressor_8_2_sh.vcd"
SIM_LOG="simulation_sh.log"

# RTL and Testbench Source Files (relative paths from sim/ directory)
RTL_COMMON_DIR="../rtl/common"
RTL_EXACT_DIR="../rtl/exact"
RTL_APPROX_DIR="../rtl/approximate"
TB_DIR="../tb"

# Ensure common modules are listed first if they contain primitives/includes
VERILOG_SOURCES=(
    "$RTL_COMMON_DIR/full_adder.v"
    "$RTL_COMMON_DIR/approx_full_adder_v1.v"
    "$RTL_EXACT_DIR/exact_compressor_8_2.v"
    "$RTL_APPROX_DIR/approx_compressor_8_2_v1.v"
    "$TB_DIR/tb_compressor_8_2.v"
)

# --- Script Execution ---

echo "Starting Simulation Script..."

# Create waves directory if it doesn't exist
echo "Ensuring waveform directory exists: $WAVEFORM_DIR"
mkdir -p "$WAVEFORM_DIR"

# Compile Verilog sources
echo "Compiling Verilog sources..."
"$VERILOG_COMPILER" -o "$SIM_EXECUTABLE" "${VERILOG_SOURCES[@]}" # Pass array of sources

# Run simulation
echo "Running simulation..."
# Use 'script' command or process substitution to capture output and display simultaneously
# Simpler: Use tee to save to log and print to stdout
"$SIMULATOR" "$SIM_EXECUTABLE" | tee "$SIM_LOG"

echo "--------------------------------------"
echo "Simulation finished."
echo "Log saved to: $SIM_LOG"
echo "Waveform saved to: $WAVEFORM_FILE"
echo "--------------------------------------"

# Optional: Automatically open waveform viewer if available
# if command -v gtkwave &> /dev/null; then
#     echo "Opening waveform viewer..."
#     gtkwave "$WAVEFORM_FILE" &
# fi

exit 0
