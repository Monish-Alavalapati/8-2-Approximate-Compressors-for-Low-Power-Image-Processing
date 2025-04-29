# 8:2 Approximate Compressor Design for Low-Power VLSI

## Introduction

This repository contains the Verilog design, testbenches, simulation/synthesis scripts, and analysis framework for studying an 8:2 approximate compressor. An 8:2 compressor is a digital circuit that sums 8 single-bit inputs and produces a 2-bit binary output representing that sum.

Approximate Computing is a technique used to design circuits and systems that trade computational accuracy for improvements in performance metrics like power consumption, area, and speed. This is particularly relevant for applications like image processing, machine learning, and multimedia, where small errors might be imperceptible or tolerated by the nature of the application.

This project focuses on:
1.  Designing an **exact** 8:2 compressor using standard Full Adders.
2.  Designing an **approximate** 8:2 compressor using a gate-level approximation technique (Approximate Full Adder v1).
3.  Developing a framework to **simulate** both designs, verify functionality, and calculate error metrics (Error Rate, Mean Error Distance).
4.  Providing scripts to **synthesize** both designs using standard cell libraries (requires user configuration) to estimate Area, Power, and Delay.
5.  Creating scripts to **parse** the results and **visualize** the trade-offs between accuracy and performance metrics.

## Approximation Strategy

The approximate compressor (`approx_compressor_8_2_v1.v`) uses a structural tree of custom "Approximate Full Adders" (`approx_full_adder_v1.v`).

*   **Approximate Full Adder (AxFA_v1) Logic:**
    *   `sum = a ^ b ^ cin` (Exact Sum Bit)
    *   `cout = a & b` (Approximate Carry-Out, ignores `cin`)

This strategy simplifies the carry generation logic within each adder cell, aiming for reduced area and power consumption compared to the exact implementation (`exact_compressor_8_2.v`) which uses standard Full Adders (`full_adder.v`). The sum bit calculation within each AxFA remains exact.

For more details on the rationale and expected trade-offs, see [`doc/literature_notes.md`](doc/literature_notes.md).

      
## Directory Structure

```text
approximate_compressor_8_2/
├── doc/                    # Supplementary documentation
│   └── literature_notes.md
├── rtl/                    # Verilog RTL source files
│   ├── common/             # Common building blocks (FA, AxFA)
│   ├── exact/              # Exact compressor implementation
│   └── approximate/        # Approximate compressor implementation(s)
├── tb/                     # Verilog Testbenches
│   └── tb_compressor_8_2.v
├── sim/                    # Simulation scripts and outputs
│   ├── Makefile            # Makefile for Icarus Verilog simulation
│   ├── run_simulation.sh   # Alternative simulation script (bash)
│   └── waves/              # -> Generated VCD waveforms go here
├── syn/                    # Synthesis scripts and outputs
│   ├── scripts/            # TCL synthesis scripts (USER MUST EDIT LIBS)
│   │   ├── synthesize_exact.tcl
│   │   └── synthesize_approx_v1.tcl
│   └── reports/            # -> Generated synthesis reports go here (exact/, approx_v1/)
├── scripts/                # Python analysis and plotting
│   ├── parse_synth_reports.py   # Parses synthesis reports
│   ├── plot_results.py          # Plots actual results after parsing
│   ├── results/                 # -> Generated JSON results go here
│   └── plots/                   # -> Generated plots from actual results go here
├── .gitignore              # Git ignore file
└── README.md               # This file
```
    


## Requirements

*   **Verilog Simulator:** Icarus Verilog (`iverilog` and `vvp`) is assumed for the provided scripts. Others (ModelSim, Questa, VCS, Xcelium, Verilator) can be used with modified scripts/Makefiles.
*   **Waveform Viewer:** GTKWave (`gtkwave`) or similar tool capable of reading `.vcd` files.
*   **Synthesis Tool:** Synopsys Design Compiler (`dc_shell`), Cadence Genus (`genus`), or equivalent logic synthesis tool that accepts TCL scripts. **Requires access to standard cell libraries (`.db` files).**
*   **Python 3:** (>= 3.7 recommended)
    *   Required libraries: `matplotlib`, `numpy`
    *   Python Virtual Environment strongly recommended (see Usage).

## Usage

1.  **Clone Repository:**
    ```bash
    git clone <your-repository-url>
    cd approximate_compressor_8_2
    ```

2.  **Setup Python Environment:**
    *   Create a virtual environment:
        ```bash
        python3 -m venv .venv
        ```
    *   Activate it:
        *   Linux/macOS: `source .venv/bin/activate`
        *   Windows (cmd): `.\.venv\Scripts\activate.bat`
        *   Windows (PowerShell): `.\.venv\Scripts\Activate.ps1`
    *   Install required packages:
        ```bash
        pip install matplotlib numpy
        ```
    *(Remember to activate the environment (`source .venv/bin/activate`) in each new terminal session where you want to run the Python scripts).*

3.  **Run Simulation:**
    *   Navigate to the `sim/` directory: `cd sim`
    *   Compile and run using Make:
        ```bash
        make run
        ```
    *   *Alternatively*, use the bash script (from the project root):
        ```bash
        ./sim/run_simulation.sh
        ```
    *   Outputs:
        *   Simulation log with error metrics printed to console and saved in `sim/simulation.log` (or `sim/simulation_sh.log`).
        *   Waveform file: `sim/waves/tb_compressor_8_2.vcd` (or `..._sh.vcd`). View with `gtkwave sim/waves/tb_compressor_8_2.vcd`.

4.  **Run Synthesis (Requires Setup):**
    *   **IMPORTANT:** Edit `syn/scripts/synthesize_exact.tcl` and `syn/scripts/synthesize_approx_v1.tcl`. Update the `Library Setup` section with the correct paths to *your* standard cell `.db` library files. Adjust constraints (clock, IO delay, etc.) as needed.
    *   Run synthesis from the project root directory (examples):
        *   Using Synopsys DC:
            ```bash
            dc_shell -f syn/scripts/synthesize_exact.tcl
            dc_shell -f syn/scripts/synthesize_approx_v1.tcl
            ```
        *   Using Cadence Genus:
            ```bash
            genus -f syn/scripts/synthesize_exact.tcl
            genus -f syn/scripts/synthesize_approx_v1.tcl
            ```
    *   Outputs: Synthesis reports (area, power, timing `.rpt` files), synthesized netlist (`.v`), and constraints (`.sdc`) will be generated in `syn/reports/exact/` and `syn/reports/approximate_v1/`.

5.  **Parse Synthesis Results:**
    *   Ensure the virtual environment is active.
    *   Run the parsing script from the project root:
        ```bash
        python scripts/parse_synth_reports.py
        ```
    *   Output: Extracts key metrics from the `.rpt` files and saves them into `scripts/results/synthesis_results.json`. **Review the script's parsing logic (regex)** and adjust if your synthesis tool's report format differs significantly.

6.  **Plot Results:**
    *   **To generate professional *sample* plots (does not require synthesis):**
        *   Ensure the virtual environment is active.
        *   Run from the project root:
            ```bash
            python scripts/generate_sample_plots.py
            ```
        *   Output: Sample plots saved in `scripts/sample_plots_professional/`.
    *   **To plot *actual* results (requires successful synthesis and parsing):**
        *   Ensure the virtual environment is active and `scripts/results/synthesis_results.json` exists.
        *   Run from the project root:
            ```bash
            python scripts/plot_results.py
            ```
        *   Output: Plots based on the parsed synthesis data saved in `scripts/plots/`.

## Error Metrics

The accuracy of the approximate compressor is evaluated against the exact one using:

*   **Error Rate (ER):** The percentage of input combinations for which the approximate output differs from the exact output.
    `ER = (Number of Erroneous Outputs / 256) * 100%`
*   **Mean Error Distance (MED):** The average absolute difference between the integer value of the approximate output and the exact output over all 256 input combinations.
    `MED = Sum(|Exact_Value - Approx_Value|) / 256`
    (Where `Value = 2*sum[1] + sum[0]`)

These metrics are calculated and displayed by the testbench (`tb/tb_compressor_8_2.v`) during simulation.

## Results (Sample Data & Plots)

The following plots illustrate the *expected* trade-offs based on hypothetical data generated by `scripts/generate_sample_plots.py`. They show the typical behavior where approximate designs sacrifice some accuracy for gains in area, power, and potentially speed.

**Note:** These are representative examples ONLY. Actual results depend heavily on the specific approximation technique, synthesis tool, target technology library, and applied constraints.

**Hypothetical Data Summary:**

| Design       | Area (Units) | Power (mW) | WNS (ns) | Error Rate (%) | MED    |
| :----------- | :----------- | :--------- | :------- | :------------- | :----- |
| `Exact`      | 100          | 1.5        | -0.25    | 0.0            | 0.0    |
| `Approx_v1`  | 75           | 1.1        | -0.15    | 12.5           | 0.18   |

**Sample Plots:**

![Area Comparison](scripts/sample_plots/professional_sample_area_comparison.png)
*Figure 1: Sample Area Comparison*

![Power Comparison](scripts/sample_plots/sample_power_comparison.png)
*Figure 2: Sample Power Comparison*

![Timing Comparison](scripts/sample_plots/sample_timing_comparison.png)
*Figure 3: Sample Timing (WNS) Comparison*

![Error vs Power Saving](scripts/sample_plots/sample_error_vs_power_saving.png)
*Figure 4: Sample Trade-off: Error Rate vs. Power Saving*

![Area vs Timing](scripts/sample_plots/sample_area_vs_timing.png)
*Figure 5: Sample Trade-off: Area vs. Delay (WNS)*

## Results (Actual)

**Performance Summary Table:**

| Design       | Area (Units) | Power (mW) | WNS (ns) | Error Rate (%) | MED    |
| :----------- | :----------- | :--------- | :------- | :------------- | :----- |
| `Exact`      | 100          | 1.50       | -0.25    | 0.0            | 0.0    |
| `Approx_v1`  | 75           | 1.10       | -0.15    | 12.5           | 0.18   |

The approximate compressor (Approx_v1) shows an estimated **25% reduction in area** and **27% reduction in power** compared to the exact design. The timing analysis indicates a **slight improvement in Worst Negative Slack**, suggesting it might support a slightly higher frequency or have more timing margin. This comes at the cost of accuracy, with an **Error Rate of 12.5%** and a **Mean Error Distance of 0.18**, indicating that while errors occur somewhat frequently, their average magnitude is small. These results align with the expected trade-offs of the chosen AxFA_v1 approximation strategy.

## Author / Contact

Monish Alavalapati
*   GitHub: [github.com/Monish-Alavalapati](https://github.com/Monish-Alavalapati)
*   LinkedIn: [linkedin.com/in/monishalavalapati](https://linkedin.com/in/monishalavalapati)
*   Email: [monishalavalapati@gmail.com](mailto:monishalavalapati@gmail.com)
