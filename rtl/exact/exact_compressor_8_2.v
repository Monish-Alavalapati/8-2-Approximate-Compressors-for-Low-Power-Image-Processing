//-----------------------------------------------------------------------------
// File         : exact_compressor_8_2.v
// Project      : 8:2 Approximate Compressor Study
// Author       : Monish Alavalapati
// Description  : Exact 8:2 Compressor implementation using a structural
//                tree of standard Full Adders.
//-----------------------------------------------------------------------------
`include "../common/full_adder.v" // Adjust path if needed during compilation

module exact_compressor_8_2 (
    input  wire [7:0] in,
    output wire [1:0] sum // sum[0] = Sum (weight 1), sum[1] = Carry (weight 2)
);

    // Internal wires for intermediate sums and carries
    // Stage 1: Reduce 8 inputs -> 3 sums (s1_x), 3 carries (c1_x) + 2 inputs remaining
    // Using 3 Full Adders
    wire s1_0, c1_0, s1_1, c1_1, s1_2, c1_2;

    full_adder fa_1_0 ( .a(in[0]), .b(in[1]), .cin(in[2]), .sum(s1_0), .cout(c1_0) );
    full_adder fa_1_1 ( .a(in[3]), .b(in[4]), .cin(in[5]), .sum(s1_1), .cout(c1_1) );
    // Handle in[6], in[7]. Use FA with cin=0 (acts as HA)
    full_adder fa_1_2 ( .a(in[6]), .b(in[7]), .cin(1'b0),  .sum(s1_2), .cout(c1_2) );

    // Stage 2: Reduce Stage 1 outputs
    // Inputs: s1_0, s1_1, s1_2 (weight 1)
    //         c1_0, c1_1, c1_2 (weight 2)
    // Using 2 Full Adders
    wire s2_0, c2_0, s2_1, c2_1;

    // Combine sums from stage 1
    full_adder fa_2_0 ( .a(s1_0), .b(s1_1), .cin(s1_2), .sum(s2_0), .cout(c2_0) );
    // Combine carries from stage 1
    full_adder fa_2_1 ( .a(c1_0), .b(c1_1), .cin(c1_2), .sum(s2_1), .cout(c2_1) );

    // Stage 3: Final combination
    // Inputs: s2_0 (weight 1) - This is the final Sum output
    //         c2_0 (weight 2), s2_1 (weight 2)
    //         c2_1 (weight 4) - This carry contributes to higher bits, not the 8:2 output directly.
    // Using 1 Full Adder (acts as HA for c2_0, s2_1)
    wire s3_0, c3_0;

    full_adder fa_3_0 ( .a(c2_0), .b(s2_1), .cin(1'b0),  .sum(s3_0), .cout(c3_0) );
    // s3_0 is the final Carry output (weight 2)
    // c3_0 contributes to weight 4, along with c2_1. Not part of 8:2 output {carry, sum}.

    // Final Outputs
    assign sum[0] = s2_0; // Sum bit (weight 1)
    assign sum[1] = s3_0; // Carry bit (weight 2)

endmodule
