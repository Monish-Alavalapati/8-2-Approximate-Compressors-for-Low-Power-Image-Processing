//-----------------------------------------------------------------------------
// File         : approx_full_adder_v1.v
// Project      : 8:2 Approximate Compressor Study
// Author       : Monish Alavalapati
// Description  : Approximate Full Adder (Version 1).
// Approximation: Simplified carry-out logic (cout = a & b). Sum is exact.
// Inspired by common AxFA designs in literature.
//-----------------------------------------------------------------------------
module approx_full_adder_v1 (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    // Exact Sum calculation
    assign sum = a ^ b ^ cin;

    // Approximate Carry-Out calculation (ignores cin)
    assign cout = a & b;
endmodule
