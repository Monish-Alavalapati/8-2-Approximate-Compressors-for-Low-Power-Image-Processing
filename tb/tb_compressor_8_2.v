//-----------------------------------------------------------------------------
// File         : tb_compressor_8_2.v
// Project      : 8:2 Approximate Compressor Study
// Author       : Monish Alavalapati
// Description  : Testbench for comparing exact and approximate (v1) 8:2
//                compressors. Iterates through all 2^8 input patterns,
//                calculates error metrics (ER, MED), and generates VCD.
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

// Include DUT definitions (paths relative to simulation execution dir, e.g., 'sim/')
`include "../rtl/exact/exact_compressor_8_2.v"
`include "../rtl/approximate/approx_compressor_8_2_v1.v"
`include "../rtl/common/full_adder.v" // Included by exact_compressor
`include "../rtl/common/approx_full_adder_v1.v" // Included by approx_compressor

module tb_compressor_8_2;

    // Parameters
    localparam DURATION = 10; // Clock cycle duration

    // Testbench Signals
    reg clk = 0;
    reg [7:0] test_vector;
    wire [1:0] exact_sum;
    wire [1:0] approx_sum_v1;

    // Error calculation variables
    integer error_count = 0;
    integer total_abs_error_distance = 0;
    integer i;
    integer exact_val, approx_val_v1, error_val;

    // Instantiate DUTs
    exact_compressor_8_2 dut_exact (
        .in(test_vector),
        .sum(exact_sum)
    );

    approx_compressor_8_2_v1 dut_approx_v1 (
        .in(test_vector),
        .sum(approx_sum_v1)
    );

    // Clock generator
    always #(DURATION/2) clk = ~clk;

    // Test sequence
    initial begin
        $display("Starting 8:2 Compressor Testbench...");
        $display("Comparing Exact vs Approximate_v1");

        // Setup VCD dump
        $dumpfile("waves/tb_compressor_8_2.vcd");
        $dumpvars(0, tb_compressor_8_2); // Dump all signals in the testbench scope

        test_vector = 8'b0;
        error_count = 0;
        total_abs_error_distance = 0;

        // Loop through all 256 input combinations
        for (i = 0; i < 256; i = i + 1) begin
            test_vector = i;
            #DURATION; // Wait one clock cycle for outputs to settle

            // Calculate integer values
            exact_val = exact_sum[0] + 2*exact_sum[1];
            approx_val_v1 = approx_sum_v1[0] + 2*approx_sum_v1[1];
            error_val = exact_val - approx_val_v1;

            // Check for error
            if (exact_sum !== approx_sum_v1) begin
                error_count = error_count + 1;
                total_abs_error_distance = total_abs_error_distance + abs(error_val);
                $display("Input: %b | Exact: %d (%b) | Approx_v1: %d (%b) | Error: %d",
                         test_vector, exact_val, exact_sum, approx_val_v1, approx_sum_v1, error_val);
            end
        end

        // Calculate final metrics
        $display("\nSimulation Complete.");
        $display("Total Input Vectors: 256");
        $display("--------------------------------------");
        $display("Error Metrics (Approximate_v1 vs Exact):");
        $display("--------------------------------------");
        $display("Total Error Count: %d", error_count);
        if (error_count > 0) begin
            $display("Error Rate (ER): %f %%", (real(error_count) / 256.0) * 100.0);
            $display("Mean Error Distance (MED): %f", real(total_abs_error_distance) / 256.0);
            // Note: MED per error = real(total_abs_error_distance) / real(error_count)
        end else begin
             $display("Error Rate (ER): 0.0 %%");
             $display("Mean Error Distance (MED): 0.0");
        end
        $display("--------------------------------------");

        $finish;
    end

    // Helper function for absolute value
    function integer abs (input integer x);
        if (x < 0)
            return -x;
        else
            return x;
    endfunction

endmodule
