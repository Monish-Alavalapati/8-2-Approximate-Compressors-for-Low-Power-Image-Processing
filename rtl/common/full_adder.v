//-----------------------------------------------------------------------------
// File         : full_adder.v
// Project      : 8:2 Approximate Compressor Study
// Author       : Monish Alavalapati
// Description  : Standard Full Adder module.
//-----------------------------------------------------------------------------
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule
