#-------------------------------------------------------------------------------
# Makefile     : Simulation Makefile
# Project      : 8:2 Approximate Compressor Study
# Author       : Monish Alavalapati
# Description  : Compiles and runs the testbench using Icarus Verilog.
#-------------------------------------------------------------------------------

# Tools
VERILOG_COMPILER = iverilog
SIMULATOR = vvp
WAVEFORM_VIEWER = gtkwave

# Source Files
RTL_COMMON_DIR = ../rtl/common
RTL_EXACT_DIR = ../rtl/exact
RTL_APPROX_DIR = ../rtl/approximate
TB_DIR = ../tb

# Include common modules first
VERILOG_SOURCES = $(RTL_COMMON_DIR)/full_adder.v \
                  $(RTL_COMMON_DIR)/approx_full_adder_v1.v \
                  $(RTL_EXACT_DIR)/exact_compressor_8_2.v \
                  $(RTL_APPROX_DIR)/approx_compressor_8_2_v1.v \
                  $(TB_DIR)/tb_compressor_8_2.v

# Output files
SIM_EXECUTABLE = compressor_tb
WAVEFORM_FILE = waves/tb_compressor_8_2.vcd
SIM_LOG = simulation.log

# Targets
.PHONY: all compile run wave clean directories

all: run

directories:
	@mkdir -p waves

compile: directories $(VERILOG_SOURCES)
	@echo "Compiling Verilog sources..."
	$(VERILOG_COMPILER) -o $(SIM_EXECUTABLE) $(VERILOG_SOURCES)

run: compile
	@echo "Running simulation..."
	$(SIMULATOR) $(SIM_EXECUTABLE) | tee $(SIM_LOG)
	@echo "Simulation finished. Log saved to $(SIM_LOG)"
	@echo "Waveform saved to $(WAVEFORM_FILE)"

wave: $(WAVEFORM_FILE)
	@echo "Opening waveform viewer..."
	$(WAVEFORM_VIEWER) $(WAVEFORM_FILE) &

clean:
	@echo "Cleaning up simulation files..."
	rm -f $(SIM_EXECUTABLE) $(SIM_LOG)
	rm -rf waves/
	rm -f iverilog.log transcript *.key *.log *.wlf

# Placeholder for waveform file if needed by 'wave' target even if run failed
$(WAVEFORM_FILE):
