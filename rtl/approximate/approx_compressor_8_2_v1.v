//-----------------------------------------------------------------------------
// File         : approx_compressor_8_2_v1.v
// Project      : 8:2 Approximate Compressor Study
// Author       : Monish Alavalapati
// Description  : Approximate 8:2 Compressor (Version 1) using a structural
//                tree of approximate Full Adders (AxFA_v1).
//-----------------------------------------------------------------------------
`include "../common/approx_full_adder_v1.v" // Adjust path if needed

module approx_compressor_8_2_v1 (
    input  wire [7:0] in,
    output wire [1:0] sum // sum[0] = Approx Sum, sum[1] = Approx Carry
);

    // Internal wires - same structure as exact compressor
    wire s1_0, c1_0, s1_1, c1_1, s1_2, c1_2;
    wire s2_0, c2_0, s2_1, c2_1;
    wire s3_0, c3_0;

    // Stage 1: Use approximate FAs
    approx_full_adder_v1 axfa_1_0 ( .a(in[0]), .b(in[1]), .cin(in[2]), .sum(s1_0), .cout(c1_0) );
    approx_full_adder_v1 axfa_1_1 ( .a(in[3]), .b(in[4]), .cin(in[5]), .sum(s1_1), .cout(c1_1) );
    approx_full_adder_v1 axfa_1_2 ( .a(in[6]), .b(in[7]), .cin(1'b0),  .sum(s1_2), .cout(c1_2) );

    // Stage 2: Use approximate FAs
    approx_full_adder_v1 axfa_2_0 ( .a(s1_0), .b(s1_1), .cin(s1_2), .sum(s2_0), .cout(c2_0) );
    approx_full_adder_v1 axfa_2_1 ( .a(c1_0), .b(c1_1), .cin(c1_2), .sum(s2_1), .cout(c2_1) );

    // Stage 3: Use approximate FAs
    approx_full_adder_v1 axfa_3_0 ( .a(c2_0), .b(s2_1), .cin(1'b0),  .sum(s3_0), .cout(c3_0) );

    // Final Outputs
    assign sum[0] = s2_0; // Approx Sum bit (weight 1) - Note: Should be exact due to AxFA sum logic
    assign sum[1] = s3_0; // Approx Carry bit (weight 2) - This is where approximation occurs

endmodule
