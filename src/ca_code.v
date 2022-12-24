// Author: Adrian Wong (adrian@almostsquare.com)

// Based on the GPS Interface Specification
// IS-GPS-200N, 01-AUG-2022
// from https://www.gps.gov/technical/icwg/IS-GPS-200N.pdf
//
// Relevant sections for reference:
//
// Section 3.2.1.3.1 Expanded C/A-Code
// Two tap encoder (tap0, tap1) method is used for PRN 1-37.
// "Initial G2 Setting" (g2_init) method is used for PRN >37.
//
// Section 3.3.2.3 C/A-Code Generation
// The Galois Field GF(2) polynomials to generate Gold Codes:
// G1 = X^10 + x^3 + 1
// G2 = X^10 + X^9 + X^8 + X^3 + X^2 + 1


module ca_code(clk, reset, expanded, tap0, tap1, g2_init, chip);

    input           clk;        // Nominally a 1.023 MHz clock
    input           reset;      // "Set All Ones" in GPS ICD

    input           expanded;   // For PRN >37, set to one
    input   [3:0]   tap0;       // For PRN 1-37, two phase tap
    input   [3:0]   tap1;       // For PRN 1-37, two phase tap
    input   [10:1]  g2_init;    // For PRN >37, load G2 register

    output          chip;       // C/A-Code Chip Output

    // G1 and G2 shift registers
    reg     [10:1]  g1, g2;

    always @ (posedge clk)
        if (reset) begin
            g1 <= 10'b1111111111;
            g2 <= expanded ? g2_init : 10'b1111111111;
        end else begin
            g1 <= {g1[9:1], g1[10] ^ g1[3]};
            g2 <= {g2[9:1], g2[10] ^ g2[9] ^ g2[8] ^ g2[6] ^ g2[3] ^ g2[2]};
        end

    assign g1_out = g1[10];
    assign g2_out = expanded ? g2[10] : g2[tap0] ^ g2[tap1];

    assign chip = g1_out ^ g2_out;

endmodule