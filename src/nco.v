// Author: Adrian Wong (adrian@almostsquare.com)

// Numerically Controlled Oscillator (NCO)
// f_out = step * f_clk / (2^n)

// TODO(adrian): Taking some shortcuts to make the mpw8 deadline.

// Shortcut 1 -- 1-bit sin and cos waveforms for the NCO
// Assuming 1-bit waveforms allows us to skip the phase-to-amplitude
// lookup for a normal sin/cos waveform and simply look at the
// highest bit and use that as the output.

module nco(clk, reset, enable, phase_sync, phase_in, step, phase_out);

    parameter WIDTH = 32;

    input               clk;            // input clock
    input               reset;          // 
    input               enable;         // enable
    input               phase_sync;     // set accumulator to phase_in
    input   [WIDTH-1:0] phase_in;       // adjustable phase input
    input   [WIDTH-1:0] step;           // adjustable step
    output  [WIDTH-1:0] phase_out;      // phase output

    reg     [WIDTH-1:0] accumulator;    // phase accumulator

    wire    [WIDTH:0]   sum;

    assign sum = accumulator + step;
    assign carry = sum[WIDTH];

    assign phase_out = accumulator;

    always @ (posedge clk)
        if (reset) begin
            accumulator <= phase_in;
        end else begin
            if (phase_sync) begin
                accumulator <= phase_in;
            end else begin
                if (enable) begin
                    accumulator <= sum[WIDTH-1:0];
                end
            end
        end
    
endmodule
